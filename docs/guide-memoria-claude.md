# Guia Completo — Claude Code + Memória Persistente

**Host:** will-zappro | **Atualizado:** 2026-04-05
**Stack:** MiniMax-M2.7 via proxy ($50) · Claude Pro OAuth ($20)
**Plugins:** 9 | **MCP Servers:** 7 | **RTX 4090** | **ZFS 3.46TB**

---

## 🚀 Acesso Rápido

| Contexto | Comando | Plano |
|----------|---------|-------|
| MiniMax | `cm` | $50 |
| Claude Pro OAuth | `cp` | $20 |
| One-shot MiniMax | `cm -p "tarefa"` | $50 |
| One-shot Claude | `cp -p "tarefa"` | $20 |
| Homelab admin | `chost "tarefa"` | — |
| Monorepo | `cmon` | — |
| Doctor | `cdr` | — |
| Continuar | `claude --resume task_abc123` | — |

---

## ⚡ Aliases ( ~/.bashrc )

```bash
alias cm='KEY=$(grep ^MINIMAX_API_KEY= ~/.claude/.secrets | cut -d= -f2-) && ANTHROPIC_BASE_URL="https://api.minimax.io/anthropic" ANTHROPIC_AUTH_TOKEN="$KEY" ANTHROPIC_MODEL="MiniMax-M2.7" API_TIMEOUT_MS="3000000" claude --dangerously-skip-permissions'

alias cp='env -u ANTHROPIC_BASE_URL -u ANTHROPIC_AUTH_TOKEN -u ANTHROPIC_MODEL -u API_TIMEOUT_MS claude --dangerously-skip-permissions'

alias chost='/usr/local/bin/codex-host'
alias cmon='cd /srv/monorepo && claude'
alias cdr='claude --doctor'
```

> Os aliases são definidos **fora** do guarda de interatividade no `.bashrc` (linha ~10). Funcionam em qualquer shell.

---

## 🔌 MCP Servers (7 ativos)

```bash
claude mcp list
```

| Server | Pacote | Função |
|--------|--------|--------|
| `filesystem` | @j0hanz/filesystem-mcp | File ops avançados |
| `git` | @cyanheads/git-mcp-server | Git completo |
| `context7` | @upstash/context7-mcp | Contexto de código |
| `memory-keeper` | mcp-memory-keeper | Knowledge graph persistente (SQLite) |
| `github` | @modelcontextprotocol/server-github | Issues, PRs, repos |
| `playwright` | chrome-devtools-mcp | Browser automation + screenshots |
| `tavily` | @modelcontextprotocol/server-tavily | Web search (via Infisical vault) |

---

## 🩺 Diagnóstico Rápido

```bash
# Docker — status dos containers
cm -p "docker ps --format '{{.Names}} {{.Status}}'"

# MCP Servers — todos ativos?
cm -p "claude mcp list"

# Disco + RAM
cm -p "df -h /srv && free -h"

# Config completa (doctor mode)
cdr

# Continuar sessão interrompida
claude --resume task_abc123
```

---

## 🏠 Homelab Comandos

```bash
# Docker
docker ps --format "table {{.Names}}\t{{.Status}}"
docker logs coolify --tail 30
docker restart coolify

# GPU
nvidia-smi --query-gpu=memory.used,memory.free --format=csv,noheader

# ZFS
zfs list -t snapshot | grep tank
sudo zfs snapshot -r "tank@pre-$(date +%Y%m%d-%H%M%S)-manual"

# Coolify health
curl -s http://localhost:8000/api/v1/health

# Logs
journalctl -u cloudflared --tail 20 --no-pager
```

---

## 🧠 Memória Persistente (memory-keeper)

### Arquitetura

```
~/.mcp-data/memory-keeper/         # Banco SQLite WAL
├── context.db                    # Principal (~450KB)
├── context.db-wal                # Write-Ahead Log
├── context.db-shm                # Shared Memory
└── checkpoints/                  # Snapshots manuais

~/.claude/memory/                  # Meta + audit
├── MEMORY.md                     # Índice rápido
├── audit-log.md                  # Auditoria
└── memory.jsonl                  # Legacy (vazio)

~/.claude/scripts/
├── env-wrapper.sh               # Infisical → Claude Code
└── backup-memory.sh             # Backup do banco
```

### Ferramentas (22 tools)

| Ferramenta | Uso |
|------------|-----|
| `context_save` | Salvar fato/observação |
| `context_search` | Busca por keyword |
| `context_semantic_search` | Busca vetorial (embeddings local) |
| `context_get` | Recuperar por key |
| `context_checkpoint` | Snapshot antes de mudanças |
| `context_restore_checkpoint` | Restaurar snapshot |
| `context_session_start` | Nova sessão (channel = git branch) |
| `context_list_channels` | Listar canais |
| `context_status` | Status do servidor |

### Tipos de Memória

| Tipo | Gatilho | Exemplo |
|------|---------|---------|
| `user` | Preferências do usuário | "will prefere respostas curtas" |
| `feedback` | Correção ou confirmação | "não usar mocks em testes de DB" |
| `project` | Decisão arquitetural | "monorepo em /srv/monorepo" |
| `reference` | Ponteiro externo | "bugs em Linear INGEST" |
| `security` | Evento de segurança | "DENIED: .claude/hooks" |

### Quando Salvar

- **feedback**: após qualquer correção do usuário
- **checkpoint**: antes de ZFS, Docker, Coolify
- **project**: ao iniciar novo projeto ou mudar arquitetura
- **reference**: ao descobrir URL/sistema novo

---

## 📦 Infisical Vault (env-wrapper.sh)

O wrapper injeta secrets do vault `vault.zappro.site` no Claude Code.

```bash
# Uso direto
~/.claude/scripts/env-wrapper.sh claude "sua mensagem"

# Verifica vault localmente
curl -s http://127.0.0.1:8200/api/status
```

### Secrets Carregados

| Secret | Origem | Uso |
|--------|--------|-----|
| `TAVILY_API_KEY` | `dev/tavily/api_key` | Tavily MCP |
| `MINIMAX_API_KEY` | `~/.claude/.secrets` | Alias cm |

---

## 💾 Backup

```bash
# Manual
~/.claude/scripts/backup-memory.sh

# Cron (diário às 2h)
# 0 2 * * * /home/will/.claude/scripts/backup-memory.sh
```

### Restaurar

```bash
# Listar backups
ls -la ~/.mcp-data/memory-keeper/backups/

# Verificar integridade
sqlite3 ~/.mcp-data/memory-keeper/context.db "PRAGMA integrity_check;"

# Restaurar do backup
cp ~/.mcp-data/memory-keeper/backups/SEU_BACKUP.db \
   ~/.mcp-data/memory-keeper/context.db
```

---

## 🛡️ Segurança

### Deny Rules (settings.json)

| Rule | Proteção |
|------|----------|
| `Bash(.claude/hooks/**)` | Bloqueia hooks de repo (CVE-2025-59536) |
| `Bash(curl *untrusted*)` | Bloqueia downloads não-verificados |
| `Read(**/CLAUDE.md)` | Confirmação para CLAUDE.md de repo |
| `Read(**/.mcp.json)` | Confirmação para .mcp.json de repo |
| `Edit(**/.mcp.json)` | Proíbe editar .mcp.json de repo |
| `Bash(apt upgrade*)` | Bloqueia upgrades de sistema |
| `Bash(zfs destroy*)` | Bloqueia destruição de ZFS |
| `Bash(terraform destroy*)` | Bloqueia destroy da Cloudflare |

### Arquivos Protegidos (immutable +i)

| Arquivo | Por quê |
|---------|---------|
| `~/.claude/CLAUDE.md` | Diretivas globais — imutável |
| `~/.claude/settings.json` | Config MiniMax — bloco env readonly |
| `~/.claude/.secrets` | MINIMAX_API_KEY — não versionar |

### CVEs Protegidas

| CVE | Mitigação |
|-----|-----------|
| CVE-2025-59536 | deny rules + hookify rules |
| CVE-2026-21852 | secrets via Infisical, não em texto |

---

## 🔧 Troubleshooting

### `cm: command not found`

```bash
# Verificar se .bashrc está sendo lido
source ~/.bashrc
type cm
```

Se `type cm` não funcionar: o guarda `case $- in *i*) ;; *) return;; esac` no `.bashrc` está bloqueando. Aliases definidos fora do guarda (linhas 5-6 do `.bashrc`).

### memory-keeper não aparece

```bash
claude mcp list | grep memory
```

Se ausente: verificar se está no `settings.json` global.

### Tavily não conecta

```bash
# Verificar vault
~/.claude/scripts/env-wrapper.sh claude mcp list | grep tavily
```

### Doctor mode

```bash
cdr
# ou
claude --doctor
```

---

## 📁 Estrutura

```
~/.claude/
├── settings.json              # env + permissions + MCP servers
├── CLAUDE.md                 # Diretivas globais (immutable)
├── .secrets                  # MINIMAX_API_KEY
├── memory/                   # Sistema de memória
│   ├── MEMORY.md
│   ├── audit-log.md
│   └── memory.jsonl
├── scripts/
│   ├── env-wrapper.sh        # Infisical wrapper
│   └── backup-memory.sh      # Backup
└── rules/                   # Hookify security rules

~/.mcp-data/memory-keeper/   # Banco SQLite
├── context.db
└── backups/

/srv/monorepo/               # Código principal
/srv/data/coolify/           # PaaS (PINADO 4.0.0-beta.470)
/srv/data/openclaw/          # Bot (porta 4001)
/srv/ops/ai-governance/      # GUARDRAILS, PORTS, NETWORK_MAP
```

---

## 📚 Referências

| Recurso | Link/Path |
|---------|-----------|
| Painel | `painel.zappro.site` |
| Guardrails | `/srv/ops/ai-governance/GUARDRAILS.md` |
| Settings | `~/.claude/settings.json` |
| Backup | `~/.mcp-data/memory-keeper/backups/` |
| Env Wrapper | `~/.claude/scripts/env-wrapper.sh` |

---

## 🤖 Agentes Customizados (6 total)

| Agente | Arquivo | Propósito |
|--------|---------|-----------|
| `executive-ceo` | `agents/executive-ceo.md` | Decisões estratégicas nível executivo |
| `review-zappro` | `agents/review-zappro.md` | Code review detalhado |
| `security-audit` | `agents/security-audit.md` | Análise OWASP, secrets, injection |
| `deploy-check` | `agents/deploy-check.md` | Snapshot + health + rollback |
| `context-optimizer` | `agents/context-optimizer.md` | Analisa contexto, sugere compactação |
| `repo-onboard` | `agents/repo-onboard.md` | Inicializa repo com template |

**Invocar:** `/agent <nome-do-agente>`

## ⚙️ Skills Recorrentes (5 total)

| Skill | Arquivo | Gatilho |
|-------|---------|---------|
| `snapshot-safe` | `skills/snapshot-safe.md` | Antes de mudança ZFS |
| `deploy-validate` | `skills/deploy-validate.md` | Antes de deploy |
| `context-prune` | `skills/context-prune.md` | Limpar sessões memory-keeper |
| `secrets-audit` | `skills/secrets-audit.md` | Antes de git push |
| `mcp-health` | `skills/mcp-health.md` | Verificar 7 MCP servers |

**Invocar:** `--skill <nome-da-skill>` ou `claude --skill <skill> <args>`

## 🪝 Hooks de Qualidade (3 total)

| Hook | Arquivo | Propósito |
|------|---------|-----------|
| `PreToolUse-Bash` | `rules/PreToolUse-Bash-validate.bash` | Bloqueia comandos perigosos |
| `PreToolUse-Edit` | `rules/PreToolUse-Edit-validate.bash` | Protege arquivos immutable |
| `Stop-session-log` | `rules/Stop-session-log.bash` | Salva log da sessão |

## 📁 Template de Inicialização

```
~/.claude/templates/default/.claude/
├── CLAUDE.md              # Template de diretivas
├── agents/README.md      # Placeholder
├── skills/README.md      # Placeholder
├── rules/default.rules   # Decision matrix
└── .clauderc             # Config de init
```

**Uso:** Ao entrar em repo sem `.claude/`, oferece copiar do template.

---

## 🌙 Modo Dormir — Agent Escaneador Universal

O "modo dormir" escaneia repositórios por tasks em múltiplos formatos, gera pipeline.json, cria smoke tests e curl scripts enquanto você dorme.

### Formatos Suportados

| Formato | Padrão | Schema |
|---------|--------|--------|
| TASKMASTER | `**/TASKMASTER*.json` | `{ tasks: [{ id, title, status, owner }] }` |
| PRD | `**/prd.md` | Markdown sections |
| ADR | `**/docs/adr/*.md` | MADR ou compact ADR |
| SLICE | branches `feature/slice-*` | slices numerados |
| TODO | `**/TODO.md`, `**/task*.md` | Lista markdown |
| TURBO | `**/turbo.json` | `{ tasks: { name, dependsOn } }` |
| GitHub Issues | via MCP github | `{ number, title, labels, state }` |

### Agent + Skills

| Componente | Arquivo | Função |
|-----------|---------|--------|
| `modo-dormir` | `agents/modo-dormir.md` | Agent principal — coordena fluxo |
| `repo-scan` | `skills/repo-scan.md` | Detecta formatos de task |
| `pipeline-gen` | `skills/pipeline-gen.md` | Gera pipeline.json com fases |
| `smoke-test-gen` | `skills/smoke-test-gen.md` | Gera smoke tests + curl |
| `human-gates` | `skills/human-gates.md` | Identifica approval gates |
| `Stop-modo-dormir` | `rules/Stop-modo-dormir.bash` | Hook — dispara modo dormir |

### Uso

```bash
# Disparar modo dormir manualmente
claude --agent modo-dormir "scan /srv/monorepo"

# Hook (digitar "voudormir" ao encerrar)
# O hook Stop detecta e dispara em background

# Listar pipelines gerados
ls -la ~/.claude/pipelines/

# Ver logs
cat ~/.claude/pipelines/modo-dormir-*.log
```

### Output

```
~/.claude/pipelines/
├── {repo}-{date}-pipeline.json      # Pipeline com fases + gates
├── {repo}-{date}-smoke-tests.sh     # Script de smoke tests
├── {repo}-{date}-curl-scripts.sh    # Scripts curl por endpoint
├── {repo}-{date}-report.md          # Relatório final
└── modo-dormir-{date}.log           # Log do agent
```

### Human Gates Detectados

| Trigger | Gate Reason | Approver |
|---------|-------------|----------|
| `needs-approval` | requires approval | human:PM |
| `blocked` | blocked | human:lead |
| `security` | security review | human:security |
| `infra` | infrastructure | human:infra |
| No owner | needs owner | human:PM |
| ADR `proposto` | not approved | human:architect |

### Relatório ao Acordar

```markdown
## 🌙 Modo Dormir — Relatório

**Repo:** /srv/monorepo
**Duração:** ~2 horas

### 📊 Formatos Detectados
- ✅ TASKMASTER: 47 tasks
- ✅ ADR: 19 arquivos (5 proposed)
- ✅ SLICE: 3 branches

### 🔴 Human Gates (5)
1. CRM-003 — needs-PM-review (bloqueado)
2. CRM-007 — security audit (bloqueado)

### 🟢 Automatizável (42)
- CRM-001, CRM-002, CRM-004...

### 📋 Pipeline + Testes Gerados
- `~/.claude/pipelines/monorepo-20260405-pipeline.json`
```

---

## 📦 Repositório GitHub Pronto

Pasta no Desktop pronta para subir no GitHub:

```
/home/will/Desktop/modo-dormir-claude/
├── README.md              # Guia principal
├── INSTALL.md            # Instalação para leigos
├── LICENSE               # MIT
├── .gitignore
├── agents/
│   └── modo-dormir.md
├── skills/
│   ├── repo-scan.md
│   ├── pipeline-gen.md
│   ├── smoke-test-gen.md
│   └── human-gates.md
├── rules/
│   └── Stop-modo-dormir.bash
└── docs/
    ├── FORMATOS.md
    └── PIPELINE.md
```

**Para subir no GitHub:**
```bash
cd /home/will/Desktop/modo-dormir-claude
git init
git add .
git commit -m "Initial commit: modo-dormir agent"
gh repo create modo-dormir-claude --public --source=. --push
```

---

*Atualizado: 2026-04-05 — repo GitHub pronto, 7 agents, 9 skills, 4 hooks, template*
