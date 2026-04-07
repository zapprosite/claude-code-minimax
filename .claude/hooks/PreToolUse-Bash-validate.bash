#!/bin/bash
# PreToolUse Hook: Bash Validation
# Protege contra comandos perigosos não cobertos por deny rules

COMMAND="$1"
TOOL_ARGS="$2"

# Extract the actual command from tool args
# Format varies, but we look for dangerous patterns

# Dangerous patterns NOT covered by deny rules
DANGEROUS_PATTERNS=(
  "mkfs"
  "dd if="
  "wipefs"
  "parted.*rm"
  "fdisk.*delete"
  "sfdisk"
  "lsblk.*rm"
  "umount.*--force"
)

# Allow patterns (whitelist)
ALLOW_PATTERNS=(
  "docker (ps|logs|inspect|compose|start|stop|restart)"
  "zfs (list|snapshot|clone|send|receive)"
  "curl.*(localhost|127\.0\.0\.1)"
  "git (status|log|diff|add|commit|push|pull|clone)"
  "nvidia-smi"
  "df -h"
  "free -h"
  "ls"
  "cat"
  "grep"
  "awk"
  "sed"
)

check_dangerous() {
  local cmd="$1"
  for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$cmd" | grep -qE "$pattern"; then
      return 1  # Blocked
    fi
  done
  return 0  # Allowed
}

check_allowed() {
  local cmd="$1"
  for pattern in "${ALLOW_PATTERNS[@]}"; do
    if echo "$cmd" | grep -qE "$pattern"; then
      return 0  # Allowed
    fi
  done
  return 1  # Not in whitelist
}

main() {
  # Only check Bash commands
  if [[ "$TOOL_ARGS" =~ ^Bash ]]; then
    if ! check_allowed "$TOOL_ARGS"; then
      echo "⚠️ PreToolUse Hook: Bash validation blocked"
      echo "Command may be dangerous: $TOOL_ARGS"
      echo "If intentional, use --dangerously-skip-permissions"
      return 1
    fi
  fi
  return 0
}

main "$@"
