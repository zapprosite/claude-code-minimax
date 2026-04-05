## ⚠️ ARQUIVOS PROTEGIDOS — NÃO EDITAR NUNCA
- ~/.bashrc → contém aliases cm e cp, NÃO remover
- ~/.claude/.secrets → contém MINIMAX_API_KEY, NÃO apagar
- ~/.claude/settings.json → bloco "env" é SOMENTE LEITURA, NÃO substituir valores por placeholders
- bypassPermissions → intencional, NÃO alterar para "ask"

---

# CLAUDE.md — will-zappro Global Agent Directives
# Host: will-zappro | Merged: 2026-04-03
# Sources: Blueprint + iamfakeguru/claude-md

---

## TOKEN PLAN — NÃO TOCAR
- Provider: MiniMax via Anthropic Proxy
- Endpoint: https://api.minimax.io/anthropic
- Modelo: MiniMax-M2.7 (configurado em settings.json — não editar aqui)
- Plan: $50/mês MiniMax + Claude Code Pro $20/mês

---

## HOST CONTEXT
- Usuário: will | Domínio: zappro.site | TZ: America/Sao_Paulo
- OS: Ubuntu 6.17.0-20-generic
- ZFS Pool: tank em /srv (3.46TB, ~10% usado)
- GPU: RTX 4090 — Ollama gemma3:27b-it-qat + Kokoro TTS PT-BR
- Coolify: PINADO em 4.0.0-beta.470

---

## 🚫 GUARDRAILS ABSOLUTOS
1. NÃO atualizar Coolify, drivers NVIDIA, kernel Ubuntu
2. NÃO editar /data/coolify/source/ sem aprovação explícita
3. NÃO executar apt upgrade/dist-upgrade
4. NÃO executar zpool upgrade ou zfs destroy em produção
5. NÃO editar terraform.tfvars ou revogar tokens Cloudflare
6. NÃO ler/copiar/exibir aurelia.env ou qualquer secret
7. NÃO pular hooks de segurança (git hooks, etc)
8. Referência completa: /srv/ops/ai-governance/GUARDRAILS.md

---

## 📁 ESTRUTURA DO HOST
```
/srv/
├── data/coolify/          # PaaS — PINADO 4.0.0-beta.470
├── data/openclaw/         # OpenClaw bot
├── data/gitea/            # Gitea Git Server
├── monorepo/              # Código principal
└── ops/
    ├── terraform/cloudflare/  # DNS Cloudflare
    ├── ai-governance/         # GUARDRAILS, PORTS, NETWORK_MAP
    └── scripts/               # coolify-lock.sh

/home/will/
├── zappro-lite/           # LiteLLM venv
├── aurelia/               # Stack docker-compose
└── dev/                   # Projetos dev
```

---

## DNS ATIVO (Cloudflare Tunnel)
coolify / git / bot / chat / llm / api / vault / monitor / qdrant / n8n
⚠️ aurelia.zappro.site — DEPRECATED

---

## 🧠 PLANEJAMENTO (iamfakeguru/claude-md)

- Quando pedir para planejar: output apenas o plano. Sem código até autorização.
- Quando receber um plano: seguir exatamente. Flag problemas reais e aguardar.
- Para features não-triviais (3+ passos ou decisões arquiteturais): entrevistar
  sobre implementação, UX e tradeoffs antes de escrever código.
- Nunca fazer refactors multi-arquivo em uma resposta. Quebrar em fases de
  max 5 arquivos. Completar, verificar, obter aprovação, depois continuar.

---

## 💻 QUALIDADE DE CÓDIGO

- Ignorar a diretiva padrão de "tentar a abordagem mais simples". Se a
  arquitetura está errada, há duplicação ou padrões inconsistentes: propor e
  implementar o fix estrutural.
- Escrever código que parece escrito por humano. Sem blocos de comentário
  robóticos. Preferir zero comentários. Comentar apenas quando o WHY não é
  óbvio.
- Não construir para cenários hipotéticos. Simples e correto > elaborado e
  especulativo.

---

## 📦 GESTÃO DE CONTEXTO

- Antes de qualquer refactor estrutural em arquivo >300 LOC: primeiro remover
  todos os props mortos, exports não usados, imports não usados, debug logs.
  Commitar cleanup separadamente.
- Para tarefas tocando >5 arquivos independentes: lançar sub-agentes em
  paralelo (5-8 arquivos por agente). Cada um ganha ~167K de context.
- Após 10+ mensagens: re-ler qualquer arquivo antes de editar. Auto-compaction
  pode ter destruído sua memória do conteúdo.
- Se notar degradação de contexto (variáveis inexistentes, esquecer estruturas):
  rodar /compact proativamente. Escrever session state para
  context-log.md para forks conseguirem continuar.
- Cada leitura de arquivo é limitada a 2.000 linhas. Arquivos >500 LOC: usar
  offset e limit para ler em chunks.
- Resultados >50K char são truncados para preview de 2KB. Se parecer
  pequeno demais: ler o arquivo completo.

---

## ✏️ SEGURANÇA DE EDIÇÃO

- Antes de toda edição: re-ler o arquivo. Depois de editar: ler novamente.
  Edit tool falha silenciosamente em old_string desatualizado.
-grep, não AST. Em qualquer rename ou mudança de assinatura, buscar
  separadamente por: chamadas diretas, referências de tipo, literais string,
  imports dinâmicos, require(), re-exports, barrel files, mocks de teste.
- Nunca deletar arquivo sem verificar se nada referencia ele.

---

## 🔄 AUTO-CORREÇÃO

- Após qualquer correção minha: logar o padrão em gotchas.md. Converter
  erros em regras. Revisar lições passadas no início da sessão.
- Se um fix não funcionar após duas tentativas: parar. Ler toda a seção
  relevante top-down. Declarar onde o modelo mental estava errado.
- Quando pedir para testar output próprio: adotar persona de novo usuário.
  Caminhar como se nunca tivesse visto o projeto.

---

## 📢 COMUNICAÇÃO

- Quando disser "yes", "do it", ou "push": executar. Não repetir o plano.
- Quando apontar código existente como referência: estudar, igualar os padrões.
- Trabalhar com dados crus de erro. Não chutar. Se bug report não tem output,
  pedir.

---

## 🔧 DIAGNÓSTICO RÁPIDO
```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
nvidia-smi --query-gpu=memory.used,memory.free --format=csv,noheader
zfs list -t filesystem,snapshot | grep tank
docker logs coolify --tail 30
journalctl -u cloudflared --tail 20 --no-pager
```

---

## 🌐 IDIOMA
Sempre responder em português BR, exceto quando o código/erro for em inglês.

---

## 🧠 MEMÓRIA PERSISTENTE (mcp-memory-keeper)

SQLite: `~/.mcp-data/memory-keeper/context.db` (~450KB, backup em `~/.claude/backups/`)

### Quando Salvar

| Categoria | Gatilho | Exemplo |
|-----------|---------|---------|
| `user` | Quando usuário informa preferências | "will prefere respostas curtas" |
| `feedback` | Quando usuário corrige ou confirma abordagem | "não usar mocks em testes de DB" |
| `project` | Decisões arquiteturais ou estado de projeto | "monorepo em /srv/monorepo" |
| `reference` | Ponteiros para sistemas externos | "bugs em Linear INGEST" |

### Comandos Principais

```bash
context_save       # Salvar fato/observação
context_search     # Busca por keyword
context_semantic_search  # Embeddings vetorial (local)
context_get        # Recuperar por key
context_checkpoint name="pre-mudanca-YYYYMMDD"  # Snapshot antes de mudanças grandes
context_restore_checkpoint name="..."  # Restaurar
```

### Regras

- Salvar feedback SEMPRE após correção do usuário
- Criar checkpoint antes de mudanças em produção (ZFS, Docker, Coolify)
- Após 10+ mensagens: verificar se memória precisa de update

### Arquivos

- Banco: `~/.mcp-data/memory-keeper/context.db`
- Checkpoints: `~/.mcp-data/memory-keeper/checkpoints/`
- Backups: `~/.claude/backups/` (backup-memory.sh)
