# my-devin-workflow

A mock Obsidian vault for running middleware incidents with Devin. **All content
is invented** — services, tickets, people, figures and logs. It shows the shape;
it is not meant to be used as-is.

## The idea

A local vault, sibling to the work repo, that is both where Devin reads context
and where you track your own work.

```
my-devin-workflow/     <- start Devin from here
../middleware/         <- the actual repo, reached by relative path
```

## What Devin reads, and when

The point of the layout: **not everything loads every time.**

| File | Enters context |
|---|---|
| `AGENTS.md` (root) | always, every session — hence 48 lines |
| `.devin/rules/prod-safety.md` | always (`trigger: always_on`) |
| `.devin/rules/data-handling.md` | always (`always_on`) |
| `.devin/rules/upstream-vendor.md` | when the model judges it relevant (`model_decision`) |
| `docs/AGENTS.md` | when touching anything under `docs/` (automatic glob rule) |
| `docs/knowledge/*.md` | by topic, or by which files are being edited |
| `.agents/skills/*/SKILL.md` | description only; the body loads on invocation |

An 800-line knowledge file loaded always is ~12k tokens every session, nearly all
of it irrelevant to the ticket in front of you. Split by topic with triggers, you
pay for what you use. That is the whole trick.

## A normal day

1. Ticket arrives → `@skills:incident INC10042` (Desktop) or `/incident` (CLI).
2. You write `definition.md` together. **The done condition is decided there**, not
   at the end.
3. You investigate. Findings go to `findings.md` with the command that proves them.
4. Close with `@skills:post-mortem`. Anything reusable is promoted to
   `docs/knowledge/`.

Status lives in `definition.md`'s frontmatter. `board.md` reads it — nothing is
maintained twice, so nothing drifts.

## Layout

```
AGENTS.md              always loaded, short
board.md               status view, generated from frontmatter
.devin/rules/          triggered rules
.agents/skills/        incident, perf, post-mortem, arch-map
docs/
  architecture.md      the map
  knowledge/           one file per area, each triggered
    people-and-routing.md   who owns what, who to ask
sessions/
  INC10038-20260825/   closed, with post-mortem
  INC10042-20260828/   blocked on the provider
  INC10051-20260828/   in progress
templates/             definition.md and post-mortem.md
```

## Why skills live in `.agents/skills/`

It is the recommended path and it is the open Agent Skills standard, so **the same
skills work in Devin Desktop, Devin CLI and Claude Code**. `.devin/skills/` also
works but ties the vault to one tool.

Desktop invokes them with `@skills:name`, CLI with `/name`. Same files.

## Two writing registers, on purpose

- `definition.md`, `findings.md`, `docs/` → precise, no padding. Read by someone
  who needs accuracy.
- `post-mortem.md` → how you would tell a colleague. Read by you a year from now,
  remembering nothing.

## Obsidian setup

`board.md` uses **Dataview**. If you see raw query blocks instead of tables, the
plugin is not enabled: Settings → Community plugins → disable Restricted mode →
Browse → Dataview → Install → Enable.

If community plugins are blocked on a managed machine, the bottom of `board.md`
covers the plugin-free routes — the Properties panel, search queries, and the
Bases core plugin. The frontmatter is the source of truth; those are just
different windows onto it.

## Data

This vault will accumulate production logs and traces. Local, not synced. Run
`redaction-scan.sh` over `sessions/` before closing each one, not just over the
repo. `people-and-routing.md` stays at roles and routing — no personal details.
