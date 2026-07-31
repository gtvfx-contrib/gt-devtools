---
name: engit
description: Perform versioning, changelog generation, release creation, bundle publishing, and repository management via the `engit` CLI. Use when bumping versions, creating GitHub releases, publishing bundles, generating changelogs, cleaning up repos, or pulling envoy bundles.
license: Proprietary
compatibility: Requires the `engit` CLI to be installed and on PATH. Requires git and a connected GitHub remote for release/publish operations.
metadata:
  tool: engit
---

# Versioning and Release Operations with Engit

## When to Use This Skill
* Managing versions, generating changelogs, creating releases, publishing bundles, cleaning up repos, or pulling envoy bundles via `engit`.
* `engit` is the developer toolchain for envoy bundles — semantic versioning, GitHub releases, bundle publishing, and repository management.

## Quick Reference

### Version Management

#### Tag a New Version
```powershell
engit tag --patch               # Auto-increment patch (v1.0.1)
engit tag --minor               # Increment minor (v1.1.0)
engit tag --major               # Increment major (v2.0.0)
engit tag --version 1.2.3       # Explicit version
engit tag --version 1.2.3-alpha # Pre-release (auto-sequences .1, .2, etc.)
engit tag --patch --dry-run     # Preview without tagging
```

#### Create a GitHub Release
```powershell
engit release                          # Release latest tag
engit release --tag v1.2.3             # Release specific tag
engit release --draft                  # Create as draft first
engit release --generate-notes         # Append GitHub "What's Changed" notes
engit release --dry-run                # Preview without creating
```

### Publish Bundles
```powershell
engit publish bundle                         # Publish to ENVOY_BUNDLE_PUBLISH_ROOT
engit publish bundle --zip --output dist     # Folder and zip in dist/
engit publish bundle --version dev           # Development publish
engit publish bundle --dry-run               # Preview file list
engit publish bundle --exclude docs/**       # Extra exclusions
```

### Changelog and Status
```powershell
engit status              # Show branch, ahead/behind, last semver tag, latest commit
engit changelog           # Generate changelog from published GitHub releases
engit changelog --tag v1.2.0   # Show only a specific release's changes
```

### Repository Maintenance
```powershell
engit cleanup                     # Prune stale refs and delete merged branches
engit cleanup --noop              # Preview what would be deleted
engit pull gt:globals             # Pull one or more bundles by ID
engit pull *                      # Pull all discovered bundles
engit web                         # Open repo on GitHub in browser
```

### Stack Publishing
```powershell
engit publish stack studio R:/my/studio.estack
envoy --set-config stack=studio   # Resolves to latest published version
```

### GitHub Search
```powershell
engit search "python"               # Search repos in configured orgs
engit search "rust" --org my-org    # Scope to a specific org
```

## Error Handling
* If `engit` is not found on PATH, the tool may not be installed — ask the user for setup guidance.
