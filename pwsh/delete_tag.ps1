param(
     [Parameter(Mandatory=$false, Position=0, HelpMessage="The tag to delete.")]
     [string]$ver
 )

if (-not $ver) {
    try {
        $ver = git describe --tags --abbrev=0
        if (-not $ver) {
            Write-Host "Error: No tags found in the repository." -ForegroundColor Red
            exit 1
        }
    }
    catch {
        Write-Host "Error: Failed to resolve the latest tag. Ensure the repository has at least one tag." -ForegroundColor Red
        exit 1
    }
}

# Validate that the tag exists locally
$tagExists = git tag -l $ver
if (-not $tagExists) {
    Write-Host "Error: Tag '$ver' does not exist locally." -ForegroundColor Red
    exit 1
}

Write-Host "About to delete tag '$ver':" -ForegroundColor Yellow
Write-Host "  1. Delete local tag"
Write-Host "  2. Delete remote tag from origin"
Write-Host "  3. Delete associated GitHub release (if any)"
Write-Host ""

$confirm = Read-Host "Type 'yes' to confirm"
if ($confirm -ne 'yes') {
    Write-Host "Aborted." -ForegroundColor Yellow
    exit 1
}

$deleted = $false

try {
    git tag -d $ver
    git push origin --delete $ver
    $deleted = $true
    Write-Host "Tag '$ver' deleted successfully." -ForegroundColor Green
}
catch {
    Write-Host "Error deleting tag '$ver': $_" -ForegroundColor Red
}

try {
    gh release delete $ver --yes
    if (-not $deleted) {
        Write-Host "GitHub release for '$ver' deleted (tag deletion failed or was skipped)." -ForegroundColor Yellow
    }
    else {
        Write-Host "GitHub release for '$ver' deleted." -ForegroundColor Green
    }
}
catch {
    if ($deleted) {
        Write-Host "Warning: Tag deleted but GitHub release for '$ver' could not be deleted: $_" -ForegroundColor Yellow
    }
    else {
        Write-Host "Error: No GitHub release found for tag '$ver'." -ForegroundColor Red
    }
}
