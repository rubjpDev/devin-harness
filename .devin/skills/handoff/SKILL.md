---
name: handoff
description: Build the PERSONETICS evidence package for the active ticket from what is already on disk. Use with /handoff [ticket-id]. Produces specs/<id>/handoff-<id>.md, ready for a human to send.
allowed-tools: read, write, grep, glob
---

# /handoff — build the PERSONETICS package

The most-repeated deliverable on this team, and the one where quality decides
whether they answer in a day or in three weeks.

**Do not re-investigate.** Everything you need should already be in
`specs/<id>/diagnosis-<id>.md`, `docs/personetics.md`, `docs/confluence/` and the
ticket. If it is not, say what is missing and stop — a handoff sent with a gap in
it costs a full round trip, which is worse than an hour of delay.

## Before you write: the honesty check

You need a **positive** finding, not an absence of one. "We couldn't find it on
our side" is not evidence it is theirs, and sending it as one damages the
relationship that gets the next ticket answered quickly.

Pick which of these you have:

- a response that violates their documented contract (missing field, wrong type,
  out-of-range enum, unparseable date)
- a response time outside their stated SLA, measured at our client
- a change in shape or behaviour correlated with a date, with before and after
- a correlation id whose trace ends on their side
- a case their docs say cannot happen, that happened

**None of them?** Say so plainly, and go back to the boundary: are we
mishandling something they legitimately sent? That is the most common root cause
on a middleware team and the reflex is always to blame the black box.

## Write it

Fill `templates/handoff-personetics.md` into `specs/<id>/handoff-<id>.md`.

**Apply the `no-ai-slop` skill** (`.devin/skills/no-ai-slop/SKILL.md`). This one
leaves the bank and lands in someone else's inbox — every filler sentence is a
sentence they skim past on the way to the ask. Short sentences, concrete nouns,
no throat-clearing, no "we hope you can assist". Say the thing and stop.

The four things that decide whether they answer without a follow-up:

1. **The ask is the first line.** Not the story. One sentence.
2. **Identifiers they can search on.** Our correlation id is useless to them —
   give them their request/session id, or the endpoint plus an exact timestamp
   with timezone. No id of theirs? Say so explicitly and give the tightest window
   you can, or the reply will be "we can't find it".
3. **Expected vs actual, as data, side by side.** Redacted, shape preserved.
   "It's wrong" is not actionable.
4. **What we already ruled out, specifically and with evidence.** This is what
   stops the first reply being "have you checked your configuration". "We checked
   our side" is worth nothing; "our request payload is byte-identical to 12 Aug,
   diffed against the recorded fixture" is worth a week.

Quote the contract clause you believe was violated, with a link to
`docs/personetics.md` or the Confluence page.

## Before you hand it back — the outbound check

**Assume this leaves the bank's perimeter.** Walk `docs/redaction.md`, then:

- [ ] No customer names, accounts, sort codes, PANs, emails, NI numbers.
- [ ] No credentials, tokens, or keys.
- [ ] No internal hostnames, cluster names, namespaces, or repo paths — fine
      internally, not fine outbound.
- [ ] Every identifier is one **they** can search on.
- [ ] The ask is in the first line.
- [ ] The "already ruled out" section is specific and evidenced.

Run `./scripts/redaction-scan.sh` before you finish.

## After they answer

When PERSONETICS replies, the answer is not just a ticket resolution — it is a
permanent shrink of the black box. Append it to `docs/personetics.md`:

- a behaviour their docs don't describe → **Known quirks**
- a definitive statement about their system → **Things they have told us**

Cite the ticket id so the thread stays findable. This is the one habit that makes
the next incident cheaper, and it is the one everyone skips.
