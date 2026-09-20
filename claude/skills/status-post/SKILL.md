---
name: status-post
description: Use when the user types "/status-post" or asks for their recurring stakeholder status update for a chat channel (point hebdo Slack, post de fin de semaine, message d'avancement, update pour la direction). Writes a non-technical progress post on a fixed template, with every figure re-measured from the repository.
version: 1.0.0
---

# Status Post Skill

Write the recurring progress post the user sends to stakeholders. It is **not** their personal
journal: the audience cannot read code, does not know the internal vocabulary, and is deciding
whether to keep trusting the plan.

Two failures to avoid, and the second is the expensive one: a post nobody understands, and a post
that reads better than reality.

## Step 0 — Load the local configuration

Read `~/.claude/status-post.local.md`. It is machine-local and NOT versioned, and it holds
everything this skill must not contain: the product name, the exact section template with its
wording, the audience, the milestones and their scopes, the vocabulary table that turns internal
names into plain language, the published links, and the commands that produce each figure.

If it is missing, ask for those and offer to create it. Never invent a milestone, a link or a
percentage, and never write project specifics into this skill.

## Step 0-bis — Rebuild the configuration when it is missing

The configuration is machine-local and deliberately unversioned, so it can be lost. Rebuilding it
is a normal task. **The template is recoverable from the posts themselves**, which is why the
first question is not a questionnaire.

1. **Ask the user to paste their two or three most recent posts.** One question, and it carries
   most of the answer. From them, derive and write down: the section order and the exact wording
   of each heading, the bullet character, the typographic conventions of the channel, the register,
   which figures appear and in what form, the invariant paragraph that must be repeated verbatim,
   and the published links.
2. **Derive the vocabulary table by pairing.** Match each plain-language phrase in the posts
   against the internal names in the repository. That pairing is the table, and it was written by
   the user, so it beats any translation you would invent. Ask about the leftovers.
3. **Ask which repositories back the figures**, then confirm each path yourself with `git log -1`.
4. **Find a command for every figure in the pasted posts, one by one.** Run it and compare against
   the figure in the most recent post. Three outcomes, and each is recorded in the configuration:
   it reproduces, so write the command down; it is close but not equal, so write down which
   definition you used and that it is not comparable to older posts; or nothing produces it, so
   record it as unsourced and **do not let it reappear** until the user supplies the rule.
5. **Ask who the audience is and what must never reach them.** This is invisible in a post: what
   is absent left no trace. Ask explicitly whether some categories of content are reserved for
   another channel, and record the rule with the example that motivated it.
6. **Check every process claim in the pasted posts against what is true now.** A sentence carried
   over for months is the most likely thing to have quietly become false. Flag each one rather
   than copying it into the template.
7. **Write the configuration, show it in full, and ask for corrections**, marking what you derived
   from the posts and what the user told you.

## Step 1 — Take what the user tells you as first-class material

Anything volunteered with the request (a push, a pause, a trade-off, a decision, a worry) is
primary material. A repository records what was done, never why it was chosen or what it cost.

- Give it the weight the user gave it, and place it where the template puts that kind of content.
- **Filter the register, not the fact.** What they say to you in private is not what they say to
  this channel: a private verdict, an internal nickname, a frustration. Keep the finding, drop the
  wording. When in doubt about whether something is for this audience, ask.
- A concern the user has not decided to share is not yours to publish. Ask before it goes in.

## Step 2 — Re-measure every figure, this session

Run the commands from the configuration. Do not copy a number from a tracking document, from the
previous post, or from anything written earlier in the conversation: those are snapshots, and a
snapshot is stale the moment a commit lands.

- **Every headline figure carries its previous value**, so the reader sees movement rather than a
  level: "58 of 110, against 47 a week ago".
- **Give the delta, never a falling percentage**, when a denominator can grow. A backlog that
  grows is normal; a percentage that drops because of it is a lie by arithmetic.
- **Do not average two different units of measure.** If the tracking distinguishes programme
  progress from whether started work is finished, they answer different questions.
- **If no command produces a figure, say so and leave it out.** An unsourced number in a
  stakeholder post survives for months and gets quoted back.
- **Distinguish "all sub-items delivered" from "closed".** Say the first if only the first is true.

## Step 3 — Translate, systematically

Nothing internal reaches this post: no epic or story identifier, no requirement code, no branch,
no file path, no framework name, no tool name. Use the configuration's vocabulary table, and where
a term is missing, write what the thing **lets someone do**.

- **Every item says why it matters**, not what it is. Prefer what was impossible before it.
- **Lead with the capability a reader can picture**, not with the item that took the most commits.
- **Name people as the reader knows them** when the configuration says to: a pilot customer with a
  name is concrete, "the pilot account" is not.
- **Keep the load-bearing invariant paragraph** the configuration defines, in full, every time.
  A guarantee restated every week is what makes it credible; a guarantee mentioned once is decor.

## Step 4 — Keep it honest, which is what makes it persuasive

- **Put the cost next to the gain.** A post with no trade-off in it reads as marketing.
- **State blockers explicitly, including "nothing is blocked"**, so the absence is information
  rather than an omission.
- **Name the real constraint**, even the unglamorous one. The constraint a team actually watches
  is more convincing than the one that sounds professional.
- **Any claim about process must be literally true.** If a check is automated, do not phrase it so
  a reader hears a human. Re-read each process sentence against what actually happened this week,
  and flag to the user any sentence carried over from a previous post that is no longer true.
- **Drop a section rather than pad it.** A week with no delivery in a category says so in a line.

## Step 5 — Match the channel, then hand it over

Follow the configuration's template order and wording exactly: the audience recognises the shape
week to week, and a reordered post reads as a different project.

Typographic conventions come from the **channel**, not from other documents the user writes: chat
posts and repository files may have opposite rules. The configuration states the channel's.

Output the post as plain text ready to paste, in one block, with no commentary inside it. Then,
outside the post, list the figures you measured with the command behind each, and any judgement
call the user should check before sending.

Never post it anywhere yourself unless explicitly asked.
