# grokbot-bridge

[![License: MIT](https://img.shields.io/badge/license-MIT-black.svg)](./LICENSE)
[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-d97757.svg)](https://docs.claude.com/en/docs/claude-code/plugins)
[![Cursor Automations](https://img.shields.io/badge/Cursor-Automations-000000.svg)](https://cursor.com/docs/cloud-agent/automations)

Talk to a **Cursor Automation** from **Claude Code**. One slash command fires the automation's
webhook; the reply comes back through a channel you control (Google Drive outbox or Slack).

```
Claude Code ──/grok "..."──▶ POST webhook ──▶ Cursor Automation (cloud agent)
     ▲                                              │
     └──── reads reply ◀── Drive outbox / Slack ◀───┘
```

## Why not just MCP?

Cursor Automations expose a webhook **trigger**, not an MCP server. The webhook is
fire-and-forget: the POST starts a run, and the docs do not describe a reply to the caller.
This plugin wraps that trigger and standardizes the return path so the loop closes.

| Option | Direction | Notes |
|---|---|---|
| **Webhook + return channel (this plugin)** | two-way | Targets your existing automation |
| Cloud Agents API (`/v1/agents`) | two-way | Launches its own agents, not the automation |
| Automation "Send to Slack" | out only | Used here as an optional return channel |

## Install

```
/plugin marketplace add lucioamor/grokbot-bridge
/plugin install grokbot-bridge@grokbot-bridge
```

## Configure

Create a Cursor Automation with a **webhook** trigger, save it, and copy the URL and API key.
Set them as environment variables (never commit them):

```powershell
# Windows (PowerShell 7+)
[Environment]::SetEnvironmentVariable('GROKBOT_WEBHOOK_URL','https://api2.cursor.sh/automations/webhook/<id>','User')
[Environment]::SetEnvironmentVariable('GROKBOT_WEBHOOK_KEY','crsr_...','User')
```

```sh
# macOS / Linux
export GROKBOT_WEBHOOK_URL='https://api2.cursor.sh/automations/webhook/<id>'
export GROKBOT_WEBHOOK_KEY='crsr_...'
```

### Automation instruction (starter)

Paste into the automation so every call gets a reply:

```
A user is sending a command from Claude Code to this webhook. The command is in the payload
field "command"; "files" may list Drive file names or links. Do the work, never send, delete,
post or spend anything without asking in chat, and save your reply as
YYYY-MM-DD_ide-reply_<slug>.md in the "outbox" folder. If the payload is empty or unclear,
say what arrived and ask. Every webhook call gets a reply.
```

## Use

```
/grok resume o arquivo 2026-10-20_ata.docx e liste decisões pendentes
```

Or ask in plain language ("manda pro Grok ..."): the `grokbot` skill triggers.

Payload sent:

```json
{ "command": "...", "files": ["..."], "source": "claude-code", "sentAt": "2026-10-21T12:00:00Z" }
```

## What's inside

```
.claude-plugin/   plugin.json, marketplace.json
commands/grok.md  /grok slash command
skills/grokbot/   skill: send + receive protocol
scripts/          send.ps1 (pwsh 7+), send.sh (bash + curl + python3)
```

## Security

Secrets live only in env vars. See [SECURITY.md](./SECURITY.md). Anyone with the key can run your
automation, so keep its instructions conservative.

## Roadmap

- [ ] `receive` helper that polls the Drive outbox / Slack channel
- [ ] Signed payloads once Cursor documents webhook verification for automations
- [ ] Optional Cloud Agents API mode for streaming results

## License

[MIT](./LICENSE)
