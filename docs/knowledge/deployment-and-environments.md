---
trigger: glob
globs:
  - "**/*.yaml"
  - "**/*.yml"
  - "**/Chart.yaml"
  - "**/values*.yaml"
---

# Deployment and environments

*Mock.*

## Namespaces

| Environment | Namespace | Consumer replicas | Can apply |
|---|---|---|---|
| DEV | `mw-dev` | 2 | yes |
| PRE | `mw-pre` | 4 | **no** |
| PROD | `mw-pro` | 8 | **no** |

## Differences that bite

- **PRE has 4 Kafka partitions, PROD has 8.** A load-distribution problem **will not
  reproduce in PRE**. If the ticket is about lag, do not lose a morning trying.
- **Provider timeout is 8s in PROD, 30s in PRE.** A timeout that only happens in
  production is usually this, not a network difference.
- **DEV points at the provider's mock**, not the real one. Useful for payload
  shape, useless for latency or real error behaviour.

## Validating a change without applying it

```bash
./scripts/k8s-validate.sh charts/mw-consumer values-pro.yaml
helm template mw-consumer charts/mw-consumer -f values-pro.yaml | yamllint -
```

Never `kubectl apply --dry-run` against PRE or PROD: it is denied and deny wins.
The wrapper does the same job without touching the cluster.
