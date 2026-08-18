#!/usr/bin/env bash
# =============================================================================
# guard-prod.sh — PreToolUse hook on `exec`. Last line of defence.
#
# .devin/config.json already denies the mutating verbs. This catches what a
# permission pattern cannot: a mutating command reaching a PRE or PROD context
# through a pipe, a shell wrapper, an alias, or a --context/-n flag.
#
# Reads the hook payload on stdin, prints a block decision on stdout.
# Exit 0 with no output = allow. Never fails open on a match.
# =============================================================================
set -u

INPUT="$(cat 2>/dev/null || true)"

# Blocking works on both agent generations at once:
#   - Devin CLI / Devin Local read the JSON decision on stdout.
#   - Cascade (legacy Windsurf) reads exit code 2 and ignores stdout.
# Exit 2 also blocks in the CLI, so emitting both is safe everywhere and means
# one script covers .devin/hooks.v1.json and .windsurf/hooks.json alike.
#
# Reasons are static, quote-free ASCII plus em dashes, so they need no escaping.
# That keeps `block` working even when jq is the thing that's missing.
block() {
  printf '{"decision":"block","reason":"%s"}\n' "$1"
  printf 'BLOCKED: %s\n' "$1" >&2
  exit 2
}

# FAIL CLOSED. Without jq this script cannot read the command it is meant to
# police, and a security hook that cannot see its input must not wave things
# through. Blocking every exec is loud and obvious; silently disabling the PROD
# guard is neither.
command -v jq >/dev/null 2>&1 || \
  block "guard-prod.sh cannot run: jq is not installed, so the PROD guard cannot inspect this command. Install it (brew install jq) — every exec is blocked until then."

# Devin CLI / Devin Local put the command under .tool_input; Cascade puts it in
# .command_line. Accept both so one script serves both hook files.
CMD="$(printf '%s' "$INPUT" | jq -r '
  .tool_input.command // .tool_input.cmd // .command_line // .command // empty
' 2>/dev/null)"
[ -n "$CMD" ] || exit 0

LOWER="$(printf '%s' "$CMD" | tr '[:upper:]' '[:lower:]')"

# 1. A mutating tool plus a mutating verb, anywhere on the line.
#
# Deliberately not positional: `kubectl -n dev --context=prod scale ...` puts
# arbitrary flags and their values between the binary and the verb, and every
# regex that tries to model that has a hole in it. Tool + verb as separate word
# matches has no hole. It can over-block (`kubectl get pods | grep delete`);
# over-blocking is the safe direction and the human can run it themselves.
tool_verb() { # tool_verb <tool-regex> <verb-regex>
  printf '%s' "$LOWER" | grep -qE "(^|[^a-z0-9_-])$1([^a-z0-9_-]|$)" &&
  printf '%s' "$LOWER" | grep -qE "(^|[[:space:]])$2([[:space:]]|$)"
}
if tool_verb 'kubectl|oc' '(apply|delete|scale|rollout|edit|patch|drain|cordon|uncordon|replace|annotate|label|set|create|expose|taint)' \
   || tool_verb 'helm' '(upgrade|install|uninstall|rollback)' \
   || tool_verb 'terraform|tofu' '(apply|destroy|import)' \
   || tool_verb 'argocd' '(sync|delete)' \
   || tool_verb 'systemctl|service' '(restart|stop|start|reload)'; then
  block "Mutating infrastructure command. Agents never apply changes — write the exact command into the diagnosis or impl report and let the human run it. See docs/environments.md."
fi

# 2. Write SQL.
if printf '%s' "$LOWER" | grep -qE '(^|[^a-z])(insert[[:space:]]+into|update[[:space:]]+[a-z_.\"]+[[:space:]]+set|delete[[:space:]]+from|drop[[:space:]]+(table|database|schema)|truncate[[:space:]]+table|alter[[:space:]]+table)'; then
  block "Write SQL detected. Agents run read-only queries only. Describe the experiment in the diagnosis and let the human decide. See docs/environments.md."
fi

# 3. Anything at all aimed at a prod/pre context, when it isn't clearly a read.
if printf '%s' "$LOWER" | grep -qE '(prod|prd|pre|preprod|live)'; then
  if ! printf '%s' "$LOWER" | grep -qE 'kubectl[[:space:]]+(get|describe|logs|top|explain|api-resources|config[[:space:]]+get)|^[[:space:]]*(grep|cat|less|tail|head|jq|awk|sed[[:space:]]+-n|ls|find|git[[:space:]]+(log|diff|show|status))'; then
    block "Command references a PRE/PROD context and is not a recognised read-only operation. If it is a read, run it as an explicit kubectl get/describe/logs/top. Otherwise hand it to the human. See docs/environments.md."
  fi
fi

# 4. Unbounded log pull.
if printf '%s' "$LOWER" | grep -qE 'kubectl[[:space:]]+logs' \
   && ! printf '%s' "$LOWER" | grep -qE '(--since|--since-time|--tail)'; then
  block "Unbounded kubectl logs. Bound it with --since / --since-time / --tail. See docs/environments.md."
fi

exit 0
