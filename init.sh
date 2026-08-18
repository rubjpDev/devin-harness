#!/usr/bin/env bash
# =============================================================================
# init.sh — devin-sdd-harness sanity check
#
# Port of claude-sdd-harness (origin: inspired by / forked from Bettatech).
# Adapted by Rubén Juárez Pérez. Ported to Devin CLI.
#
# This does NOT run your tests, builds or linters. Five microservices, tests run
# by hand — automating that is deliberately out of scope for now.
#
# What it does check is what an agent can silently break: harness structure,
# state file validity, and the two safety guards. Cheap, and it means a red
# result is always worth reading.
#
# Exits non-zero on any FAIL.
# =============================================================================
set -u

FAIL=0
ok()   { printf '[OK]   %s\n' "$1"; }
warn() { printf '[WARN] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1"; FAIL=1; }

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT" || { echo "[FAIL] cannot cd to harness root"; exit 1; }

echo "== devin-sdd-harness check =="

# --- 1. Required tooling -----------------------------------------------------
if command -v jq >/dev/null 2>&1; then
  ok "jq present"
  HAVE_JQ=1
else
  fail "jq not found — required (brew install jq)"
  HAVE_JQ=0
fi

# --- 2. Base harness files ---------------------------------------------------
for f in \
  AGENTS.md \
  repos.json \
  feature_list.json \
  CHECKPOINTS.md \
  progress/current.md \
  progress/active.json \
  docs/environments.md \
  docs/personetics.md \
  docs/redaction.md
do
  [ -f "$f" ] && ok "exists: $f" || fail "missing: $f"
done

for d in .devin/agents .devin/skills templates specs; do
  [ -d "$d" ] && ok "exists: $d/" || fail "missing: $d/"
done

# --- 3. Subagent definitions parse ------------------------------------------
for a in triage coder validator spec_creator; do
  f=".devin/agents/${a}.md"
  if [ ! -f "$f" ]; then
    fail "missing subagent: $f"
  elif head -1 "$f" | grep -q '^---$' && grep -q "^name: ${a}$" "$f"; then
    ok "subagent ok: $a"
  else
    fail "subagent $a: frontmatter missing or name mismatch"
  fi
done

# --- 4. State files ----------------------------------------------------------
if [ "$HAVE_JQ" -eq 1 ] && [ -f feature_list.json ]; then
  if jq empty feature_list.json >/dev/null 2>&1; then
    ok "feature_list.json parses"

    INPROG="$(jq '[.items[]? | select(.status == "in_progress")] | length' feature_list.json)"
    if [ "${INPROG:-0}" -le 1 ]; then
      ok "at most one item in_progress (found ${INPROG:-0})"
    else
      fail "more than one item in_progress (found ${INPROG})"
    fi

    # The vocabulary lives in feature_list.json (rules.valid_status) — one copy.
    BADSTATUS="$(jq -r '
      (.rules.valid_status // ["pending","in_progress","done","blocked"]) as $valid
      | [.items[]? | select(.status as $s | ($valid | index($s)) | not) | .id]
      | join(", ")' feature_list.json)"
    [ -z "$BADSTATUS" ] && ok "all statuses valid" || fail "invalid status on: ${BADSTATUS}"
  else
    fail "feature_list.json does not parse"
  fi
fi

if [ "$HAVE_JQ" -eq 1 ] && [ -f progress/active.json ]; then
  jq empty progress/active.json >/dev/null 2>&1 \
    && ok "progress/active.json parses" \
    || fail "progress/active.json does not parse"
fi

# --- 5. Redaction scan (hard fail) -------------------------------------------
if [ -x scripts/redaction-scan.sh ]; then
  ./scripts/redaction-scan.sh || fail "redaction scan found possible customer data"
else
  warn "scripts/redaction-scan.sh missing or not executable"
fi

# --- 6. Guard self-check -----------------------------------------------------
# The guards are the only thing between an agent and a PROD mutation. A guard
# nobody tests is a guard that stopped working and nobody noticed.
if [ -x scripts/test-guards.sh ]; then
  if ./scripts/test-guards.sh >/tmp/harness_guards.log 2>&1; then
    ok "guard self-check ($(grep -o '[0-9]* checks passed' /tmp/harness_guards.log))"
  else
    fail "guard self-check FAILED (see /tmp/harness_guards.log)"; tail -10 /tmp/harness_guards.log
  fi
fi

# --- 7. Verdict --------------------------------------------------------------
echo "== result =="
if [ "$FAIL" -ne 0 ]; then
  echo "[FAIL] check failed"
  exit 1
fi
echo "[OK] check passed"
exit 0
