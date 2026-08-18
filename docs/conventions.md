# Conventions — coding standards

<!-- Living doc. Source code wins over this doc on disagreement — record drift
     when you find it. Replace the stubs with the team's real conventions. -->

## Formatting and linting

- <linter/formatter per repo, e.g. spotless + checkstyle, eslint + prettier>.
  All checks clean before the gate goes green.
- Types / schemas throughout. No untyped public boundaries.

## Error handling

- Explicit errors. Catch specific exceptions, never a bare catch.
- Errors cross layer boundaries as domain errors, translated to protocol errors
  only at the edge.
- No silent failures — log with the correlation id, or propagate.
- Logs carry the correlation id and never carry a payload body.

## The PERSONETICS boundary

- Every field they send is validated at our edge before it reaches our logic.
  Nulls, absent keys, unexpected enums, unparseable dates.
- Timeout, retry and fallback behaviour is explicit and documented per call.
- Their types never leak past the client layer.

## YAML and Kubernetes

- One concern per file. No 800-line manifests.
- Every resource declares requests **and** limits, with a reason in the PR.
- Probes: liveness and readiness are different things — a readiness probe that
  restarts pods is a bug waiting for a traffic spike.
- ConfigMap for config, Secret for secrets, and never a secret value in git.
- Charts are linted; manifests are dry-run validated. Both before review.

## Tests

- Tests live alongside what they cover.
- Every behaviour change ships its test in the same change.
- Fast and deterministic. Mock external I/O, including PERSONETICS.
- Contract tests against a recorded (redacted) PERSONETICS response beat mocks
  written from the docs — the docs are what we already know is incomplete.

## Complexity

- Split long procedural blocks into focused private functions.
- No deeply-stacked conditionals in long methods.

---
*Stub at bootstrap. Replace with the team's real conventions.*
