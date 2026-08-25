---
name: arch-map
description: Draw or update the map of a repo or of the whole system, to understand where data flows.
argument-hint: "[repo | system]"
allowed-tools:
  - read
  - grep
  - glob
  - write
triggers:
  - user
---

# /arch-map — the map

For arriving at a part of the system you do not know and needing its shape before
its detail.

Two different outputs, kept apart:

- **`repo`** → which modules exist inside a repository and what calls what.
- **`system`** → what is deployed, where, and what is **not** there. Load balancer,
  cache, queue, replica, rate limiter. What is missing and why is half the value of
  the drawing: a map showing only what exists reads as naivety.

Update `docs/architecture.md`; do not rewrite the whole thing when one piece
changed.

Rules: map by reading the code, not the documentation — documentation goes stale
before code does. A node is something you would draw on a whiteboard, not a file.
Past 40 nodes you went too fine; collapse.
