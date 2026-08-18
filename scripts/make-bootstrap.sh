#!/usr/bin/env bash
# =============================================================================
# make-bootstrap.sh — pack this harness into a paste-able shell script.
#
# For a locked-down machine: no git, no cloud, no USB, no AirDrop. You paste one
# script into a terminal and the whole harness reconstructs itself.
#
# Run it again after ANY change to the harness and re-paste. That is the whole
# maintenance story — the one-off blob is what rots, the generator does not.
#
# Usage:
#   ./scripts/make-bootstrap.sh              -> dist/bootstrap.sh (single file)
#   ./scripts/make-bootstrap.sh --split 20   -> dist/part-01.sh ... (20 KB each)
#
# Requires only tar, gzip, base64, shasum — all shipped with macOS.
# =============================================================================
set -eu

cd "$(dirname "$0")/.." || exit 1
ROOT="$(pwd)"
NAME="$(basename "$ROOT")"
OUT="$ROOT/dist"
SPLIT_KB=0

case "${1:-}" in
  --split) SPLIT_KB="${2:?--split needs a size in KB}" ;;
  "") ;;
  *) echo "usage: $0 [--split <KB>]" >&2; exit 2 ;;
esac

mkdir -p "$OUT"
# Clear only what THIS mode produces, so generating the split form does not
# delete a single-file bootstrap you generated a minute earlier.
if [ "$SPLIT_KB" -eq 0 ]; then
  rm -f "$OUT"/bootstrap.sh
else
  rm -f "$OUT"/part-*.sh "$OUT"/README.txt
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Pack from the PARENT so the archive contains the directory itself.
# dist/ is excluded: the generator's output never ships inside its own payload.
( cd "$ROOT/.." && tar czf "$TMP/h.tgz" \
    --exclude='.DS_Store' \
    --exclude="$NAME/dist" \
    --exclude="$NAME/progress/.session_start" \
    --exclude="$NAME/progress/.acu_per_hour" \
    "$NAME" )

SUM="$(shasum -a 256 "$TMP/h.tgz" | cut -d' ' -f1)"
FILES="$(tar tzf "$TMP/h.tgz" | grep -c '[^/]$')"

# -b 76 wraps the base64. Without it macOS emits ONE line ~90 KB long, which
# many terminals truncate or mangle on paste. This is the whole reason the
# payload is wrapped rather than dumped.
base64 -b 76 < "$TMP/h.tgz" > "$TMP/h.b64"

emit_header() {
  cat <<HDR
#!/usr/bin/env bash
# devin-sdd-harness — self-extracting bootstrap
# Generated $(date -u +%Y-%m-%dT%H:%MZ) · ${FILES} files · sha256 ${SUM}
#
# Paste this whole thing into a terminal, or: bash bootstrap.sh
# It creates ./${NAME}/ in the current directory and verifies itself.
set -eu

DEST="\${1:-${NAME}}"
if [ -e "\$DEST" ]; then
  echo "refusing to overwrite existing '\$DEST' — move it aside or pass another name" >&2
  exit 1
fi

for t in base64 tar shasum; do
  command -v "\$t" >/dev/null 2>&1 || { echo "missing required tool: \$t" >&2; exit 1; }
done

TMP="\$(mktemp -d)"
trap 'rm -rf "\$TMP"' EXIT

echo "decoding..."
base64 -d > "\$TMP/h.tgz" <<'PAYLOAD_EOF'
HDR
}

emit_footer() {
  cat <<'FTR'
PAYLOAD_EOF

GOT="$(shasum -a 256 "$TMP/h.tgz" | cut -d' ' -f1)"
if [ "$GOT" != "__SUM__" ]; then
  echo "CHECKSUM MISMATCH — the paste was truncated or mangled." >&2
  echo "  expected __SUM__" >&2
  echo "  got      $GOT" >&2
  echo "Re-paste, or use the --split parts." >&2
  exit 1
fi

tar xzf "$TMP/h.tgz"
chmod +x "__NAME__"/*.sh "__NAME__"/scripts/*.sh 2>/dev/null || true
[ "$DEST" = "__NAME__" ] || mv "__NAME__" "$DEST"

echo
echo "extracted __FILES__ files into ./$DEST"
echo "running the check..."
echo
( cd "$DEST" && ./init.sh )
FTR
}

# --- single file -------------------------------------------------------------
if [ "$SPLIT_KB" -eq 0 ]; then
  { emit_header; cat "$TMP/h.b64"; emit_footer; } \
    | sed -e "s|__SUM__|${SUM}|g" -e "s|__NAME__|${NAME}|g" -e "s|__FILES__|${FILES}|g" \
    > "$OUT/bootstrap.sh"
  chmod +x "$OUT/bootstrap.sh"
  printf 'dist/bootstrap.sh  %s KB, %s lines, %s files\n' \
    "$(( $(wc -c < "$OUT/bootstrap.sh") / 1024 ))" \
    "$(wc -l < "$OUT/bootstrap.sh" | tr -d ' ')" "$FILES"
  exit 0
fi

# --- split parts -------------------------------------------------------------
# Each part appends its slice to a scratch file; the last one decodes and
# verifies. Paste them in order; the parts refuse to run out of sequence.
LINES_PER_PART=$(( SPLIT_KB * 1024 / 77 ))
split -l "$LINES_PER_PART" "$TMP/h.b64" "$TMP/chunk."
TOTAL=$(ls "$TMP"/chunk.* | wc -l | tr -d ' ')

i=0
for c in "$TMP"/chunk.*; do
  i=$((i+1))
  PART="$(printf '%02d' "$i")"
  F="$OUT/part-${PART}.sh"
  {
    printf '#!/usr/bin/env bash\n'
    printf '# devin-sdd-harness bootstrap — part %s of %s\n' "$i" "$TOTAL"
    printf '# Paste the parts IN ORDER. The last one extracts and verifies.\n'
    printf 'set -eu\nSCRATCH="${TMPDIR:-/tmp}/devin-harness-boot.b64"\n'
    if [ "$i" -eq 1 ]; then
      printf ': > "$SCRATCH"\n'
    else
      printf '[ -s "$SCRATCH" ] || { echo "part %s ran before part 1 — start over from part-01.sh" >&2; exit 1; }\n' "$i"
    fi
    printf 'cat >> "$SCRATCH" <<'"'"'CHUNK_EOF'"'"'\n'
    cat "$c"
    printf 'CHUNK_EOF\n'
    printf 'echo "part %s/%s stored ($(wc -l < "$SCRATCH" | tr -d " ") lines so far)"\n' "$i" "$TOTAL"
    if [ "$i" -eq "$TOTAL" ]; then
      cat <<'LAST'
DEST="${1:-__NAME__}"
[ -e "$DEST" ] && { echo "refusing to overwrite existing '$DEST'" >&2; exit 1; }
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
base64 -d < "$SCRATCH" > "$TMP/h.tgz"
GOT="$(shasum -a 256 "$TMP/h.tgz" | cut -d' ' -f1)"
if [ "$GOT" != "__SUM__" ]; then
  echo "CHECKSUM MISMATCH — a part was truncated, mangled or pasted out of order." >&2
  echo "  expected __SUM__" >&2
  echo "  got      $GOT" >&2
  rm -f "$SCRATCH"
  echo "Scratch cleared. Start again from part-01.sh." >&2
  exit 1
fi
tar xzf "$TMP/h.tgz"
chmod +x "__NAME__"/*.sh "__NAME__"/scripts/*.sh 2>/dev/null || true
[ "$DEST" = "__NAME__" ] || mv "__NAME__" "$DEST"
rm -f "$SCRATCH"
echo; echo "extracted __FILES__ files into ./$DEST"; echo
( cd "$DEST" && ./init.sh )
LAST
    fi
  } | sed -e "s|__SUM__|${SUM}|g" -e "s|__NAME__|${NAME}|g" -e "s|__FILES__|${FILES}|g" > "$F"
  chmod +x "$F"
  printf 'dist/part-%s.sh  %s KB, %s lines\n' "$PART" \
    "$(( $(wc -c < "$F") / 1024 ))" "$(wc -l < "$F" | tr -d ' ')"
done

cat > "$OUT/README.txt" <<TXT
devin-sdd-harness — split bootstrap, ${TOTAL} parts, ${FILES} files
sha256 of payload: ${SUM}

Paste part-01.sh, then part-02.sh, and so on IN ORDER, into the same terminal.
Each one tells you it stored its chunk. The last one extracts, verifies the
checksum and runs ./init.sh.

A part pasted out of order, or a truncated paste, fails loudly on the checksum
and clears the scratch file. Nothing half-written ever lands on disk.
TXT
echo "dist/README.txt"
