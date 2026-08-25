# Middleware architecture

*Mock. Service names, figures and logs are invented — this is a shape, not a
record of any real system.*

## What it does

Translates between the banking core, which speaks SOAP and thinks in accounts,
and the upstream personalisation engine, which speaks REST and thinks in
customers. No business logic of its own: it normalises, routes, retries and logs.

```
banking core ──SOAP──> [ middleware ] ──REST──> personalisation engine
                           │  │
                           │  └──> Kafka (movement events)
                           └─────> Postgres (idempotency + audit)
```

## Services

| Service | What it does | PROD replicas |
|---|---|---|
| `mw-gateway` | SOAP entry, validates and translates | 6 |
| `mw-router` | Picks destination, handles retries | 4 |
| `mw-consumer` | Consumes Kafka, pushes to the provider | 8 |
| `mw-audit` | Writes the trail to Postgres | 2 |

## What the code does not tell you

- **Idempotency keys off `correlation_id`, not the message id.** The core reuses
  message ids across environments; that caused a collision in PRE (INC9987).
- **The consumer processes in batches of 500 with a single commit at the end.** A
  failure on message 499 reprocesses all 500. That is deliberate — the provider is
  idempotent.
- **Retries use exponential backoff, capped at 4.** The fifth goes to the DLQ. The
  DLQ does not drain itself; it has to be triggered by hand.
- **The provider timeout is 8s** because their measured p99 is 5.2s. Lowering it
  looks sensible right up until the false negatives start.

## Where problems come from

Almost everything that breaks sits at an edge, not in the middle: type
translation with the core, contracts changing upstream, and memory pressure in
`mw-consumer` when a batch lands on a traffic peak.
