---
id: INC10051
title: Consumer approaches its memory limit during the morning peak
status: working
blocked_by:
environment: PROD
ongoing: true
system: mw-consumer
opened: 2026-08-28
updated: 2026-08-28
closed:
outcome:
---

# INC10051 — Consumer memory at peak

## What looks wrong

"The consumer pod goes red on the dashboard around half eight but it doesn't fall
over. Is that normal?" — a colleague, over Slack. No formal ticket.

## How we will know it is fixed

`mw-consumer` peak memory stays below 700 MB (the warning threshold) across the
08:00-09:30 window, and above all on the 1st of the month.

## Scope

- **Since when:** unknown. This is the first time anyone looked.
- **How many affected:** nobody yet. It has never restarted on memory.
- **Workaround available:** n/a, there is no service incident

## What we already know at open

`docs/knowledge/performance.md` puts the limit at 1 GB and the warning at 700 MB.
It also says scaling past 8 replicas achieves nothing, because the bottleneck is
the 8 Kafka partitions.

## What is NOT part of this

Redesigning batch processing. If the conclusion is that the batch size must come
down, that is a change with its own ticket and its own testing.
