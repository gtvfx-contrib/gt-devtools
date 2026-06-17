@{
    RootModule        = 'MessageBox.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'c4e6a8d1-3b2f-4e7a-9d05-f1b2c3d4e5f6'
    Author            = 'gtvfx'
    Description       = 'Display Windows Forms message boxes from PowerShell with the terminal as the owner window.'
    PowerShellVersion = '5.1'

    FunctionsToExport = @('Show-MessageBox')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
