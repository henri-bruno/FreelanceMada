#!/usr/bin/env python
"""Script pour lancer les migrations Django et capturer la sortie."""
import subprocess
import sys
import os

os.chdir(os.path.dirname(os.path.abspath(__file__)))

python_exe = os.path.join('venv', 'Scripts', 'python.exe')

# Test DB connection
print("=== TEST CONNEXION DB ===")
result_check = subprocess.run(
    [python_exe, 'manage.py', 'showmigrations'],
    capture_output=True,
    text=True,
    encoding='utf-8',
    errors='replace'
)
print("STDOUT:", result_check.stdout)
print("STDERR:", result_check.stderr)
print("CODE:", result_check.returncode)

print("\n=== MIGRATION ===")
result = subprocess.run(
    [python_exe, 'manage.py', 'migrate', '--verbosity=2'],
    capture_output=True,
    text=True,
    encoding='utf-8',
    errors='replace'
)
print("STDOUT:", result.stdout)
print("STDERR:", result.stderr)
print("CODE:", result.returncode)

# Write to file
with open('migrate_result.txt', 'w', encoding='utf-8') as f:
    f.write("=== SHOWMIGRATIONS ===\n")
    f.write(result_check.stdout + "\n")
    f.write(result_check.stderr + "\n")
    f.write(f"Return code: {result_check.returncode}\n\n")
    f.write("=== MIGRATE ===\n")
    f.write(result.stdout + "\n")
    f.write(result.stderr + "\n")
    f.write(f"Return code: {result.returncode}\n")

print("Résultats écrits dans migrate_result.txt")
