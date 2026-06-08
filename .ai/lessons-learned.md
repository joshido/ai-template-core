# Lessons Learned

Recorded mistakes and how to avoid them. Read this before starting any task.

---

<!-- Add entries here as you encounter and resolve issues. Use this format:

## N. Short title

**What happened:** Description of the mistake or unexpected behavior.

**Fix applied:** What was done to resolve it.

**How to avoid:** Rule or check to prevent recurrence.

---
-->

## 1. Pushed docs changes directly to main without a PR

**What happened:** Small documentation updates (AGENTS.md and README.md) were committed and pushed directly to `main` on both repos, bypassing branch protection and the PR requirement.

**Fix applied:** None — changes were already merged and user accepted the state.

**How to avoid:** All changes, including docs, must go through a feature branch and PR. No exceptions, regardless of how small the change is.

---
