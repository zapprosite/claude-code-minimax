---
name: mcp-health
description: Verifica status dos 7 MCP servers ativos — filesystem, git, context7, memory-keeper, github, playwright, tavily
context: fork
disable-model-invocation: true
allowed-tools:
  - Bash
  - Read
paths:
  - ~/.claude/skills/**
---

# Skill: MCP Health

Verifica status de todos os 7 MCP servers configurados.

## Lista de MCP Servers

| # | Server | Package | Purpose |
|---|--------|---------|---------|
| 1 | filesystem | @j0hanz/filesystem-mcp | File ops avançados |
| 2 | git | @cyanheads/git-mcp-server | Git completo |
| 3 | context7 | @upstash/context7-mcp | Contexto de código |
| 4 | memory-keeper | mcp-memory-keeper | Knowledge graph persistente |
| 5 | github | @modelcontextprotocol/server-github | Issues, PRs, repos |
| 6 | playwright | chrome-devtools-mcp | Browser automation |
| 7 | tavily | @modelcontextprotocol/server-tavily | Web search |

## Health Check

```bash
# Listar todos MCP servers
claude mcp list

# Para cada server: verificar se está respondendo
echo "=== MCP Health Check ==="

# 1. filesystem
claude mcp list | grep -q "filesystem.*running" && echo "✅ filesystem: OK" || echo "❌ filesystem: FAIL"

# 2. git
claude mcp list | grep -q "git.*running" && echo "✅ git: OK" || echo "❌ git: FAIL"

# 3. context7
claude mcp list | grep -q "context7.*running" && echo "✅ context7: OK" || echo "❌ context7: FAIL"

# 4. memory-keeper
claude mcp list | grep -q "memory-keeper.*running" && echo "✅ memory-keeper: OK" || echo "❌ memory-keeper: FAIL"

# 5. github
claude mcp list | grep -q "github.*running" && echo "✅ github: OK" || echo "❌ github: FAIL"

# 6. playwright
claude mcp list | grep -q "playwright.*running" && echo "✅ playwright: OK" || echo "❌ playwright: FAIL"

# 7. tavily
claude mcp list | grep -q "tavily.*running" && echo "✅ tavily: OK" || echo "❌ tavily: FAIL"
```

## Teste de Funcionalidade

### memory-keeper
```bash
mcp__memory-keeper__context_status
```

### context7
```bash
mcp__context7__reserve_context "test" max_tokens=100
```

### github (se configurado)
```bash
# Testar autenticação
gh auth status 2>/dev/null || echo "⚠️ github: not authenticated"
```

### filesystem
```bash
# Testar listagem
ls -la ~/.claude/
```

### git
```bash
# Testar git
git status --short 2>/dev/null || echo "⚠️ git: not a repo"
```

## Diagnóstico de Problemas

| Server | Problema Comum | Solução |
|--------|---------------|---------|
| tavily | `API key missing` | Verificar `TAVILY_API_KEY` no vault |
| playwright | `chrome not found` | Reinstalar chrome-devtools-mcp |
| github | `auth failed` | `gh auth login` |
| memory-keeper | `database locked` | `sqlite3 context.db "PRAGMA integrity_check;"` |
| context7 | `rate limit` | Aguardar, não é crítica |

## Output

```
## 🔌 MCP Health — $(date '+%Y-%m-%d %H:%M')

### ✅ Servers Ativos (7/7)
- ✅ filesystem
- ✅ git
- ✅ context7
- ✅ memory-keeper
- ✅ github
- ✅ playwright
- ✅ tavily

// ou //

### ⚠️ Servers Parciais (N/7)
- ✅ filesystem
- ❌ tavily — API key missing

### 📋 Ações
- Reiniciar server com problema
- Verificar logs do MCP
- Verificar conexão de rede
```

## Gatilho

Usar quando:
- MCP tools não funcionam como esperado
- Antes de diagnose de problemas
- Após restart do sistema
- Verificação periódica de saúde

## Erros Comuns

| Erro | Causa | Solução |
|------|-------|---------|
| `command not found` | MCP server não instalado | Reinstall via npm |
| `connection refused` | Server não started | `claude mcp start <server>` |
| `timeout` | Rede ou rate limit | Aguardar e retry |
