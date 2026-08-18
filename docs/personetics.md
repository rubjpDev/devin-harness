# PERSONETICS — the black box

<!-- FILL THIS IN. This file is the single highest-value document in the
     harness: it is what turns "it must be them" into a positive finding. Every
     time a handoff comes back with an answer, a line gets added here. -->

They own the business logic and the data. We are middleware. For us their
behaviour is observable only from the outside: what we send, what comes back,
how long it took, and what their docs say should happen.

## The rule that keeps us honest

**"I could not find the cause in our code" is not evidence that the cause is
theirs.** To send a handoff you need a *positive* finding:

- a response that violates their documented contract (missing field, wrong type,
  out-of-range enum, malformed date)
- a response time outside their stated SLA, measured at our client
- a change in shape or behaviour correlated with a date, with before/after
- a correlation id whose trace ends on their side
- a case their docs say cannot happen, that happened

Without one of those, the cause is more likely **the boundary** — us mishandling
something they legitimately sent. Check that first. It is the single most common
root cause on a middleware team, and the reflex is always to blame the black box.

## Contract

<!-- Fill in per integration. One table per endpoint / message we consume. -->

### `<endpoint or topic name>`

| | |
|---|---|
| Direction | we call them / they call us / async |
| Docs | <Confluence link, and the exported copy under `docs/confluence/`> |
| Auth | <mechanism — never the credential> |
| SLA | p50 / p95 / p99, and the timeout we set |
| Our timeout | |
| Retry policy | attempts, backoff, idempotency |
| On failure | what we do — fallback, queue, error to caller |

**Fields we depend on:**

| Field | Type | Nullable per their docs | Nullable in reality | Notes |
|---|---|---|---|---|

The "nullable in reality" column is the one that pays for this document.

## Known quirks

<!-- Append-only. Every quirk here is one that already cost someone a night.
     Format: - **YYYY-MM-DD** (<ticket id>): <what they do that the docs don't say>. -->

*None recorded yet.*

## Things they have told us

<!-- Answers that came back from a handoff. Cite the ticket so the thread is
     findable. These are the facts that stop us re-asking the same question. -->

*None recorded yet.*

## How to reach them

<!-- Fill in: channel, ticket system, expected response time, escalation path,
     who on their side owns which area, timezone. -->

| | |
|---|---|
| Normal channel | |
| Urgent / P1 path | |
| Expected turnaround | |
| Escalation | |

## What a good handoff looks like

Their side sees a black box too. A handoff that makes them ask a follow-up costs
a full round trip — often days. `templates/handoff-personetics.md` is built to
prevent that. The three things that most often trigger a follow-up:

1. **No identifier they can search on.** Our correlation id is useless to them.
   Give them theirs: their request id, session id, or the exact timestamp with
   timezone plus the endpoint.
2. **No "we already checked".** Without it, the first reply is "have you checked
   your configuration". List what you ruled out, with evidence.
3. **No expected-vs-actual.** "It's wrong" is not actionable. Show both, as
   redacted data, side by side.
