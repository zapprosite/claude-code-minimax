#!/bin/bash
# Stop Hook: Session Log
# Salva contexto da sessão antes de fechar

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
SESSION_DIR="$HOME/.claude/sessions"

# Create session directory if not exists
mkdir -p "$SESSION_DIR"

# Session file
SESSION_FILE="$SESSION_DIR/session-$(date '+%Y%m%d-%H%M%S').log"

# Collect basic session info
{
  echo "=== Claude Code Session Log ==="
  echo "Timestamp: $TIMESTAMP"
  echo "Host: will-zappro"
  echo ""
  echo "--- Working Directory ---"
  pwd
  echo ""
  echo "--- Recent Git Activity ---"
  git status --short 2>/dev/null || echo "Not a git repo"
  echo ""
  echo "--- Docker Services ---"
  docker ps --format "table {{.Names}}\t{{.Status}}" 2>/dev/null || echo "Docker not available"
  echo ""
  echo "--- ZFS Snapshots (Today) ---"
  zfs list -t snapshot 2>/dev/null | grep "$(date +%Y%m%d)" | head -5 || echo "No ZFS snapshots today"
  echo ""
  echo "--- Memory Status ---"
  mcp__memory-keeper__context_status 2>/dev/null || echo "memory-keeper not available"
  echo ""
  echo "=== End Log ==="
} > "$SESSION_FILE"

# Keep only last 50 session logs
ls -t "$SESSION_DIR"/session-*.log 2>/dev/null | tail -n +51 | xargs rm -f 2>/dev/null

echo "Session log saved: $SESSION_FILE"
