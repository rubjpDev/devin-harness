# Environments — what the agent may touch

<!-- FILL THIS IN before the first real session. The rules below are the
     defaults; the tables are stubs. An agent that guesses at cluster names is
     worse than one that asks. -->

## The one rule

**PROD and PRE are read-only for every agent, always.**

Agents produce commands. Humans run them. There is no permission mode, no
"just this once", and no urgency that changes this. An incident is exactly the
situation where an agent's mistaken `kubectl delete` is unrecoverable.

## What agents may run where

| | local | dev cluster | PRE | PROD |
|---|---|---|---|---|
| `kubectl get` / `describe` / `logs` / `top` | ✅ | ✅ | ✅ | ✅ |
| `kubectl apply` / `delete` / `scale` / `rollout` / `edit` | ✅ | ❌ | ❌ | ❌ |
| `kubectl exec` (read-only command) | ✅ | ✅ | ask human | ❌ |
| read-only SQL (`SELECT`, bounded) | ✅ | ✅ | ✅ | ask human |
| any write SQL, DDL, migration | ✅ | ❌ | ❌ | ❌ |
| restart / redeploy / `helm upgrade` | ✅ | ❌ | ❌ | ❌ |
| reading metrics / traces / dashboards | ✅ | ✅ | ✅ | ✅ |

"local" means a container or cluster on your laptop, where a mistake costs
nothing. **Every shared cluster is read-only**, dev included — the deny list in
`.devin/config.json` and `scripts/guard-prod.sh` are global, not per-environment,
because a command line does not reliably say which cluster it will hit.

"ask human" means: write the exact command into the diagnosis under **Fix
options** or **Open questions**, and stop.

## Bounding every read

An unbounded read against PROD is its own incident. Always bound:

```bash
kubectl logs deploy/<svc> -n <ns> --since=30m --tail=2000
kubectl logs deploy/<svc> -n <ns> --since-time=2026-08-17T13:50:00Z --tail=5000
```

```sql
SELECT count(*) FROM t WHERE created_at > now() - interval '1 hour';  -- shape, not rows
```

Prefer `count(*)`, `exists`, `group by`, `min`/`max` on a timestamp — the shape
of the problem, not the rows. Never `SELECT *` on a table holding customer data.

## Evidence strength — always say which

Three different claims, three different weights. State which one you have:

- **reproduced locally** — strongest, you controlled the inputs
- **confirmed in PRE** — strong, real topology, non-production data
- **observed in PROD** — real, but you only saw it; you did not control it

## Environment map

<!-- Replace with the real values. Keep internal hostnames OUT of anything sent
     to PERSONETICS. -->

| Env | Cluster / context | Namespaces | Log access | Notes |
|---|---|---|---|---|
| local | | | | |
| dev | | | | |
| PRE | | | | |
| PROD | | | | |

## Access checklist

<!-- Fill in: which of these you actually have, and how you authenticate.
     "I don't have this" is useful information for the agent. -->

- [ ] `kubectl` context for PRE
- [ ] `kubectl` context for PROD (read-only role)
- [ ] Log aggregator (Splunk / Kibana / Loki?) — URL and how to query
- [ ] Metrics (Grafana / Prometheus?) — URL
- [ ] Tracing — URL, and whether correlation ids propagate to PERSONETICS
- [ ] Read replica for PRE / PROD databases

## Deploy and change windows

<!-- Fill in: who deploys, how, whether there is a freeze window, what needs a
     change record. The coder writes deployment notes in impl_<id>.md; they are
     only useful if they reference the real process. -->
