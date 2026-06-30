from pathlib import Path
from datetime import timedelta
import os
import re

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = 'django-insecure-freelancemada-secret-key-change-in-production'

DEBUG = True

ALLOWED_HOSTS = ['*']

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'rest_framework_simplejwt',
    'corsheaders',
    'api',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'freelancemada_backend.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'freelancemada_backend.wsgi.application'

# ============================================================
# DATABASE CONFIGURATION
# Pour changer de base de données, modifiez DATABASE_URL:
#
# Neon:    postgresql://user:pass@ep-xxx.region.aws.neon.tech/neondb?sslmode=require
# Railway: postgresql://user:pass@host.railway.app:5432/railway
# ============================================================

DATABASE_URL = os.environ.get(
    'DATABASE_URL', 
    'postgresql://neondb_owner:npg_Gra5BSzD8iqO@ep-dark-field-ajgdcozb-pooler.c-3.us-east-2.aws.neon.tech/neondb?sslmode=require'
)

if DATABASE_URL:
    # Parse DATABASE_URL automatiquement
    m = re.match(
        r'postgresql://(?P<user>[^:]+):(?P<password>[^@]+)@(?P<host>[^:/]+)(?::(?P<port>\d+))?/(?P<name>[^?]+)',
        DATABASE_URL
    )
    if m:
        DATABASES = {
            'default': {
                'ENGINE': 'django.db.backends.postgresql',
                'NAME': m.group('name'),
                'USER': m.group('user'),
                'PASSWORD': m.group('password'),
                'HOST': m.group('host'),
                'PORT': m.group('port') or '5432',
                'OPTIONS': {'sslmode': 'require'},
                'CONN_MAX_AGE': 60,
            }
        }
    else:
        raise ValueError(f"DATABASE_URL invalide: {DATABASE_URL}")
else:
    # ⬇️  Remplacez ici vos infos de connexion manuellement
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': 'neondb',               # ← Nom de la DB
            'USER': 'neondb_owner',          # ← Votre utilisateur
            'PASSWORD': 'VOTRE_MOT_DE_PASSE', # ← Votre mot de passe
            'HOST': 'ep-xxx.region.aws.neon.tech',  # ← Votre host Neon
            'PORT': '5432',
            'OPTIONS': {'sslmode': 'require'},
            'CONN_MAX_AGE': 60,
        }
    }

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

LANGUAGE_CODE = 'fr-fr'
TIME_ZONE = 'Indian/Antananarivo'
USE_I18N = True
USE_TZ = True

STATIC_URL = 'static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
STORAGES = {
    "default": {
        "BACKEND": "django.core.files.storage.FileSystemStorage",
    },
    "staticfiles": {
        "BACKEND": "whitenoise.storage.CompressedManifestStaticFilesStorage",
    },
}
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

AUTH_USER_MODEL = 'api.User'

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
    ),
}

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(days=7),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),
    'ROTATE_REFRESH_TOKENS': True,
    'AUTH_HEADER_TYPES': ('Bearer',),
}

CORS_ALLOW_ALL_ORIGINS = True
