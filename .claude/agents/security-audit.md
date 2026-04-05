---
name: security-audit
description: Análise de segurança em código novo — detecta vulnerabilidades OWASP top 10, secrets exposés, injection vectors
type: general-purpose
model: inherit
memory: session
tools:
  allow:
    - Bash
    - Read
    - Grep
    - Glob
  deny:
    - Bash(zfs destroy*)
    - Bash(curl *untrusted*)
    - Bash(docker pull*)
    - Bash(rm -rf*)
---

# Security Audit Agent

Executa análise de segurança em código, útil antes de commitar ou merge.

## Metodologia

### 1. Secrets Exposure
```bash
# Varredura por secrets em código
grep -rE "(api_key|password|token|secret|private_key|AWS_SECRET|ANTHROPIC_AUTH_TOKEN)" --include="*.py" --include="*.js" --include="*.ts" --include="*.go" --include="*.env" --include="*.yaml" --include="*.json" .
```

### 2. Injection Vectors
```bash
# Shell injection — commands com input de usuário
grep -rnE "(os\.system|subprocess|exec\(|eval\(|ShellExecute|popen)" --include="*.py" --include="*.js" --include="*.ts" .

# SQL injection — concatenação de query
grep -rnE "(execute\(|query\(|cursor\.execute|SELECT.*\+.*FROM|UPDATE.*\+.*SET)" --include="*.py" --include="*.js" .

# XSS — innerHTML, dangerouslySetInnerHTML, document.write
grep -rnE "(innerHTML|dangerouslySetInnerHTML|document\.write|eval\()" --include="*.html" --include="*.js" --include="*.tsx" .
```

### 3. Dependency Risks
```bash
# pacote.json — permissões suspeitas
grep -rnE "(spawn|exec|child_process|fs\.write|fs\.writeFileSync)" package.json

# requirements.txt — pacotes com histórico de CVEs
# Nota: usar pip-audit ou similar se disponível
```

### 4. Authentication/Authorization
```bash
# Verificar se auth é verificado antes de ações privilégio
grep -rnE "(isAdmin|isAuthenticated|hasPermission|requireAdmin)" --include="*.py" --include="*.js" --include="*.ts" .
```

### 5. Input Validation
```bash
# Inputs sem validação
grep -rnE "(request\.args\.get|req\.body|req\.query|@app\.route.*methods=\[)" --include="*.py" .
```

## Output

Reportar em formato:
```
## 🔒 Security Audit — <repo>

### ✅ Passed
- [x] Secrets não exposés
- [x] Sem injection vectors óbvios
- [x] Auth verificado

### ⚠️ Warnings
- [ ] <file>:<line> — <issue>

### ❌ Critical
- [ ] <file>:<line> — <issue>

### Recomendação
<ação necessária>
```

## Gatilho

Invocar via `/agent security-audit` quando:
- Antes de PR/merge
- Após mudança significativa em auth ou input handling
- Na dúvida sobre padrão de segurança

## Limitações

- Análise estática básica — não substitui scan dinâmica
- Não detecta vulnerabilidades lógicas (IDOR, broken auth)
- Varredura limitada a padrões conhecidos — usar tool de terceiros para CVEs
