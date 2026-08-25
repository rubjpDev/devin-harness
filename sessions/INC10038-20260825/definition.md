---
id: INC10038
title: Consumer stops pushing to the provider and does not recover
status: closed
blocked_by:
environment: PROD
ongoing: false
system: mw-consumer
opened: 2026-08-25
updated: 2026-08-25
closed: 2026-08-25
outcome: fixed
---

# INC10038 — Consumer stops pushing and does not recover

## What looks wrong

"Since 3am no new movements are reaching the engine. No error, nothing is just
arriving." — night on-call.

## How we will know it is fixed

Kafka lag drops below 500 and stays there, and new movements reach the provider
continuously for 30 minutes.

## Scope

- **Since when:** 2026-08-25 03:12
- **How many affected:** every movement after that time, roughly 240,000
- **Workaround available:** no, they queue up

## What we already know at open

`grep` across docs/ returned nothing. First occurrence.

## What is NOT part of this

Why DNS failed. That belongs to platform and has its own ticket.
