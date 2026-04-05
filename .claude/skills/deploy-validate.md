---
name: deploy-validate
description: Health check completo + plano de rollback antes de deploy
context: fork
disable-model-invocation: true
allowed-tools:
  - Bash
  - Read
paths:
  - ~/.claude/skills/**
---

# Skill: Deploy Validate

Executa validação completa antes de qualquer deploy.

## Health Check

```bash
# Docker services status
docker ps --format "table {{.Names}}\t{{.Status}}"

# Health endpoints
for service in qdrant n8n coolify; do
  case $service in
    qdrant) port=6333; url="http://localhost:${port}/health" ;;
    n8n) port=5678; url="http://localhost:${port}/api/v1/health" ;;
    coolify) port=8000; url="http://localhost:${port}/api/v1/health" ;;
  esac
  status=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
  if [ "$status" = "200" ]; then
    echo "✅ $service: healthy"
  else
    echo "❌ $service: FAIL (HTTP $status)"
  fi
done

# GPU status
nvidia-smi --query-gpu=memory.used,memory.free --format=csv,noheader 2>/dev/null || echo "⚠️ GPU: unavailable"

# Disk usage
df -h /srv | tail -1
```

## Rollback Plan

```bash
# Gerar plano de rollback
SNAPSHOT_LATEST=$(zfs list -t snapshot | grep "$(date +%Y%m%d)" | tail -1 | awk '{print $1}')
echo "ROLLBACK COMMAND:"
echo "sudo zfs rollback -r $SNAPSHOT_LATEST"
```

## Decision Matrix

| Condição | Resultado |
|----------|----------|
| Todos services HTTP 200 | ✅ APTO |
| 1 service down | ⚠️ CAUTELA — verificar se crítico |
| 2+ services down | ❌ BLOQUEADO |
| Disco >90% | ❌ BLOQUEADO |
| Pool not ONLINE | ❌ BLOQUEADO |

## Output Format

```
## 🚀 Deploy Validation — $(date '+%Y-%m-%d %H:%M')

### ✅ Services
- Qdrant: ✅/❌
- n8n: ✅/❌
- Coolify: ✅/❌

### 💾 Resources
- Disk /srv: <uso>
- GPU Memory: <used>/<free>

### 📋 Rollback
\`\`\`
sudo zfs rollback -r <snapshot>
\`\`\`

### 🟢/APTO ou 🔴/BLOQUEADO
```

## Gatilho

Usar antes de:
- `docker compose up -d --pull`
- Upgrade de imagem Docker
- Mudança de configuração em produção
- Deploy via Coolify

## Erros Comuns

| Erro | Causa | Solução |
|------|-------|---------|
| `curl: connection refused` | Serviço não rodando | `docker start <name>` |
| `HTTP 500` | Serviço errorando | Ver logs: `docker logs <name>` |
| `GPU: unavailable` | Driver NVIDIA issue | `nvidia-smi` direto |
