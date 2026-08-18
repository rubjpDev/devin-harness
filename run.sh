#!/usr/bin/env bash
# Launch Devin CLI as the orchestrator for this harness.
#
# The orchestrator model is set in .devin/config.json ("model": "sonnet").
# Per-agent models live in each .devin/agents/*.md frontmatter — do NOT pass a
# global model override here, it would flatten the ACU tiering.
#
# Usage:  ./run.sh                    interactive
#         ./run.sh "INC-1234: ..."    with an opening prompt
set -eu
cd "$(dirname "$0")"

command -v devin >/dev/null 2>&1 || {
  echo "devin CLI not found. Install it, then: devin auth login" >&2; exit 1; }

# Structure + guard check before starting. Runs no tests; takes about a second.
./init.sh || { echo "Check is red — fix it before starting a session." >&2; exit 1; }

exec devin "$@"
