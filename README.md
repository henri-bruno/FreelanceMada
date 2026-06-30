# FreelanceMada

## Déploiement du backend sur Hugging Face Spaces

Ce dépôt contient le backend Django dans le dossier `backend/`.

### Fichiers créés

- `Dockerfile`
- `.dockerignore`

### Instructions de déploiement

1. Crée un nouveau Space sur Hugging Face.
2. Choisis un Space de type `Docker`.
3. Connecte le Space à ce dépôt GitHub ou pousse ce dépôt dans le Space.
4. Dans les paramètres du Space, ajoute la variable d'environnement suivante :
   - `DATABASE_URL` : l'URL de ta base PostgreSQL externe.
5. Assure-toi que la DB est accessible depuis le Space et que `ALLOWED_HOSTS` est correctement configuré.

### Points importants

- Hugging Face Spaces ne fournit pas de base de données PostgreSQL intégrée.
- Le backend Django est servi par `gunicorn` sur le port `7860`.
- `collectstatic` est exécuté pendant la construction de l'image.

### Exemple de `DATABASE_URL`

```
postgresql://user:password@host:5432/dbname?sslmode=require
```

### Automatisation de la création du Space

Un script d'aide est disponible :

- `create_hf_space.py`

Il crée un Space Docker sur Hugging Face si tu as configuré un jeton dans :

- `HF_TOKEN`
- `HUGGINGFACE_TOKEN`
- ou `~/.huggingface/token`

### Structure du projet

- `backend/` : application Django
- `Dockerfile` : build Docker racine pour Spaces
- `.dockerignore` : fichiers ignorés lors de la construction
- `create_hf_space.py` : script de création de Space Hugging Face

## Déploiement du backend sur Render

Vous pouvez également héberger le backend sur Render.com en utilisant l'environnement Python natif.

### Instructions de déploiement sur Render

1. Créez un compte sur [Render.com](https://render.com).
2. Créez un nouveau **Web Service** et connectez ce dépôt GitHub.
3. Configurez les paramètres suivants :
   - **Name** : `freelancemada-backend`
   - **Root Directory** : `backend`
   - **Runtime** : `Python 3`
   - **Build Command** : `pip install -r requirements.txt && python manage.py collectstatic --noinput`
   - **Start Command** : `gunicorn freelancemada_backend.wsgi:application`
4. Ajoutez la variable d'environnement dans les paramètres :
   - `DATABASE_URL` : l'URL de votre base de données PostgreSQL Neon.
5. Déployez le service. Render s'occupera d'installer les dépendances et de lancer le serveur.

