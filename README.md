# AI Workflow Template (Core — Plugin-Free)

A project-agnostic four-agent AI development workflow for Claude Code, Gemini CLI, GitHub Copilot and OpenAI Codex. This is the **plugin-free variant**: only the GitHub plugin is used (for PR creation); everything else uses native tools.

> **Full plugin version** (Superpowers, Context7, Code Review, and more): [joshido/ai-template](https://github.com/joshido/ai-template)

## What's Included

| File | Purpose |
|------|---------|
| `AGENTS.md` | Single source of truth — workflow, Orchestrator role, conventions |
| `CLAUDE.md`, `GEMINI.md` | Generated copies of `AGENTS.md` — never edit by hand |
| `.claude/agents/` | Subagents: tester, developer, reviewer, tool-caller |
| `.gemini/agents/`, `.github/agents/` | Generated Gemini CLI and Copilot versions of the subagents — never edit by hand |
| `.ai/plan-template.md` | Required format for presenting implementation plans |
| `.ai/lessons-learned.md` | Short log of mistakes and how to avoid them |
| `.ai/session-notes.md` | Orchestrator notes for the current feature (created on first use) |
| `.claude/settings.json` | Claude Code settings; its SessionStart hook turns on the git hooks |
| `scripts/sync-agent-files.sh` | Regenerates `CLAUDE.md`, `GEMINI.md` and the Gemini/Copilot agents |
| `.githooks/pre-commit` | Runs the sync script on every commit |
| `.github/workflows/agent-files.yml` | CI check that all generated files are in sync |

## How to Use

1. Copy all files into the root of your new repository.
2. Enable the git hooks once per clone: `git config core.hooksPath .githooks`. Claude Code does this automatically at session start.
3. Replace the `<!-- CUSTOMIZE -->` section in `AGENTS.md` with a description of your project, then commit — `CLAUDE.md` and `GEMINI.md` are regenerated.
4. Add your permissions and preferences to `.claude/settings.json`.
5. Delete this README or replace it with your project README.

## Customization

- **Workflow** → edit `AGENTS.md` only. Run `scripts/sync-agent-files.sh` (or just commit) to update the copies.
- **Agent behavior** → edit the file in `.claude/agents/`, then commit. The Gemini and Copilot versions keep `name`, `description` and `tools` (mapped to each tool's names) and use each tool's default model.
- **Models** → agents use aliases (`opus`, `sonnet`, `haiku`) that resolve to the latest release. To pin a version, set `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL` or `ANTHROPIC_DEFAULT_HAIKU_MODEL` in your environment.

## AI Tool Support

| Tool | Reads |
|------|-------|
| Claude Code | `CLAUDE.md` + `.claude/agents/` |
| Gemini CLI | `GEMINI.md` + `.gemini/agents/` |
| GitHub Copilot | `AGENTS.md` + `.github/agents/` |
| OpenAI Codex | `AGENTS.md` |

## Workflow Overview

```
Plan approved → Tester → Developer → Reviewer → commit → next task → PR
```
