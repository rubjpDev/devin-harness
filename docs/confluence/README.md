# docs/confluence/ — exported Confluence pages

Drop the exported pages here as **markdown or plain text**, one file per page.
Agents grep this directory before exploring code, so an export that lives here
saves ACUs on every incident that touches it.

## How to get them in

Confluence → page → `...` → Export → Markdown (or copy-paste into a `.md`).
Name the file after the page, kebab-case: `personetics-batch-contract.md`.

Keep the source URL at the top of each file so a diagnosis can link it:

```markdown
<!-- source: https://confluence.<...>/display/XXX/Page+Title
     exported: 2026-08-17 -->
```

## What is worth exporting

Ranked by how often it stops an agent from guessing:

1. The PERSONETICS interface contracts — fields, types, SLAs, error codes.
2. Runbooks for the services we own.
3. The environment / topology pages: cluster names, namespaces, endpoints.
4. Architecture decision records.
5. On-call escalation paths.

## What is NOT worth exporting

Meeting notes, project plans, org charts, anything with customer data in it.
Every file here is read by an agent and costs context on the sessions that grep
it. Ten good pages beat two hundred.

## Redaction

Confluence pages contain screenshots and pasted payloads. **Strip customer data
before committing an export** — `docs/redaction.md` applies to this directory
exactly like everywhere else, and `redaction-scan.sh` scans it.

## Staleness

Confluence rots. Put the export date in the header. When a page contradicts the
running system, **the system wins** — fix the page upstream and re-export, and
note the drift in `docs/knowledge-pack.md`.
