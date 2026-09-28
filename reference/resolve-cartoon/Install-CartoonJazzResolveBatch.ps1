$ErrorActionPreference = 'Stop'
$source = Join-Path $PSScriptRoot 'CartoonJazzResolveBatch.lua'
$targetDir = Join-Path $env:APPDATA 'Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Utility'
$target = Join-Path $targetDir 'Cartoon Jazz - Import and Render Batch.lua'

if (!(Test-Path -LiteralPath $source)) { throw "Script not found: $source" }
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
Copy-Item -LiteralPath $source -Destination $target -Force
$previous = Join-Path $targetDir 'Cartoon Jazz - Import and Render Batch.py'
if (Test-Path -LiteralPath $previous) { Remove-Item -LiteralPath $previous -Force }
Write-Output "Installed Resolve menu script: $target"
Write-Output 'Restart DaVinci Resolve once to load the new menu item.'
Write-Output 'Run: Workspace > Scripts > Cartoon Jazz - Import and Render Batch'
