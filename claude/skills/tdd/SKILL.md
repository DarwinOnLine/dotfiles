---
name: tdd
description: Use when the user types "/tdd" or asks to work in TDD, fix a bug with tests, or develop a feature test-first. Enforces a strict red-green-refactor cycle with automatic validation.
version: 1.0.0
---

# TDD Skill

Test-driven development workflow for both bug fixing and feature development.

## Detect project test setup
- Identify the test framework: PHPUnit, Jest, Vitest, etc.
- Locate existing test files for patterns (directory structure, naming, base classes, fixtures)
- Identify how to run tests (`php bin/phpunit`, `npm test`, `npx vitest`, etc.)
- Check for static analysis tools (PHPStan, ESLint)

## Mode A — Bug Fix

Use when the user describes a bug to fix.

### Step 1 — Understand
- Read the relevant source code and understand the current behavior
- Identify the root cause before writing anything

### Step 2 — Red (write failing test)
- Write a test that precisely reproduces the reported bug
- Run the test to confirm it **fails for the right reason**
- If the test passes, your understanding is wrong — re-read the code and adjust

### Step 3 — Green (fix)
- Implement the **minimal fix** to make the test pass
- Run the full test suite (not just the new test) after every edit
- Max 5 iterations — if stuck after 5, stop and explain the blocker to the user

### Step 4 — Validate
- All tests pass (new + existing)
- Run static analysis if available
- Show: the failing test, the fix diff, and green test output

## Mode B — Feature Development

Use when the user wants to develop a new feature test-first.

### Step 1 — Plan test cases
- Based on the feature requirements, list the test cases to cover:
  - Happy path(s)
  - Edge cases
  - Error cases / validation
- Present the test plan to the user for approval before writing any code

### Step 2 — Iterative red-green cycle
For each test case, in order:
1. **Red** — Write the test, run it, confirm it fails
2. **Green** — Write the minimal production code to make it pass
3. **Run full suite** — Ensure nothing else broke
4. Move to the next test case

### Step 3 — Refactor (optional)
- Once all tests are green, review the production code for cleanup opportunities
- Only refactor if there's clear duplication or poor structure
- Re-run full suite after any refactor

### Step 4 — Validate
- Full test suite green
- Static analysis clean
- Show summary: number of tests added, files created/modified

## Rules
- **Never skip the red step** — always verify the test fails before fixing
- **Never mark as done if tests are failing**
- **Run the full suite**, not just the new test, after every change
- Follow existing test conventions in the project (naming, structure, base classes)
- If fixtures/factories exist in the project, use them instead of creating raw test data
