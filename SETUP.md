# 📖 Guia de Instalação Detalhada

**Passo a passo completo para leigos configurarem Claude Code + MiniMax.**

---

## Índice

1. [O Que Você Precisa](#1-o-que-você-precisa)
2. [Instalar Claude Code](#2-instalar-claude-code)
3. [Criar Conta MiniMax](#3-criar-conta-minimax)
4. [Configurar Aliases](#4-configurar-aliases)
5. [Copiar Arquivos](#5-copiar-arquivos)
6. [Configurar API Key](#6-configurar-api-key)
7. [Testar Tudo](#7-testar-tudo)
8. [Configurar MCP Servers](#8-configurar-mcp-servers-opcional)
9. [Configurar Dashboard](#9-configurar-dashboard-opcional)

---

## 1. O Que Você Precisa

### Necessário:
- **Computador** com Mac, Linux, ou Windows com WSL
- **Terminal** (Prompt de Comando, Terminal, iTerm2, etc)
- **Internet** para baixar arquivos

### Opcional (mas recomendado):
- **Git** instalado
- **Conta MiniMax** (para API key)
- **Conta Claude Pro** (para OAuth)

---

## 2. Instalar Claude Code

### Mac (com Homebrew)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install anthropic/claude-code/claude
```

### Linux/WSL

```bash
curl -s https://storage.googleapis.com/claude-code-downloads/install.sh | sh
```

### Verificar Instalação

```bash
claude --version
```

Se aparecer algo como `claude 1.x.x`, funcionou!

---

## 3. Criar Conta MiniMax

### Passo 3.1: Acesse o Console

1. Abra o navegador
2. Acesse: https://console.minimax.io/
3. Clique em "Sign Up" se não tem conta

### Passo 3.2: Crie uma API Key

1. Faça login
2. No menu, procure "API Keys" ou "Keys"
3. Clique em "Create New Key" ou similar
4. **Copie a chave** — você NÃO poderá ver de novo!

### Passo 3.3: Salve a Chave

A chave parece com:
```
eyJhbm5ubGktYWlkIjoiMTIzNDU2Nzg5MCJ9...
```

**IMPORTANTE:** Copie e salve em um lugar seguro (senha manager, bloco de notas).

---

## 4. Configurar Aliases

### O que são aliases?

Aliases são atalhos no terminal. Em vez de digitar:
```
ANTHROPIC_BASE_URL="..." ANTHROPIC_AUTH_TOKEN="..." claude ...
```

Você digita apenas:
```
cm
```

### Passo 4.1: Encontre seu shell

```bash
echo $SHELL
```

- Se aparecer `/bin/bash` → edite `~/.bashrc`
- Se aparecer `/bin/zsh` → edite `~/.zshrc`

### Passo 4.2: Edite o arquivo

```bash
nano ~/.bashrc
```

### Passo 4.3: Adicione no FINAL

```bash
# === Claude Code MiniMax Setup ===

# Cole sua API Key aqui (SUBSTITUA o texto)
export MINIMAX_API_KEY="COLE_SUA_CHAVE_AQUI"

# Alias para MiniMax (modelo principal)
alias cm='KEY=$(grep ^MINIMAX_API_KEY= ~/.claude/.secrets | cut -d= -f2-) && ANTHROPIC_BASE_URL="https://api.minimax.io/anthropic" ANTHROPIC_AUTH_TOKEN="$KEY" ANTHROPIC_MODEL="MiniMax-M2.7" API_TIMEOUT_MS="3000000" claude --dangerously-skip-permissions'

# Alias para Claude Pro OAuth (backup)
alias cp='env -u ANTHROPIC_BASE_URL -u ANTHROPIC_AUTH_TOKEN -u ANTHROPIC_MODEL -u API_TIMEOUT_MS claude --dangerously-skip-permissions'
```

### Passo 4.4: Salve e Saia

```
Ctrl + O     (Salvar)
Enter        (Confirmar nome)
Ctrl + X     (Sair)
```

### Passo 4.5: Recarregue

```bash
source ~/.bashrc
```

---

## 5. Copiar Arquivos

### Copiar a Pasta .claude

```bash
# Entre na pasta do repositório
cd claude-code-minimax-setup

# Copie tudo
cp -r .claude ~/
cp -r .claude/scripts ~/

# Crie diretórios necessários
mkdir -p ~/.mcp-data/memory-keeper
mkdir -p ~/.claude/pipelines
```

### Permissões

```bash
chmod +x ~/.claude/rules/*.bash
chmod +x ~/.claude/scripts/*
chmod 600 ~/.claude/settings.json 2>/dev/null
```

---

## 6. Configurar API Key

### Método 1: Arquivo .secrets (Recomendado)

```bash
nano ~/.claude/.secrets
```

Digite:
```
MINIMAX_API_KEY=sua_chave_aqui
```

```
Ctrl + O
Enter
Ctrl + X
```

```bash
chmod 600 ~/.claude/.secrets
```

### Método 2: Variável de Ambiente

```bash
export MINIMAX_API_KEY="sua_chave_aqui"
```

⚠️ Este método precisa repetir a cada nova sessão do terminal.

---

## 7. Testar Tudo

### Teste 1: MiniMax

```bash
cm -p "Qual é o modelo que você está usando?"
```

Deve responder algo sobre MiniMax.

### Teste 2: Claude Pro

```bash
cp -p "Qual é o modelo que você está usando?"
```

Deve responder sobre Claude.

### Teste 3: Agentes

```bash
cm --agent review-zappro "me ajude a revisar este código: function hello() { return 'hi' }"
```

### Teste 4: Skills

```bash
cm --skill mcp-health
```

### Teste 5: Help

```bash
cm --help
cp --help
```

---

## 8. Configurar MCP Servers (Opcional)

MCP servers são extensões que adicionam funcionalidades.

### memory-keeper (Memória Persistente)

```bash
# Instale
npm install -g mcp-memory-keeper

# Adicione ao settings.json
nano ~/.claude/settings.json
```

Adicione na seção `mcpServers`:

```json
"memory-keeper": {
  "command": "npx",
  "args": ["mcp-memory-keeper"],
  "env": {
    "DATA_DIR": "/caminho/para/.mcp-data/memory-keeper"
  }
}
```

### github (GitHub Integration)

```bash
# Gere token em https://github.com/settings/tokens
# Precisa de: repo, read:user, workflow

nano ~/.claude/settings.json
```

Adicione:

```json
"github": {
  "command": "node",
  "args": ["/caminho/para/@modelcontextprotocol/server-github/dist/index.js"],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "seu_token_aqui"
  }
}
```

### tavily (Web Search)

```bash
# Obtenha key em https://tavily.com/
nano ~/.claude/settings.json
```

Adicione:

```json
"tavily": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-tavily"],
  "env": {
    "TAVILY_API_KEY": "sua_chave_tavily"
  }
}
```

---

## 9. Configurar Dashboard (Opcional)

O dashboard é um página HTML que mostra status e atalhos.

### Opção A: Abrir Direto

```bash
# Navegue até o repositório
cd claude-code-minimax-setup/docs

# Abra no navegador
open painel-dashboard.html       # Mac
xdg-open painel-dashboard.html   # Linux
start painel-dashboard.html      # Windows
```

### Opção B: Servidor Local

```bash
cd claude-code-minimax-setup/docs
python3 -m http.server 8080
```

Acesse: http://localhost:8080/painel-dashboard.html

---

## 🔧 Troubleshooting

### "command not found: claude"

```bash
# Reinicie o terminal
exec bash

# Ou instale novamente
curl -s https://storage.googleapis.com/claude-code-downloads/install.sh | sh
```

### "MINIMAX_API_KEY: unbound variable"

Você configurou `MINIMAX_API_KEY` no `~/.bashrc` mas não criou o arquivo `~/.claude/.secrets`.

```bash
nano ~/.claude/.secrets
# Digite: MINIMAX_API_KEY=sua_chave
# Ctrl+O, Enter, Ctrl+X
```

### "Permission denied" ao copiar

```bash
sudo cp -r .claude ~/
sudo cp -r .claude/scripts ~/
sudo mkdir -p ~/.mcp-data/memory-keeper
sudo chmod +x ~/.claude/rules/*.bash
```

### "curl: (22) Requested URL must be https"

O alias está tentando usar `http`. Verifique se a URL está correta no alias.

### "claude: command not found" após install

```bash
which claude
# Se não aparecer nada:

# Mac
brew reinstall anthropic/claude-code/claude

# Linux
curl -s https://storage.googleapis.com/claude-code-downloads/install.sh | sh
```

---

## ✅ Checklist Final

Depois de configurar, marque:

- [ ] Claude Code instalado (`claude --version`)
- [ ] Alias `cm` funciona
- [ ] Alias `cp` funciona
- [ ] Pasta `.claude` copiada para `~/`
- [ ] Arquivo `~/.claude/.secrets` criado
- [ ] `chmod 600 ~/.claude/.secrets`
- [ ] Testou `cm -p "teste"`
- [ ] Testou `cp -p "teste"`

---

## 📞 Ainda Com Problemas?

1. **Google**: pesquise o erro exato
2. **文档**: leia o `README.md` e `GUIA-RAPIDO.md`
3. **Comunidade**: peça ajuda em fóruns

---

*Guia criado para leigos que querem o melhor setup de Claude Code!*
