# Dockerfile pour déployer le backend Django sur Hugging Face Spaces
# Le backend Django est dans le dossier backend/.
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=7860

WORKDIR /app

COPY backend/requirements.txt ./
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY backend/ ./backend
WORKDIR /app/backend

RUN python manage.py collectstatic --noinput

EXPOSE 7860

CMD ["gunicorn", "freelancemada_backend.wsgi:application", "--bind", "0.0.0.0:7860", "--workers", "1", "--threads", "4"]
