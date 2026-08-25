# INC10051 — findings (in progress)

## Measured

Window 2026-08-28 08:00-09:30, sampled every 5 minutes:

```
$ kubectl top pods -n mw-pro -l app=mw-consumer
peak observed:        820 Mi  (limit 1 Gi, warning 700 Mi)
median in window:     610 Mi
outside peak:         480 Mi
```

Margin against the limit: **18%**. No OOM has occurred.

## Correlation

Memory tracks batch size, not message count:

```
batch 500 (current config) -> 820 Mi
batch 200 (measured in PRE) -> 390 Mi
```

Linear, and expected: the whole batch is held in memory until the commit at the
end. That is recorded in `docs/architecture.md` as a deliberate decision.

## The concern, not yet measured

The 1st of the month is 4x. **That day has never been measured.** If the relationship
holds, it does not fit.

Next: pull the 1 August history from the metrics aggregator, which keeps 30 days.
Today is the 28th, so **it expires in three days**. That is the next thing to do.

## Ruled out for now

- **Memory leak**: outside peak it returns to 480 MB consistently. It rises and
  falls, it does not rise and stay.
- **More replicas**: 8 partitions, 8 pods. A ninth pod gets no partition and
  distributes nothing.
