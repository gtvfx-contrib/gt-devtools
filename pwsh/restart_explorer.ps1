
param(
    [Parameter(Mandatory=$false, HelpMessage="Skip the confirmation prompt.")]
    [switch]$Force,

    [Parameter(Mandatory=$false, HelpMessage="Preview the action without executing.")]
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$explorerRunning = Get-Process -Name explorer -ErrorAction SilentlyContinue
if ($explorerRunning) {
    Write-Host "Windows Explorer is currently running (PID: $($explorerRunning.Id))." -ForegroundColor Cyan
}
else {
    Write-Host "Windows Explorer is not running." -ForegroundColor Yellow
}

if (-not $Force) {
    $confirm = Read-Host "Type 'yes' to restart Windows Explorer"
    if ($confirm -ne 'yes') {
        Write-Host "Aborted." -ForegroundColor Yellow
        exit 0
    }
}

if ($DryRun) {
    Write-Host "[DRY RUN] Would execute:" -ForegroundColor Cyan
    if ($explorerRunning) {
        Write-Host "  Stop-Process -Name explorer -Force" -ForegroundColor Gray
    }
    Write-Host "  Start-Process explorer" -ForegroundColor Gray
    exit 0
}

try {
    Write-Host "Restarting Windows Explorer..." -ForegroundColor Cyan

    if ($explorerRunning) {
        Stop-Process -Name explorer -Force -ErrorAction Stop
        Write-Host "Explorer process stopped." -ForegroundColor Green
        Start-Sleep -Seconds 2
    }

    Start-Process explorer -ErrorAction Stop
    Write-Host "Windows Explorer restarted successfully." -ForegroundColor Green
}
catch {
    Write-Host "Error: Failed to restart Windows Explorer: $_" -ForegroundColor Red
    exit 1
}
