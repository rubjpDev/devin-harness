# docs/ — the durable knowledge

Glob rule: this loads when Devin reads or writes something under `docs/`, not on
every session.

What goes here is what will still be true next week. Anything that only matters
for one incident stays in its `sessions/` folder.

- `knowledge/` — one file per area. Each has its own `AGENTS.md`, so it activates
  only when touched.
- `architecture.md` — the map of the system and where data flows.

When a session finds something that will be needed again, promote it here. A line
or two, with date and ticket:

- **INC10038** (2026-08-25): the connection pool does not recover on its own after
  a DNS failure; the pod has to be restarted.

What does NOT go here: incident detail, lists of files changed, anything the code
already says.
