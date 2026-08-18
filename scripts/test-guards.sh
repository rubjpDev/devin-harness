#!/usr/bin/env bash
# =============================================================================
# test-guards.sh — the one runnable check behind the two guard scripts.
#
# guard-prod.sh and redaction-scan.sh are the only things standing between an
# agent and a PROD mutation or a committed PAN. Both are regex logic, so both
# get a check. No framework: asserts and an exit code.
#
# Run:  ./scripts/test-guards.sh
# =============================================================================
set -u
cd "$(dirname "$0")/.." || exit 1

PASS=0 FAILED=0
chk() { # chk <BLOCK|ALLOW> <command>
  local want="$1" cmd="$2" got
  printf '{"tool_name":"exec","tool_input":{"command":%s}}' \
    "$(jq -Rn --arg c "$cmd" '$c')" | ./scripts/guard-prod.sh >/dev/null 2>&1
  [ $? -eq 2 ] && got=BLOCK || got=ALLOW
  if [ "$got" = "$want" ]; then
    PASS=$((PASS+1))
  else
    FAILED=$((FAILED+1)); printf '  FAIL want=%-5s got=%-5s  %s\n' "$want" "$got" "$cmd"
  fi
}

echo "== guard-prod.sh =="
chk BLOCK 'kubectl apply -f k8s/'
chk BLOCK 'kubectl -n dev scale deploy/x --replicas=0'
chk BLOCK 'kubectl --context=prod-uk delete pod foo'
chk BLOCK 'helm upgrade svc ./chart'
chk BLOCK 'terraform -chdir=infra apply'
chk BLOCK 'ssh node systemctl restart svc'
chk BLOCK 'kubectl logs deploy/svc'                      # unbounded
chk BLOCK 'psql -c "DELETE FROM t WHERE id=1"'
chk BLOCK 'psql -c "UPDATE mandates SET status = 1"'
chk ALLOW 'kubectl get pods -n prod-uk -o wide'
chk ALLOW 'kubectl describe pod x -n pre'
chk ALLOW 'kubectl logs deploy/svc -n pre --since=30m --tail=500'
chk ALLOW 'kubectl top pods -n prod'
chk ALLOW './scripts/k8s-validate.sh k8s/'
chk ALLOW 'helm lint charts/svc'
chk ALLOW 'git diff HEAD~1'
chk ALLOW 'grep -rn "timeout" src/'
chk ALLOW 'psql -c "SELECT count(*) FROM t LIMIT 1"'

echo "== redaction-scan.sh =="
TMP="progress/.guardtest.md"
scan_should() { # scan_should <fail|pass> <content> <label>
  printf '%s\n' "$2" > "$TMP"
  if ./scripts/redaction-scan.sh >/dev/null 2>&1; then got=pass; else got=fail; fi
  rm -f "$TMP"
  if [ "$got" = "$1" ]; then PASS=$((PASS+1)); else
    FAILED=$((FAILED+1)); printf '  FAIL want=%-4s got=%-4s  %s\n' "$1" "$got" "$3"
  fi
}
scan_should fail 'card 4111 1111 1111 1111'          "PAN"
scan_should fail 'sort code 09-01-27'                "sort code"
scan_should fail 'contact jane.doe@santander.co.uk'  "email"
scan_should fail 'GB29NWBK60161331926819'            "IBAN"
scan_should fail 'api_key = sk-abcdefghijklmnop1234' "credential"
scan_should pass 'a customer with an expired card on file'    "redacted prose"
scan_should pass '14:02 ERROR [corr=7f3a-91c2] read timeout'  "redacted log line"

echo
if [ "$FAILED" -eq 0 ]; then
  echo "[OK]   ${PASS} checks passed"
  exit 0
fi
echo "[FAIL] ${FAILED} failed, ${PASS} passed"
exit 1
