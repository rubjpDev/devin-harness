---
trigger: model_decision
description: Who owns what, and who to ask when an incident needs someone else. Use when a session is about to be blocked, escalated or handed off.
---

# People and routing

*Mock — invented names. Keep this to roles and routing: who owns what and what to
ask them for. Not personal details.*

The point of this file is to stop a session dying in "I need someone else" without
saying who. When you are about to set `status: blocked`, the `blocked_by` value
should come from here.

## Our team

| Person | Role | Go to them for |
|---|---|---|
| Alice Fairweather | Tech Lead | Design calls, anything that needs a decision above ticket level. Sign-off before a PROD change. |
| Rubén Juárez | Backend / incidents | Middleware, this vault |
| Tom Brackley | Backend | `mw-consumer` and Kafka. Wrote the batching. |
| Priya Raghavan | QA | Reproducing in PRE, regression tests |

## Outside the team

| Person / team | Owns | Ask them for | Typical wait |
|---|---|---|---|
| Peter Nkemdirim — Data | Core data feeds, schemas | **Replicating an incident in PRE when it looks like a user-data issue.** Also schema changes on the core side. | same day |
| Sandra Ilić — Platform | k8s, DNS, networking | Cluster-level failures, DNS, anything below the app. Applying changes in PRE/PROD. | 2-4h, faster if PROD |
| Marcus Dowell — Provider liaison | The upstream relationship | Chasing a handoff ticket, contract changes, their release notes | 1-3 days |
| Service Desk | Ticket intake | Reassigning, priority changes, chasing the reporter for detail | n/a |

## Routing rules that save a day

- **Suspected user-data issue → Peter, Data team, and ask specifically for a PRE
  replication.** Do not spend the morning trying to reproduce with production data
  you should not be handling anyway.
- **Anything below the application — DNS, networking, node pressure → Sandra,
  Platform.** Signal: all four services degrade at once. If only one is unhappy, it
  is ours.
- **A PRE or PROD change needs two people**: Alice signs off, Platform applies.
  Never one person doing both, and never us doing either.
- **Provider handoff goes through Marcus**, not straight to their support queue.
  Tickets raised outside that route come back asking for the correlation id we
  already sent.
- **Out of hours**, on-call is the only route. Nothing in this table applies at
  3am.

## When you block a session

Set `blocked_by` to the person or team, plus their ticket reference if there is
one:

```yaml
status: blocked
blocked_by: provider (their ticket PRV-4417)
```

The board shows how many days each blocked item has been sitting. Anything past
three days needs a chase, not more waiting.
