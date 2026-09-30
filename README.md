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
| `.claude/settings.json` | Claude Code settings; its SessionStart hook runs `install-hooks.sh` |
| `.gemini/settings.json` | Gemini CLI settings; same SessionStart hook |
| `.github/hooks/install-hooks.json` | Copilot cloud agent and CLI sessionStart hook; runs `install-hooks.sh` |
| `scripts/sync-agent-files.sh` | Regenerates `CLAUDE.md`, `GEMINI.md` and the Gemini/Copilot agents |
| `.githooks/pre-commit` | Runs the sync script on every commit |
| `scripts/install-hooks.sh` | Enables `.githooks` without overwriting an existing hook setup |
| `.github/workflows/agent-files.yml` | CI check that all generated files are in sync |

## How to Use

1. Copy all files into the root of your new repository.
2. Enable the git hooks once per clone: `scripts/install-hooks.sh`. Claude Code, Gemini CLI, and Copilot's cloud agent and CLI run it at session start (Gemini asks you to trust the project hook the first time; Copilot's hook is bash-only, so on Windows run the script yourself). It never overwrites an existing `core.hooksPath` or custom hooks; if you have them, it tells you to call `.githooks/pre-commit` from your own pre-commit hook.
3. Replace the `<!-- CUSTOMIZE -->` section in `AGENTS.md` with a description of your project, then commit — `CLAUDE.md` and `GEMINI.md` are regenerated.
4. Add your permissions and preferences to `.claude/settings.json`.
5. Delete this README or replace it with your project README.

## Customization

- **Workflow** → edit `AGENTS.md` only. Run `scripts/sync-agent-files.sh` (or just commit) to update the copies.
- **Agent behavior** → edit the file in `.claude/agents/`, then commit. The Gemini and Copilot versions keep `name`, `description` and `tools` (mapped to each tool's names).
- **Models** → set per tool in each file in `.claude/agents/`:
  - `model:` — Claude Code alias (`opus`, `sonnet`, `haiku`), resolves to the latest release. To pin a version, set `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL` or `ANTHROPIC_DEFAULT_HAIKU_MODEL`.
  - `gemini-model:` — Gemini CLI alias (`pro`, `flash`, `flash-lite`) or a model ID; copied to the Gemini agent's `model`.
  - `copilot-model:` — a Copilot model name such as `Claude Sonnet 5 (copilot)`; copied to the Copilot agent's `model`. Copilot has no aliases, so update these when models change, and check that the model is available where you use it: [supported models](https://docs.github.com/en/copilot/reference/ai-models/supported-models).
  - Remove a line to use that tool's default model.

## AI Tool Support

| Tool | Reads |
|------|-------|
| Claude Code | `CLAUDE.md` + `.claude/agents/` |
| Gemini CLI | `GEMINI.md` + `.gemini/agents/` + `.gemini/settings.json` |
| GitHub Copilot | `AGENTS.md` + `.github/agents/` + `.github/hooks/` |
| OpenAI Codex | `AGENTS.md` |

## Workflow Overview

```
Plan approved → Tester → Developer → Reviewer → commit → next task → PR
```
