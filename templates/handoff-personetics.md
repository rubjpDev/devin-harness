<!-- The PERSONETICS evidence package. Written by `triage`, sent by the human.
     Lives at specs/<id>/handoff-<id>.md.

     ASSUME THIS LEAVES THE BANK'S PERIMETER.
     No customer data. No credentials. No internal hostnames, cluster names or
     repo paths. See docs/redaction.md.

     Style: no-ai-slop (.devin/skills/no-ai-slop/SKILL.md). Short sentences,
     concrete nouns, no filler. This lands in someone else's inbox.
     Goal: they can reproduce without asking us one follow-up question.
     Hard cap: ~1 screen plus the evidence blocks. -->

# <ticket id> — <one-line subject>

**Ask:** <one sentence. What you need them to do or tell you. First line, always.>

**Environment:** <PRE / PROD> · **Since:** <first occurrence, with timezone> ·
**Rate:** <how often> · **Ongoing:** <yes / no> · **Customer impact:** <yes / no>

## How to find it on your side

| | |
|---|---|
| Your request / session id | `<their id>` |
| Endpoint / topic | `<name>` |
| Timestamp (UTC) | `<exact, with timezone>` |
| Additional occurrences | `<2–3 more ids, or a time window>` |

<!-- Their identifiers, not ours. Our correlation id means nothing to them.
     If we have no id of theirs, say so explicitly and give the tightest
     window plus endpoint we can. -->

## What we expected

```json
{ "field": "<type or documented value>" }
```

Per <document / clause>: <link to their doc or the Confluence page>, section
<x.y>. Quote the relevant line:

> <the clause you believe was violated>

## What we got

```json
{ "field": null }
```

<!-- Redacted, shape preserved. Field names and types stay; values are elided
     or replaced with their type. -->

**The difference in one line:** <e.g. "`settlementDate` was null on 12 of 4,200
responses; your spec marks it non-nullable.">

## Timeline

| When (UTC) | What |
|---|---|
| <date> | last known good |
| <date> | first occurrence |
| <date> | reported |

## What we have already ruled out

<!-- This is the section that stops the reply "have you checked your config".
     Be specific and evidenced. Vague claims here cost a round trip. -->

- <thing ruled out> — <how, with evidence. One line each.>
- Our request payload is unchanged since <date> — <evidence>.
- Our timeout is <n>ms, above your stated p99 of <n>ms — <evidence>.
- No deploy on our side in the window — <evidence>.

## What we need back

- [ ] <specific question 1>
- [ ] <specific question 2>

**Needed by:** <date, and why — a customer-facing deadline, a release, a P1 clock>

---

<!-- Before sending, walk docs/redaction.md. Then check:
     [ ] No customer names, accounts, PANs, emails, tokens.
     [ ] No internal hostnames, cluster names, namespaces or repo paths.
     [ ] Every identifier here is one THEY can search on.
     [ ] The "already ruled out" section is specific, not "we checked our side".
     [ ] The ask is in the first line. -->
