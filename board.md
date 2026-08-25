# Board

Generated from each `definition.md`'s frontmatter. Do not edit by hand — status
lives in the session, this is just the view.

> **Seeing raw query blocks instead of tables?** The Dataview plugin is not
> enabled. Settings → Community plugins → turn off Restricted mode → Browse →
> "Dataview" → Install → Enable. Then reopen this note.
>
> If community plugins are blocked on your work machine, see
> **"Without Dataview"** at the bottom — the frontmatter works either way.

## Open now

```dataview
TABLE WITHOUT ID
  link(file.folder, id) AS "Ticket",
  title AS "What's wrong",
  status AS "Status",
  blocked_by AS "Waiting on",
  environment AS "Env",
  updated AS "Touched"
FROM "sessions"
WHERE status != "closed"
SORT choice(status = "working", 0, choice(status = "blocked", 1, 2)) ASC, updated DESC
```

## Blocked, and on whom

```dataview
TABLE WITHOUT ID
  link(file.folder, id) AS "Ticket",
  blocked_by AS "Waiting on",
  (date(today) - date(updated)).day AS "Days stuck"
FROM "sessions"
WHERE status = "blocked"
SORT updated ASC
```

Anything past three days needs a chase. See `docs/knowledge/people-and-routing.md`
for who to chase.

## Closed in the last 30 days

```dataview
TABLE WITHOUT ID
  link(file.folder, id) AS "Ticket",
  title AS "What happened",
  outcome AS "Outcome",
  closed AS "Closed"
FROM "sessions"
WHERE status = "closed" AND closed >= date(today) - dur(30 days)
SORT closed DESC
```

---

## Scratch notes

By hand, deliberately. The paper-and-pen bit that belongs to no single incident.

- Ask about Kafka partitions in PRE: 4 against 8 in PROD means half the lag
  tickets cannot be reproduced there.
- The UTC offset in `mw-consumer` has been open since INC9903. Costs ten minutes
  every time I cross time windows.
- Chase PRV-4417 if nothing by Monday — Marcus.

---

## Without Dataview

If community plugins are unavailable, nothing is lost: the status lives in the
frontmatter either way, and Obsidian shows it natively.

- **Properties panel** — open any `definition.md` and the fields render as a
  table at the top. No plugin needed.
- **Search** — `path:sessions status:blocked` in the search pane returns the same
  set as the query above.
- **Bases** — a newer core plugin (no install, enable it under Settings → Core
  plugins) that builds table views over frontmatter. Worth checking whether your
  Obsidian version has it before reaching for a community plugin.

The frontmatter is the source of truth. Dataview, Bases and search are three ways
of looking at the same thing, and all three keep working if one is unavailable.
