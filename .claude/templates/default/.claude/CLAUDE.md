# CLAUDE.md — <project name>

## Regras do Projeto

### Padrão de Código
- TypeScript: prefer `interface` over `type` for object shapes
- Python: PEP 8, type hints obrigatórios
- Error handling: sempre com tratamento específico, nunca `except: pass`

### Estrutura
```
src/
├── api/          # Endpoints
├── core/         # Lógica de negócio
├── services/     # Integrações externas
└── utils/        # Helpers
```

### Workflows
- Build: `bun run build`
- Test: `bun test`
- Deploy: `./scripts/deploy.sh`

## Configurações

### Variáveis de Ambiente
| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `DATABASE_URL` | Connection string do DB | `postgresql://...` |
| `API_KEY` | Chave da API | Usar vault |

### Health Endpoints
- `/health` — health check básico
- `/health/ready` — readiness probe
- `/health/live` — liveness probe

## Histórico

| Data | Mudança | Autor |
|------|---------|-------|
