# INC10038 — post-mortem

## What broke

The consumer stopped pushing movements to the provider at 3am and stayed that way,
without throwing a visible error.

## Why it actually broke

Internal DNS dropped for about a minute and a half. The connection pool did the
right thing — marked the connections dead — but **it never reopens them**. It only
health-checks a connection when creating one, never afterwards. So when DNS came
back, the pool was still full of dead connections holding slots, and everything
new sat waiting for a slot that was never going to free up.

The nasty part is that it does not error. It just waits. That is why nobody
noticed until morning.

## What fixed it

Restarting the pods:

```bash
kubectl rollout restart deployment/mw-consumer -n mw-pro
```

Eleven minutes and lag was back to zero.

## What wasted our time

Half an hour chasing `pool exhausted` as if it were a connection leak. It was not
— the pool was full of connections waiting, not leaked. **And this was already
written in `docs/knowledge/logs-and-traces.md`**, the note saying that message is
almost never the cause. It was not read first.

Concrete takeaway: the grep across docs/ before investigating is not bureaucracy.
The answer was sitting there.

## If it happens again

Check for a DNS failure in the ten minutes before the first `pool exhausted`:

```bash
kubectl logs -n mw-pro -l app=mw-consumer --since=6h | grep -B2 "dns resolution failed"
```

If there is one, this is it. Restart and move on.

## Promoted to docs/

One line in `docs/knowledge/logs-and-traces.md`: the pool does not recover on its
own from a DNS failure, the pod has to be restarted.
