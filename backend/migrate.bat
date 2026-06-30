@echo off
echo ============================================
echo  FREELANCEMADA - MIGRATION SUPABASE
echo ============================================
echo.

cd /d "%~dp0"

echo [1] Installation des dependances...
venv\Scripts\pip.exe install -r requirements.txt -q
if %ERRORLEVEL% neq 0 (
    echo ERREUR: Installation des dependances echouee
    pause
    exit /b 1
)
echo     OK: Dependances installees

echo.
echo [2] Verification de la connexion Supabase...
venv\Scripts\python.exe -c "import django; import os; os.environ['DJANGO_SETTINGS_MODULE']='freelancemada_backend.settings'; django.setup(); from django.db import connection; c=connection.cursor(); c.execute('SELECT 1'); print('    OK: Connexion Supabase etablie')" 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERREUR: Impossible de se connecter a Supabase
    echo Verifiez votre connexion internet et les credentials
    pause
    exit /b 1
)

echo.
echo [3] Affichage de l'etat des migrations...
venv\Scripts\python.exe manage.py showmigrations 2>&1

echo.
echo [4] Application des migrations...
venv\Scripts\python.exe manage.py migrate --verbosity=2 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERREUR: La migration a echoue
    pause
    exit /b 1
)

echo.
echo ============================================
echo  MIGRATION TERMINEE AVEC SUCCES!
echo ============================================
echo.
pause
