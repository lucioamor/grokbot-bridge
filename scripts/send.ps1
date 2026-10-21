#requires -Version 7
<#
Sends a command to the Grok Bot Cursor Automation webhook.
Secrets come from user env vars only (never stored in files):
  GROKBOT_WEBHOOK_URL  e.g. https://api2.cursor.sh/automations/webhook/<id>
  GROKBOT_WEBHOOK_KEY  the crsr_... key
#>
param(
  [Parameter(Mandatory)][string]$Command,
  [string[]]$Files = @()
)

$ErrorActionPreference = 'Stop'

$url = $env:GROKBOT_WEBHOOK_URL
$key = $env:GROKBOT_WEBHOOK_KEY
if (-not $url -or -not $key) {
  Write-Error 'Set GROKBOT_WEBHOOK_URL and GROKBOT_WEBHOOK_KEY as user environment variables.'
}

# Correlation id: ISO date + time (UTC, to the second) + 4 hex chars, e.g. 2026-10-21T143005Z-a3f9
$now = (Get-Date).ToUniversalTime()
$id  = '{0}-{1}' -f $now.ToString("yyyy-MM-dd'T'HHmmss'Z'"), (Get-Random -Maximum 65536).ToString('x4')

$body = [ordered]@{
  id      = $id
  command = $Command
  files   = $Files
  source  = 'claude-code'
  sentAt  = $now.ToString('o')
} | ConvertTo-Json -Depth 5

$bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($body)
$resp = Invoke-WebRequest -Method Post -Uri $url `
  -Headers @{ Authorization = "Bearer $key" } `
  -ContentType 'application/json; charset=utf-8' `
  -Body $bytes -SkipHttpErrorCheck

"ID $id"
"HTTP $([int]$resp.StatusCode)"
$resp.Content
