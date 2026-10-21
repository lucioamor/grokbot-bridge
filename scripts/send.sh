#!/usr/bin/env bash
# Sends a command to a Cursor Automation webhook (macOS/Linux/Git Bash).
# Secrets come from env vars only:
#   GROKBOT_WEBHOOK_URL  https://api2.cursor.sh/automations/webhook/<id>
#   GROKBOT_WEBHOOK_KEY  crsr_...
# Usage: send.sh "<command text>" [file-name-or-link ...]
set -euo pipefail

: "${GROKBOT_WEBHOOK_URL:?set GROKBOT_WEBHOOK_URL}"
: "${GROKBOT_WEBHOOK_KEY:?set GROKBOT_WEBHOOK_KEY}"
[ $# -ge 1 ] || { echo "usage: send.sh \"<command>\" [files...]" >&2; exit 2; }

command_text=$1; shift
# Correlation id: ISO date + time (UTC, to the second) + 4 hex chars, e.g. 2026-10-21T143005Z-a3f9
id="$(date -u +%Y-%m-%dT%H%M%SZ)-$(printf '%04x' $((RANDOM % 65536)))"
payload=$(python3 - "$id" "$command_text" "$@" <<'PY'
import json, sys, datetime
print(json.dumps({
    "id": sys.argv[1],
    "command": sys.argv[2],
    "files": sys.argv[3:],
    "source": "claude-code",
    "sentAt": datetime.datetime.now(datetime.timezone.utc).isoformat(),
}, ensure_ascii=False))
PY
)
echo "ID $id"

curl -sS -w '\nHTTP %{http_code}\n' -X POST "$GROKBOT_WEBHOOK_URL" \
  -H "Authorization: Bearer $GROKBOT_WEBHOOK_KEY" \
  -H 'Content-Type: application/json; charset=utf-8' \
  --data-binary "$payload"
