# docs/knowledge/ — how this is split

One file per area, each loading only when needed. That is the whole trick: the
knowledge is centralised, but you do not pay for all of it every session.

| File | Activates when |
|---|---|
| `logs-and-traces.md` | chasing an error, following a correlation id |
| `data-and-schemas.md` | data failures, fields arriving malformed |
| `performance.md` | latency, traffic peaks, memory |
| `deployment-and-environments.md` | k8s, config, differences between environments |
| `people-and-routing.md` | about to block, escalate or hand off — who owns what |

If a file goes past ~200 lines, split it. An 800-line file gets read in full to
answer a two-line question.
