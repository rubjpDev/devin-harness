---
name: incident
description: Open an incident. Creates the session folder, writes the definition with me, and decides where to start.
argument-hint: "<TICKET-ID> [+ pasted ticket text]"
allowed-tools:
  - read
  - write
  - edit
  - grep
  - glob
  - exec
triggers:
  - user
---

# /incident — open an incident

The daily entry point. I have just pasted a ticket.

## 1. Check whether this already happened — free, and the biggest time saver

Before anything else:

```bash
grep -rin "<error string>" docs/ sessions/
```

A hit means this has history. **Read it and tell me before starting any
investigation.** A repeat incident with a known cause does not need a diagnosis;
it needs the fix we already know.

## 2. Create the session

`sessions/<TICKET-ID>-<DDMMYYYY>/` with `definition.md` inside, from
`templates/definition.md`.

**We write the definition together.** Do not fill it in alone and show it to me —
if a field is not in the ticket, ask. Especially these three, which decide
everything after:

- **What looks wrong**, in the reporter's words, not yours.
- **Environment**, and whether it is still happening right now.
- **How we will know it is fixed.** If we cannot answer this, we do not start: it
  is the definition of done, and without it the incident does not close, it gets
  abandoned.

Register: plain and precise, no padding (`no-ai-slop`).

## 3. Decide where to enter

| What you have | Do this |
|---|---|
| Cause already known (wrong value, expired cert, limit too low) | Fix it. Do not investigate what we already know. |
| An error and no idea where it comes from | `docs/knowledge/logs-and-traces.md`, start from the correlation id |
| Data arriving malformed | `docs/knowledge/data-and-schemas.md`, diff payload against schema **before** reading code |
| Slow, or a traffic peak | `/perf` |
| Smells like it comes from upstream | Keep going — you need a positive finding to say so |
| It is a question, not a fault | Answer it. Do not create a session. |

## 4. Write down what you find

In `findings.md`, same folder, as you go. **Evidence, not guesses**: the command
that proves it and its trimmed output. What you ruled out goes in too, with why —
that is half the value when this recurs in March.

If evidence says it is the provider's, the outcome is `handoff` and it needs a
positive finding, not a "nothing wrong on our side".

If you cannot reproduce it, the outcome is `cannot_reproduce` and you say what you
need. That is a legitimate result. Do not try fourteen times hoping for a
different one.

## 5. Status

In `definition.md`'s frontmatter. `board.md` reads it — do not maintain the status
in two places.
