# CHECKPOINTS.md — reusable review baseline

<!-- devin-sdd-harness — port of claude-sdd-harness (origin: inspired by /
     forked from Bettatech). Adapted by Rubén Juárez Pérez. -->

The `validator` walks this list for every item, marking `[x]` (pass) or `[ ]`
(fail / not applicable, with a note). Lane-specific sections apply only to their
lane.

## Data protection (blocking — always)

- [ ] `./scripts/redaction-scan.sh` is clean.
- [ ] No customer names, emails, accounts, sort codes, PANs or NI numbers in any
      committed file, fixture, test, comment or commit message.
- [ ] No credential, token or key written anywhere.
- [ ] Records are referenced by internal id only, never id plus an identifier.
- [ ] Quoted log lines carry no payload bodies.

## Contract and scope

- [ ] The contract exists and was written **before** the code:
      `diagnosis-<id>.md` (incident), `specs/<id>/` (full), or `acceptance` (light).
- [ ] Full lane: human approval happened **before** implementation began.
- [ ] Only the repos declared in scope were changed.
- [ ] No harness artifacts created inside the repos being developed.
- [ ] No scope creep — no unrelated refactors, no "while I was in there".

## Incident lane (blocking)

- [ ] A regression test exists and, read as code, genuinely asserts the
      diagnosed behaviour rather than restating current behaviour.
- [ ] The review hands the human the exact stash / run / restore commands to
      prove it goes red without the fix, and says the fix is unproven until then.
- [ ] The fix addresses the root cause the diagnosis named, not where the error
      surfaced.
- [ ] Blast radius handled: replay/backfill done, or explicitly deferred with a
      reason.
- [ ] `post-mortem-<id>.md` exists and closes with what would have caught it
      earlier.

## Handoff lane

- [ ] The ask is in the first line.
- [ ] Every identifier is one PERSONETICS can search on, not just ours.
- [ ] Expected vs actual is shown as data, redacted.
- [ ] The contract clause is quoted with a link.
- [ ] "Already ruled out" is specific and evidenced, not "we checked our side".
- [ ] Nothing internal leaks: no hostnames, namespaces, repo paths, credentials.

## Config / YAML / Kubernetes

- [ ] Every manifest was validated (`k8s-validate.sh`, `helm lint`, `yamllint`)
      and the output is in `impl_<id>.md`.
- [ ] The change was diffed against the **live object**, not an assumption.
- [ ] Every resource/limit/timeout number has an evidenced reason, not a guess.
- [ ] No secret **value** was written.
- [ ] Deployment impact stated: rollout, restart, window, order.
- [ ] Rollback path is written down.

## Implementation quality

- [ ] Follows `docs/conventions.md` and the layering in `docs/architecture.md`.
- [ ] Explicit error handling — no bare catch, no silent failures.
- [ ] Long procedural blocks split into focused functions. No 100-line methods.
- [ ] Comments only where the code genuinely needs them.
- [ ] Types / schemas throughout.
- [ ] Minimal is **not** a finding — ponytail is on by default.

## Verification and traceability

Tests, builds and linters are run **by hand**, by the human. So these check the
handover, not a green pipeline.

- [ ] Every requirement / criterion / diagnosed cause has a test or a declared
      verification path.
- [ ] `impl_<id>.md` gives the **exact command** to run, the directory, and what
      a pass looks like. "Run the tests" does not count.
- [ ] The coder claims nothing passed that they did not actually run.
- [ ] Everything checkable without a suite (dry-runs, rendered templates, parses,
      diff vs the live object) **was** run, with the output recorded.
- [ ] `./init.sh` exits green (structure and guards).
- [ ] `review_<id>.md` records an explicit verdict.

## Session hygiene

- [ ] `feature_list.json` status matches reality.
- [ ] `progress/active.json` matches the active item.
- [ ] `progress/current.md` was updated during the work.
- [ ] `progress/history.md` was appended on close.
- [ ] Durable findings went to `docs/knowledge-pack.md`; a PERSONETICS quirk went
      to `docs/personetics.md`.
