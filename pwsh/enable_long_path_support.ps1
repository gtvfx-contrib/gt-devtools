# Enables long path support (\\?\) for Windows, allowing paths longer than 260 characters.
# Requires administrator privileges.

param(
    [Parameter(Mandatory=$false, HelpMessage="Skip the confirmation prompt.")]
    [switch]$Force,

    [Parameter(Mandatory=$false, HelpMessage="Preview the change without executing.")]
    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Elevate to Administrator if needed ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting administrator elevation..." -ForegroundColor Yellow
    try {
        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -NoProfile -File `"$PSCommandPath`" -Force" -Verb RunAs -Wait
        Write-Host "Elevated process launched. Exiting current session." -ForegroundColor Yellow
    }
    catch {
        Write-Host "Error: Administrator elevation was denied. Please run this script as Administrator." -ForegroundColor Red
        exit 1
    }
    exit 0
}

# --- Check current state ---
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
$regName = "LongPathsEnabled"

$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue
if ($currentValue) {
    $isAlreadyEnabled = ($currentValue.$regName -eq 1)
    if ($isAlreadyEnabled) {
        Write-Host "Long path support is already enabled." -ForegroundColor Green
        exit 0
    }
    else {
        Write-Host "Long path support is currently disabled (value: $($currentValue.$regName))." -ForegroundColor Yellow
    }
}
else {
    Write-Host "LongPathsEnabled registry value not found. It will be created." -ForegroundColor Yellow
}

# --- Confirm action ---
if (-not $Force) {
    $confirm = Read-Host "Enable long path support (sets $regName = 1 in HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem)"
    if ($confirm -ne 'yes') {
        Write-Host "Aborted." -ForegroundColor Yellow
        exit 0
    }
}

# --- Apply the change ---
try {
    if ($WhatIf) {
        Write-Host "[WHAT IF] Would execute:" -ForegroundColor Cyan
        Write-Host "  New-ItemProperty -Path `"$regPath`" -Name `"$regName`" -Value 1 -PropertyType DWord -Force" -ForegroundColor Gray
        exit 0
    }

    New-ItemProperty -Path $regPath -Name $regName -Value 1 -PropertyType DWord -Force | Out-Null

    # --- Verify ---
    $verify = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue
    if ($verify -and $verify.$regName -eq 1) {
        Write-Host "Long path support enabled successfully." -ForegroundColor Green
        Write-Host "Note: Some applications may require a restart to recognize this change." -ForegroundColor Yellow
    }
    else {
        Write-Host "Warning: Registry value set but verification failed. Check the registry manually." -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Host "Error: Failed to enable long path support: $_" -ForegroundColor Red
    exit 1
}
