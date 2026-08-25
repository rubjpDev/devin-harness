---
trigger: model_decision
description: Data failures, fields arriving empty or malformed, contract differences between the core and the provider.
---

# Data and schemas

*Mock.*

## The underlying mismatch

The core sends optionals as empty strings; the provider wants them absent.
`mw-gateway` strips them, but **only at the top level — nested objects are not
cleaned**. That is where half the data failures come from.

## Fields that cause trouble

| Field | Problem | Where it is handled |
|---|---|---|
| `account.alias` | Core sends `""`, provider rejects | level-1 strip, fine |
| `holder.secondaryDoc` | Nested, not stripped | **open**, INC10042 |
| `movement.amount` | Core uses comma decimals on some channels | normalised in the router |
| `movement.date` | Two formats depending on channel (`dd/MM/yyyy` and ISO) | normalised in the router |

## Checking without touching production

```bash
# what the provider's contract requires
cat ../middleware/contracts/provider-v3.schema.json | jq '.required'

# validate a sample payload (no real data)
jq -f ../middleware/scripts/normalize.jq fixtures/sample-movement.json
```

## The rule that saves time

Before reading any code, **diff the outgoing payload against the schema**. Two out
of three "data failures" are a field the core changed without telling anyone, not
a bug on our side. With the schema diff in hand the ticket closes in twenty
minutes.
