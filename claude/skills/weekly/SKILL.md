---
name: weekly
description: Use when the user types "/weekly" or asks to write, generate, or update their weekly journal entry (weekly, point hebdo, journal de la semaine, bilan de la semaine). Reconstructs the past week from measured evidence rather than recollection, ticks the previous entry against that evidence, and drafts the coming week.
version: 1.0.0
---

# Weekly Skill

Write a weekly journal entry that is **reconstructed from evidence**, never from memory or from
what the previous entry projected. A weekly written from the previous week's plan records
intentions; a weekly written from the repository records facts.

## Step 0 — Load the local configuration

Read `~/.claude/weekly.local.md`. It is machine-local and NOT versioned, and it names:

- the journal file and its format contract;
- the code repositories that are the primary evidence;
- the derived tracking documents that hold authoritative counts;
- where decisions are recorded.

If that file is missing, ask the user for those four things and offer to create it. Never guess a
path, and never write project specifics into this skill.

## Step 0-bis — Rebuild the configuration when it is missing

The configuration is machine-local and deliberately unversioned, so it can be lost. Rebuilding it
is a normal task, not an error path. **Most of it is derivable**: the journal carries its own past
entries, and the repositories carry their own conventions. Ask only for what you cannot observe.

1. **Ask for the journal file**, and nothing else yet. One question.
2. **Read it, and read its directory.** Past entries give you the section order, the objective
   ceiling, the checkbox and blocker conventions, the typographic habits and the register. A
   sibling file explaining how to fill it in is the format contract: prefer it over your reading.
3. **Ask which repositories are the evidence**, then confirm each one yourself: run `git log -1`
   in it and report what you found, so a wrong path fails now rather than at the next entry.
4. **Find the derived tracking documents rather than asking for them.** Generated files usually
   announce themselves in their first lines. Present what you found and let the user correct.
5. **Ask only what remains genuinely invisible**: which journal entry is theirs if the directory
   holds several, and any convention that past entries contradict each other on.
6. **Write the configuration, show it in full, and ask for corrections.** State explicitly which
   parts you derived and which the user told you, so they know what to check.
7. **Prove it once.** Re-measure a single figure from the newest entry and compare. If it does not
   reproduce, the configuration is wrong somewhere and that is worth knowing before a real run.

Record in it the traps that were paid for on this project, not just the paths: the counting rules
that caused a wrong entry once, and any convention learned from a correction. That is the part no
artefact carries, and the part that is expensive to relearn.

## Step 1 — Take what the user tells you as first-class material

Whatever the user volunteers with the request (a worry, a trade-off they made, a decision, a
reason behind a push) is **primary material, not a hint**. It is the half of the week no command
can reconstruct: a repository records what was done, never why it was chosen or what it cost.

- **Do not verify it away.** If evidence is silent on it, the evidence is incomplete, not the
  user wrong. Silence is expected for a motive or a concern.
- **Corroborate it where you can, and let the figures do the arguing.** A stated worry lands when
  it carries the measurement that shows it is real; the same worry alone reads as a mood.
- **Give it the weight the user gave it.** Something raised as a concern belongs in the entry as a
  concern, and usually deserves its own detached block rather than a bullet buried in a list, so
  it reads as what it is.
- **Use it to steer Step 2.** A mentioned push, pause or reprioritisation tells you which part of
  the log to read closely.
- **Ask when the framing is genuinely ambiguous**, and not otherwise. What they already told you
  is an answer, not an invitation to re-ask it.
- **The rephrasing rule below applies to the user's own words too.** A verdict they said to you
  in private is not a verdict they said to their readers. Keep the finding, drop the quote.

Anything the user asks to have stated must appear in the entry. If it does not fit within the
objective ceiling, it goes in the record of the week or in a lead-in line, never dropped.

## Step 2 — Gather evidence, in this order

The order matters: each source answers a different question, and the cheap ones lie by omission.

1. **`git log --since=<last entry date>`** on each code repository, with `--format` and
   `--stat`. This is the primary source. Read commit **bodies**, not just subjects: on repos whose
   convention carries the motive in the message, the body is where a decision lives.
2. **The derived tracking documents** for counts. These are generated, so they are authoritative
   for "how many" and silent on "why".
3. **The decision records** (arbitration notes, decision logs, running journals) for what was
   settled and what was deliberately deferred. A documentation-only commit is often the week's
   most important deliverable.
4. **Any generated projection** (a task board, an exported view) last, and only to cross-check.
   A projection carries state, never a decision: a reordering or a trade-off leaves no trace in it.

Do not stop at source 4 if sources 1 to 3 disagree with it. The repository wins.

## Step 3 — Tick the previous entry against the evidence

Go through the previous entry's objectives one by one and resolve each to done, partial, or not
done, **citing the evidence**. Then:

- **Partial is worth stating as partial.** "3 of 4, and the 4th was deliberately deferred by the
  decision of <date>" is a different fact from "not finished", and the distinction is the useful one.
- **Not done gets a blocker note**, and say which kind: arbitrated away, or simply left behind.
  The second is the one worth surfacing.
- **Never edit a dated entry's facts.** It records what was true then. If a later measurement
  contradicts it, note that in the new entry instead.

## Step 4 — Write the new entry

Follow the journal's own format contract from Step 0 (position of the newest block, objective
ceiling, checkbox and blocker conventions). Respect its ceiling: if the cap is three objectives,
put the framing in a lead-in line above them rather than adding a fourth item.

Lead with what carries the most consequence, not with what took the most commits.

## Reading rules that prevent confident errors

These are the traps that produce a plausible, wrong entry. Check each before writing a number.

- **A count of finished sub-items is not a finished container.** "All stories done" and "the epic
  is closed" are different claims when a container's exit condition depends on another one.
- **A moving denominator is not a regression.** Backlogs grow. Say "58 of 110 (was 47 of 103)"
  rather than a percentage that appears to fall.
- **Two units of measure answer two questions.** If the tracking distinguishes programme progress
  from whether started work is finished, never average them into one number.
- **A roadmap checkbox describes an intended milestone, not a meeting that happened.** The only
  source for "that session did not take place" is the meeting record itself. Never infer it.
- **Measured facts pass through; reported speech gets rephrased.** Internal journals quote the
  user's own verdicts verbatim because that is their job. A weekly has a different audience, and a
  quoted verdict becomes a judgement on the record. Keep the finding, drop the quote.
- **Cite a number only if you re-measured it this session.** A figure copied from a document is
  copied from a snapshot, and snapshots go stale silently.

## Step 5 — Re-read what was written

Re-read the file after writing. Verify the new block is in position, the previous block's
checkboxes changed as intended, and the journal's typographic conventions hold. Malformed
structure raises no error.

Back the file up before editing, and report what was written plus any judgement call the user
should review.
