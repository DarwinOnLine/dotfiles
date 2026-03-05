---
name: ui-prepare
description: Use when the user types "/ui-prepare" or before starting any significant UI/frontend task. Catalogs existing UI patterns in the project to ensure consistency before writing new code.
version: 1.0.0
---

# UI Prepare Skill

Extract and catalog existing UI patterns before any frontend implementation.

## Workflow

### Step 1 — Identify similar features
- Ask the user which feature/component they want to build (if not already clear)
- Find 2-3 existing components that are most similar in purpose or structure
- If unsure, ask the user which component to use as reference

### Step 2 — Extract patterns
For each reference component, read the full source and document:

**Structure:**
- File organization (component, template, styles, tests)
- Component hierarchy and composition patterns

**Markup & styling:**
- CSS framework used (Tailwind, Bootstrap, custom...)
- Class naming conventions (BEM, utility-first, etc.)
- Layout patterns (grid, flex, specific wrappers)
- Responsive breakpoints if applicable

**Logic:**
- Data binding / state management patterns
- Event handling conventions
- Service injection / API call patterns
- Form handling and validation approach
- Translation key format and usage

### Step 3 — Present pattern summary
Show a concise summary grouped by category:

```
## Patterns found in [ComponentA, ComponentB]

**Layout:** Bootstrap grid, .card wrapper, .table-responsive for tables
**CSS classes:** .btn-primary for actions, .text-muted for secondary info
**Data:** Service injection via constructor, Observable pattern with async pipe
**Translations:** `module.entity.field` format, stored in messages.fr.xlf
**Forms:** Reactive forms, validators in dedicated file
```

### Step 4 — Confirm before coding
- Ask the user to validate the patterns before proceeding
- Flag any inconsistencies between reference components
- Only start implementation after confirmation
