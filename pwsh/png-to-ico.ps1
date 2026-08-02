param(
    [Parameter(Mandatory=$true, HelpMessage="Path to the source PNG file.")]
    [string]$source,

    [Parameter(Mandatory=$true, HelpMessage="Path to the output ICO file.")]
    [string]$output
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Validate source file ---
if (-not (Test-Path $source -PathType Leaf)) {
    Write-Host "Error: Source file not found: $source" -ForegroundColor Red
    exit 1
}

$sourceExt = [System.IO.Path]::GetExtension($source).ToLower()
if ($sourceExt -ne '.png') {
    Write-Host "Error: Source file must be a PNG file. Got: '$sourceExt'" -ForegroundColor Red
    exit 1
}

# --- Validate output directory ---
$outputDir = [System.IO.Path]::GetDirectoryName($output)
if ($outputDir -and (-not (Test-Path $outputDir -PathType Container))) {
    Write-Host "Error: Output directory does not exist: $outputDir" -ForegroundColor Red
    exit 1
}

# --- Resolve Python module ---
$py_path = Join-Path $PSScriptRoot "..\py"
$py_module = Join-Path $py_path "convert_png_to_ico.py"

if (-not (Test-Path $py_module -PathType Leaf)) {
    Write-Host "Error: Python module not found: $py_module" -ForegroundColor Red
    exit 1
}

# --- Execute conversion ---
try {
    envoy python $py_module $source $output
}
catch {
    Write-Host "Error: Failed to convert '$source' to ICO: $_" -ForegroundColor Red
    exit 1
}
