---
name: smoke-test-gen
description: Gera smoke tests e curl scripts para cada endpoint/serviço do pipeline
context: fork
disable-model-invocation: true
allowed-tools:
  - Bash
  - Write
paths:
  - ~/.claude/skills/**
---

# Skill: Smoke Test Gen

Gera scripts de smoke test e curl para cada endpoint/serviço.

## Uso

```bash
# Gerar smoke tests a partir de pipeline.json
claude --skill smoke-test-gen ~/.claude/pipelines/monorepo-20260405-pipeline.json

# Gerar direto do repo
claude --skill smoke-test-gen /srv/monorepo --port 3000
```

## Output Files

### Smoke Test Script
```
~/.claude/pipelines/{repo}-{date}-smoke-tests.sh
```

### Curl Scripts
```
~/.claude/pipelines/{repo}-{date}-curl-scripts.sh
```

## Smoke Test Template

```bash
#!/bin/bash
# Smoke Tests — {repo} — {date}
# Gerado automaticamente pelo modo-dormir

set -e

BASE_URL="${BASE_URL:-http://localhost:3000}"
REPO="{repo}"

echo "=== Smoke Tests: $REPO ==="
echo "Base URL: $BASE_URL"
echo ""

PASS=0
FAIL=0

test_endpoint() {
  local name="$1"
  local expected="$2"
  shift 2

  if "$@" 2>/dev/null | grep -q "$expected"; then
    echo "✅ $name"
    ((PASS++))
  else
    echo "❌ $name"
    ((FAIL++))
  fi
}

# Health
test_endpoint "health" "ok" curl -sf "$BASE_URL/health"

# API Endpoints
test_endpoint "leads.list" "result" curl -sf "$BASE_URL/trpc/leads.list"
test_endpoint "kanban.boards" "result" curl -sf "$BASE_URL/trpc/kanban.boards"
test_endpoint "clients.list" "result" curl -sf "$BASE_URL/trpc/clients.list"

# Auth (if not authenticated, expect 401)
test_endpoint "auth.required" "401\|unauthorized" curl -sf -o /dev/null -w "%{http_code}" "$BASE_URL/api/private"

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

if [ $FAIL -gt 0 ]; then
  exit 1
fi
```

## Curl Script Template

```bash
#!/bin/bash
# Curl Scripts — {repo} — {date}
# Gerado automaticamente pelo modo-dormir

BASE_URL="${BASE_URL:-http://localhost:3000}"
AUTH_TOKEN="${AUTH_TOKEN:-}"

# Helper
curl_api() {
  local method="$1"
  local path="$2"
  local body="$3"

  echo "=== $method $path ==="
  if [ -n "$body" ]; then
    curl -s -X "$method" "$BASE_URL$path" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $AUTH_TOKEN" \
      -d "$body" | jq .
  else
    curl -s -X "$method" "$BASE_URL$path" \
      -H "Authorization: Bearer $AUTH_TOKEN" | jq .
  fi
  echo ""
}

# Health
curl_api GET "/health"

# Leads
curl_api GET "/trpc/leads.list"
curl_api POST "/trpc/leads.create" '{"name":"Test Lead","email":"test@example.com"}'

# Clients
curl_api GET "/trpc/clients.list"
curl_api POST "/trpc/clients.create" '{"name":"Test Client"}'

# Kanban
curl_api GET "/trpc/kanban.boards"
curl_api POST "/trpc/kanban.cards.create" '{"boardId":1,"title":"Test Card"}'

# Equipment
curl_api GET "/trpc/equipment.list"

# Service Orders
curl_api GET "/trpc/serviceOrders.list"

echo "=== All curl scripts executed ==="
```

## Dynamic Discovery

Detecta endpoints automaticamente de:

### tRPC
```bash
# Find all tRPC routers
grep -r "procedures\|routers\|\.query\|\.mutation" apps/backend/src/ \
  | grep -oE "\/[a-z]+\.[a-z]+" \
  | sort -u

# Parse router files
grep -E "t\.procedure\|\.query\(|\.mutation\(" apps/backend/src/modules/*/router.ts
```

### REST
```bash
# Find Fastify routes
grep -rE "fastify\.(get|post|put|delete|patch)" apps/backend/src/ \
  | grep -oE "'/[a-z/]+'" | sort -u
```

### GraphQL
```bash
# Find GraphQL resolvers
grep -rE "Query\.|Mutation\." apps/backend/src/*/schema.ts 2>/dev/null | head -20
```

## Template Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `${BASE_URL}` | API base URL | `http://localhost:3000` |
| `${AUTH_TOKEN}` | Bearer token | empty |
| `${REPO}` | Repository name | from path |
| `${DATE}` | Generation date | `YYYYMMDD` |

## Options

```bash
# Custom port
claude --skill smoke-test-gen /srv/monorepo --port 8080

# With auth
claude --skill smoke-test-gen /srv/monorepo --token "eyJ..."

# Specific module only
claude --skill smoke-test-gen /srv/monorepo --module leads

# Dry run (output to stdout)
claude --skill smoke-test-gen /srv/monorepo --dry-run
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All tests passed |
| 1 | One or more tests failed |
| 2 | No endpoints discovered |

## Examples

### Full Generation
```bash
$ claude --skill smoke-test-gen /srv/monorepo

=== Smoke Tests: monorepo ===
Base URL: http://localhost:3000

✅ health
✅ leads.list
✅ kanban.boards
❌ clients.list

=== Results ===
Passed: 3
Failed: 1

Smoke tests saved to:
~/.claude/pipelines/monorepo-20260405-smoke-tests.sh
~/.claude/pipelines/monorepo-20260405-curl-scripts.sh
```

### Run Tests
```bash
# Make executable
chmod +x ~/.claude/pipelines/monorepo-20260405-smoke-tests.sh

# Run
~/.claude/pipelines/monorepo-20260405-smoke-tests.sh

# Or with custom URL
BASE_URL=http://api.staging.local:3000 ~/.claude/pipelines/monorepo-20260405-smoke-tests.sh
```
