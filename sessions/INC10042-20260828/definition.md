---
id: INC10042
title: Provider rejects onboarding when the secondary document field is empty
status: blocked
blocked_by: provider (their ticket PRV-4417)
environment: PROD
ongoing: true
system: mw-gateway
opened: 2026-08-28
updated: 2026-08-28
closed:
outcome:
---

# INC10042 — Onboarding rejected on empty secondary document

## What looks wrong

"Some customers aren't being onboarded into the engine. They exist in the core but
the engine says they don't. Looks like it's the ones with two account holders." —
support.

## How we will know it is fixed

An onboarding request with an empty `holder.secondaryDoc` completes and the
customer appears in the engine. Verifiable end to end with the correlation id.

## Scope

- **Since when:** 2026-08-27 around 18:00, matching their deployment
- **How many affected:** 1,203 rejected onboardings, all joint accounts
- **Workaround available:** not automated. They can be onboarded by hand from the
  provider's console, but there are 1,203 of them.

## What we already know at open

`docs/knowledge/data-and-schemas.md` already lists `holder.secondaryDoc` as
**open**: it is a nested field and the empty-value strip only runs at the top
level. The suspicion was written down before this happened.

## What is NOT part of this

Fixing the strip for every nested field. That is the right medium-term change but
not now: first we need to know whether the provider is going to revert.
