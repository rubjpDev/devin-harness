---
name: perf
description: Investigate latency, traffic peaks or memory pressure. Cheapest checks first, with the baselines in front of you.
argument-hint: "<TICKET-ID | service>"
allowed-tools:
  - read
  - write
  - grep
  - glob
  - exec
triggers:
  - user
  - model
---

# /perf — performance

Separate from `/incident` on purpose. An error is found in logs; latency is found
in metrics. Merging the two loops produces one that does both badly.

## First: is this even a problem?

Open `docs/knowledge/performance.md` and compare against the baselines **before**
investigating. And check the clock: there are two daily peak windows and one
monthly. A peak inside its window is not an incident.

If it is within normal range, say so and stop. "It's slow" with no number is not a
ticket.

## Order, cheapest first

1. **The clock.** Peak window? First of the month?
2. **Lag or latency?** Different things. Kafka lag says we are not keeping up;
   latency says each operation is slow. The fixes look nothing alike.
3. **`kubectl top pods -n mw-pro`.** If something is at 90% memory, stop there —
   nothing else matters until that is explained.
4. **Provider p99.** If theirs rises, ours rises behind it, and it is not ours.
5. **Scaling.** Careful: past 8 consumer replicas nothing improves, the bottleneck
   is the 8 Kafka partitions. Asking for more pods is burning money.
6. **Profiling.** Only if none of the above explained it.

## What to write

In `findings.md`, with **numbers and a time window**, not adjectives:

```
gateway p99 2026-08-28 08:00-09:30 -> 4.1 s (normal 1.4 s, warning 3 s)
provider p99 same window           -> 6.8 s (normal 5.2 s)
=> gateway rises because the provider rises; the delta is theirs, not ours
```

"It was slow" with no figure and no window is worthless a month later.

## Forbidden

Do not scale, restart or change limits in PRE or PROD. Write the exact command
that would be needed and stop. A human applies it.
