---
name: post-mortem
description: Close an incident. Writes the post-mortem in plain register and promotes anything reusable to docs/.
argument-hint: "<TICKET-ID>"
allowed-tools:
  - read
  - write
  - edit
  - grep
  - exec
triggers:
  - user
---

# /post-mortem — close it out

## First

```bash
./scripts/redaction-scan.sh sessions/<TICKET-ID>*/
```

Anything it finds gets cleaned before closing. Not after.

## The post-mortem

`post-mortem.md` in the session folder, from `templates/post-mortem.md`.

**Plain register, the way you would tell a colleague** (`bro`). Rubén will read
this a year from now remembering none of it. It is not a report for management: it
is a note to the future.

What it has to answer, and not much else:

- What broke, in one sentence.
- Why it actually broke. Not the symptom.
- What fixed it.
- **What wasted our time.** This is the most valuable part and the one always
  skipped. The false lead, the place we looked first that was wrong, the
  assumption that turned out false.
- If it happens again, where to start.

No generic "lessons learned". No "system robustness has been improved". What
happened and what was done.

## Promote what is durable

If this will be needed again, one or two lines in the matching
`docs/knowledge/` file, with date and ticket:

- **INC10038** (2026-08-25): the pool does not recover on its own after a DNS failure.

**Only if it is reusable.** Incident detail stays in its folder. If nothing durable
came out, promote nothing — filling the knowledge base for the sake of it is how
it stops being read.

## Close

`status: closed` and `closed:` with the date, in `definition.md`'s frontmatter.
The board updates itself.
