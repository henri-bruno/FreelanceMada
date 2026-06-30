# Dockerfile pour déployer le backend Django sur Hugging Face Spaces
# Utilise le port 7860 attendu par Spaces.
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=7860

WORKDIR /app

# Installer les dépendances Python
COPY requirements.txt ./
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copier l’application
COPY . .

# Collecte des fichiers statiques
RUN python manage.py collectstatic --noinput

EXPOSE 7860

CMD ["gunicorn", "freelancemada_backend.wsgi:application", "--bind", "0.0.0.0:7860", "--workers", "1", "--threads", "4"]
