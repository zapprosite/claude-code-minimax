---
name: snapshot-safe
description: Cria snapshot ZFS com preflight checklist antes de mudanças críticas
context: fork
disable-model-invocation: true
allowed-tools:
  - Bash
  - Read
paths:
  - ~/.claude/skills/**
---

# Skill: Snapshot Safe

Cria snapshot ZFS antes de qualquer mudança crítica em produção.

## Preflight Checklist

Executar ANTES de criar snapshot:

```bash
# 1. Verificar serviços rodando
docker ps --format "table {{.Names}}\t{{.Status}}"

# 2. Verificar disco livre (>10%)
df -h /srv | awk 'NR==2 {print $5}' | grep -oE '[0-9]+'

# 3. Verificar ZFS pool healthy
zpool status tank | grep "state:"
```

## Criar Snapshot

```bash
# Gerar nome descritivo
SNAPSHOT="tank@pre-$(date +%Y%m%d-%H%M%S)-${DESCRIPTION:-manual}"

# Criar snapshot
sudo zfs snapshot -r "$SNAPSHOT"

# Verificar criado
zfs list -t snapshot | grep "$(date +%Y%m%d)"
```

## Variáveis

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `${DESCRIPTION}` | Descrição da mudança | `docker-upgrade`, `config-change` |

## Rollback

```bash
sudo zfs rollback -r "$SNAPSHOT"
```

## Validação Pós-Snapshot

```bash
# Verificar snapshot existe
zfs list -t snapshot | grep "$(date +%Y%m%d)"

# Verificar serviços ainda rodando
docker ps
```

## Gatilho

Usar quando:
- Antes de upgrade Docker/serviço
- Antes de mudança em configuração ZFS
- Antes de modificar `/srv/data`
- Antes de apt upgrade

## Erros Comuns

| Erro | Causa | Solução |
|------|-------|---------|
| `permission denied` | sudo needed | Usar `sudo` |
| `cannot create snapshot` | Pool full | Liberar espaço primeiro |
| `dataset is busy` | Serviços ativos | Parar serviços antes |
