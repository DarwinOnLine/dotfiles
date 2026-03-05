---
name: review
description: Use when the user types "/review" or asks to review code, a PR, or recent changes. Performs a deep code review by reading surrounding context before providing feedback.
version: 1.0.0
---

# Review Skill

Deep code review with mandatory context reading.

## Workflow

### Step 1 — Identify scope
- If no specific files are mentioned, review the current diff (`git diff` + `git diff --staged`)
- If a PR number or branch is given, use `git diff main...HEAD` or equivalent
- List all modified files

### Step 2 — Read context (MANDATORY)
Before reviewing ANY file, read:
- The full file being reviewed (not just the diff)
- Related files: interfaces, parent classes, services used, tests
- Neighboring components if UI changes are involved (to verify pattern consistency)

**Never review a diff in isolation. Always understand the surrounding architecture first.**

### Step 3 — Review checklist
For each modified file, check:

**Correctness:**
- Logic errors, off-by-one, null/undefined handling
- Edge cases not covered
- Type safety issues

**Patterns & conventions:**
- Does the code follow existing project patterns?
- Are naming conventions respected?
- Is the code consistent with neighboring files?

**Security:**
- SQL injection, XSS, command injection (OWASP top 10)
- Secrets or credentials exposed
- Input validation at system boundaries

**Quality:**
- No over-engineering or premature abstractions
- No dead code or commented-out blocks left behind
- No missing error handling at external boundaries (APIs, user input)

### Step 4 — Report
Present findings grouped by severity:
1. **Bloquant** — Must fix before merge (bugs, security, broken logic)
2. **Important** — Should fix (pattern violations, missing edge cases)
3. **Suggestion** — Nice to have (style, minor improvements)

If everything looks good, say so concisely. Don't invent issues to seem thorough.
