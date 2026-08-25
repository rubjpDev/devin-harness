---
trigger: always_on
---

# Environments: what can be touched

| Environment | Read | Write |
|---|---|---|
| LOCAL | yes | yes |
| DEV | yes | yes |
| PRE | yes | **no** — a human applies |
| PROD | yes | **no** — a human applies |

Always allowed: `kubectl get|describe|logs|top`, `helm lint|template`, `yamllint`, `jq`.

Denied in PRE and PROD, no exceptions: `kubectl apply|delete|scale|rollout|edit|patch|drain|cordon`,
`helm upgrade|install|uninstall|rollback`, `terraform apply|destroy`.

A dry run goes through `./scripts/k8s-validate.sh`, never `kubectl apply --dry-run`:
deny wins over allow, so a bare `apply` is blocked anyway.

If the fix needs PRE or PROD: **write the exact command into `findings.md` and
stop.** It gets run by whoever carries the responsibility.
