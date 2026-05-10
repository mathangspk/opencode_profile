#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
printf 'Bootstrapping opencode_profile from %s\n' "$ROOT"

for item in core workflows integrations agents projects install workspace scaffolds; do
  if [ ! -e "$ROOT/$item" ]; then
    printf 'Missing required path: %s\n' "$ROOT/$item" >&2
    exit 1
  fi
done

printf 'Structure check passed.\n'
printf 'Next steps:\n'
printf '1. Run ./install/verify.sh.\n'
printf '2. Run ./install/init-machine.sh.\n'
printf '3. Run ./install/start-session.sh --mode full.\n'
