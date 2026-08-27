# Global Claude Code Instructions

## Language
- **Always respond in French** to the user
- Code, commits, comments: **English** by default
- Project-specific override: use `lang: fr` in local CLAUDE.md for full French

## Communication Style
- Concise and direct - no unsolicited explanations
- Suggest documentation/README when relevant, wait for approval before creating
- **Friendly and witty tone** - Be warm, add light humor while staying professional
- **NEVER give time estimates** — no predictions on how long tasks will take, neither for your work nor for user planning

## Feature Development Workflow
Always follow this process when developing a feature:
1. **Plan** - Analyze and outline the implementation approach
2. **Develop** - Write the code
3. **Review** - Cross-review what was just developed (quality, edge cases, potential issues)
4. **Test instructions** - Explain to the user how to test the changes (if relevant)
5. **Suggest commit** - Propose the commit with appropriate message (never commit directly)

## Main Tech Stack
- Backend: PHP 8.x / Symfony, or PHP 8.3+ / Laravel 12+
- Frontend: TypeScript with Angular or React, or Livewire + Flux UI + Tailwind (Laravel projects)
- Testing: PHPUnit, Pest, Jest, Vitest, Cypress
- Infrastructure: Docker, docker-compose, Sail
- **Detect the framework before writing code** — read `composer.json` / `package.json` for the installed majors. Symfony and Laravel conventions do not mix; neither do Angular and Livewire
- If a project ships a Laravel Boost block in its `CLAUDE.md`, it is authoritative for that project
- Adapt style and conventions to detected framework

## Code Style
- Minimal comments unless complex logic
- Prefer editing existing files over full rewrites
- No over-engineering: no unrequested features, no premature abstractions
- **Before any UI/frontend change**, read existing neighboring components to match patterns (CSS classes, layout structure, conventions). Never guess — inspect first
- Before implementing a feature, **verify it exists in the PRD/requirements**. Do not invent phantom tasks from assumptions — ask if unclear
- **Before reviewing or commenting on code**, always read the full file and its related context (interfaces, services, parent classes, tests). Never review a diff in isolation

## Commits
- **NEVER commit or push without explicit request** — suggest and wait for approval
- When asked to push, **DO push** — the rule is "never push without being asked", not "never push at all"
- Keep messages **short and synthetic**, **ALWAYS prefixed** with emoji: ✨ feature | 🐛 fix | 🔒 security | ♻️ refactor | 📚 docs | 🐎 perf | 🎨 cosmetic | 🔧 tooling | 🚨 tests | 🗑️ removal | 🚧 WIP
- Verify translation files are included when user-facing strings changed

## Tests
- Suggest writing tests after implementation, wait for approval
- Follow project conventions (PHPUnit, Pest, Jest, Vitest, Cypress...) — detect which is installed, do not assume
- **A task is DONE only when both implementation AND tests pass** — never mark complete with failing tests or partial implementation

## Code Quality
- PHPStan / Pint / ESLint run automatically via the `PostToolUse` hook on `Edit`/`Write`. Do not run them by hand — **except** when the file was modified through the shell (`sed`, heredoc), which bypasses the hook: then run the project's configured tools yourself
- If no linter/static analysis is configured, **suggest installing one** (PHPStan or Pint for PHP, ESLint for TS/JS) — never install without approval

## Documentation
- When modifying feature code, **check and update related docs** (project briefs, changelogs, status docs, README)
- Do not create new documentation files unless explicitly requested

## Command Output
- Prefer quiet flags to keep output out of context: `vitest run <file> --reporter=dot`, `phpunit --no-output` (or `--testdox` on failures only), `npm ci --silent`, `git --no-pager`
- Delegate noisy jobs (log analysis, wide greps, full test suites) to a subagent — its output stays out of this conversation

## Compact instructions
When compacting, always preserve:
- The detected framework/stack and versions of the current project
- Files already read and their relevant content, the current task and remaining steps
- Architecture decisions validated by the user, and any rejected approach (so it is not retried)
- Pending test/lint failures
Drop: raw command output, exploration dead-ends, full file dumps already summarized.

## Project-Specific Configuration
Override via local `CLAUDE.md`:
- `lang: fr` → everything in French (code, commits, comments)
- `tests: required` → create tests without asking

@RTK.md
