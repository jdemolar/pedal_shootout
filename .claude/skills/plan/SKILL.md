---
name: plan
description: Start the plan-first workflow — explore the codebase, write a plan doc to docs/plans/, create a plan branch, commit, push, and open a PR for review before any implementation begins. Use when starting any non-trivial feature or change.
disable-model-invocation: true
allowed-tools: Read, Write, Glob, Grep, Bash
---

Start the plan-first workflow for: $ARGUMENTS

## Current State
- Current branch: !`git branch --show-current`
- Existing plans: !`ls docs/plans/*.md 2>/dev/null | xargs -I{} basename {} | sort || echo "(none)"`
- todo.md (top 60 lines): !`head -60 docs/plans/todo.md 2>/dev/null || echo "(not found)"`

---

## Steps

### 1. Derive names

From the description in $ARGUMENTS, derive:
- A kebab-case **branch name**: `<short-feature-description>-plan` (e.g., `audio-view-plan`)
- A kebab-case **plan filename**: `docs/plans/<short-feature-description>.md` (e.g., `docs/plans/audio-view.md`)

If the branch already exists locally or remotely, append `-v2` (or next available suffix).

### 2. Confirm starting point

If the current branch is not `main`, warn the user that you're branching from a non-main branch, and confirm before proceeding.

### 3. Create the plan branch

```bash
git checkout -b <branch-name>
```

### 4. Explore the codebase

Before writing, gather the context needed to write a concrete plan:
- Read files directly relevant to the feature (similar components, types, utilities, context)
- Check existing patterns (how comparable features are structured)
- Note what Phase 1 / prior work already provides, if applicable

### 5. Write the plan document

Write `docs/plans/<filename>.md`. The plan should be specific enough that a developer could implement it without asking follow-up questions. Include:

- **Context** — what already exists, what this builds on, any prior phases
- **Goals** — what this work achieves and how users will interact with it
- **Files to create** — table with file path and purpose
- **Files to modify** — table with file path and the specific change
- **Step-by-step implementation** — numbered steps with interface/type definitions and key code snippets inline
- **Verification** — test commands to run + manual checks to confirm it works

### 6. Commit, push, and open the PR

```bash
git add docs/plans/<filename>.md
git commit -m "Plan: <short description>

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
git push -u origin <branch-name>
gh pr create \
  --title "Plan: <short description>" \
  --body "<summary of what the plan covers and why>\n\nThis is a plan-only PR for review before implementation begins."
```

### 7. Report back

Output the PR URL and a one-paragraph summary of what the plan covers. Note that once the PR is approved and merged, the next step is to create a **separate implementation branch** and open a separate implementation PR that:
- Moves `docs/plans/<filename>.md` → `docs/plans/completed/<filename>.md`
- Checks off the relevant items in `docs/plans/todo.md`
- Contains all the implementation code
