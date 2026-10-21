# Security

## Secrets

This plugin never stores the webhook URL or key. Both are read from environment variables
(`GROKBOT_WEBHOOK_URL`, `GROKBOT_WEBHOOK_KEY`) at call time. Never commit them, paste them in
issues, or print them in chat. If a key leaks, regenerate it in the Cursor Automation settings.

## What a command can do

The webhook starts a run of **your** automation with **your** automation's tools. Anyone holding
the key can trigger it. Keep the automation's instructions conservative (for example: prepare,
never send/delete/post/spend without asking) and treat the key like a password.

## Reporting a vulnerability

Open a private advisory: Security tab > "Report a vulnerability".
