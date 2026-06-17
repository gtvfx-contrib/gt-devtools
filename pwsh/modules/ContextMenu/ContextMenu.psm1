<#
.SYNOPSIS
    Canonical module for managing Windows Explorer context menu entries via the registry.

.DESCRIPTION
    Provides a consistent, scalable interface for adding and removing HKCU context menu
    items across File, Directory, and Directory Background scopes.

    Each context menu entry is defined as a hashtable:

        $entry = @{
            Name        = 'MyTool'               # Registry key name
            DisplayName = 'Open with My Tool'    # Text shown in context menu
            Command     = '"C:\path\to\tool.exe" "%V"'  # Shell command
            Icon        = 'C:\path\to\icon.ico'  # Optional
            Scopes      = @('File', 'Directory', 'Background')
        }

.NOTES
    Scopes:
        File        -> HKCU:\Software\Classes\*\shell\
        Directory   -> HKCU:\Software\Classes\Directory\shell\
        Background  -> HKCU:\Software\Classes\Directory\background\shell\

    The File scope registry path contains a literal '*' key. PowerShell's registry
    provider treats '*' as a wildcard in -Path arguments, so all registry operations
    in this module use -LiteralPath or the .NET Microsoft.Win32.Registry API to
    avoid wildcard expansion.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:ScopeRoots = @{
    File        = 'HKCU:\Software\Classes\*\shell'
    Directory   = 'HKCU:\Software\Classes\Directory\shell'
    Background  = 'HKCU:\Software\Classes\Directory\background\shell'
}

# Registry paths for the Windows 11 classic context menu tweak.
# The InprocServer32 key with an empty default value masks the Win11 compact
# menu COM object, restoring the legacy full context menu.
$script:ClassicMenuClsidPath   = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}'
$script:ClassicMenuKeyPath     = "$script:ClassicMenuClsidPath\InprocServer32"


function script:Get-EntryPath {
    param([string]$Scope, [string]$Name)
    return Join-Path $script:ScopeRoots[$Scope] $Name
}


function script:New-RegistryKeyLiteral {
    # New-Item does not support -LiteralPath, so we use the .NET API directly
    # to create registry keys that contain literal wildcard characters (e.g. '*').
    param([string]$HkcuPath)
    $regPath = $HkcuPath -replace '^HKCU:\\', ''
    $key = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($regPath)
    if ($key) { $key.Close() }
}


function script:Test-ClassicContextMenuActive {
    # Returns $true if the InprocServer32 key exists with an empty default value,
    # which is the state that activates the classic context menu.
    if (-not (Test-Path -LiteralPath $script:ClassicMenuKeyPath)) {
        return $false
    }
    $regPath = $script:ClassicMenuKeyPath -replace '^HKCU:\\', ''
    $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($regPath)
    if (-not $key) { return $false }
    $defaultValue = $key.GetValue('')
    $key.Close()
    return $null -ne $defaultValue
}


function Test-ContextMenuItem {
    <#
    .SYNOPSIS
        Returns $true if the context menu entry exists for all specified scopes.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Entry
    )

    foreach ($scope in $Entry.Scopes) {
        $path = script:Get-EntryPath -Scope $scope -Name $Entry.Name
        if (-not (Test-Path -LiteralPath $path)) {
            return $false
        }
    }
    return $true
}


function Register-ContextMenuItem {
    <#
    .SYNOPSIS
        Registers a context menu entry in the Windows registry for the current user.

    .DESCRIPTION
        Creates the required registry keys under HKCU for each specified scope.
        Idempotent — safe to run multiple times.

        By default, also ensures the Windows 11 classic context menu is active so
        that registered entries are always visible without clicking "Show more options".
        Set -RestoreClassicMenu:$false to opt out of this behaviour.

    .PARAMETER Entry
        Hashtable defining the context menu entry. Required keys: Name, DisplayName,
        Command, Scopes. Optional key: Icon.

    .PARAMETER RestoreClassicMenu
        When $true (default), ensures the Windows 11 classic (legacy) context menu
        registry entry is present so custom entries appear without an extra click.
        Pass $false to skip this step.

    .EXAMPLE
        $entry = @{
            Name        = 'EnvoyCode'
            DisplayName = 'Open with Envoy Code'
            Command     = '"C:\tools\envoycode.bat" "%V"'
            Icon        = 'C:\tools\envoycode.ico'
            Scopes      = @('File', 'Directory', 'Background')
        }
        Register-ContextMenuItem -Entry $entry

    .EXAMPLE
        Register-ContextMenuItem -Entry $entry -RestoreClassicMenu:$false
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Entry,

        [bool]$RestoreClassicMenu = $true
    )

    if ($RestoreClassicMenu) {
        Enable-ClassicContextMenu
    }

    foreach ($scope in $Entry.Scopes) {
        $entryPath   = script:Get-EntryPath -Scope $scope -Name $Entry.Name
        $commandPath = Join-Path $entryPath 'command'

        try {
            if (-not (Test-Path -LiteralPath $entryPath)) {
                script:New-RegistryKeyLiteral $entryPath
            }
            Set-ItemProperty -LiteralPath $entryPath -Name '(default)' -Value $Entry.DisplayName

            if ($Entry.ContainsKey('Icon') -and $Entry.Icon) {
                Set-ItemProperty -LiteralPath $entryPath -Name 'Icon' -Value $Entry.Icon
            }

            if (-not (Test-Path -LiteralPath $commandPath)) {
                script:New-RegistryKeyLiteral $commandPath
            }
            Set-ItemProperty -LiteralPath $commandPath -Name '(default)' -Value $Entry.Command

            Write-Host "  [+] Registered [$scope] $($Entry.Name)" -ForegroundColor Green
        }
        catch {
            Write-Error "  [!] Failed to register [$scope] $($Entry.Name): $_"
        }
    }
}


function Unregister-ContextMenuItem {
    <#
    .SYNOPSIS
        Removes a context menu entry from the Windows registry for the current user.

    .DESCRIPTION
        Deletes the registry keys for each specified scope. Silently skips entries
        that do not exist. Idempotent — safe to run multiple times.

    .PARAMETER Entry
        Hashtable defining the context menu entry. Required keys: Name, Scopes.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Entry
    )

    foreach ($scope in $Entry.Scopes) {
        $entryPath = script:Get-EntryPath -Scope $scope -Name $Entry.Name

        try {
            if (Test-Path -LiteralPath $entryPath) {
                Remove-Item -LiteralPath $entryPath -Recurse -Force
                Write-Host "  [-] Removed [$scope] $($Entry.Name)" -ForegroundColor Yellow
            }
            else {
                Write-Host "  [=] Not found  [$scope] $($Entry.Name) (skipped)" -ForegroundColor DarkGray
            }
        }
        catch {
            Write-Error "  [!] Failed to remove [$scope] $($Entry.Name): $_"
        }
    }
}


function Enable-ClassicContextMenu {
    <#
    .SYNOPSIS
        Restores the classic (Windows 10-style) right-click context menu in Windows 11.

    .DESCRIPTION
        Creates the registry key that masks Windows 11's modern context menu shell
        extension, restoring the full legacy context menu on right-click. Idempotent —
        safe to call multiple times.

        To apply changes, restart Windows Explorer or call Restart-WindowsExplorer.

        To revert, call Disable-ClassicContextMenu.
    #>
    [CmdletBinding()]
    param()

    if (script:Test-ClassicContextMenuActive) {
        Write-Host '  [=] Classic context menu already enabled.' -ForegroundColor DarkGray
        return
    }

    try {
        $regPath = $script:ClassicMenuKeyPath -replace '^HKCU:\\', ''
        $key = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($regPath)
        if ($key) {
            $key.SetValue('', '')
            $key.Close()
        }
        Write-Host '  [+] Classic context menu enabled.' -ForegroundColor Green
    }
    catch {
        Write-Error "  [!] Failed to enable classic context menu: $_"
    }
}


function Disable-ClassicContextMenu {
    <#
    .SYNOPSIS
        Restores the Windows 11 modern right-click context menu.

    .DESCRIPTION
        Removes the registry key that forces the classic context menu, reverting to
        Windows 11's default modern context menu. Idempotent — safe to call multiple times.

        To apply changes, restart Windows Explorer or call Restart-WindowsExplorer.
    #>
    [CmdletBinding()]
    param()

    if (-not (Test-Path -LiteralPath $script:ClassicMenuClsidPath)) {
        Write-Host '  [=] Modern context menu already active (key not present).' -ForegroundColor DarkGray
        return
    }

    try {
        Remove-Item -LiteralPath $script:ClassicMenuClsidPath -Recurse -Force
        Write-Host '  [-] Classic context menu disabled (Windows 11 modern menu restored).' -ForegroundColor Yellow
    }
    catch {
        Write-Error "  [!] Failed to disable classic context menu: $_"
    }
}


function Restart-WindowsExplorer {
    <#
    .SYNOPSIS
        Safely restarts Windows Explorer to apply context menu changes.
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n  Restarting Windows Explorer..." -ForegroundColor Cyan

    try {
        $explorer = Get-Process -Name explorer -ErrorAction SilentlyContinue
        if ($explorer) {
            Stop-Process -Id $explorer.Id -Force
            Start-Sleep -Milliseconds 500
        }
        Start-Process explorer.exe
        Write-Host "  [+] Explorer restarted." -ForegroundColor Green
    }
    catch {
        Write-Error "  [!] Failed to restart Explorer: $_"
    }
}


Export-ModuleMember -Function @(
    'Register-ContextMenuItem'
    'Unregister-ContextMenuItem'
    'Test-ContextMenuItem'
    'Enable-ClassicContextMenu'
    'Disable-ClassicContextMenu'
    'Restart-WindowsExplorer'
)
