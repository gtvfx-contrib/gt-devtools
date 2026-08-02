# This gets the status of the GlobalProtect VPN connection

param(
    [Parameter(Mandatory=$false, HelpMessage="Show detailed information about all GlobalProtect adapters.")]
    [switch]$Detailed
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$pangpAdapters = Get-NetAdapter -InterfaceDescription "PANGP*" -ErrorAction SilentlyContinue

if (-not $pangpAdapters) {
    Write-Host "GlobalProtect VPN is not installed or not connected." -ForegroundColor Yellow
    exit 1
}

if ($Detailed) {
    $pangpAdapters | Format-Table -AutoSize Name, InterfaceDescription, InterfaceIndex, Status, MacAddress
    exit 0
}

# Determine overall connection status
$connectedCount = ($pangpAdapters | Where-Object { $_.Status -eq 'Up' }).Count
$disconnectedCount = ($pangpAdapters | Where-Object { $_.Status -eq 'Disconnected' }).Count

if ($connectedCount -gt 0) {
    Write-Host "GlobalProtect VPN is connected." -ForegroundColor Green
    exit 0
}
elseif ($disconnectedCount -gt 0) {
    Write-Host "GlobalProtect VPN is disconnected." -ForegroundColor Red
    exit 1
}
else {
    Write-Host "GlobalProtect VPN status is unknown." -ForegroundColor Yellow
    exit 1
}
