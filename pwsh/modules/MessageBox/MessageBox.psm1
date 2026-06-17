<#
.SYNOPSIS
    PowerShell module for displaying Windows Forms message boxes with the
    terminal as the owner window.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Win32Window {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
}
"@

function Show-MessageBox {
    <#
    .SYNOPSIS
        Display a Windows Forms message box with the terminal as the owner window.

    .DESCRIPTION
        Shows a modal Windows Forms message box. When run from a console host,
        attempts to obtain the terminal's window handle via GetConsoleWindow() and
        assigns it as the owner so the dialog appears focused and in front of the
        terminal. Falls back to a standard unowned message box when no console
        window is available (e.g. when running headlessly or under a non-console
        host).

        Returns the DialogResult so callers can branch on OK / Cancel / Yes / No
        without needing a separate prompt.

    .PARAMETER Message
        The text displayed in the body of the message box.

    .PARAMETER Title
        The text displayed in the title bar. Defaults to 'Message'.

    .PARAMETER Buttons
        The set of buttons to display. Accepts any System.Windows.Forms.MessageBoxButtons
        value (OK, OKCancel, YesNo, YesNoCancel, RetryCancel, AbortRetryIgnore).
        Defaults to OK.

    .PARAMETER Icon
        The icon displayed alongside the message text. Accepts any
        System.Windows.Forms.MessageBoxIcon value (Information, Warning, Error, Question,
        etc.). Defaults to Information.

    .OUTPUTS
        System.Windows.Forms.DialogResult
        The button the user clicked (e.g. OK, Cancel, Yes, No).

    .EXAMPLE
        Show-MessageBox -Message 'Deployment complete.' -Title 'Done'

        Displays an informational message box with an OK button.

    .EXAMPLE
        $result = Show-MessageBox -Message 'Overwrite existing file?' `
                                  -Title 'Confirm' `
                                  -Buttons YesNo `
                                  -Icon Question
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            # proceed
        }

        Prompts the user with Yes/No buttons and branches on the result.

    .EXAMPLE
        Show-MessageBox -Message 'Build failed.' -Title 'Error' -Icon Error

        Displays an error icon message box.
    #>
    [CmdletBinding()]
    [OutputType([System.Windows.Forms.DialogResult])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter()]
        [string]$Title = 'Message',

        [Parameter()]
        [System.Windows.Forms.MessageBoxButtons]$Buttons = [System.Windows.Forms.MessageBoxButtons]::OK,

        [Parameter()]
        [System.Windows.Forms.MessageBoxIcon]$Icon = [System.Windows.Forms.MessageBoxIcon]::Information
    )

    $terminalHandle = [Win32Window]::GetConsoleWindow()
    $owner = $null

    if ($terminalHandle -ne [IntPtr]::Zero) {
        $owner = [System.Windows.Forms.NativeWindow]::new()
        $owner.AssignHandle($terminalHandle)
    }

    try {
        if ($owner) {
            [System.Windows.Forms.MessageBox]::Show($owner, $Message, $Title, $Buttons, $Icon)
        } else {
            [System.Windows.Forms.MessageBox]::Show($Message, $Title, $Buttons, $Icon)
        }
    } finally {
        if ($owner) {
            $owner.ReleaseHandle()
        }
    }
}


Export-ModuleMember -Function @(
    'Show-MessageBox'
)
