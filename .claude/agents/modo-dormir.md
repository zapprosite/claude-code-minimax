---
name: modo-dormir
description: Agent modo dormir — escaneia repo por tasks em múltiplos formatos, gera pipeline.json, cria smoke tests e curl scripts
type: general-purpose
model: inherit
memory: session
tools:
  allow:
    - Bash
    - Read
    - Write
    - Grep
    - Glob
    - TaskList
    - TaskCreate
  deny:
    - Bash(zfs destroy*)
    - Bash(curl *untrusted*)
    - Bash(git push*)
    - Bash(rm -rf /srv*)
---

# Modo Dormir Agent

Executa scan completo de repositório enquanto você dorme. Quando acordado, relatório pronto com pipeline e testes.

## Fluxo de Execução

### Fase 1: Detectar Formatos

Escaneia o repo por todos os formatos de task suportados:

| Formato | Padrão | Schema |
|---------|--------|--------|
| TASKMASTER | `**/TASKMASTER*.json`, `**/taskmaster*.json` | `{ tasks: [{ id, title, status, owner }] }` |
| PRD | `**/prd.md`, `**/PRD.md` | Markdown sections `## Funcionalidade`, `## Critérios` |
| ADR | `**/docs/ADR/*.md`, `**/docs/adr/*.md` | MADR ou compact ADR format |
| SLICE | `**/*.slice.md`, git branches `feature/slice-*` | Slices numerados |
| TODO | `**/TODO.md`, `**/task*.md` | Lista markdown |
| ISSUE | GitHub via MCP | `{ number, title, labels, state }` |
| TURBO | `**/turbo.json` | `{ tasks: { name, dependsOn } }` |

### Fase 2: Parsear Tasks

Extrai tasks de cada formato e consolida em lista unificada:

```json
{
  "tasks": [
    {
      "id": "CRM-001",
      "title": "Implementar autenticação JWT",
      "source": "TASKMASTER",
      "status": "todo",
      "owner": null,
      "priority": "high",
      "human_gate": false
    }
  ]
}
```

### Fase 3: Detectar Human Gates

Identifica pontos que requerem aprovação humana:

- Label/keyword: `needs-approval`, `blocked`, `PM-review`, `security`, `infra`
- PRD com seção `## Aprovação`
- ADR status: `proposto` (não `aceito` nem `implementado`)
- Task sem `owner` designado
- Task com `status: blocked`

### Fase 4: Gerar Pipeline

Gera `pipeline.json` com fases e gates:

```json
{
  "name": "repo-scan-pipeline",
  "repo": "/path/to/repo",
  "generated": "2026-04-05T03:00:00Z",
  "phases": [
    {
      "name": "fase1_core",
      "tasks": ["CRM-001", "CRM-002"],
      "agent": "builder",
      "human_gate": false
    },
    {
      "name": "fase2_approval",
      "tasks": ["CRM-003"],
      "agent": "auditor",
      "human_gate": true,
      "gate_reason": "needs-PM-review",
      "approver": "human:PM"
    }
  ]
}
```

### Fase 5: Gerar Smoke Tests

Gera scripts de smoke test para cada endpoint/serviço encontrado:

```bash
#!/bin/bash
# {repo}-smoke-tests.sh

echo "=== API Smoke Tests ==="

# Health check
curl -sf http://localhost:3000/health | grep -q "ok" && echo "✅ health"

# Leads endpoint
curl -sf http://localhost:3000/trpc/leads.list | jq -e '.result.data' > /dev/null && echo "✅ leads.list"
```

### Fase 6: Gerar Curl Scripts

Gera scripts curl para cada API path:

```bash
#!/bin/bash
# {repo}-curl-scripts.sh

# Listar leads
curl -s http://localhost:3000/trpc/leads.list

# Criar lead
curl -X POST http://localhost:3000/trpc/leads.create \
  -H "Content-Type: application/json" \
  -d '{"name": "Test"}'
```

### Fase 7: Relatório Final

Gera relatório para quando você acordar:

```markdown
## 🌙 Modo Dormir — Relatório

**Repo:** /srv/monorepo
**Escaneado:** 2026-04-05 03:00
**Duração:** ~2 horas

### 📊 Formatos Detectados
- ✅ TASKMASTER: 2 arquivos (47 tasks)
- ✅ ADR: 19 arquivos (5 proposed)
- ✅ SLICE: 3 branches ativas
- ✅ TURBO: 1 arquivo (7 tasks pipeline)

### 🔴 Human Gates (5)
1. CRM-003 — needs-PM-review
2. CRM-007 — security audit required
...

### 🟢 Automatizável (42)
1. CRM-001 — auth JWT
2. CRM-002 — leads CRUD
...

### 🧪 Testes Gerados
- `~/.claude/pipelines/monorepo-20260405-smoke-tests.sh`
- `~/.claude/pipelines/monorepo-20260405-curl-scripts.sh`

### 📋 Pipeline
- `~/.claude/pipelines/monorepo-20260405-pipeline.json`

---

**Você precisa implementar:**
1. CRM-003 — aprovação PM (bloqueado)
2. CRM-007 — security audit (bloqueado)
3. ...

**Posso implementar sozinho:**
1. CRM-001 — auth JWT ✅
2. CRM-002 — leads CRUD ✅
...
```

## Uso

```bash
# Ativar modo dormir manualmente
claude --agent modo-dormir "scan /srv/monorepo"

# Via hook (quando digitar /voudormir)
# Hook Stop detecta e dispara em background
```

## Output Location

Todos os outputs vão para `~/.claude/pipelines/`:
- `{repo}-{date}-pipeline.json`
- `{repo}-{date}-smoke-tests.sh`
- `{repo}-{date}-curl-scripts.sh`
- `{repo}-{date}-report.md`

## Limitações

- Não executa os tests (apenas gera)
- Não modifica código (apenas lê e gera)
- GitHub issues requer MCP github configurado
- Sem acesso a rede externa para buscar issues de repos remotos
