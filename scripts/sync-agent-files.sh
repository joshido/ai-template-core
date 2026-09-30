#!/bin/sh
# Generate CLAUDE.md and GEMINI.md as copies of AGENTS.md.
# Usage: sync-agent-files.sh [--check | --staged]
#   --check   exit 1 if a generated file is out of date (for CI)
#   --staged  copy from the staged AGENTS.md (for the pre-commit hook)
set -eu

mode=${1:-}
root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
header='<!-- Generated from AGENTS.md by scripts/sync-agent-files.sh. Edit AGENTS.md instead. -->'

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
{
  printf '%s\n\n' "$header"
  if [ "$mode" = --staged ]; then
    git -C "$root" show :AGENTS.md
  else
    cat "$root/AGENTS.md"
  fi
} > "$tmp"

status=0
for f in CLAUDE.md GEMINI.md; do
  cmp -s "$tmp" "$root/$f" && continue
  if [ "$mode" = --check ]; then
    echo "$f is out of date. Run scripts/sync-agent-files.sh" >&2
    status=1
  else
    cp "$tmp" "$root/$f"
    echo "Updated $f from AGENTS.md"
  fi
done
exit $status
