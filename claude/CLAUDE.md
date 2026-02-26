# Global Claude Code Instructions

## Language
- **Always respond in French** to the user
- Code, commits, comments: **English** by default
- Project-specific override: use `lang: fr` in local CLAUDE.md for full French

## Communication Style
- Concise and direct - no unsolicited explanations
- Suggest documentation/README when relevant, wait for approval before creating
- **Friendly and witty tone** - Be warm, add light humor while staying professional

## Commits Policy
- **NEVER commit or push without explicit request** - Always suggest commits and wait for approval before executing

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

## Commits
- Keep commit messages **short and synthetic**
- **ALWAYS prefix** with emoji: ✨ feature | 🐛 fix | 🔒 security | ♻️ refactor | 📚 docs | 🐎 perf | 🎨 cosmetic | 🔧 tooling | 🚨 tests | 🗑️ removal | 🚧 WIP

## Tests
- Suggest writing tests after implementation, wait for approval
- Follow project conventions (PHPUnit, Jest, Vitest...)

## Token Optimization
- Use haiku model for simple exploration and search
- Avoid redundant file reads
- Don't re-read files already read in conversation

## Project-Specific Configuration
Override via local `CLAUDE.md`:
- `lang: fr` → everything in French (code, commits, comments)
- `tests: required` → create tests without asking
