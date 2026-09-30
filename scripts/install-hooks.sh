#!/bin/sh
# Point git at .githooks so the pre-commit sync runs. Never overwrites an
# existing hook setup: if another hooks path or custom hooks exist, it prints
# how to add .githooks/pre-commit to them instead. All output goes to stderr
# so session-start hooks don't add it to the model's context.
set -eu

root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
current=$(git -C "$root" config --get core.hooksPath || true)

[ "$current" = .githooks ] && exit 0

if [ -n "$current" ]; then
  echo "core.hooksPath is already '$current'. To keep agent files in sync, call .githooks/pre-commit from your pre-commit hook." >&2
  exit 0
fi

hooks=$(git -C "$root" rev-parse --git-path hooks)
case $hooks in /*) ;; *) hooks="$root/$hooks" ;; esac
for f in "$hooks"/*; do
  case $f in *.sample) continue ;; esac
  if [ -f "$f" ]; then
    echo "Custom hooks found in $hooks. To keep agent files in sync, call .githooks/pre-commit from your pre-commit hook." >&2
    exit 0
  fi
done

git -C "$root" config core.hooksPath .githooks
echo "Enabled git hooks in .githooks" >&2
