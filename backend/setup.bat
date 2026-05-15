@echo off
echo ========================================
echo  FreeLanceMada - Setup Backend Django
echo ========================================

echo.
echo [1/4] Creation de l'environnement virtuel...
python -m venv venv

echo.
echo [2/4] Activation et installation des dependances...
call venv\Scripts\activate.bat
pip install -r requirements.txt

echo.
echo [3/4] Migrations de la base de donnees SQLite...
python manage.py makemigrations
python manage.py migrate

echo.
echo [4/4] Creation du superutilisateur admin...
python manage.py createsuperuser --email admin@freelancemada.mg --username admin

echo.
echo ========================================
echo  Setup termine ! Demarrez avec :
echo  venv\Scripts\activate
echo  python manage.py runserver
echo ========================================
pause
