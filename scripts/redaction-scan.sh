#!/usr/bin/env bash
# =============================================================================
# redaction-scan.sh — grep the committed tree for customer/payment data shapes.
#
# A SAFETY NET, NOT A GUARANTEE. It catches formats, not judgement. A name in
# prose sails straight through. Read docs/redaction.md; this only backs it up.
#
# Scans: specs/ progress/ docs/ templates/ (the files that get committed).
# Exit 0 = clean, 1 = hits found.
#
# ponytail: grep + a handful of regexes. If false positives get annoying, add
# paths to the SKIP list rather than reaching for a PII-detection library.
# =============================================================================
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1

TARGETS=""
for d in specs progress docs templates; do
  [ -d "$d" ] && TARGETS="$TARGETS $d"
done
[ -n "$TARGETS" ] || { echo "[OK]   redaction scan: nothing to scan"; exit 0; }

# Paths whose matches are examples, not leaks.
SKIP='docs/redaction.md|templates/handoff-personetics.md|scripts/redaction-scan.sh'

HITS=0
scan() { # scan <label> <extended-regex>
  local label="$1" re="$2" out
  out="$(grep -rInE "$re" $TARGETS 2>/dev/null | grep -vE "^($SKIP)" || true)"
  if [ -n "$out" ]; then
    echo "[FAIL] possible ${label}:"
    printf '%s\n' "$out" | head -10 | sed 's/^/       /'
    HITS=1
  fi
}

# 13-19 digit runs, optionally spaced/dashed — PANs.
scan "card number" '(^|[^0-9])([0-9]{4}[ -]?){3}[0-9]{1,7}([^0-9]|$)'
# UK sort code.
scan "sort code" '(^|[^0-9])[0-9]{2}-[0-9]{2}-[0-9]{2}([^0-9]|$)'
# IBAN.
scan "IBAN" '\b[A-Z]{2}[0-9]{2}[A-Z0-9]{11,30}\b'
# Email address.
scan "email address" '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
# UK National Insurance number.
scan "NI number" '\b[A-CEGHJ-PR-TW-Z]{2}[0-9]{6}[A-D]\b'
# Common credential prefixes and inline secrets.
scan "credential" '(sk-[A-Za-z0-9]{16,}|ghp_[A-Za-z0-9]{20,}|xox[baprs]-|-----BEGIN [A-Z ]*PRIVATE KEY-----|eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{10,})'
scan "inline secret" '(password|passwd|secret|api[_-]?key|bearer|authorization)[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9/+_-]{8,}'

if [ "$HITS" -ne 0 ]; then
  echo "[FAIL] redaction scan found possible customer or credential data."
  echo "       Fix it, or add the path to SKIP if it is a documented example."
  echo "       Rules: docs/redaction.md"
  exit 1
fi

echo "[OK]   redaction scan clean"
exit 0
