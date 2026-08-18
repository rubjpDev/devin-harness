<!-- The incident contract, written by `triage` BEFORE any code exists.
     Lives at specs/<id>/diagnosis-<id>.md. This is to an incident what the spec
     is to a feature: what the `coder` implements against and what the
     `validator` reviews against.

     NO customer data. Internal ids only. This file is committed.
     See docs/redaction.md. -->

# Diagnosis — <incident id>

**Symptom:** <one or two lines, in the reporter's terms. What they saw.>

**Where the cause lives:** <ours / PERSONETICS / the boundary> — <one line of why>

**Status:** <diagnosed / escalate / cannot_reproduce> ·
**Environment:** <PRE / PROD> · **Ongoing:** <yes / no>

## Reproduction

```bash
# exact, runnable, bounded. Or: the correlation id a human can follow end to end.
```

**Observed:** <what happens when you run it>

## Root cause

`<path/to/file.java:142>` or `<k8s/deployment.yaml:resources.limits.memory>`

<The mechanism, in two or three sentences: why the bad state could exist at all.
Cite what you read. This is not "where the error was thrown" — it is why the
thrown error was possible.>

```
# the code, manifest or log line that proves it
```

## Timeline

| When | What changed |
|---|---|
| <date / commit / deploy / configmap / cert / scaling event> | <what> |
| <date> | first occurrence |
| <date> | reported |

`unknown` is an acceptable answer for the first row. A guess is not.

## Blast radius

- **Other callers of this path:** <who else hits it>
- **Data already wrong:** <shape and rough count, or `none`>
- **Replay / backfill needed:** <yes + what, or no + why not>
- **Still happening:** <yes / no>

## The regression test

- **File:** `<path>`
- **Asserts:** <what>
- **Fails today because:** <why>

This test is the acceptance criterion for the fix.

## Fix options

1. **<minimal option>** — <one line>. ← recommended, because <one line>
2. <alternative> — <one line, and why it's more than needed now>

You recommend; the human decides.

## Ruled out

- <hypothesis> — eliminated by <evidence>.

<!-- This section is what stops the next person redoing your work at 3am.
     Write it even when it feels obvious. -->

## Open questions

- <what you could not determine, and what you'd need to>
- <any exposed credential — report to the human immediately, do not wait>

## Evidence sources

| Claim | Source | Strength |
|---|---|---|
| <claim> | <local repro / PRE / PROD logs / code alone> | <strong / weak> |

## Data handling

<what you redacted, or `none` — the ticket was clean>
