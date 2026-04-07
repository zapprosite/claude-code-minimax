#!/bin/bash
# Stop Hook: Modo Dormir
# Dispara modo dormir quando usuário digita /voudormir ou encerra sessão

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
SESSION_DIR="$HOME/.claude/pipelines"

# Verificar se modo dormir foi solicitado
# O hook Stop sempre roda, então verificamos via flag ou pattern no input

# Se o último input continha "voudormir" ou "modo dormir" ou "dormir"
LAST_INPUT="${CLAUDE_LAST_USER_INPUT:-}"

if echo "$LAST_INPUT" | grep -qiE "voudormir|modo dormir|dormir|zzz|sleep"; then
  echo "🌙 Modo Dormir detectado — iniciando scan..."

  # Obter repo atual
  REPO="${PWD:-$(pwd)}"

  # Criar log
  LOG_FILE="$SESSION_DIR/modo-dormir-$(date +%Y%m%d-%H%M%S).log"
  mkdir -p "$SESSION_DIR"

  {
    echo "=== Modo Dormir Log ==="
    echo "Timestamp: $TIMESTAMP"
    echo "Repo: $REPO"
    echo "User: ${USER:-will}"
    echo ""
    echo "=== Iniciando Scan ==="
  } > "$LOG_FILE"

  # Disparar agent modo-dormir em background
  # Usa nohup para não morrer com a sessão
  nohup claude --agent modo-dormir "scan $REPO" \
    >> "$LOG_FILE" 2>&1 &

  AGENT_PID=$!
  echo "Agent PID: $AGENT_PID" >> "$LOG_FILE"

  echo ""
  echo "🌙 Zzz... modo dormir ativado"
  echo "   Repo: $REPO"
  echo "   Log: $LOG_FILE"
  echo "   PID: $AGENT_PID"
  echo ""
  echo "Quando acordar, check: $SESSION_DIR/"

  # Salvar PID para tracking
  echo "$AGENT_PID" > "$SESSION_DIR/modo-dormir.pid"

else
  # Hook Stop normal — salvar session log apenas
  {
    echo "=== Session Log ==="
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Repo: ${PWD:-$(pwd)}"
  } > "$SESSION_DIR/session-$(date +%Y%m%d-%H%M%S).log"
fi
