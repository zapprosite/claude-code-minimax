# 🤖Aliases — Comandos Abreviados

**Tudo que você pode digitar com apenas 2 letras.**

---

## Agentes (/agent)

| Alias | Comando Completo | O Que Faz |
|-------|-----------------|-----------|
| `/md` | `/agent modo-dormir` | Escaneia repo enquanto você dorme |
| `/rr` | `/agent review-zappro` | Code review detalhado |
| `/sa` | `/agent security-audit` | Análise OWASP + secrets |
| `/dc` | `/agent deploy-check` | Snapshot + health + rollback |
| `/co` | `/agent context-optimizer` | Analisa contexto |
| `/ro` | `/agent repo-onboard` | Inicializa repo |
| `/ec` | `/agent executive-ceo` | Decisões estratégicas |

---

## Skills (--skill ou /skill)

| Alias | Comando Completo | Quando Usar |
|-------|-----------------|-------------|
| `/ss` | `--skill snapshot-safe` | Antes de mudar ZFS |
| `/dv` | `--skill deploy-validate` | Antes de deploy |
| `/cp` | `--skill context-prune` | Limpar sessões |
| `/sec` | `--skill secrets-audit` | Antes de git push |
| `/mcp` | `--skill mcp-health` | Diagnosticar MCP |
| `/rs` | `--skill repo-scan` | Detectar tasks |
| `/pg` | `--skill pipeline-gen` | Gerar pipeline |
| `/st` | `--skill smoke-test-gen` | Gerar testes |
| `/hg` | `--skill human-gates` | Ver approval gates |

---

## Aliases Bash

| Alias | Comando | Para Que Serve |
|-------|---------|----------------|
| `cm` | MiniMax | Modelo principal ($50/mês) |
| `cp` | Claude Pro | Backup ($20/mês) |

---

## Exemplos Rápidos

```bash
# Code review rápido
/rr me ajuda a revisar esse código

# Snapshot antes de mudar
/ss antes de atualizar o Docker

# Verificar MCP
/mcp

# Escaneear projeto
/md scan ~/Desktop/meu-projeto

# Secrets audit
/sec antes de commitar

# Diagnosticar
/mcp
```

---

## Tabela de Referência Rápida

```
/md  = modo-dormir      (escaneia repo dormindo)
/rr  = review-zappro    (code review)
/sa  = security-audit   (segurança)
/dc  = deploy-check     (validação deploy)
/co  = context-optimizer (otimiza contexto)
/ro  = repo-onboard     (inicializa repo)
/ec  = executive-ceo     (decisões)

/ss  = snapshot-safe    (snapshot ZFS)
/dv  = deploy-validate  (valida deploy)
/cp  = context-prune    (limpa sessões)
/sec = secrets-audit   (verifica secrets)
/mcp = mcp-health      (diagnóstico MCP)
/rs  = repo-scan        (detecta tasks)
/pg  = pipeline-gen    (gera pipeline)
/st  = smoke-test-gen  (gera testes)
/hg  = human-gates     (ver gates)
```
