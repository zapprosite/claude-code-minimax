# ⚡ Guia Rápido — Referência

**Tudo que você precisa saber em uma página.**

---

## 🚀 Comandos Principais

### MiniMax (Modelo Principal)
```bash
cm "sua pergunta aqui"
cm -p "tarefa"                    # one-shot
cm --agent nome-do-agente          # usar agente
cm --skill nome-da-skill           # usar skill
cm mcp list                        # listar MCP
cm --doctor                        # diagnóstico
```

### Claude Pro OAuth (Backup)
```bash
cp "sua pergunta aqui"
cp -p "tarefa"                    # one-shot
cp --agent nome-do-agente
```

### Continuar Sessão
```bash
claude --resume session_id
claude --continue
```

---

## 🤖 Agentes

| Comando | O Que Faz |
|---------|-----------|
| `/agent executive-ceo` | Decisões estratégicas |
| `/agent review-zappro` | Code review completo |
| `/agent security-audit` | Análise de segurança |
| `/agent deploy-check` | Validação pré-deploy |
| `/agent context-optimizer` | Analisa contexto |
| `/agent repo-onboard` | Inicializa repo |
| `/agent modo-dormir` | Escaneia enquanto dorme |

---

## ⚙️ Skills

| Comando | Quando Usar |
|---------|-------------|
| `--skill snapshot-safe` | Antes de mudar ZFS |
| `--skill deploy-validate` | Antes de deploy |
| `--skill context-prune` | Limpar sessões |
| `--skill secrets-audit` | Antes de git push |
| `--skill mcp-health` | Diagnosticar |
| `--skill repo-scan` | Detectar tasks |
| `--skill pipeline-gen` | Gerar pipeline |
| `--skill smoke-test-gen` | Gerar testes |
| `--skill human-gates` | Ver approval gates |

---

## 📁 Arquivos Importantes

| Arquivo | Para Que Serve |
|---------|----------------|
| `~/.claude/settings.json` | Config do Claude Code |
| `~/.claude/.secrets` | API keys (NÃO compartilhe!) |
| `~/.claude/CLAUDE.md` | Suas diretivas globais |
| `~/.mcp-data/memory-keeper/` | Memória persistente |
| `~/.claude/pipelines/` | Pipelines gerados |

---

## 🔌 MCP Servers

```bash
# Listar todos
claude mcp list

# Adicionar
claude mcp add github -- npx @modelcontextprotocol/server-github

# Remover
claude mcp remove github
```

### Servers Ativos

| Server | Função |
|--------|--------|
| filesystem | File ops |
| git | Git |
| context7 | Contexto |
| memory-keeper | Memória |
| github | GitHub |
| playwright | Browser |
| tavily | Search |

---

## 🏠 Homelab (Se tiver ZFS/Docker)

```bash
# Docker
docker ps
docker logs nome-do-container

# ZFS
zfs list
sudo zfs snapshot -r tank@pre-$(date +%Y%m%d-%H%M%S)-manual

# Health
curl -s http://localhost:8000/api/v1/health  # Coolify
```

---

## 📊 Diagnóstico

```bash
# Status geral
cm -p "docker ps --format '{{.Names}} {{.Status}}'"

# Disco
cm -p "df -h /srv && free -h"

# GPU
nvidia-smi

# Tudo
cdr  # ou claude --doctor
```

---

## 💡 Atalhos Úteis

### Glob Patterns
```bash
ls **/*.md          # Todos .md
ls **/test*.js     # test*.js em qualquer lugar
ls **/node_modules/ # node_modules
```

### Grep
```bash
grep "minimax" ~/.claude/**/*.md
grep -r "TODO" --include="*.py"
```

---

## 🔐 Segurança

### NUNCA faça:
- Commit secrets no git
- Expor API keys em código
- Executar `curl | sh` de sources desconhecidos
- Deletar `/srv/data` ou ZFS pools

### SEMPRE:
- Use `~/.claude/.secrets` para API keys
- Use `secrets-audit` antes de git push
- Snapshot antes de mudanças críticas

---

## 📝 Formatos de Task (Modo Dormir)

| Formato | Exemplo |
|---------|---------|
| TASKMASTER | `TASKMASTER.json` |
| PRD | `prd.md` |
| ADR | `docs/adr/*.md` |
| SLICE | `feature/slice-9-*` |
| TODO | `TODO.md` |
| TURBO | `turbo.json` |

---

## 🆘 Erros Comuns

| Erro | Solução |
|------|---------|
| `cm: command not found` | `source ~/.bashrc` |
| `MINIMAX_API_KEY: unbound` | Criar `~/.claude/.secrets` |
| `Permission denied` | `chmod +x` nos arquivos |
| `claude: not found` | Reinstalar Claude Code |

---

## 📚 Documentação

| Arquivo | O Que Tem |
|---------|-----------|
| `README.md` | Visão geral |
| `SETUP.md` | Instalação detalhada |
| `GUIA-RAPIDO.md` | Esta página |
| `docs/FORMATOS.md` | Formatos de task |
| `docs/PIPELINE.md` | Como usar pipeline |

---

## 💰 Custos

| Serviço | Preço |
|---------|-------|
| MiniMax | $50/mês |
| Claude Pro | $20/mês |
| Claude Code Pro | $20/mês |
| **Total** | **~$90/mês** |

---

*Guarde esta página para referência rápida!*
