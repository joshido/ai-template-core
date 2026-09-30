#!/bin/sh
# Fail if the given commits include unsquashed fixup!/squash!/amend! commits.
# Usage: check-no-fixups.sh <git log revision args>, e.g. origin/main..HEAD
set -eu

root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
# Run git on its own so a bad range or repo fails the check instead of passing.
log=$(git -C "$root" log --format='%h %s' "$@")
found=$(printf '%s\n' "$log" | grep -E '^[0-9a-f]+ (fixup|squash|amend)! ' || true)
[ -z "$found" ] && exit 0

echo "Unsquashed fixup commits:" >&2
echo "$found" | sed 's/^/  /' >&2
echo "Fold them into the commits they fix, then push again:" >&2
echo "  GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash origin/main" >&2
exit 1
