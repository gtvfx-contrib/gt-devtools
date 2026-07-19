#-------------------------------------------------------------------------------
#region realRoot
#-------------------------------------------------------------------------------
# We're loading via a symlink so $PSScriptRoot is the directory of the symlink, 
# not the actual file location. We'll resolve the symlink to get the real file 
# location for loading any other config files relative to this location.
$realRoot = Split-Path (Get-Item $PSCommandPath).Target

#endregion realRoot
#-------------------------------------------------------------------------------
#region Oh-My-Posh
#-------------------------------------------------------------------------------
# Oh-My-Posh is a popular prompt theme engine for PowerShell. 

# This loads the main style graphics and config.
& "$realRoot\posh-windows-amd64" init pwsh --config "$realRoot\custom.omp.json" | Invoke-Expression

#endregion Oh-My-Posh
#-------------------------------------------------------------------------------
#region Terminal-Icons
#-------------------------------------------------------------------------------
# This adds icons to file and folder info in commands like Get-ChildItem and ls.

if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Repository PSGallery -Force
}
Import-Module Terminal-Icons

#endregion Terminal-Icons
#-------------------------------------------------------------------------------
#region PSReadLine Prediction
#-------------------------------------------------------------------------------
# This enables the new AI-powered command prediction feature in PowerShell 7.2 and later.

Set-PSReadLineOption -PredictionViewStyle ListView

#endregion PSReadLine Prediction
#-------------------------------------------------------------------------------
#region functions and aliases
#--------------------------------------------------------------------------------
# Custom functions and aliases can be added here:

# ll is a common alias for Get-ChildItem -Force, similar to 'ls -la' in Linux.
function ll { Get-ChildItem -Force $args }

# rg is a wrapper for ripgrep (rg.exe) that sanitizes Windows-style paths to use forward slashes, which ripgrep prefers.
function rg {
    $argsSanitized = $args | ForEach-Object {
        if ($_ -match '^[A-Z]:\\') {
            # Convert backslashes to forward slashes for ripgrep stability
            $_ -replace '\\', '/'
        } else {
            $_
        }
    }
    & rg.exe $argsSanitized
}

#endregion functions and aliases
#-------------------------------------------------------------------------------
#region VSCode PATH integration
#-------------------------------------------------------------------------------

if ($env:TERM_PROGRAM -eq 'vscode') {
    $pathsToAdd = @('cmd', 'pwsh') | ForEach-Object { Join-Path ($env:DEV_TOOLS_ROOT) $_ }
    $currentEntries = [System.Collections.Generic.List[string]]($env:PATH -split ';' | Where-Object { $_ -ne '' })

    foreach ($path in $pathsToAdd) {
        if (-not $currentEntries.Contains($path)) {
            $currentEntries.Add($path)
        }
    }
    $env:PATH = $currentEntries -join ';'
}

#endregion VSCode PATH integration
#-------------------------------------------------------------------------------
#region User Customization
#-------------------------------------------------------------------------------

# Allow per-user customization by sourcing an optional script at $env:DEV_CONFIG\pwsh\profile.local.ps1.
# Users can set DEV_CONFIG to a directory containing their personal config files.
if ($env:DEV_CONFIG) {
    $userProfile = Join-Path $env:DEV_CONFIG 'pwsh\profile.local.ps1'
    if (Test-Path $userProfile) {
        . $userProfile
    }
}

#endregion User Customization
#-------------------------------------------------------------------------------
