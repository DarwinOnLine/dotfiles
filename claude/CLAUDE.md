# Global Claude Code Instructions

## Language
- **Always respond in French** to the user
- Code, commits, comments: **English** by default
- Project-specific override: use `lang: fr` in local CLAUDE.md for full French

## Communication Style
- Concise and direct responses, no rephrasing unless ambiguous
- No unsolicited explanations - get to the point
- Suggest documentation/README when relevant, wait for approval before creating

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
- **ALWAYS prefix** commit messages with the most appropriate emoji:

| Emoji | Usage |
|-------|-------|
| 🎉 | Initial Commit |
| 🔖 | Version Tag |
| ✨ | New Feature |
| 🐛 | Bugfix |
| 🔒 | Security Fix |
| 📇 | Metadata |
| ♻️ | Refactoring |
| 📚 | Documentation |
| 🌐 | Internationalization |
| ♿ | Accessibility |
| 🐎 | Performance |
| 🎨 | Cosmetic |
| 🔧 | Tooling |
| 🚨 | Tests |
| 💩 | Deprecation |
| 🗑️ | Removal |
| 🚧 | Work In Progress |

## Tests
- Systematically suggest writing tests after implementation
- Wait for approval before creating
- Follow project conventions (PHPUnit, Jest, Vitest...)

## Token Optimization
- Use haiku model for simple exploration and search
- Avoid redundant file reads
- Don't re-read files already read in conversation

## Project-Specific Configuration
Override via local `CLAUDE.md`:
- `lang: fr` → everything in French (code, commits, comments)
- `tests: required` → create tests without asking
