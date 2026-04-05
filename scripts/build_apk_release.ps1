$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)

flutter build apk --release

$raw = Select-String -Path "pubspec.yaml" -Pattern "^version:\s*(.+)$" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }
if (-not $raw) { throw "Could not read version from pubspec.yaml" }
$parts = $raw -split "\+", 2
$verName = $parts[0]
$buildNum = if ($parts.Length -gt 1) { $parts[1] } else { "0" }

$destDir = "build/app/outputs/apk/release"
New-Item -ItemType Directory -Force -Path $destDir | Out-Null
$src = "build/app/outputs/flutter-apk/app-release.apk"
if (-not (Test-Path $src)) { throw "Missing $src — build failed?" }
$dst = Join-Path $destDir "NeonPulse-v${verName}-b${buildNum}.apk"
Copy-Item -Path $src -Destination $dst -Force
Write-Host "Copied: $dst"
