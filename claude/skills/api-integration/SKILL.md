---
name: api-integration
description: Use when the user types "/api-integration" or asks to integrate, call, or consume an external/third-party API (intégration API, webhook, SDK, endpoint, appel HTTP). Enforces documentation verification, dry-run payload validation, and explicit inference flagging before any write operation.
version: 1.0.0
---

# API Integration Skill

Guardrails for integrating any external API. The failure mode this prevents:
building parsing or mutation logic on an *assumed* response shape, then sending
real writes against it.

## Workflow

### 1. Verify understanding first
If API documentation is provided (or fetchable), explicitly summarize before writing code:
- Response format for each relevant endpoint (exact structure, field names, nesting)
- Required field formats (prefixes, encoding, date formats, constraints)
- Authentication scheme and where the credential goes
- Known async behaviors, propagation delays, rate limits, pagination

Cite the doc for each point. **If you can't cite it, flag it as an inference.**
If no documentation is available at all, say so plainly and stop to ask how the
user wants to proceed — do not guess a contract.

### 2. Log raw responses first
When building logic on top of a response, log/display the **raw** response on the
first real call before writing any parsing. Show it to the user. Only then write
the mapping code.

### 3. Separate payload from send
For any write/mutation operation (POST/PUT/PATCH/DELETE), implement a `--dry-run`
flag (or equivalent) that prints the exact payload — headers redacted, body in full
— without sending. The user validates the payload before the first real call is
wired up. Never ship a write path whose first execution is against production.

### 4. Flag inferences explicitly
Maintain the distinction in every statement:
- "The doc says X" → state it as fact, with the reference
- "I'm assuming X based on common patterns" → flag it explicitly, every time

Never present an inference with the same confidence as a documented fact.

## Checklist before declaring done
- [ ] Endpoint contracts summarized and cited (or inferences flagged)
- [ ] Raw response shown to the user before parsing logic was written
- [ ] `--dry-run` exists for every mutation, and its payload was validated
- [ ] Credentials read from env/config — never hardcoded, never logged
- [ ] Error paths handled: non-2xx, timeout, malformed body, rate limit
