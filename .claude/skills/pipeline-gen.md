---
name: pipeline-gen
description: Gera pipeline.json com fases e human approval gates a partir de tasks detectadas
context: fork
disable-model-invocation: true
allowed-tools:
  - Bash
  - Read
  - Write
paths:
  - ~/.claude/skills/**
---

# Skill: Pipeline Gen

Gera pipeline.json com fases e human approval gates.

## Uso

```bash
# Ler repo-scan output e gerar pipeline
claude --skill pipeline-gen ~/.claude/pipelines/repo-scan-20260405.json

# Ou escanear e gerar direto
claude --skill pipeline-gen /srv/monorepo
```

## Pipeline Schema

```json
{
  "$schema": "https://pipeline.schema.dev",
  "name": "string",
  "repo": "string",
  "generated": "ISO8601",
  "version": "1.0.0",
  "phases": [
    {
      "name": "string",
      "tasks": ["task-id-1", "task-id-2"],
      "agent": "builder|auditor|reviewer",
      "human_gate": boolean,
      "gate_reason": "string (if human_gate=true)",
      "approver": "human:role",
      "depends_on": ["previous-phase"]
    }
  ],
  "smoke_tests": [
    {
      "name": "string",
      "command": "curl or script path",
      "expected": "string"
    }
  ],
  "curl_scripts": [
    {
      "method": "GET|POST|PUT|DELETE",
      "path": "/api/endpoint",
      "body": "json (optional)"
    }
  ]
}
```

## Phase Generation Rules

### Auto-grouping
- Tasks com mesma priority → mesma fase
- Tasks com dependências → fases sequenciais
- Tasks sem owner → human_gate = true

### Human Gate Triggers

| Condition | Gate Reason | Approver |
|-----------|-------------|----------|
| `needs-approval` label | requires approval | human:PM |
| `blocked` status | blocked | human:lead |
| `security` label | security review | human:security |
| `infra` label | infrastructure | human:infra |
| `status: proposed` (ADR) | not approved | human:architect |
| No owner assigned | needs owner | human:PM |

### Agent Assignment

| Task Type | Agent |
|-----------|-------|
| CRUD, API, backend | builder |
| Frontend, UI | frontend |
| Security, auth | security-audit |
| Testing | tester |
| Review, audit | auditor |
| Documentation | writer |

## Example

### Input (from repo-scan)
```json
{
  "tasks": [
    {"id": "CRM-001", "title": "Auth JWT", "source": "TASKMASTER", "status": "todo", "owner": null, "priority": "high"},
    {"id": "CRM-002", "title": "Leads CRUD", "source": "TASKMASTER", "status": "todo", "owner": "dev", "priority": "high"},
    {"id": "CRM-003", "title": "Deploy approval", "source": "TASKMASTER", "status": "todo", "owner": null, "labels": ["needs-approval"]}
  ]
}
```

### Output Pipeline
```json
{
  "name": "crm-pipeline",
  "repo": "/srv/monorepo",
  "generated": "2026-04-05T03:00:00Z",
  "phases": [
    {
      "name": "fase1_auth_core",
      "tasks": ["CRM-001"],
      "agent": "builder",
      "human_gate": true,
      "gate_reason": "no-owner-assigned",
      "approver": "human:lead"
    },
    {
      "name": "fase2_leads",
      "tasks": ["CRM-002"],
      "agent": "builder",
      "human_gate": false,
      "depends_on": ["fase1_auth_core"]
    },
    {
      "name": "fase3_deploy",
      "tasks": ["CRM-003"],
      "agent": "builder",
      "human_gate": true,
      "gate_reason": "requires-approval",
      "approver": "human:PM",
      "depends_on": ["fase2_leads"]
    }
  ],
  "smoke_tests": [
    {"name": "health", "command": "curl -sf http://localhost:3000/health", "expected": "ok"},
    {"name": "leads-list", "command": "curl -sf http://localhost:3000/trpc/leads.list", "expected": "array"}
  ],
  "curl_scripts": [
    {"method": "GET", "path": "/health"},
    {"method": "GET", "path": "/trpc/leads.list"},
    {"method": "POST", "path": "/trpc/leads.create", "body": "{\"name\":\"Test\"}"}
  ]
}
```

## Output Location

```
~/.claude/pipelines/{repo-name}-{date}-pipeline.json
```

## Integration

Gera output que pode ser consumido por:
- Claude Code agent (execução)
- Orchestrator app (`apps/orchestrator/`)
- GitHub Actions
- Qualquer CI/CD pipeline

## Commands

```bash
# Gerar pipeline
pipeline-gen /srv/monorepo

# Com repo-scan input
cat ~/.claude/pipelines/repo-scan-20260405.json | pipeline-gen

# Validar pipeline
pipeline-gen --validate ~/.claude/pipelines/monorepo-20260405-pipeline.json
```
