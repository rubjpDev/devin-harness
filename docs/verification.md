# Verification — how the work gets proved

## Nothing here runs your tests

Five microservices, suites run by hand. This harness does not run a test, a
build, or a linter, and that is deliberate.

What changes is **who executes**, not whether verification exists. The agent's
job is to name the verification path precisely enough that running it is
mechanical. Yours is to run it.

## What `./init.sh` actually checks

```bash
./init.sh
```

Structure and safety, in about a second:

- `jq` present
- harness files and directories exist
- every subagent's frontmatter parses and its name matches
- `feature_list.json` and `progress/active.json` parse; at most one item
  `in_progress`; all statuses in the allowed vocabulary
- the redaction scan is clean
- the guard self-check passes (25 checks)

Red means an agent broke the harness or left customer data in the tree. It never
means a test failed, because it never ran one.

## What the agent must hand you

In `progress/impl_<id>.md`, for every change:

- the **exact command**, the directory it runs from, and what a pass looks like
- the output of anything it *could* check itself (see below)
- what needs a rollout, restart, or window to deploy
- what it did **not** verify, said plainly

`./mvnw -Dtest=SettlementDateTest test` is a verification path.
"Run the tests" is not, and the `validator` rejects it.

An agent never claims something passed. It wrote the test; it did not watch it
go green.

## What the agent still runs itself

Anything that costs one command and no suite:

```bash
./scripts/k8s-validate.sh k8s/          # dry-run; cannot apply
helm lint charts/<chart>
helm template charts/<chart> | ./scripts/k8s-validate.sh /dev/stdin
yamllint -d relaxed <file>
kubectl get <kind> <name> -o yaml       # diff the change against what's live
```

There is no reason to hand these to a human, so the `validator` treats a missing
dry-run output as CHANGES_REQUESTED.

`kubectl apply` is denied outright for agents. `k8s-validate.sh` is the only
sanctioned path to a dry-run.

## Proving an incident fix

A regression test that passes before and after the fix proves nothing. Since the
agent cannot run it, the review hands you three commands:

```bash
git stash push -- <the fix files>
<the test command>          # must go RED
git stash pop
```

Until you have seen it go red, the fix is unproven — and the review says so in
those words.

## Data protection

```bash
./scripts/redaction-scan.sh
```

Blocking, on every check, after every edit, and as a `Stop` hook — a session
cannot end on a hit. Rules: `docs/redaction.md`.

## Definition of verified

Every requirement, acceptance criterion, or diagnosed root cause has a test or a
declared verification path; the exact command is written down; everything
checkable without a suite was checked and its output recorded; the redaction
scan is clean; and `./init.sh` is green.
