# ⏰ Cron Jobs — Automação Segura

**Jobs automáticos que rodam sem você precisar digitar comandos.**

---

## ⚠️ Regras de Segurança

- **NUNCA** jobs destrutivos (delete, destroy, wipe)
- **SEMPRE** com log para auditoria
- **READ-ONLY** ou **BACKUP** apenas
- Jobs rodam no horário de São Paulo (TZ: America/Sao_Paulo)

---

## 📋 Jobs Disponíveis

| Frequência | Horário | Job | O Que Faz |
|------------|---------|-----|-----------|
| Diário | 02:00 | Backup memory | Faz backup do SQLite |
| Diário | 03:00 | **Modo Dormir** | Escaneia repo, gera pipeline |
| Diário | 08:00 | MCP health | Verifica 7 MCP servers |
| Semanal | Domingo 03:00 | Context prune | Limpa sessões antigas |
| Semanal | Quarta 09:00 | Secrets audit | Varredura de secrets |

---

## 🚀 Instalar Todos

```bash
# Copie para crontab
crontab -e

# Cole os jobs abaixo (salve com Ctrl+O, Enter, Ctrl+X)
```

---

## 📝 Jobs para Copiar

```cron
# ═══════════════════════════════════════════
# CLAUDE CODE AUTOMATION — will-zappro
# TZ: America/Sao_Paulo
# ═══════════════════════════════════════════

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DIÁRIO — Backup memory (2h)
# Backup do banco SQLite antes do dia começar
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
0 2 * * * ~/.claude/scripts/backup-memory.sh >> ~/.claude/logs/backup.log 2>&1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DIÁRIO — MODO DORMIR (3h) ⭐
# Escaneia repositório enquanto você dorme
# GERA: pipeline.json + smoke tests + curl scripts
# CUSTO: ~$5-10 em tokens MiniMax
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
0 3 * * * cm --agent modo-dormir "scan /srv/monorepo" >> ~/.claude/logs/modo-dormir.log 2>&1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DIÁRIO — MCP health check (8h)
# Verifica se todos os MCP servers estão OK
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
0 8 * * * cm -p "Execute: --skill mcp-health" >> ~/.claude/logs/mcp-health.log 2>&1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEMANAL — Context prune (Domingo 3h)
# Limpa sessões >7 dias do memory-keeper
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
0 3 * * 0 cm -p "Execute: --skill context-prune" >> ~/.claude/logs/context-prune.log 2>&1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SEMANAL — Secrets audit (Quarta 9h)
# Varredura de secrets exposés no monorepo
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
0 9 * * 3 cm -p "Execute: --skill secrets-audit in /srv/monorepo" >> ~/.claude/logs/secrets.log 2>&1
```

---

## 📁 Logs

```bash
# Ver logs
ls ~/.claude/logs/

# Ver backup log
cat ~/.claude/logs/backup.log

# Ver MCP health
tail -20 ~/.claude/logs/mcp-health.log

# Ver secrets audit
tail -20 ~/.claude/logs/secrets.log
```

---

## 🗑️ Limpar Logs Antigos

```bash
# Logs >30 dias
find ~/.claude/logs/ -name "*.log" -mtime +30 -delete

# Ou adicionar ao cron (último dia do mês)
0 0 28-31 * * find ~/.claude/logs/ -name "*.log" -mtime +30 -delete
```

---

## ➕ Adicionar Seu Próprio Job

```bash
crontab -e
```

Formato:
```
┌───────────── minute (0-59)
│ ┌───────────── hour (0-23)
│ │ ┌───────────── day of month (1-31)
│ │ │ ┌───────────── month (1-12)
│ │ │ │ ┌───────────── day of week (0-6, Sun=0)
│ │ │ │ │
* * * * * command
```

**Exemplos:**

```cron
# A cada 5 minutos
*/5 * * * * cm -p "Check system health"

# A cada hora
0 * * * * cm -p "Verify ZFS snapshot"

# Todo dia às 6h da manhã
0 6 * * * cm -p "Morning system check"

# Toda semana segunda às 7h
0 7 * * 1 cm -p "Weekly review"
```

---

## ❌ Remover Todos os Jobs

```bash
crontab -r
```

**Cuidado:** Remove todos os jobs de uma vez.

---

## ✅ Verificar Jobs Ativos

```bash
crontab -l
```

---

## 📊 Status dos Jobs

```bash
# Último backup
ls -la ~/.mcp-data/memory-keeper/backups/ | tail -5

# Último health check
tail -3 ~/.claude/logs/mcp-health.log

# Último secrets audit
tail -3 ~/.claude/logs/secrets.log
```

---

## 🔔 Notificações (Opcional)

Adicione notificação ao email ou Slack:

```cron
# Com email (precisa mailutils)
0 8 * * * cm -p "Execute: --skill mcp-health" 2>&1 | mail -s "Claude Health" seu@email.com

# Com Slack webhook (requer curl)
0 8 * * * cm -p "Execute: --skill mcp-health" && curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Claude Health: OK"}' SEU_WEBHOOK_URL
```

---

## ⚡ Cron Special Strings

| String | Equivalente | Quando |
|--------|-------------|--------|
| `@hourly` | `0 * * * *` | A cada hora |
| `@daily` | `0 0 * * *` | Meia-noite |
| `@weekly` | `0 0 * * 0` | Domingo meia-noite |
| `@monthly` | `0 0 1 * *` | Dia 1 meia-noite |

---

## 💡 Dicas

1. **Logs são essenciais** — sempre redirecione saída para `.log`
2. **Horário de SP** — configure TZ no topo do crontab
3. **Mais seguro** — use paths absolutos (`/home/will/.claude/...`)
4. **Teste antes** — rode o comando manualmente antes de colocar no cron
5. **Backup primeiro** — sempre backup antes de mudar

---

## 📝 Crontab do Usuário

Para editar:
```bash
crontab -e
```

Para ver:
```bash
crontab -l
```

Para remover:
```bash
crontab -r
```

---

## 🔒 Jobs Permitidos (Seguro)

| ✅ Permitido | ❌ Bloqueado |
|-------------|--------------|
| `--skill mcp-health` | `zfs destroy` |
| `--skill context-prune` | `docker rm` |
| `--skill secrets-audit` | `rm -rf` |
| `--skill snapshot-safe` | `git push --force` |
| `backup-memory.sh` | `terraform destroy` |
| `cm -p "health check"` | `curl *untrusted*` |
