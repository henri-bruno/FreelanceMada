import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'freelancemada_backend.settings')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
django.setup()

from django.core.management import call_command
from django.db import connection

print("=" * 60)
print("APPLYING MIGRATIONS TO THE NEW NEON DATABASE")
print("=" * 60)

try:
    # Test Connection
    print("Testing connection...")
    with connection.cursor() as cursor:
        cursor.execute("SELECT version();")
        db_version = cursor.fetchone()[0]
        print(f"Connected successfully to Neon PostgreSQL:\n{db_version}\n")
    
    # Run Migrations
    print("Running Django migrate command...")
    call_command('migrate', verbosity=2)
    print("\n[SUCCESS] Migrations completed successfully!")
    
except Exception as e:
    print(f"\n[ERROR] Error occurred: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

print("=" * 60)
