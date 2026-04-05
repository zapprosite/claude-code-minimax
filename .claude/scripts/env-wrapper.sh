#!/bin/bash
# env-wrapper.sh — Inject secrets from Infisical vault into Claude Code environment
#
# Usage: ./env-wrapper.sh claude [args...]
#   OR alias: alias claude='/path/to/env-wrapper.sh'
#
# Prerequisites:
#   pip install "infisical-sdk>=0.1.3,<1.0.17"
#
# Secrets loaded from vault.zappro.site:
#   - TAVILY_API_KEY → dev/tavily/api_key

set -e

INFISICAL_HOST="http://127.0.0.1:8200"
INFISICAL_TOKEN="st.799590ae-d36f-4e64-b940-aea0fb85cad8.6e0c269870bb4b5e004e3ed6ab3a1fe1.c9872f2b30bc650e7b27c851df04b0ad"
INFISICAL_PROJECT_ID="e42657ef-98b2-4b9c-9a04-46c093bd6d37"
INFISICAL_ENV="dev"

echo "[env-wrapper] Loading secrets from Infisical vault..." >&2

python3 - << 'PYEOF'
from infisical_sdk import InfisicalSDKClient
import os

client = InfisicalSDKClient(
    host="http://127.0.0.1:8200",
    token="st.799590ae-d36f-4e64-b940-aea0fb85cad8.6e0c269870bb4b5e004e3ed6ab3a1fe1.c9872f2b30bc650e7b27c851df04b0ad"
)

secrets = client.secrets.list_secrets(
    project_id="e42657ef-98b2-4b9c-9a04-46c093bd6d37",
    environment_slug="dev",
    secret_path="/"
)

secrets_dict = {s.secret_key: s.secret_value for s in secrets.secrets}

tavily = secrets_dict.get('TAVILY_API_KEY', '')
anthropic = secrets_dict.get('ANTHROPIC_API_KEY', '')

if not tavily:
    raise ValueError('TAVILY_API_KEY not found in vault')

with open(os.environ['HOME'] + '/.claude/.secrets', 'w') as f:
    f.write(f'export TAVILY_API_KEY={tavily}\n')
    if anthropic:
        f.write(f'export ANTHROPIC_AUTH_TOKEN={anthropic}\n')
PYEOF
 || { echo "[env-wrapper] ERROR: Failed to fetch from Infisical vault" >&2; exit 1; }

. ~/.claude/.secrets
rm -f ~/.claude/.secrets

echo "[env-wrapper] Secrets loaded: TAVILY_API_KEY=***" >&2

exec claude "$@"
