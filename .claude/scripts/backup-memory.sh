#!/bin/bash
# backup-memory.sh — Backup mcp-memory-keeper SQLite database
#
# Usage: ./backup-memory.sh
# Cron: 0 2 * * * /home/will/.claude/scripts/backup-memory.sh
#
# Keeps last 7 backups locally
# Verifies integrity with PRAGMA integrity_check

BACKUP_DIR="/home/will/.mcp-data/memory-keeper/backups"
DB_PATH="/home/will/.mcp-data/memory-keeper/context.db"
MAX_BACKUPS=7

set -e

# Create backup dir if needed
mkdir -p "$BACKUP_DIR"

# Timestamp
DATE=$(date +%Y%m%d-%H%M%S)
HOSTNAME=$(hostname)
BACKUP_FILE="${BACKUP_DIR}/context-${HOSTNAME}-${DATE}.db"

# Copy database
cp "$DB_PATH" "$BACKUP_FILE"

# Verify integrity
if ! sqlite3 "$BACKUP_FILE" "PRAGMA integrity_check;" | grep -q "ok"; then
    echo "[backup-memory] ERROR: Integrity check failed for $BACKUP_FILE" >&2
    rm -f "$BACKUP_FILE"
    exit 1
fi

echo "[backup-memory] Backup created: $BACKUP_FILE ($(du -h $BACKUP_FILE | cut -f1))"

# Prune old backups (keep last MAX_BACKUPS)
cd "$BACKUP_DIR"
ls -t | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm --

# Report status
BACKUP_COUNT=$(ls -1 *.db 2>/dev/null | wc -l)
echo "[backup-memory] Backups on disk: $BACKUP_COUNT (max: $MAX_BACKUPS)"
