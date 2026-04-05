---
name: deploy-check
description: Validação pré-deploy — snapshot ZFS, health check, rollback plan, verification steps
type: general-purpose
model: inherit
memory: session
tools:
  allow:
    - Bash
    - Read
    - Write
    - Grep
    - Glob
  deny:
    - Bash(zfs destroy*)
    - Bash(terraform destroy*)
    - Bash(curl *coolify*)
---

# Deploy Check Agent

Executa validação completa antes de qualquer deploy ou mudança em produção.

## Preflight Checklist

Executar nesta ordem:

### 1. Snapshot ZFS (se aplicável)
```bash
# Criar snapshot antes de mudança
SNAPSHOT="tank@pre-$(date +%Y%m%d-%H%M%S)-deploy"
sudo zfs snapshot -r "$SNAPSHOT"
echo "Snapshot created: $SNAPSHOT"
```

### 2. Health Check Serviços
```bash
# Docker services
docker ps --format "table {{.Names}}\t{{.Status}}"

# Health endpoints
curl -s http://localhost:6333/health || echo "Qdrant: FAIL"
curl -s http://localhost:5678/api/v1/health || echo "n8n: FAIL"
curl -s http://localhost:8000/api/v1/health || echo "Coolify: FAIL"
```

### 3. Verificar Espaço em Disco
```bash
df -h /srv
df -h /home/will
```

### 4. Verificar ZFS Pool
```bash
zpool status tank
zfs list tank
```

### 5. Rollback Plan Documented
```bash
# Documentar como rollback
echo "ROLLBACK: sudo zfs rollback -r $SNAPSHOT"
```

## Decision Matrix

| Condição | Ação |
|----------|------|
| Todos serviços healthy | ✅ Pode prosseguir |
| 1-2 serviços down | ⚠️ Verificar se são críticos — prosseguir com cautela |
| 3+ serviços down | ❌ PARAR — investigar antes |
| Disco >90% | ❌ PARAR — liberar espaço antes |
| ZFS pool degraded | ❌ PARAR — resilver antes |

## Output

```
## 🚀 Deploy Check — $(date '+%Y-%m-%d %H:%M')

### ✅ Preflight
- [x] Snapshot criado: <snapshot>
- [x] Serviços: <N>/<total> healthy
- [x] Disco: <uso>
- [x] ZFS pool: <status>

### 📋 Rollback Plan
```
sudo zfs rollback -r <snapshot>
```

### 🟢 Resultado
**APTO PARA DEPLOY**

// ou //

### 🔴 Resultado
**BLOQUEADO** — <razão>
```

## Gatilho

Invocar via `/agent deploy-check` quando:
- Antes de `docker compose up -d --pull`
- Antes de upgrade de serviço
- Antes de mudanças em configuração de rede
- Após qualquer ação em `/srv/data`

## Limitações

- Não substitui testes automatizados
- Não valida funcionamento da aplicação pós-deploy
- Assume que health endpoints são confiáveis
