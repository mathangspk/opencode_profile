#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
printf 'Bootstrapping opencode_profile from %s\n' "$ROOT"

for item in core workflows integrations agents projects install; do
  if [ ! -e "$ROOT/$item" ]; then
    printf 'Missing required path: %s\n' "$ROOT/$item" >&2
    exit 1
  fi
done

printf 'Structure check passed.\n'
printf 'Next steps:\n'
printf '1. Fill project profiles under projects/.\n'
printf '2. Update projects/registry/projects-index.md.\n'
printf '3. Run ./install/verify.sh.\n'
