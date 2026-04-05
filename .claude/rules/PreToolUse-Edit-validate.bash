#!/bin/bash
# PreToolUse Hook: Edit Validation
# Confirma que edit não vai destruir arquivo protegido

FILE_PATH="$1"
TOOL_ARGS="$2"

# Protected files (from CLAUDE.md)
PROTECTED_FILES=(
  "/home/will/.bashrc"
  "/home/will/.claude/.secrets"
  "/home/will/.claude/settings.json"
  "/home/will/.claude/CLAUDE.md"
  "/home/will/.claude/backups/"
)

# Allow patterns for Edit
ALLOW_PATTERNS=(
  "\.md\$"
  "\.py\$"
  "\.js\$"
  "\.ts\$"
  "\.tsx\$"
  "\.json\$"
  "\.yaml\$"
  "\.yml\$"
  "\.sh\$"
  "\.txt\$"
  "/srv/monorepo/"
  "/srv/data/"
)

check_protected() {
  local file="$1"
  for protected in "${PROTECTED_FILES[@]}"; do
    if [[ "$file" == *"$protected"* ]]; then
      return 1  # Blocked
    fi
  done
  return 0  # Not protected
}

check_allowed() {
  local file="$1"
  for pattern in "${ALLOW_PATTERNS[@]}"; do
    if [[ "$file" =~ $pattern ]]; then
      return 0  # Allowed
    fi
  done
  return 1  # Not in whitelist
}

main() {
  # Only check Edit tool
  if [[ "$TOOL_ARGS" =~ ^Edit ]]; then
    if check_protected "$FILE_PATH"; then
      if ! check_allowed "$FILE_PATH"; then
        echo "⚠️ PreToolUse Hook: Edit validation blocked"
        echo "File not in allowed patterns: $FILE_PATH"
        echo "Protected files cannot be edited."
        return 1
      fi
    else
      echo "⚠️ PreToolUse Hook: Protected file detected"
      echo "File is protected: $FILE_PATH"
      echo "Use chattr -i to temporarily remove immutable flag"
      return 1
    fi
  fi
  return 0
}

main "$@"
