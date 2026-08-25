---
trigger: model_decision
description: Response times, traffic peaks, memory consumption, saturation.
---

# Performance

*Mock.*

## Baselines

Without these you cannot say whether something is actually slow.

| Metric | Normal | Warning | Broken |
|---|---|---|---|
| gateway p50 | 120 ms | 300 ms | 800 ms |
| gateway p99 | 1.4 s | 3 s | 6 s |
| provider p99 | 5.2 s | 7 s | 8 s (= timeout) |
| Kafka lag | < 500 | 5,000 | 50,000 |
| consumer memory | 480 MB | 700 MB | 850 MB (limit 1 GB) |

## Peaks have a timetable

Two a day: **08:00-09:30** (opening) and **20:00-21:00** (end-of-day movements).
And one monthly, on the 1st, when salaries land — that one is 4x and it is the one
that breaks things.

A peak inside those windows is not an incident. It is Tuesday.

## Order to check, cheapest first

1. **Is it a peak window?** Check the clock before anything else.
2. **Kafka lag or response latency?** Different problems with different fixes,
   confused constantly because both present as "it's slow".
3. **`kubectl top pods -n mw-pro`** — if a pod is at 90% memory, the rest of the
   investigation is worthless until that is explained.
4. **Provider p99.** If theirs rises, ours rises behind it. Not ours.
5. Only then, profiling.

## Already known

- **`mw-consumer` reaches 820 MB with 500-message batches at peak** against a 1 GB
  limit. No OOM yet, but the margin is 18%. Measured in INC10051.
- **Scaling `mw-consumer` past 8 replicas achieves nothing**: the bottleneck is the
  8 Kafka partitions. Extra pods sit idle with no partition assigned.
- **Gateway p99 includes provider time.** A "slow gateway" is usually a slow
  provider under a different name.
