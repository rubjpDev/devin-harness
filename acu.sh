#!/usr/bin/env bash
# =============================================================================
# acu.sh — devin-sdd-harness session / ACU meter
#
# Devin bills in ACUs, not tokens, and the CLI does not hand us a token
# transcript. So this measures what we CAN measure honestly — active session
# wall time per ticket — and converts it to an ACU estimate you calibrate
# against the real number on the Devin dashboard.
#
# Modes:
#   (no args)      hook mode — called by SessionStart / SessionEnd
#   --report       spend per ticket
#   --budget       this month's burn vs the 800 ACU allowance
#   --calibrate N  set ACU_PER_HOUR from a real dashboard reading
#
# ponytail: wall time as the ACU proxy, with a calibration knob. Swap for the
# Devin usage API if one ever exposes per-session ACUs.
# =============================================================================
set -u

ROOT="$(cd "$(dirname "$0")" && pwd)"
LOG="$ROOT/progress/acu.jsonl"
STAMP="$ROOT/progress/.session_start"
RATEFILE="$ROOT/progress/.acu_per_hour"
BUDGET="${ACU_BUDGET:-800}"

rate() { [ -f "$RATEFILE" ] && cat "$RATEFILE" || echo "${ACU_PER_HOUR:-4}"; }

case "${1:-}" in
  --calibrate)
    [ -n "${2:-}" ] || { echo "usage: $0 --calibrate <acus-per-hour>" >&2; exit 2; }
    printf '%s\n' "$2" > "$RATEFILE"
    echo "ACU_PER_HOUR set to $2 — future reports use it."
    exit 0
    ;;

  --report)
    command -v jq >/dev/null 2>&1 || { echo "jq required" >&2; exit 1; }
    [ -s "$LOG" ] || { echo "No sessions logged yet ($LOG)."; exit 0; }
    R="$(rate)"
    echo "== spend per ticket (est. at ${R} ACU/h — calibrate with --calibrate) =="
    {
      printf 'ticket\tsessions\tminutes\test_acus\n'
      jq -s -r --argjson r "$R" '
        group_by(.ticket // "none") | .[]
        | [ (.[0].ticket // "none"),
            length,
            ((map(.duration_seconds // 0) | add) / 60 | floor),
            ((map(.duration_seconds // 0) | add) / 3600 * $r * 10 | round / 10) ]
        | @tsv' "$LOG"
    } | column -t -s "$(printf '\t')"
    exit 0
    ;;

  --budget)
    command -v jq >/dev/null 2>&1 || { echo "jq required" >&2; exit 1; }
    [ -s "$LOG" ] || { echo "No sessions logged yet ($LOG)."; exit 0; }
    R="$(rate)"
    MONTH="$(date -u +%Y-%m)"
    DAY="$(date -u +%d | sed 's/^0//')"
    DAYS="$(date -u -v+1m -v1d -v-1d +%d 2>/dev/null || echo 30)"  # macOS date
    USED="$(jq -s -r --arg m "$MONTH" --argjson r "$R" '
      [ .[] | select((.ended_at // "") | startswith($m)) | .duration_seconds // 0 ]
      | add // 0 | . / 3600 * $r | . * 10 | round / 10' "$LOG")"
    echo "== ACU budget — ${MONTH} =="
    printf 'allowance     %s ACU\n' "$BUDGET"
    printf 'used (est.)   %s ACU   (day %s of %s)\n' "$USED" "$DAY" "$DAYS"
    printf 'remaining     %s ACU\n' \
      "$(awk -v b="$BUDGET" -v u="$USED" 'BEGIN{printf "%.1f", b-u}')"
    awk -v b="$BUDGET" -v u="$USED" -v d="$DAY" -v n="$DAYS" 'BEGIN{
      if (d > 0) {
        proj = u / d * n;
        printf "projected     %.0f ACU by month end\n", proj;
        if (proj > b) printf "[WARN] on track to overrun by %.0f ACU — tighten delegation\n", proj - b;
        else          printf "[OK]   on track (%.0f%% of allowance)\n", proj / b * 100;
      }
    }'
    echo "estimate only — calibrate against app.devin.ai usage: ./acu.sh --calibrate <acus/h>"
    exit 0
    ;;
esac

# --- Hook mode ---------------------------------------------------------------
# Never blocks a session: every path exits 0.
INPUT="$(cat 2>/dev/null || true)"
EVENT=""
SESSION="unknown"
if command -v jq >/dev/null 2>&1 && [ -n "$INPUT" ]; then
  EVENT="$(printf '%s' "$INPUT" | jq -r '.hook_event_name // empty' 2>/dev/null)"
  SESSION="$(printf '%s' "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)"
fi

now() { date -u +%s; }

case "$EVENT" in
  SessionStart|"")
    # Empty event name: called manually or the payload was unreadable. Treat a
    # missing stamp as a start, a present one as an end — idempotent either way.
    if [ "$EVENT" = "SessionStart" ] || [ ! -f "$STAMP" ]; then
      printf '%s %s\n' "$(now)" "$SESSION" > "$STAMP"
      exit 0
    fi
    ;;
esac

# SessionEnd (or a manual second call): close the row.
[ -f "$STAMP" ] || exit 0
START="$(cut -d' ' -f1 "$STAMP" 2>/dev/null || echo)"
[ -n "$START" ] || { rm -f "$STAMP"; exit 0; }
DUR=$(( $(now) - START ))
rm -f "$STAMP"
[ "$DUR" -ge 0 ] || exit 0

TICKET="none"
if command -v jq >/dev/null 2>&1 && [ -f "$ROOT/progress/active.json" ]; then
  TICKET="$(jq -r '.id // .ticket // "none"' "$ROOT/progress/active.json" 2>/dev/null || echo none)"
fi
[ -z "$TICKET" ] || [ "$TICKET" = "null" ] && TICKET="none"

mkdir -p "$ROOT/progress"
printf '{"ended_at":"%s","session_id":"%s","ticket":"%s","duration_seconds":%s}\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$SESSION" "$TICKET" "$DUR" >> "$LOG"
exit 0
