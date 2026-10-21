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
payload=$(python3 - "$command_text" "$@" <<'PY'
import json, sys, datetime
print(json.dumps({
    "command": sys.argv[1],
    "files": sys.argv[2:],
    "source": "claude-code",
    "sentAt": datetime.datetime.now(datetime.timezone.utc).isoformat(),
}, ensure_ascii=False))
PY
)

curl -sS -w '\nHTTP %{http_code}\n' -X POST "$GROKBOT_WEBHOOK_URL" \
  -H "Authorization: Bearer $GROKBOT_WEBHOOK_KEY" \
  -H 'Content-Type: application/json; charset=utf-8' \
  --data-binary "$payload"
