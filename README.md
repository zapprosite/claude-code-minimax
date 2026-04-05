# 🚀 Guia Completo — Claude Code + MiniMax 2.7 + Pro OAuth

**Configure seu Claude Code do ZERO com MiniMax por $50 e Claude Pro OAuth por $20.**

---

## 💰 Quanto Custa?

| Serviço | Preço | Para Que Serve |
|---------|--------|----------------|
| MiniMax via proxy | $50/mês | Modelo principal (MiniMax-M2.7) |
| Claude Pro OAuth | $20/mês | Claude Pro via OAuth |
| Claude Code Pro | $20/mês | CLI do Claude Code |
| **Total** | **~$90/mês** | Setup completo |

> 💡 O MiniMax é o modelo principal (mais barato), Claude Pro OAuth é backup.

---

## 📋 O Que Este Repositório Instala

### 🤖 Agentes (7)
| Agente | O Que Faz |
|--------|-----------|
| `executive-ceo` | Decisões estratégicas |
| `review-zappro` | Code review detalhado |
| `security-audit` | Análise OWASP + secrets |
| `deploy-check` | Snapshot + health + rollback |
| `context-optimizer` | Analisa contexto |
| `repo-onboard` | Inicializa repos com template |
| `modo-dormir` | Escaneia repo enquanto você dorme |

### ⚙️ Skills (9)
| Skill | Quando Usar |
|-------|-------------|
| `snapshot-safe` | Antes de mudar ZFS |
| `deploy-validate` | Antes de deploy |
| `context-prune` | Limpar sessões |
| `secrets-audit` | Antes de git push |
| `mcp-health` | Diagnosticar MCP |
| `repo-scan` | Detectar tasks |
| `pipeline-gen` | Gerar pipeline |
| `smoke-test-gen` | Gerar testes |
| `human-gates` | Identificar aprovações |

### 🪝 Hooks (4)
| Hook | Protege Contra |
|------|----------------|
| `PreToolUse-Bash` | Comandos perigosos |
| `PreToolUse-Edit` | Arquivos protected |
| `Stop-session-log` | Salva log da sessão |
| `Stop-modo-dormir` | Ativa modo dormir |

### 🔌 MCP Servers (7) — Opcionais
| Server | Função |
|--------|--------|
| `filesystem` | File ops avançadas |
| `git` | Git completo |
| `context7` | Contexto de código |
| `memory-keeper` | Memória persistente |
| `github` | Issues + PRs |
| `playwright` | Browser automation |
| `tavily` | Web search |

---

## 🎯 Quick Start (10 minutos)

### Passo 1: Clone Este Repositório

```bash
git clone https://github.com/SEU-USUARIO/claude-code-minimax-setup.git
cd claude-code-minimax-setup
```

### Passo 2: Instale o Claude Code

```bash
# Mac
brew install anthropic/claude-code/claude

# Linux/WSL
curl -s https://storage.googleapis.com/claude-code-downloads/install.sh | sh

# Verifique
claude --version
```

### Passo 3: Configure as Variáveis de Ambiente

```bash
# Edite seu ~/.bashrc ou ~/.zshrc
nano ~/.bashrc
```

Adicione no FINAL do arquivo:

```bash
# === Claude Code MiniMax Setup ===

# MiniMax API Key (obtenha em https://console.minimax.io/)
export MINIMAX_API_KEY="SEU_TOKEN_AQUI"

# Claude Code Aliases
alias cm='KEY=$(grep ^MINIMAX_API_KEY= ~/.claude/.secrets | cut -d= -f2-) && ANTHROPIC_BASE_URL="https://api.minimax.io/anthropic" ANTHROPIC_AUTH_TOKEN="$KEY" ANTHROPIC_MODEL="MiniMax-M2.7" API_TIMEOUT_MS="3000000" claude --dangerously-skip-permissions'

alias cp='env -u ANTHROPIC_BASE_URL -u ANTHROPIC_AUTH_TOKEN -u ANTHROPIC_MODEL -u API_TIMEOUT_MS claude --dangerously-skip-permissions'
```

Salve (Ctrl+O, Enter, Ctrl+X no nano).

```bash
# Recarregue
source ~/.bashrc
```

### Passo 4: Copie os Arquivos

```bash
# Copie a pasta .claude para seu home
cp -r .claude ~/

# Copie os scripts
cp -r .claude/scripts ~/

# Crie o diretório de memória
mkdir -p ~/.mcp-data/memory-keeper
```

### Passo 5: Configure a API Key

```bash
# Crie o arquivo de secrets
nano ~/.claude/.secrets
```

Digite:
```
MINIMAX_API_KEY=seu_token_aqui
```

Salve (Ctrl+O, Enter, Ctrl+X).

```bash
chmod 600 ~/.claude/.secrets
```

### Passo 6: Teste!

```bash
# Teste MiniMax (deve responder)
cm -p "Olá, você é MiniMax?"

# Teste Claude Pro (deve responder)
cp -p "Olá, você é Claude Pro?"

# Verifique MCP servers
cm mcp list
```

---

## 📁 Estrutura do Repositório

```
claude-code-minimax-setup/
├── README.md                  # Este arquivo
├── SETUP.md                  # Guia detalhado de instalação
├── GUIA-RAPIDO.md            # Referência rápida
├── .claude/
│   ├── settings.json         # Configurações globais
│   ├── CLAUDE.md            # Diretivas globais
│   ├── agents/              # 7 agentes customizados
│   ├── skills/              # 9 skills
│   ├── rules/               # 4 hooks
│   ├── memory/              # Setup memória
│   ├── scripts/             # Scripts úteis
│   └── templates/           # Templates de projeto
└── docs/
    ├── painel-dashboard.html # Dashboard web (opcional)
    ├── FORMATOS.md           # Formatos de task
    └── PIPELINE.md          # Como usar pipeline
```

---

## 🔧 Configuração Detalhada

### MiniMax API Key

1. Acesse https://console.minimax.io/
2. Crie conta ou faça login
3. Vá em API Keys
4. Copie a chave
5. Cole no `~/.claude/.secrets`

### Claude Pro OAuth

O alias `cp` usa OAuth nativo. Você precisa:
1. Ter Claude Pro ativo (anthropic.com/claude-pro)
2. estar logado com `claude auth login`

### MCP Servers

Para ativar os MCP servers, edite `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "memory-keeper": {
      "command": "npx",
      "args": ["mcp-memory-keeper"],
      "env": {
        "DATA_DIR": "/caminho/para/.mcp-data/memory-keeper"
      }
    }
  }
}
```

---

## 🎨 Dashboard (Opcional)

Este repositório inclui um dashboard HTML em `docs/painel-dashboard.html`.

**Para usar:**
1. Abra o arquivo no navegador
2. Ou sirva com um servidor local:
```bash
cd docs
python3 -m http.server 8080
```
3. Acesse http://localhost:8080

---

## ❓ FAQ

### "cm: command not found"

```bash
source ~/.bashrc
type cm
```

Se não funcionar, verifique se adicionou o alias no lugar certo (DEPOIS do guarda de interactive).

### "MINIMAX_API_KEY: unbound variable"

Você esqueceu de criar o arquivo `~/.claude/.secrets`. Crie agora:

```bash
nano ~/.claude/.secrets
# Digite: MINIMAX_API_KEY=seu_token
# Ctrl+O, Enter, Ctrl+X
```

### "Permission denied" ao copiar

```bash
sudo cp -r .claude ~/
```

### Como usar os agentes?

```bash
# Com MiniMax
cm --agent review-zappro

# Com Claude Pro
cp --agent security-audit
```

### Como usar as skills?

```bash
cm --skill snapshot-safe
cm --skill deploy-validate
```

---

## 🆘 Precisa de Ajuda?

1. Leia o `SETUP.md` para instruções detalhadas
2. Leia o `GUIA-RAPIDO.md` para referência
3. Verifique os exemplos em `docs/`

---

## 💡 Dicas

- **MiniMax (`cm`)**: Mais barato, bom para tarefas routine
- **Claude Pro (`cp`)**: Melhor para tarefas complexas
- **Modo Dormir**: Use antes de dormir, acordar com tudo pronto
- **Memory Keeper**: Salva contexto entre sessões

---

## 📜 Licença

MIT License — Use, modifique, distribua.

---

*Setup completo com ❤️ para devs que querem o melhor do Claude Code*
