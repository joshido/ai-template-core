#!/bin/sh
# Generate tool-specific copies of the shared agent context:
#   AGENTS.md           -> CLAUDE.md, GEMINI.md
#   .claude/agents/*.md -> .gemini/agents/*.md, .github/agents/*.agent.md
# Usage: sync-agent-files.sh [--check | --staged]
#   --check   exit 1 if a generated file is missing, stale or out of date (for CI)
#   --staged  read sources from the index and stage the results (for the pre-commit hook)
set -eu

mode=${1:-}
root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
script=scripts/sync-agent-files.sh
out=$(mktemp -d)
trap 'rm -rf "$out"' EXIT

# Print a source file from the index (--staged) or the working tree.
src() {
  if [ "$mode" = --staged ]; then git -C "$root" show ":$1"; else cat "$root/$1"; fi
}

# List agent sources, relative to the repo root.
agent_sources() {
  if [ "$mode" = --staged ]; then
    git -C "$root" ls-files -- '.claude/agents/*.md'
  else
    for f in "$root"/.claude/agents/*.md; do
      [ -e "$f" ] && echo ".claude/agents/${f##*/}"
    done
  fi
}

# Convert a Claude Code subagent (stdin) to another tool's format.
# Keeps name, description and tools (mapped to the target's tool names).
# The model comes from gemini-model: or copilot-model: in the source; Claude's
# own model: is dropped. Without one, the target uses its default model.
convert_agent() { # $1 = gemini | copilot, $2 = source path
  awk -v fmt="$1" -v source="$2" -v script="$script" '
    function trim(s) { gsub(/^[ \t"]+|[ \t"]+$/, "", s); return s }
    BEGIN {
      if (fmt == "gemini") {
        map["Bash"] = "run_shell_command"; map["Read"] = "read_file"
        map["Write"] = "write_file"; map["Edit"] = "replace"
        map["Glob"] = "glob"; map["Grep"] = "grep_search"
        map["WebSearch"] = "google_web_search"; map["WebFetch"] = "web_fetch"
      } else {
        map["Bash"] = "execute"; map["Read"] = "read"
        map["Write"] = "edit"; map["Edit"] = "edit"
        map["Glob"] = "search"; map["Grep"] = "search"
        map["WebSearch"] = "web"; map["WebFetch"] = "web"
      }
    }
    fm < 2 && /^---[ \t]*$/ {
      if (++fm == 2) {
        print "---"
        for (i = 1; i <= n; i++) print keep[i]
        if (model != "") print "model: " model
        if (tools != "") {
          count = split(tools, list, ",")
          line = ""
          for (i = 1; i <= count; i++) {
            t = trim(list[i])
            if (!(t in map)) { printf "%s: no %s equivalent for tool %s, skipped\n", source, fmt, t > "/dev/stderr"; continue }
            if (seen[map[t]]++) continue
            if (fmt == "gemini") line = line "\n  - " map[t]
            else line = line (line == "" ? "" : ", ") "\"" map[t] "\""
          }
          if (fmt == "gemini") print "tools:" line
          else print "tools: [" line "]"
        }
        print "---"
        print ""
        print "<!-- Generated from " source " by " script ". Edit that file instead. -->"
      }
      next
    }
    fm == 1 {
      if ($0 ~ /^(name|description):/) keep[++n] = $0
      else if ($0 ~ /^tools:/) tools = substr($0, 7)
      else if ($0 ~ "^" fmt "-model:") { model = $0; sub(/^[a-z]+-model:[ \t]*/, "", model) }
      next
    }
    { print }
  '
}

# Build every generated file in $out.
for f in CLAUDE.md GEMINI.md; do
  {
    echo "<!-- Generated from AGENTS.md by $script. Edit AGENTS.md instead. -->"
    echo
    src AGENTS.md
  } > "$out/$f"
done

mkdir -p "$out/.gemini/agents" "$out/.github/agents"
for a in $(agent_sources); do
  name=${a##*/}
  src "$a" | convert_agent gemini "$a" > "$out/.gemini/agents/$name"
  src "$a" | convert_agent copilot "$a" > "$out/.github/agents/${name%.md}.agent.md"
done

status=0

# Write or check each generated file.
for f in $(cd "$out" && find . -type f | sed 's|^\./||' | sort); do
  cmp -s "$out/$f" "$root/$f" && continue
  if [ "$mode" = --check ]; then
    echo "$f is out of date. Run $script" >&2
    status=1
    continue
  fi
  mkdir -p "$(dirname "$root/$f")"
  cp "$out/$f" "$root/$f"
  echo "Updated $f"
  if [ "$mode" = --staged ]; then git -C "$root" add -- "$f"; fi
done

# Remove generated agents whose source is gone. Hand-written agents
# (without the "Generated from" marker) are left alone.
for f in "$root"/.gemini/agents/*.md "$root"/.github/agents/*.agent.md; do
  [ -e "$f" ] || continue
  rel=${f#"$root"/}
  [ -e "$out/$rel" ] && continue
  grep -q "^<!-- Generated from .* by $script" "$f" || continue
  if [ "$mode" = --check ]; then
    echo "$rel is stale (its source was removed). Run $script" >&2
    status=1
    continue
  fi
  rm "$f"
  echo "Removed $rel"
  if [ "$mode" = --staged ]; then git -C "$root" rm -q --cached --ignore-unmatch -- "$rel"; fi
done

exit $status
