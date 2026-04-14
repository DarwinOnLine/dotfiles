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

## Commits Policy
- **NEVER commit or push without explicit request** - Always suggest commits and wait for approval before executing
- When asked to push, **DO push** — the rule is "never push without being asked", not "never push at all"
- When committing UI changes, verify translation files are included if any user-facing strings were added/changed

## Feature Development Workflow
Always follow this process when developing a feature:
1. **Plan** - Analyze and outline the implementation approach
2. **Develop** - Write the code
3. **Review** - Cross-review what was just developed (quality, edge cases, potential issues)
4. **Test instructions** - Explain to the user how to test the changes (if relevant)
5. **Suggest commit** - Propose the commit with appropriate message (never commit directly)

## Main Tech Stack
- Backend: PHP 8.x / Symfony
- Frontend: TypeScript with Angular or React
- Infrastructure: Docker, docker-compose
- Adapt style and conventions to detected framework

## Code Style
- Minimal comments unless complex logic
- Prefer editing existing files over full rewrites
- No over-engineering: no unrequested features, no premature abstractions
- **Before any UI/frontend change**, read existing neighboring components to match patterns (CSS classes, layout structure, conventions). Never guess — inspect first
- Before implementing a feature, **verify it exists in the PRD/requirements**. Do not invent phantom tasks from assumptions — ask if unclear
- **Before reviewing or commenting on code**, always read the full file and its related context (interfaces, services, parent classes, tests). Never review a diff in isolation

## External API Integrations

Before implementing any integration with an external API:

1. **Verify understanding first** — If API documentation is provided, explicitly summarize:
   - Response format for each relevant endpoint (exact structure, field names)
   - Required field formats (prefixes, encoding, constraints)
   - Known async behaviors or propagation delays
   Cite the doc for each point. If you can't cite it, flag it as an inference.

2. **Separate payload from send** — For write/mutation operations, always implement
   a `--dry-run` flag (or equivalent) that displays the exact payload without sending,
   before wiring up the actual call. The user validates the payload first.

3. **Flag inferences explicitly** — Distinguish:
   - "The doc says X" → state it as fact
   - "I'm assuming X based on common patterns" → flag it explicitly
   Never present an inference with the same confidence as a documented fact.

4. **Log raw responses first** — When building logic on top of an API response,
   log/display the raw response on the first real call before processing it.
   Don't build parsing logic on assumed response shapes.

## Documentation
- When modifying feature code, **check and update related docs** (project briefs, changelogs, status docs, README)
- Do not create new documentation files unless explicitly requested

## Configuration Replication
- When replicating config from a reference project (CI, Docker, etc.), **audit each file for relevance** before copying
- Never blindly copy project-specific files (scripts, reports, .idea). Ask before including anything ambiguous
- Preserve existing legacy config unless explicitly told to remove it

## Commits
- Keep commit messages **short and synthetic**
- **ALWAYS prefix** with emoji: ✨ feature | 🐛 fix | 🔒 security | ♻️ refactor | 📚 docs | 🐎 perf | 🎨 cosmetic | 🔧 tooling | 🚨 tests | 🗑️ removal | 🚧 WIP

## Code Quality Tools
- When editing PHP files, if `phpstan.neon` (or `.dist`) exists at project root, run PHPStan after your changes
- When editing TS/JS files, if `.eslintrc.*` or `eslint.config.*` exists, run ESLint after your changes
- If no linter/static analysis is configured on the project, **suggest installing one** (PHPStan for PHP, ESLint for TS/JS) — do not install without approval

## Tests
- Suggest writing tests after implementation, wait for approval
- Follow project conventions (PHPUnit, Jest, Vitest...)
- **A task is DONE only when both implementation AND tests pass** — never mark complete with failing tests or partial implementation

## Token Optimization
- Use haiku model for simple exploration and search
- Avoid redundant file reads
- Don't re-read files already read in conversation

## Project-Specific Configuration
Override via local `CLAUDE.md`:
- `lang: fr` → everything in French (code, commits, comments)
- `tests: required` → create tests without asking
