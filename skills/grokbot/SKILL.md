---
name: grokbot
description: Send a command to Grok Bot (Cursor Automation) from Claude Code through its webhook, and check for its reply. Use when the user says "manda pro Grok", "pergunta ao GrokBot", "send to Grok Bot", or wants Drive-side work done by Grok Bot.
---

# Grok Bot bridge

Grok Bot is a Cursor Automation with a webhook trigger. The webhook is **fire-and-forget**:
the POST starts a run; the answer is not guaranteed in the HTTP response. Replies appear in
the Grok Bot chat, prefixed `[IDE]`.

## Send

1. Confirm with the user the exact text if it is not already explicit. Never send secrets or PII from this repo.
2. Run:

```powershell
pwsh -NoProfile -File "${CLAUDE_PLUGIN_ROOT}/scripts/send.ps1" -Command "<text>" -Files "<drive file name or link>"
```

On macOS/Linux/Git Bash use `bash "${CLAUDE_PLUGIN_ROOT}/scripts/send.sh" "<text>" "<file>"`.

3. Report HTTP status and body. 2xx = run started, not finished.

Payload sent: `{ command, files[], source: "claude-code", sentAt }`. The automation prompt
tells Grok Bot to read `command`, look for files in the `!Grok Bot/uploads` Drive folder and reply
with `[IDE]`.

## Receive (return channel)

The webhook has no callback. Use one of:

- **Drive outbox (recommended, works with this setup):** ask Grok Bot to also save each reply as
  `YYYY-MM-DD_ide-reply_<slug>.md` in `!Grok Bot/outbox`. Read it with the Google Drive MCP
  (`search_files` then `read_file_content`).
- **Slack:** the automation has a "Send to Slack" tool; point replies to a channel and read it via Slack MCP.
- **Cloud Agents API** (`POST /v1/agents`, `POST /v1/agents/{id}/runs`, `GET .../runs/{runId}`):
  true two-way, but it launches its own agent, not the Automation. Use for new agents only.

## Rules

- The automation should follow the owner's standing rules (nothing sent/deleted/posted/spent
  without approval). Do not word commands to bypass that.
- Webhook URL/key live only in env vars `GROKBOT_WEBHOOK_URL` / `GROKBOT_WEBHOOK_KEY`.
  Never write them into files, commits or chat.
