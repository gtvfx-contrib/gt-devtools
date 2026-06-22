<#
.SYNOPSIS
    Clone a git repository into a structured directory under DEV_PATH.

.DESCRIPTION
    Clones a git repository into DEV_PATH\<org>\<repo-parts>\ where hyphens
    in the repository name are converted to subdirectory separators.

    Supports both HTTPS and SSH repository URL formats.

.PARAMETER RepoUrl
    URL of the repository to clone.

    Supported formats:
      https://github.com/gtvfx-contrib/gt-bundle_configs.git
      git@github.com:gtvfx-contrib/gt-bundle_configs.git

.EXAMPLE
    clone.ps1 https://github.com/gtvfx/gt-pythonlibs.git
    Clones into DEV_PATH\gtvfx\gt\pythonlibs\

.EXAMPLE
    clone.ps1 git@github.com:gtvfx-contrib/gt-bundle_configs.git
    Clones into DEV_PATH\gtvfx-contrib\gt\bundle_configs\

.NOTES
    Requires DEV_PATH environment variable to be set to the development root directory.
#>

param(
    [Parameter(Position=0)]
    [string]$RepoUrl
)

if (-not $RepoUrl -or $RepoUrl -in '--help', '-h', '-?') {
    Get-Help $PSCommandPath -Detailed
    return
}

if (-not $env:DEV_PATH) {
    Write-Error "DEV_PATH environment variable is not set.`nPlease set DEV_PATH to your development root directory."
    exit 1
}

if (-not (Test-Path $env:DEV_PATH)) {
    Write-Error "DEV_PATH directory does not exist: $($env:DEV_PATH)"
    exit 1
}

# Parse SSH format: git@github.com:org/repo.git
if ($RepoUrl -match '^git@[^:]+:([^/]+)/(.+?)(?:\.git)?$') {
    $org = $Matches[1]
    $repoName = $Matches[2]
}
# Parse HTTPS format: https://github.com/org/repo.git
elseif ($RepoUrl -match '^https?://[^/]+/([^/]+)/(.+?)(?:\.git)?$') {
    $org = $Matches[1]
    $repoName = $Matches[2]
}
else {
    Write-Error @"
Cannot parse repository URL: $RepoUrl
Expected one of:
  HTTPS  https://github.com/org/repo.git
  SSH    git@github.com:org/repo.git
"@
    exit 1
}

# Convert hyphens in the repo name to path separators
# e.g. gt-bundle_configs -> gt\bundle_configs
$repoPath = $repoName -replace '-', [System.IO.Path]::DirectorySeparatorChar

# Build the full target path: DEV_PATH\org\repo-parts
$dirPath = [IO.Path]::Combine($env:DEV_PATH, $org, $repoPath)

Write-Host "Creating directory structure: $dirPath"
$null = New-Item -ItemType Directory -Path $dirPath -Force

Write-Host "Cloning $repoName from $org into $dirPath..."
git clone $RepoUrl $dirPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "Successfully cloned to $dirPath"
} else {
    Write-Error "Failed to clone repository"
    exit 1
}
