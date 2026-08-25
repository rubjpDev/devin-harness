# INC10038 — findings

## What is visible

```
$ kubectl top pods -n mw-pro -l app=mw-consumer
NAME                            CPU    MEMORY
mw-consumer-7d4f8b6c9-2xk4p     2m     412Mi
mw-consumer-7d4f8b6c9-8vn2q     2m     408Mi
```

CPU at 2%. It is not working — it is waiting.

```
$ kubectl logs -n mw-pro -l app=mw-consumer --since=6h | grep -c "pool exhausted"
1847
```

First occurrence 03:12:06. Nothing before that.

## The false lead

`pool exhausted` pointed at a connection leak, and half an hour went that way. It
was not: the pool was full of connections **waiting**, not leaked. This is written
down in `docs/knowledge/logs-and-traces.md` and it was not read first. Cost: 30
minutes.

## The cause

Three minutes before the first `pool exhausted`:

```
03:09:41 WARN  dns resolution failed for provider-api.internal (attempt 1/3)
03:09:51 WARN  dns resolution failed for provider-api.internal (attempt 2/3)
03:10:01 ERROR dns resolution failed, marking connection unhealthy
```

Internal DNS dropped for about 90 seconds. The pool marked connections unhealthy —
correct. **But it never reopens them when DNS returns**: the dead connections keep
occupying slots and new requests wait for a slot that never frees. The pool has no
periodic health check, only one at creation.

Confirmed at `../middleware/mw-consumer/src/pool/ConnectionPool.java:88` —
`healthCheck` is called from `acquire()` and nowhere else.

## Ruled out

- **Kafka**: lag rises because nobody is consuming, not the other way round. The
  brokers are healthy.
- **The provider**: responds fine to a manual request from another pod.
- **Memory**: 412 MB of 1 GB, nowhere near.

## The fix

Restart the consumer pods. Command written out for a human to apply:

```bash
kubectl rollout restart deployment/mw-consumer -n mw-pro
```

Applied by Rubén at 09:47. Lag back to 0 in 11 minutes.

## Left open

The restart is a patch. The pool should reopen dead connections on its own. That
goes as a separate improvement, not in this ticket.
