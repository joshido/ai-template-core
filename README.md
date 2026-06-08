# AI Workflow Template

A project-agnostic four-agent AI development workflow for Claude Code, Gemini CLI, and GitHub Copilot.

## What's Included

| File | Purpose |
|------|---------|
| `AGENTS.md` | Single source of truth — workflow rules, agent definitions, conventions |
| `CLAUDE.md` | Claude Code entry point → reads AGENTS.md |
| `GEMINI.md` | Gemini CLI entry point → reads AGENTS.md |
| `.github/copilot-instructions.md` | GitHub Copilot entry point → reads AGENTS.md |
| `.ai/agents/` | Agent role definitions (orchestrator, tester, developer, reviewer) |
| `.ai/plan-template.md` | Required format for presenting implementation plans |
| `.ai/plugins.md` | GitHub plugin assignment (Orchestrator only) |
| `.ai/lessons-learned.md` | Running log of mistakes and how to avoid them |
| `.claude/settings.json` | Claude Code configuration (permissions, model, hooks) |

## How to Use

1. Copy all files from this folder into the root of your new repository.
2. Open `AGENTS.md` and replace the `<!-- CUSTOMIZE -->` section in **Purpose** with a description of your project.
3. Populate `.claude/settings.json` with your Claude Code permissions and preferences.
4. Delete this README or replace it with your project README.

## Customization

- **Workflow changes** → edit `AGENTS.md` only. The three tool entry files automatically inherit it.
- **Agent behavior** → edit the relevant file in `.ai/agents/`.
- **Mistakes log** → add entries to `.ai/lessons-learned.md` as you work.
- **Plugin assignments** → only GitHub is used (Orchestrator, for PR creation). Edit `.ai/plugins.md` if needed.

## Workflow Overview

```
User approves plan
       ↓
Orchestrator breaks into tasks
       ↓
Tester writes BDD tests
       ↓
Developer implements until tests pass
       ↓
Reviewer checks quality + security
       ↓
Orchestrator commits → next task
```

All workflow updates belong in `AGENTS.md`.
