---
name: ci-replicate
description: Use when the user types "/ci-replicate" or asks to replicate, copy, or set up CI/CD pipelines from a reference project to another project. Ensures relevance audit before copying any file.
version: 1.0.0
---

# CI Replicate Skill

Replicate CI/CD configuration from a reference project with relevance auditing.

## Workflow

### Step 1 — Identify source and target
- Ask for the reference project path (source) if not provided
- Confirm the target project (current working directory or specified path)
- Identify CI system in use (GitLab CI, GitHub Actions, etc.)

### Step 2 — Inventory source files
List ALL CI-related files in the reference project:
- Pipeline configs (`.gitlab-ci.yml`, `.github/workflows/`, etc.)
- Scripts referenced by the pipeline (`scripts/`, `ci/`, etc.)
- Docker files used in CI (`Dockerfile`, `docker-compose.ci.yml`, etc.)
- Quality tool configs (`.phpstan.neon`, `phpcs.xml`, `sonar-project.properties`, etc.)

### Step 3 — Relevance audit (MANDATORY)
For each file found, present a table:

| File | Verdict | Reason |
|------|---------|--------|
| `.gitlab-ci.yml` | NEEDED | Main pipeline config |
| `sonar-report.sh` | SKIP | Project-specific reporting script |
| `.idea/` | SKIP | IDE config, never copy |

**Rules:**
- **SKIP** any file that looks project-specific (custom scripts, reports, templates with hardcoded values)
- **SKIP** IDE files (`.idea/`, `.vscode/`), OS files (`.DS_Store`)
- **ASK** for anything ambiguous
- **NEEDED** only for genuinely reusable config

**Wait for user approval of the audit before proceeding.**

### Step 4 — Adapt and create
For each NEEDED file:
- Copy and **adapt** to the target project (project name, paths, specific settings)
- Do NOT blindly copy — review each value for target relevance
- Preserve any existing legacy config in the target (blocks marked with comments, historical settings)
- Flag hardcoded values that need manual adjustment

### Step 5 — Validate
- Lint pipeline files if possible (`yamllint`, `gitlab-ci-lint`, etc.)
- Check that all referenced scripts/Docker images exist or are created
- Show a summary of created/modified files
- Suggest a commit but do NOT commit without approval
