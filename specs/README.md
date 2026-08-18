# specs/ — the folder convention

Every non-trivial item gets a folder named after its ticket id. The folder is
the **source of truth**; `feature_list.json` is only the index. When they
disagree, the folder wins for content and the index gets corrected for status.

## Incident lane (the default here)

```
specs/INC-1234/
  diagnosis-INC-1234.md      # triage's contract: repro, root cause, blast
                             # radius, the regression test. Written BEFORE code.
  post-mortem-INC-1234.md    # validator's human write-up, after the review
```

The diagnosis is to an incident what the spec is to a feature: **the contract
the coder implements against**. No spec, no acceptance array, no approval gate —
incidents are urgent and the diagnosis is what "fixed" means.

The post-mortem replaces the walkthrough: what broke, why, what stops it now, a
timeline, what data was affected, and — the reason it is worth writing — what
would have caught it earlier.

## Handoff lane

```
specs/INC-1234/
  diagnosis-INC-1234.md      # optional, when we diagnosed our side first
  handoff-INC-1234.md        # the PERSONETICS evidence package
```

There is no coder step. The human sends the package and the item sits at
`handoff` until they answer. When the answer lands, the quirk goes into
`docs/personetics.md` — that is how the black box gets smaller over time.

## Full lane (rare here)

```
specs/PROJ-42/
  scope.yaml         # envelope: repos, order, verify, environments, rollback
  requirements.md    # strict EARS, stable R ids
  design.md          # modules, decisions, rejected alternatives, risks
  tasks.md           # stable T ids, each mapped to R ids
  brief.md           # HUMAN one-screen summary, before the approval gate
  walkthrough.md     # HUMAN walkthrough of the diff, after the review
```

The first four are written **for the coder**: exhaustive and long. `brief.md`
and `walkthrough.md` are written **for you**: ~1 screen each, diagrams and real
snippets instead of prose. Both are views, never sources of truth.

## Light lane

No folder. The item lives as an entry in `feature_list.json` with an
`acceptance` array. Ask explicitly if a trivial change still deserves a
walkthrough.

## No customer data. Ever.

Every file here is committed. Internal ids only. `docs/redaction.md`, and
`redaction-scan.sh` scans this directory on every gate.
