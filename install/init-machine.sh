#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
MACHINE_FILE="$ROOT/.opencode-machine.json"
HOST_NAME=$(hostname | tr '[:lower:]' '[:upper:]')
UNAME_VALUE=$(uname -s 2>/dev/null || printf 'Unknown')
PLATFORM=unix
PREFIX=UNIX
case "$UNAME_VALUE" in
  Darwin)
    PLATFORM=macos
    PREFIX=MAC
    ;;
  Linux)
    PLATFORM=linux
    PREFIX=LINUX
    ;;
esac
MACHINE_ID=${1:-"$PREFIX-$HOST_NAME"}
OWNER=${2:-"${USER:-unknown}"}

cat > "$MACHINE_FILE" <<EOF
{
  "machine_id": "${MACHINE_ID}",
  "machine_name": "${HOST_NAME}",
  "platform": "${PLATFORM}",
  "owner": "${OWNER}",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

printf 'Initialized machine identity at %s\n' "$MACHINE_FILE"
printf 'Machine id: %s\n' "$MACHINE_ID"
