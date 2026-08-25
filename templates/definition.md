---
id: INC00000
title: <one line, what looks wrong>
status: pending        # pending | working | blocked | q&a | closed
blocked_by:            # who we are waiting on, if status is blocked
environment: PROD      # LOCAL | DEV | PRE | PROD
ongoing: true          # is it still happening right now?
system: mw-gateway
opened: 2026-00-00
updated: 2026-00-00
closed:
outcome:               # fixed | handoff | cannot_reproduce | not-a-bug
---

# <ID> — <title>

## What looks wrong

<In the reporter's words, not mine. If the ticket says "movements aren't showing
up", that is what goes here, not "serialisation failure in the consumer".>

## How we will know it is fixed

<The concrete condition. Without this we do not start: it is what separates
closing an incident from abandoning it.>

## Scope

- **Since when:** <date and time, or "unknown">
- **How many affected:** <number, or how to find out>
- **Workaround available:** <yes/no, what it is>

## What we already know at open

<Whatever the grep across docs/ and sessions/ turned up. If this happened before,
the link to that session goes here — and a diagnosis is probably unnecessary.>

## What is NOT part of this

<Scope deliberately left out, so the session does not sprawl.>
