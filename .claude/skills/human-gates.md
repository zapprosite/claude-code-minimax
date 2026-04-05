---
name: human-gates
description: Identifica pontos de aprovação humana no pipeline — tasks bloqueadas, needs-approval, security, infra
context: fork
disable-model-invocation: true
allowed-tools:
  - Read
  - Bash
paths:
  - ~/.claude/skills/**
---

# Skill: Human Gates

Identifica pontos no pipeline onde aprovação humana é necessária.

## Uso

```bash
# Analisar pipeline.json por human gates
claude --skill human-gates ~/.claude/pipelines/monorepo-20260405-pipeline.json

# Escaneia repo direto
claude --skill human-gates /srv/monorepo
```

## Human Gate Triggers

### Label/Status Based
| Trigger | Gate Reason | Default Approver |
|---------|-------------|------------------|
| `needs-approval` | requires approval | human:PM |
| `blocked` | blocked | human:lead |
| `PM-review` | PM review required | human:PM |
| `security` | security review | human:security |
| `infra` | infrastructure | human:infra |
| `legal` | legal review | human:legal |
| `design` | design approval | human:design |

### File-Based
| File Pattern | Gate Reason |
|-------------|-------------|
| `**/prd.md` com `## Aprovação` | PRD approval |
| `**/docs/adr/*.md` status `proposto` | ADR not approved |
| `**/security/**` | security sensitive |
| `**/billing/**`, `**/payments/**` | financial |

### Task-Based
| Condition | Gate Reason |
|-----------|-------------|
| No `owner` assigned | needs owner |
| `status: blocked` | blocked |
| `priority: critical` | critical priority |
| Dependência de gate anterior | sequential gate |

## Output Format

```json
{
  "human_gates": [
    {
      "id": "gate-001",
      "task_id": "CRM-003",
      "task_title": "Deploy approval",
      "gate_reason": "requires-approval",
      "approver": "human:PM",
      "location": {
        "file": "TASKMASTER.json",
        "line": 42
      },
      "blocking": true,
      "depends_on": ["gate-002"]
    }
  ],
  "summary": {
    "total_gates": 5,
    "by_reason": {
      "requires-approval": 2,
      "security": 1,
      "blocked": 1,
      "no-owner": 1
    },
    "blocking_tasks": 3,
    "sequential_gates": 2
  }
}
```

## Gate Types

### 1. Approval Gate
Requer aprovação explícita de pessoa.

```yaml
gate:
  type: approval
  approvers:
    - role: PM
    - role: tech-lead
  timeout: 86400  # 24 hours
  escalation: security-lead
```

### 2. Choice Gate
Requer escolha entre opções.

```yaml
gate:
  type: choice
  options:
    - label: "Aprovado"
      next: fase_next
    - label: "Rejeitado"
      next: fase_revisao
    - label: "Mover para backlog"
      next: backlog
```

### 3. Manual Gate
Requer execução manual de passo.

```yaml
gate:
  type: manual
  instruction: "Faça deploy manual para staging"
  verification:
    type: curl
    endpoint: /health
    expected: "ok"
```

### 4. Info Gate
Apenas notifica, não bloqueia.

```yaml
gate:
  type: info
  notify:
    - channel: slack
      message: "Fase 2 completa"
```

## Analysis Commands

### Scan for Labels
```bash
grep -rE "needs-approval|PM-review|security|blocked|infra" \
  "$REPO"/**/*.{json,yaml,yml,md} 2>/dev/null
```

### Scan for Unowned Tasks
```bash
# TASKMASTER
jq '.tasks[] | select(.owner == null)' "$REPO"/TASKMASTER.json

# GitHub issues (via MCP)
gh issue list --assignee none --state open
```

### Scan ADR Status
```bash
grep -rE "^Status.*proposto|^Status.*proposed" \
  "$REPO"/docs/adr/*.md 2>/dev/null
```

## Report Template

```markdown
## 🔴 Human Gates — {repo}

**Total:** {N} gates
**Bloqueando:** {M} tasks

### Por Aprovador

| Aprovador | Gates | Tasks |
|-----------|-------|-------|
| human:PM | 2 | CRM-003, CRM-007 |
| human:security | 1 | CRM-010 |
| human:infra | 1 | CRM-012 |
| human:lead | 1 | CRM-015 |

### Por Tipo

| Tipo | Count |
|------|-------|
| Approval | 3 |
| Choice | 1 |
| Manual | 1 |

### Gates Bloqueantes

1. **CRM-003** — Deploy approval
   - Reason: requires-approval
   - Approver: human:PM
   - Blocking: Yes

2. **CRM-010** — Security audit
   - Reason: security
   - Approver: human:security
   - Blocking: Yes

### Gates Sequenciais

1. gate-001 → gate-002 (CRM-001 → CRM-002)
2. gate-003 → (CRM-003 depends on CRM-002)

---

**Ação necessária:** Você precisa aprovar manualmente antes de prosseguir.
```

## Integration with Pipeline

Adiciona `human_gate` field ao pipeline.json:

```json
{
  "phases": [
    {
      "name": "fase2_deploy",
      "tasks": ["CRM-003"],
      "human_gate": true,
      "gate": {
        "type": "approval",
        "approvers": [{"role": "PM"}],
        "timeout": 86400
      }
    }
  ]
}
```

## Commands

```bash
# Full analysis
claude --skill human-gates /srv/monorepo

# From pipeline
claude --skill human-gates ~/.claude/pipelines/monorepo-20260405-pipeline.json

# Summary only
claude --skill human-gates /srv/monorepo --summary

# JSON output
claude --skill human-gates /srv/monorepo --format json
```

## Auto-Approval Rules

有些tasks podem ser auto-aprovadas:

| Condition | Auto-Approve |
|-----------|--------------|
| `status: ready` | Yes |
| `approved-by: AI` + low risk | Yes |
| `minor-change` + tests pass | Yes |

Configure em `~/.claude/settings.json`:
```json
{
  "humanGates": {
    "autoApprove": ["ready", "minor"],
    "requireApproval": ["security", "infra", "billing"]
  }
}
```
