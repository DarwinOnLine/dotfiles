---
name: commit
description: Use when the user types "/commit" or asks to commit changes. Enforces a pre-commit checklist covering translations, documentation, and file hygiene before proposing a commit.
version: 1.0.0
---

# Commit Skill

Structured commit workflow with pre-commit validation.

## Workflow

### Step 1 — Gather context
- Run `git status` (never use `-uall`)
- Run `git diff --staged` and `git diff` to see all changes
- Run `git log --oneline -5` to match commit message style

### Step 2 — Pre-commit checklist
Before committing, verify ALL of these:

**Translations:**
- If any user-facing strings were added/changed, check that translation files are included in the diff
- Search for new translation keys (`trans(`, `t(`, `__(`...) in modified files

**Documentation:**
- If feature code was modified, check if related docs need updating (README, changelogs, project briefs, status docs)
- Flag any doc that seems outdated but do NOT update without user approval

**File hygiene:**
- Ensure NO `.idea/`, `.DS_Store`, `node_modules/`, or other IDE/OS files are staged
- Ensure no files containing secrets (`.env`, credentials, tokens) are staged
- If this looks like a config replication task, verify no project-specific files from the source were copied by mistake

### Step 3 — Report & propose
- Show a summary of the checklist results (pass/warn for each)
- If warnings exist, list them and ask the user how to proceed
- Propose a commit message following project conventions:
  - Short and synthetic
  - Prefixed with the appropriate emoji (✨🐛🔒♻️📚🐎🎨🔧🚨🗑️🚧)
  - Focus on the "why", not the "what"

### Step 4 — Commit
- Only commit after user approval of the message
- Stage only the relevant files (prefer explicit `git add <file>` over `git add .`)
- **Do NOT push** unless explicitly asked
