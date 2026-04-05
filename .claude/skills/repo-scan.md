---
name: repo-scan
description: Escaneia repositório por todos os formatos de task (TASKMASTER, ADR, slices, TODO, issues, TURBO, Linear)
context: fork
disable-model-invocation: true
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
paths:
  - ~/.claude/skills/**
---

# Skill: Repo Scan

Detecta todos os formatos de task listing em um repositório.

## Uso

```bash
claude --skill repo-scan /path/to/repo
```

## Formatos Suportados

| Formato | Glob Patterns | Schema Key |
|---------|--------------|------------|
| TASKMASTER | `**/TASKMASTER*.json`, `**/taskmaster*.json` | `tasks[].id, title, status, owner` |
| PRD | `**/prd.md`, `**/PRD.md` | `## Funcionalidade`, `## Critérios` |
| ADR | `**/docs/ADR/*.md`, `**/docs/adr/*.md` | MADR ou compact format |
| SLICE | `**/*.slice.md`, git branches | `feature/slice-*` pattern |
| TODO | `**/TODO.md`, `**/task*.md` | `- [ ] task` ou `* task` |
| TURBO | `**/turbo.json` | `tasks[].name, dependsOn` |
| GitHub Issues | via MCP github | `number, title, labels, state` |

## Scan Commands

### TASKMASTER Detection
```bash
glob "**/TASKMASTER*.json" "$REPO"
glob "**/taskmaster*.json" "$REPO"
grep -l "TASKMASTER\|\"tasks\"\:" "$REPO"/**/*.json 2>/dev/null
```

### PRD Detection
```bash
glob "**/prd.md" "$REPO"
glob "**/PRD.md" "$REPO"
grep -l "PRD\|Product Requirements" "$REPO"/**/*.md 2>/dev/null
```

### ADR Detection
```bash
glob "**/docs/ADR/*.md" "$REPO"
glob "**/docs/adr/*.md" "$REPO"
find "$REPO" -type d -name ADR -o -name adr 2>/dev/null
```

### SLICE Detection
```bash
# Files
glob "**/*.slice.md" "$REPO"

# Git branches
git branch -a 2>/dev/null | grep "slice-"
```

### TODO Detection
```bash
glob "**/TODO.md" "$REPO"
glob "**/task*.md" "$REPO"
grep -l "\- \[ \]\|\- \[x\]" "$REPO"/**/*.md 2>/dev/null
```

### TURBO Detection
```bash
glob "**/turbo.json" "$REPO"
grep -l "turborepo\|tasks" "$REPO"/**/turbo.json 2>/dev/null
```

## Output Format

```json
{
  "formats_detected": ["TASKMASTER", "ADR", "SLICE", "TURBO", "TODO"],
  "files_found": {
    "TASKMASTER": [
      "/path/to/repo/TASKMASTER.json"
    ],
    "PRD": [],
    "ADR": [
      "/path/to/repo/docs/adr/0001-crm-leads-clientes.md",
      "/path/to/repo/docs/adr/0002-crm-equipamentos.md"
    ],
    "SLICE": [
      "/path/to/repo/branch: feature/slice-9-kanban",
      "/path/to/repo/apps/backend/src/db/seeds/slices-10-12.seed.ts"
    ],
    "TODO": [],
    "TURBO": [
      "/path/to/repo/turbo.json"
    ],
    "ISSUES": []
  },
  "tasks_count": {
    "total": 47,
    "by_format": {
      "TASKMASTER": 15,
      "ADR": 19,
      "TURBO": 7,
      "SLICE": 6
    }
  },
  "human_gates_detected": 5,
  "scan_timestamp": "2026-04-05T03:00:00Z"
}
```

## Parse Functions

### Parse TASKMASTER
```bash
cat "$file" | jq '.tasks[] | {id, title, status, owner}'
```

### Parse ADR (MADR)
```bash
# Extract status
grep -E "^## Decisão|^## Decisão|^Status:" "$file"

# Extract title
grep -E "^# ADR|^# ADR-N" "$file"
```

### Parse SLICE
```bash
# From branch names
git branch -a | grep "slice-" | sed 's/.*slice-/slice-/'

# From seed files
grep -E "slice|Slice" "$file" | grep -oE "[0-9]+-[0-9]+"
```

### Parse TURBO
```bash
cat turbo.json | jq '.tasks | keys'
```

## Human Gate Triggers

Tasks que requerem humano:
- `needs-approval` label
- `blocked` status
- `PM-review` label
- `security` label
- `infra` label
- `status: proposed` em ADR

## Examples

### Full Scan
```bash
REPO="/srv/monorepo"
OUTPUT="~/.claude/pipelines/repo-scan-$(date +%Y%m%d).json"

{
  "formats_detected": [],
  "files_found": {},
  "tasks_count": 0,
  "human_gates_detected": 0
}
```

### Single Format
```bash
claude --skill repo-scan --format TASKMASTER /srv/monorepo
```
