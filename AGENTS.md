# AGENTS.md — working vault

Always loaded. Keep it short: what gets read every session is paid for every
session. The long material lives in `docs/knowledge/`, which loads only when it
is relevant.

## What this is

The vault where I track middleware incidents. It is not a code repo — the code
lives in `../middleware/`. This holds the knowledge and the sessions.

```
my-devin-workflow/     <- you are here, start Devin from this directory
../middleware/         <- the actual repo
```

## Hard rules — not negotiable

- **PRE and PROD are read-only.** No `kubectl apply|delete|scale|rollout|edit|patch`,
  no `helm upgrade|install|rollback`. Diagnose freely; a human applies.
- **Never customer data in a vault file.** Internal ids and correlation ids only.
  A document number, an account number, an email or a token in a file is a new
  incident with its own clock. When in doubt, do not paste it.
- **No `git push`.** I make the commits.
- **One ticket at a time.** If something is `working` and another arrives, ask
  which one wins.

## How work runs

1. New ticket → `@skills:incident <ID>` (Desktop) or `/incident` (CLI). Creates the
   session folder and writes `definition.md` **with me**, not alone.
2. Investigation → `findings.md` in the same folder. Evidence, not guesses.
3. Closed → `@skills:post-mortem`. Plain register — I will read it a year from now.
4. Status lives in `definition.md`'s frontmatter. `board.md` reads it.

## Before investigating anything

Check whether this already happened:

```bash
grep -rin "<error string>" docs/ sessions/
```

One hit there beats half an hour of log reading. If you find something, say so
before starting a diagnosis.

## Writing registers

- `definition.md`, `findings.md`, `docs/` → precise, no padding (`no-ai-slop`).
- `post-mortem.md` → how you would tell a colleague (`bro`).
