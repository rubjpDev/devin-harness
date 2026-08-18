#!/usr/bin/env bash
# =============================================================================
# stop-gate.sh — Stop hook. Runs the gate before the agent is allowed to finish.
#
# Mid-implementation a red check is expected, so it does not block then. What it
# never lets through is a redaction hit: a session must not end with customer
# data sitting in the tree.
#
# Exit 0 = let it stop. Exit 2 = block, stdout is fed back to the agent.
# =============================================================================
set -u

INPUT="$(cat 2>/dev/null || true)"

# Don't recurse: if we already blocked once this turn, let it go.
if command -v jq >/dev/null 2>&1 && [ -n "$INPUT" ]; then
  ACTIVE="$(printf '%s' "$INPUT" | tr -d '\000-\037' | jq -r '.stop_hook_active // empty' 2>/dev/null)"
  [ "$ACTIVE" = "true" ] && exit 0
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 0

# --- Redaction is never excused ---------------------------------------------
if [ -x scripts/redaction-scan.sh ] && ! ./scripts/redaction-scan.sh > /tmp/harness_redaction.log 2>&1; then
  echo "[harness] BLOCKED — the redaction scan found possible customer or credential data."
  cat /tmp/harness_redaction.log
  echo "[harness] Fix it before finishing. Rules: docs/redaction.md"
  exit 2
fi

# --- The gate ----------------------------------------------------------------
if ./init.sh > /tmp/harness_init.log 2>&1; then
  echo "[harness] init.sh OK"
  exit 0
fi

STATUS="idle"
if command -v jq >/dev/null 2>&1 && [ -f progress/active.json ]; then
  STATUS="$(jq -r '.status // "idle"' progress/active.json 2>/dev/null || echo idle)"
fi

case "$STATUS" in
  in_progress*)
    echo "[harness] check RED — expected mid-implementation (status ${STATUS}); see /tmp/harness_init.log"
    exit 0
    ;;
esac

echo "[harness] init.sh FAILED and nothing is in_progress — see /tmp/harness_init.log"
tail -20 /tmp/harness_init.log
exit 2
