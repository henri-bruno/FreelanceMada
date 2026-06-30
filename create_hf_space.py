import os
from pathlib import Path

try:
    from huggingface_hub import HfApi
    from huggingface_hub.errors import RepositoryNotFoundError
except ImportError as exc:
    print('ERROR: huggingface_hub not installed:', exc)
    raise SystemExit(1)

# Detect token from environment or default file
hf_token = os.getenv('HF_TOKEN') or os.getenv('HUGGINGFACE_TOKEN')
if not hf_token:
    home = Path.home()
    token_path = home / '.huggingface' / 'token'
    if token_path.exists():
        hf_token = token_path.read_text().strip()

if not hf_token:
    print('ERROR: No Hugging Face token found. Set HF_TOKEN or HUGGINGFACE_TOKEN, or login with ``huggingface-cli login``.')
    raise SystemExit(1)

api = HfApi()

space_name = 'freelancemada-backend'
space_type = 'docker'
repo_id = None

try:
    user_info = api.whoami(token=hf_token)
    user_name = user_info.get('name') or user_info.get('user')
    print('Authenticated as:', user_name)
except Exception as exc:
    print('ERROR: Unable to authenticate with Hugging Face token:', exc)
    raise SystemExit(1)

try:
    repo_id = f'{user_name}/{space_name}'
    api.create_repo(name=space_name, token=hf_token, repo_type='space', space_sdk='docker', exist_ok=True)
    print('Space created or already exists:', repo_id)
except Exception as exc:
    print('ERROR: Failed to create Space:', exc)
    raise SystemExit(1)

print('Repository URL: https://huggingface.co/spaces/' + repo_id)
print('Next step: push this repository to that Space with `git push` or connect GitHub.')
