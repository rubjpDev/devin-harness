# Current working note

- **Date:** —
- **Active item:** none
- **Lane:** —
- **Status:** harness bootstrapped (idle)
- **Next step:** fill in `repos.json`, `docs/environments.md` and
  `docs/personetics.md`, drop the Confluence exports into `docs/confluence/`,
  then run `./init.sh`.

---

## Bootstrap summary

Port of `claude-sdd-harness` to Devin CLI / Devin Desktop, for the Santander UK
middleware team. Four subagents (`triage`, `coder`, `validator`, `spec_creator`)
in `.devin/agents/`. Four lanes: **incident** and **handoff** are the daily ones;
**light** and **full** are the exception here.

What the port changed versus the original:

- `.claude/` → `.devin/`; `CLAUDE.md` + `AGENTS.md` merged into one small
  always-on `AGENTS.md` (Devin injects rules every session — keep them lean).
- The orchestrator is no longer a subagent file: it *is* `AGENTS.md`, read by
  the main session.
- No test/build/lint gate at all. Five microservices, suites run by hand.
  `init.sh` checks structure, state and the guards; agents name the verification
  path and the human executes it.
- `tutor` dropped — this is work, not a learning portfolio.
- New: the **handoff lane** and the PERSONETICS evidence package.
- New: `docs/redaction.md` + a blocking redaction scan on edit, gate and stop.
- New: `docs/environments.md` + `scripts/guard-prod.sh` — PROD/PRE are read-only
  for every agent, enforced by a PreToolUse hook, not just by prose.
- `metrics.sh` (token cost) → `acu.sh` (session time → ACU estimate vs the
  800/month allowance).
