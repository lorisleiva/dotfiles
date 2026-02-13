---
description: Create or update a PR.md file with a short PR description
argument-hint: "[path]"
---

# Generate PR Description

Create a `PR.md` file summarizing the changes for use as a pull request description.

## Arguments

- `$1` (optional): Path where the `PR.md` file should be created. Defaults to the repository root.

## Process

1. **Determine the scope of changes.** This project often uses Graphite for PR stacking, where each branch/PR corresponds to a single commit. Use the following heuristic:
   - Check `git status` for uncommitted working tree changes.
   - If the working changes are substantial (i.e. they look like they form a coherent PR on their own), use those as the basis for the description — this likely means a new PR is being drafted before `gt create`.
   - If the working changes are minor or empty, use the **latest single commit** on the current branch. Do NOT diff all commits back to `main` — in a stacked PR workflow, each branch typically has one commit representing one PR.
2. **Analyze the changes.** Read the diff carefully and check any related changeset files for additional context.
3. **Write the `PR.md` file** at the specified path (or repo root) following the guidelines below.

## Guidelines

- Start with "This PR..." and explain the changes in a few sentences.
- Keep it concise and focused on what matters to a reviewer.
- Don't get creative with headers — use them sparingly and only when the PR has clearly distinct sections.
- When it helps illustrate the change, include short code examples showing before/after usage (using `diff` blocks or plain code blocks as appropriate).
- Don't repeat the full changeset content — the PR description should complement it, not duplicate it.
