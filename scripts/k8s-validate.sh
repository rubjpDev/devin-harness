#!/usr/bin/env bash
# =============================================================================
# k8s-validate.sh — validate manifests without any chance of applying them.
#
# `kubectl apply` is denied outright in .devin/config.json, and deny beats allow,
# so agents cannot reach even `--dry-run` directly. This wrapper is the only
# sanctioned path: it hard-codes --dry-run and refuses to pass anything else.
#
# Usage:  ./scripts/k8s-validate.sh <file-or-dir> [more...]
# =============================================================================
set -eu

[ $# -gt 0 ] || { echo "usage: $0 <manifest-or-dir> [...]" >&2; exit 2; }

# Refuse anything that looks like an attempt to smuggle in a real apply.
for a in "$@"; do
  case "$a" in
    -*) echo "[FAIL] flags are not accepted — paths only: $a" >&2; exit 2;;
  esac
done

command -v kubectl >/dev/null 2>&1 || { echo "[WARN] kubectl not found — skipping"; exit 0; }

STATUS=0
for target in "$@"; do
  [ -e "$target" ] || { echo "[FAIL] no such path: $target"; STATUS=1; continue; }
  echo "== dry-run: $target"
  if kubectl apply --dry-run=client -f "$target"; then
    echo "[OK]   $target"
  else
    echo "[FAIL] $target did not validate"
    STATUS=1
  fi
done

exit "$STATUS"
