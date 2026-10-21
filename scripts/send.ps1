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

$body = [ordered]@{
  command = $Command
  files   = $Files
  source  = 'claude-code'
  sentAt  = (Get-Date).ToUniversalTime().ToString('o')
} | ConvertTo-Json -Depth 5

$bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($body)
$resp = Invoke-WebRequest -Method Post -Uri $url `
  -Headers @{ Authorization = "Bearer $key" } `
  -ContentType 'application/json; charset=utf-8' `
  -Body $bytes -SkipHttpErrorCheck

"HTTP $([int]$resp.StatusCode)"
$resp.Content
