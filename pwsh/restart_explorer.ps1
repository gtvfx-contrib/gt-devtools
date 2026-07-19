
Write-Output "Restarting Windows Explorer..."
Stop-Process -Name explorer -Force
Start-Process explorer
Write-Output "Windows Explorer restarted."
