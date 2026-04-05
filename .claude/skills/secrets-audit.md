---
name: secrets-audit
description: Varredura de secrets exposés em código — api_keys, passwords, tokens, credentials
context: fork
disable-model-invocation: true
allowed-tools:
  - Bash
  - Read
paths:
  - ~/.claude/skills/**
---

# Skill: Secrets Audit

Varre código em busca de secrets exposés antes de git push.

## Padrões de Secrets

```bash
# API Keys e Tokens
grep -rnE "(api[_-]?key|apikey|API[_-]?KEY)" --include="*.py" --include="*.js" --include="*.ts" --include="*.go" --include="*.sh" --include="*.env*" .

# Passwords e Secrets
grep -rnE "(password|passwd|pwd|secret|SECRET|PRIVATE|private[_-]?key)" --include="*.py" --include="*.js" --include="*.ts" --include="*.go" --include="*.yaml" --include="*.yml" --include="*.json" .

# AWS
grep -rnE "(AWS[_-]?ACCESS|AWS[_-]?SECRET|aws[_-]?access|aws[_-]?secret)" --include="*.py" --include="*.js" --include="*.sh" --include="*.env*" .

# Cloudflare
grep -rnE "(CLOUDFLARE[_-]?API|CF[_-]?API|cloudflare[_-]?token)" --include="*.py" --include="*.js" --include="*.sh" --include="*.env*" .

# Database credentials
grep -rnE "(DATABASE[_-]?URL|DB[_-]?HOST|postgresql://|mysql://|mongodb://|redis://)" --include="*.py" --include="*.js" --include="*.ts" --include="*.env*" --include="*.yaml" .

# Anthropic/OpenAI
grep -rnE "(ANTHROPIC[_-]?API|OPENAI[_-]?API|OPENAI[_-]?KEY|ANTHROPIC[_-]?KEY)" --include="*.py" --include="*.js" --include="*.sh" --include="*.env*" .
```

## Arquivos de Configuração

```bash
# .env* não versionados (esperado)
cat .gitignore | grep -E "\.env|\.env\.|env-local"

# Arquivos que NÃO deveriam estar no git
grep -rnE "(id_rsa|id_ed25519|\.pem|\.key)" --include="*.py" --include="*.js" --include="*.sh" .

# Docker secrets
grep -rnE "(POSTGRES_PASSWORD|MYSQL_ROOT_PASSWORD|REDIS_PASSWORD)" --include="*.yml" --include="*.yaml" --include="*.json" --include="*.env*" .
```

## Check do Git

```bash
# Verificar se há secrets no staging
git diff --cached --name-only

# Check histórico de commits (últimos 10)
git log --oneline -10 --stat

# Verificar remotes
git remote -v
```

## Output

```
## 🔐 Secrets Audit — $(date '+%Y-%m-%d %H:%M')

### ✅ Passou
- [x] Nenhum secret óbvio encontrado
- [x] .gitignore configurado

### ⚠️ Warnings
- [ ] <file>:<line> — possível secret exposto (verificar)

### ❌ Falhas
- [ ] <file>:<line> — <pattern> ENCONTRADO

### 📋 Ação Necessária
1. Remover secret do código
2. Adicionar à deny list
3. Usar variáveis de ambiente
4. ROTATE o secret comprometido
```

## Gatilho

**OBRIGATÓRIO** antes de:
- `git push`
- `git commit` com código novo
- Compartilhar código externamente
- After deprecation warnings

## Regra de Ouro

> Se encontrar ANY secret em código: ABORTAR e não continuar até resolver.

## Limitações

- Varredura estática básica — não detecta secrets ofuscados
- Não substitui scanner dedicado (trufflehog, git-secrets)
- Não detecta secrets em arquivos binary
- Não varre历史文化

## Erros Comuns

| Erro | Causa | Solução |
|------|-------|---------|
| `ALERT: secret found` | Secret expuesto | NUNCA dar git add; usar env vars |
| `.env in git` | .gitignore missing | Adicionar ao .gitignore |
