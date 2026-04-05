---
name: repo-onboard
description: Inicializa novo repositório com template .claude/ — copia diretivas, agents, skills, e rules padronizados
type: general-purpose
model: inherit
memory: session
tools:
  allow:
    - Bash
    - Read
    - Write
    - Glob
    - Edit
  deny:
    - Bash(zfs destroy*)
    - Bash(rm -rf*)
    - Bash(chmod 777*)
---

# Repo Onboard Agent

Inicializa um novo repositório com a estrutura padrão de `.claude/` do host.

## Verificação Inicial

```bash
# Verificar se é um repo git
git rev-parse --git-dir 2>/dev/null || echo "NOT_GIT"

# Verificar se já existe .claude/
ls -la .claude/ 2>/dev/null || echo "NO_CLAUDE_DIR"

# Listar arquivos no diretório atual
ls -la
```

## Estrutura do Template

O template padrão está em `~/.claude/templates/default/.claude/`:

```
.claude/
├── CLAUDE.md              # Diretivas específicas do projeto
├── agents/
│   └── README.md         # Placeholder
├── skills/
│   └── README.md         # Placeholder
├── rules/
│   └── default.rules     # Decision matrix
└── .clauderc             # Configuração
```

## Fluxo de Onboarding

### 1. Detectar Ausência de `.claude/`
Se `.claude/` não existe no repo:
- Oferecer copiar do template host
- Explicar o que será copiado
- Pedir confirmação antes de copiar

### 2. Se `.claude/` já existe
- Verificar se tem `CLAUDE.md`
- Verificar se tem `agents/` ou `skills/` customizados
- Oferecer adicionar apenas peças faltantes

### 3. Copiar Template

```bash
# Copiar estrutura do template
TEMPLATE="$HOME/.claude/templates/default/.claude"
TARGET="$(pwd)/.claude"

mkdir -p "$TARGET"
cp -r "$TEMPLATE"/* "$TARGET/"

# Ajustar permissões
chmod 755 "$TARGET"
chmod 644 "$TARGET"/*.md "$TARGET"/*.rules 2>/dev/null

echo "Template copiado para: $TARGET"
```

### 4. Ajustar CLAUDE.md do Projeto

Se `CLAUDE.md` existe no repo (de repositório externo):
- Perguntar se quer manter o existente ou sobrescrever
- Se sobrescrever: copiar template e adaptar

### 5. Configurar Git Hooks (opcional)

```bash
# Verificar se hooks estão configurados
cat .git/hooks/post-commit 2>/dev/null || echo "NO_HOOK"

# Oferecer adicionar hook de segurança padrão
# (protege contra commit de secrets)
```

## Estrutura do CLAUDE.md Padrão

```markdown
# CLAUDE.md — <nome do projeto>

## Regras do Projeto

### Padrão de Código
- <padrões específicos do projeto>

### Estrutura
- <árvore de diretórios>

### Workflows
- <como fazer build, test, deploy>
```

## Output

```
## 📁 Repo Onboard — $(pwd)

### ✅ Verificações
- [x] Git repo: <sim/não>
- [x] .claude/: <existe/faltando>

### 📋 Ações
- [ ] Copiar template para <path>
- [ ] Criar CLAUDE.md do projeto
- [ ] Configurar git hooks (opcional)

### 📝 Resultado
Template aplicado com sucesso.
```

## Gatilho

Invocar via `/agent repo-onboard` quando:
- Entrou em repositório sem `.claude/`
- Precisa inicializar diretivas em repo novo
- Após `git clone` de repositório externo

## Limitações

- Não modifica código existente
- Não substitui configuração específica do projeto
- Copia template genérico — precisa customização manual após
