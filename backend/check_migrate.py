"""
Script optimisé: migration + vérification en une seule passe.
Utilise psycopg2 directement pour éviter les connexions multiples.
"""
import sys
import os

# Configuration
DB_CONFIG = {
    'host': 'db.uygdschelfrkajzaxink.supabase.co',
    'port': 5432,
    'dbname': 'postgres',
    'user': 'postgres',
    'password': 'MAChuo2004#!',
    'sslmode': 'require',
    'connect_timeout': 30,
}

OUTPUT_FILE = 'check_migrate_result.txt'

lines = []

def log(msg):
    print(msg)
    lines.append(msg)

def save():
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))

log("=" * 60)
log("FREELANCEMADA - MIGRATION SUPABASE")
log("=" * 60)

# Step 1: Setup Django
log("\n[1] Configuration Django...")
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'freelancemada_backend.settings')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

try:
    import django
    django.setup()
    log("    ✓ Django configuré")
except Exception as e:
    log(f"    ✗ Erreur Django: {e}")
    save()
    sys.exit(1)

# Step 2: Test DB connection
log("\n[2] Test connexion Supabase...")
try:
    from django.db import connection
    with connection.cursor() as cursor:
        cursor.execute("SELECT version();")
        version = cursor.fetchone()[0]
        log(f"    ✓ Connecté! PostgreSQL: {version[:50]}...")
except Exception as e:
    log(f"    ✗ Erreur connexion: {e}")
    save()
    sys.exit(1)

# Step 3: Show current migration state
log("\n[3] Etat actuel des migrations:")
try:
    from django.db.migrations.executor import MigrationExecutor
    executor = MigrationExecutor(connection)
    plan = executor.migration_plan(executor.loader.graph.leaf_nodes())
    
    applied = []
    pending = []
    
    for key, applied_state in executor.loader.applied_migrations.items():
        applied.append(f"    [X] {key[0]}.{key[1]}")
    
    for migration, backwards in plan:
        pending.append(f"    [ ] {migration.app_label}.{migration.name}")
    
    if applied:
        log(f"    Migrations appliquées ({len(applied)}):")
        for m in sorted(applied):
            log(m)
    
    if pending:
        log(f"\n    Migrations en attente ({len(pending)}):")
        for m in pending:
            log(m)
    else:
        log("    Toutes les migrations sont appliquées!")
        
except Exception as e:
    log(f"    ✗ Erreur: {e}")

# Step 4: Run migrations
log("\n[4] Exécution des migrations...")
try:
    from django.core.management import call_command
    from io import StringIO
    out = StringIO()
    
    call_command('migrate', verbosity=1, stdout=out, stderr=out)
    output = out.getvalue()
    
    if output.strip():
        log("    Résultat:")
        for line in output.split('\n'):
            if line.strip():
                log(f"    {line}")
    else:
        log("    Aucune migration à appliquer - base de données à jour!")
        
    log("    ✓ Migration terminée")
except Exception as e:
    log(f"    ✗ Erreur migration: {e}")
    import traceback
    log(traceback.format_exc())
    save()
    sys.exit(1)

# Step 5: Verify tables exist
log("\n[5] Vérification des tables créées:")
try:
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            ORDER BY table_name;
        """)
        tables = [row[0] for row in cursor.fetchall()]
        log(f"    {len(tables)} tables trouvées:")
        for t in tables:
            log(f"      - {t}")
except Exception as e:
    log(f"    ✗ Erreur vérification: {e}")

# Step 6: Final state check
log("\n[6] Vérification finale - aucune migration en attente:")
try:
    executor2 = MigrationExecutor(connection)
    plan2 = executor2.migration_plan(executor2.loader.graph.leaf_nodes())
    if not plan2:
        log("    ✓ SUCCÈS: Toutes les migrations sont appliquées!")
    else:
        log(f"    ✗ Il reste {len(plan2)} migrations en attente!")
        for migration, _ in plan2:
            log(f"      - {migration.app_label}.{migration.name}")
except Exception as e:
    log(f"    ✗ Erreur: {e}")

log("\n" + "=" * 60)
log("MIGRATION TERMINÉE")
log("=" * 60)

save()
print(f"\nRésultats sauvegardés dans {OUTPUT_FILE}")
