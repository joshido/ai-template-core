# AGENTS.md

This is the primary context file for this repository.

## Purpose

<!-- CUSTOMIZE: Replace this section with a description of your project. -->
This repo builds [describe your project]. Each component lives in its own folder.

## Core Principles

- Never assume — if uncertain, ask.
- If the user states something exists, treat it as fact and use the web to verify if needed.

---

## Workflow Rules

- No implementation starts without user approval of the plan.
- Once a plan is agreed on, proceed with all file additions and modifications without asking for further approval — this includes files inside `.ai/`.
- Deletions always require explicit user approval unless the user has stated otherwise for a specific task.
- Shell: Never use `cd` in shell commands; use absolute paths or the `dir_path` parameter.
- One task at a time. Each task is committed before the next begins.
- A task is **done** only when all four conditions are met:
  1. Tests exist (BDD, written by Tester)
  2. Implementation passes all tests (written by Developer)
  3. Reviewed with no issues or vulnerabilities (by Reviewer)
  4. Committed to the branch

---

## Per-Task Flow

```
User approves plan
       │
       ▼
  Orchestrator breaks plan into tasks
       │
       ▼
  Tester writes BDD tests (no implementation yet)
       │
       ▼
  Orchestrator reviews tests → rejects/requests changes if needed
       │
       ▼
  Developer implements until all tests pass
       │
       ▼
  Orchestrator reviews implementation → rejects/requests changes if needed
       │
       ▼
  Reviewer checks quality, correctness, security
       │
       ▼
  Orchestrator evaluates findings → applies valid ones, rejects noise
       │
       ▼
  All clear → Orchestrator commits
       │
       ▼
  Task marked done → next task begins
```

---

## Guard Rules

- If Tester output is weak or off-target, Orchestrator sends it back — not to Developer.
- If Developer output fails tests or deviates from plan, Orchestrator sends it back — not to Reviewer.
- If Reviewer raises a valid finding, Developer fixes it and the review reruns before commit.
- Orchestrator never commits unless tests pass and review is clean.

---

## Escalation
If an agent fails to produce acceptable output after **3 rounds** of feedback, the Orchestrator stops and escalates to the user with:
- What the task is
- What was attempted
- What keeps failing or being rejected
- A specific question or decision needed to unblock

Do not loop indefinitely. Escalate and wait.

---

## Branch Strategy

- Each feature gets its own branch: `feat/<feature-name>`
- Each bug fix gets its own branch: `fix/<short-description>`
- Never push directly to `main`
- A PR is created when a feature reaches a shippable milestone or is complete — not per task
- Branch naming uses kebab-case

---

## Plan Template

See `.ai/plan-template.md` for the required format when presenting a plan to the user.

---

## Commit Convention

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]
```

**Types:** `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`, `ci`

Examples:
- `feat(auth): add JWT validation`
- `fix(api): handle null response from upstream`
- `docs(readme): update setup instructions`
- `test(parser): add BDD scenarios for edge cases`
- `chore(deps): update dependencies`

---

## Model Assignments

When dispatching subagents, always pass the `model` parameter explicitly. Use the most cost-effective model for the task and escalate only if blocked.

| Role | Default Model | Upgrade Path |
|---|---|---|
| Tester | `haiku` | → `sonnet` if BDD scenarios are complex or failing review |
| Developer | `haiku` | → `sonnet` if BLOCKED after 3 attempts |
| Reviewer | `haiku` | → `sonnet` for deep security or architectural review |
| Orchestrator | `sonnet` | (Always Sonnet for coordination and planning) |

**Opus Escalation:** If a task remains blocked even after escalating to `sonnet`, the Orchestrator must ask the user for permission before using `opus` for a specific task.

---

## Agents

Agent definitions live in `.ai/agents/`. Each agent is loaded only when needed:

- `.ai/agents/orchestrator.md` — primary agent, plans and drives the workflow
- `.ai/agents/tester.md` — writes BDD tests before implementation
- `.ai/agents/developer.md` — implements tasks and makes tests pass
- `.ai/agents/reviewer.md` — reviews code quality, correctness, and security

The only plugin used is **GitHub** (Orchestrator only), for PR creation. All other capabilities use native tools.

Recorded mistakes and how to avoid them are in `.ai/lessons-learned.md`. Read it before starting any task.
