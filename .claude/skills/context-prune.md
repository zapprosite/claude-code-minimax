---
name: context-prune
description: Limpa sessões antigas e compacta memory-keeper para liberar contexto
context: fork
disable-model-invocation: true
allowed-tools:
  - Bash
  - Read
paths:
  - ~/.claude/skills/**
---

# Skill: Context Prune

Limpa sessões antigas da memory-keeper e compacta o banco SQLite.

## Status Atual

```bash
# Verificar uso atual
mcp__memory-keeper__context_status

# Listar sessões
mcp__memory-keeper__context_session_list limit=20

# Estatísticas por canal
mcp__memory-keeper__context_channel_stats includeInsights=true
```

## Identificar Sessões Antigas

```bash
# Sessões com mais de 7 dias
mcp__memory-keeper__context_session_list limit=50

# Filtrar por data (sessões antigas)
# olderThan = "7 days"
```

## Compactação

```bash
# Compactar sessões >7 dias
mcp__memory-keeper__context_compress olderThan="7 days" preserveCategories=["user","feedback","project","reference"]

# Verificar redução
mcp__memory-keeper__context_status
```

## Limpeza de Checkpoints

```bash
# Listar checkpoints
ls -la ~/.mcp-data/memory-keeper/checkpoints/

# Remover checkpoints >30 dias
find ~/.mcp-data/memory-keeper/checkpoints/ -mtime +30 -delete 2>/dev/null

# Contagem após cleanup
ls ~/.mcp-data/memory-keeper/checkpoints/ | wc -l
```

## Session Cleanup

```bash
# Buscar sessões inativas
mcp__memory-keeper__context_search query="session" searchIn=["key"] limit=50

# Deletar sessões específicas (se necessário)
mcp__memory-keeper__context_batch_delete sessionId=<session_id>
```

## Output

```
## 🧹 Context Prune — $(date '+%Y-%m-%d %H:%M')

### 📊 Antes
- Sessões ativas: <N>
- Tamanho banco: <KB>
- Checkpoints: <N>

### 🧹 Ações
- [ ] Compactar sessões >7 dias
- [ ] Remover checkpoints >30 dias
- [ ] Limpar sessões inativas

### 📊 Depois (estimado)
- Sessões: <N> (-<N>)
- Tamanho: <KB> (-<KB>)
```

## Gatilho

Usar quando:
- Após 20+ mensagens em sessão única
- Antes de tasks muito longas
- Quando `mcp__memory-keeper__context_status` mostra >80% uso
- Quando contexto parece degradado

## Limitações

- Compactação é não-destrutiva para categorias importantes
- Sessões `user`, `feedback`, `project`, `reference` são preservadas
- Checkpoints manuais são preservados

## Erros Comuns

| Erro | Causa | Solução |
|------|-------|---------|
| `cannot compress` | Sessão em uso | Tentar após fim da task |
| `database locked` | another process | Aguardar e retry |
