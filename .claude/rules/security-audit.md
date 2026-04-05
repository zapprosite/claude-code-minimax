---
name: block-repo-hooks
enabled: true
event: Bash
pattern: \.claude/hooks/
---

⚠️ **Hooks de repositório bloqueados**

Hooks em .claude/hooks/ de repos podem executar código antes de qualquer confirmação de confiança.
Isso é vetor de ataque (CVE-2025-59536).

Bloqueado: Não execute hooks de repositórios externos.
