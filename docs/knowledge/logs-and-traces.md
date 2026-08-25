---
trigger: model_decision
description: Chasing errors in logs, following a correlation id, understanding what each service records.
---

# Logs and traces

*Mock.*

## Where to start

Always the `correlation_id`, never the error text. The text is duplicated across
four services; the correlation id crosses the whole system.

```bash
kubectl logs -n mw-pro -l app=mw-gateway --since=2h | grep "<correlation-id>"
```

An id appears in this order: `mw-gateway` (entry), `mw-router` (routing),
`mw-consumer` (push), `mw-audit` (close). **If the `mw-audit` line is missing, the
operation never completed**, even if the client saw a 200 — the gateway responds
before the consumer finishes.

## What misleads

- **`WARN pool exhausted` is almost never the cause.** It appears when something
  downstream has stalled and the pool fills up waiting. Find what is waiting.
- **`mw-consumer` timestamps are UTC, everything else is local time.** Fixed in the
  gateway (INC9903), still open in the consumer. Crossing time windows without
  adjusting makes the ordering look impossible.
- **`ERROR mapping failed` with no field name is the core sending an empty
  optional**, not a mapping bug. See `data-and-schemas.md`.

## Windows and retention

Pod logs live 7 days; the aggregator keeps 30. Further back than that only the
audit table remains, which has the what but not the why.

## Searches worth keeping

```bash
# errors grouped by type over the last hour
kubectl logs -n mw-pro -l app=mw-router --since=1h \
  | grep ERROR | sed 's/.*ERROR //' | cut -d: -f1 | sort | uniq -c | sort -rn

# one id end to end, across all four services
for s in gateway router consumer audit; do
  echo "== $s"; kubectl logs -n mw-pro -l app=mw-$s --since=3h | grep "<correlation-id>"
done
```
