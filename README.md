# gt-devtools

Windows developer toolbox: CMD scripts, PowerShell utilities, Windows Explorer context
menu extensions, and Python helpers — all wired up by a single installer.

> **Platform:** Windows only · **Requires:** PowerShell 5.1+

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start — `setup.ps1`](#quick-start--setupps1)
- [Directory Structure](#directory-structure)
- [CMD Scripts (`cmd/`)](#cmd-scripts-cmd)
- [PowerShell Scripts (`pwsh/`)](#powershell-scripts-pwsh)
  - [PowerShell Profile (`pwsh/config/`)](#powershell-profile-pwshconfig)
  - [GitHub Management (`pwsh/github/`)](#github-management-pwshgithub)
- [Context Menu Items](#context-menu-items)
- [Python Utilities (`py/`)](#python-utilities-py)
- [Python Startup (`pyinit/`)](#python-startup-pyinit)
- [Envoy Environment (`envoy_env/`)](#envoy-environment-envoy_env)
- [ContextMenu PowerShell Module](#contextmenu-powershell-module)
- [Re-running Setup After Moving the Repo](#re-running-setup-after-moving-the-repo)
- [Contributing](#contributing)

---

## Prerequisites

| Requirement | Purpose |
|-------------|---------|
| PowerShell 5.1+ | Required to run `setup.ps1` and all `pwsh/` scripts |
| `DEV_PATH` env var | Root directory for all git repositories. Used by `clone.bat`, workspace path scanners |
| `ENVOY_BNDL_ROOTS` env var | Semicolon-delimited list of repo roots. Used by `repo.ps1` |
| Python (optional) | Required for scripts in `py/` |

Set environment variables permanently from PowerShell:

```powershell
[Environment]::SetEnvironmentVariable('DEV_PATH', 'R:\repo', 'User')
[Environment]::SetEnvironmentVariable('ENVOY_BNDL_ROOTS', 'R:\repo\my-project', 'User')
```

---

## Quick Start — `setup.ps1`

`setup.ps1` (repo root) is the single entry point for installing gt-devtools. Run it once
after cloning and again whenever the repo is moved to a new location.

```powershell
.\setup.ps1
```

**What it does:**

1. Adds `cmd\` and `pwsh\` to the user-level `PATH` so all tools are available in any
   terminal without a full path.
2. Adds `pwsh\modules\` to `PSModulePath` so the `ContextMenu` module is importable from
   any PowerShell session.
3. Stores the install location in `HKCU:\Software\gt-devtools\InstallPath` for stale-path
   detection on future re-runs.
4. Sets the `DEV_TOOLS_ROOT` user environment variable to the repo root so other tools can
   resolve the repo path without hardcoding it.
5. Installs three Windows Explorer context menu entries (see
   [Context Menu Items](#context-menu-items)).
6. Restarts Windows Explorer to apply context menu changes.
7. Shows a dialog box confirming completion and whether a terminal restart is needed.

**Properties:**

- **Idempotent** — safe to run multiple times; duplicate PATH entries are never added.
- **Handles repo moves** — stale entries from the previous location are automatically
  removed before the new paths are added.
- **No admin required** — all changes are user-scoped (`HKCU`, User PATH).

After running, **restart your terminal** for the `PATH` changes to take effect.

---

## Directory Structure

```
gt-devtools/
├── setup.ps1            ← installer / entry point
├── cmd/                 ← CMD/batch scripts (added to PATH by setup)
├── pwsh/                ← PowerShell scripts (added to PATH by setup)
│   ├── config/          ← PowerShell profile and Oh-My-Posh theme
│   ├── github/          ← GitHub CLI management scripts and module
│   └── modules/
│       └── ContextMenu/ ← PowerShell module for context menu management
├── context_menu/        ← per-item install/uninstall scripts
│   ├── CopyPathToClipboard/
│   ├── EnCode/
│   └── to_unix_to_windows/
├── py/                  ← Python helper scripts
├── pyinit/              ← Python REPL startup script
├── envoy_env/           ← Envoy bundle environment configuration
├── docs/                ← Additional documentation
└── resource/
    └── icons/           ← .ico files used by context menu entries
```

---

## CMD Scripts (`cmd/`)

All batch scripts are added to `PATH` by `setup.ps1`. Every script supports
`-h` / `--help` / `/?` for inline usage help.

### Git Operations

| Script | Description |
|--------|-------------|
| `clone.bat` | Clone a repo into a structured path derived from the URL. Requires `DEV_PATH`. Hyphens in the repo name become subdirectories: `org/gt-pythonlibs` → `%DEV_PATH%\org\gt\pythonlibs\` |
| `branch.bat` | Create a new branch and push it to the remote |
| `checkout.bat` | Git checkout wrapper |
| `pull_main.bat` | Pull the latest `main` branch while staying on the current branch |
| `push_rebase.bat` | Push with rebase |
| `latest_tag.bat` | Show the most recent git tag |
| `list_tags.bat` | List all git tags |
| `rename_branch.bat` | Rename the current branch locally and on the remote |
| `status.bat` | Git status wrapper |
| `cleanup.bat` | Clean up merged / stale branches |

**Examples:**

```batch
:: Clone a repo — creates %DEV_PATH%\organization\gt\pythonlibs\
clone https://github.com/organization/gt-pythonlibs.git

:: Create and push a new branch
branch feature/my-feature

:: Update main without switching branches
pull_main
```

### Environment & Path Management

| Script | Description |
|--------|-------------|
| `env.bat` | Open the Windows Environment Variables editor |
| `update_path.bat` | Scan workspace git repos and add their `bin/` directories to `PATH` |
| `update_pythonpath.bat` | Scan workspace git repos and add their `py/` directories to `PYTHONPATH` |
| `print_env.bat` | Display all environment variables |
| `toggle_log_debug.bat` | Toggle debug logging on/off |
| `update_prompt.bat` | Update the console prompt |
| `user_site.bat` | Open the Python user site-packages directory in Explorer |

### Path Utilities

| Script | Description |
|--------|-------------|
| `normpath.bat` | Normalize a path (uses `py/normpath.py`). Reads from clipboard when no argument given |
| `path_tounix.bat` | Convert Windows backslashes to forward slashes |
| `path_towindows.bat` | Convert Unix forward slashes to backslashes |

```batch
normpath "C:/Some/Unix/path"
path_tounix
path_towindows
```

### File & Navigation

| Script | Description |
|--------|-------------|
| `explore.bat` | Open Windows Explorer at the current directory |
| `persistent_copy.bat` | Robust file copy with retry logic (uses `py/persistent_copy.py`) |

### System

| Script | Description |
|--------|-------------|
| `stop_killer_services.bat` | Stop resource-intensive background services |

### Shared Infrastructure

| Script | Description |
|--------|-------------|
| `func.cmd` | Shared functions library imported by other batch scripts. Provides `check_help_flag`, `check_common_flags`, debug mode toggle, etc. |
| `EXAMPLES_flag_handling.bat` | Reference example showing standardized flag-handling patterns |

---

## PowerShell Scripts (`pwsh/`)

Added to `PATH` by `setup.ps1`. Call from any terminal with `.ps1` extension or, if
`$PSDefaultParameterValues` is configured, by name alone.

| Script | Description |
|--------|-------------|
| `repo.ps1` | `cd` to the first path in `ENVOY_BNDL_ROOTS` (your repo root) |
| `envoy-code.ps1` | Open a file or directory in VS Code via `envoy vscode`. Registered as the **Open with Envoy Code** context menu command |
| `update_path.ps1` | Scan a workspace directory for git repos and add their `bin/` dirs to `PATH`. Supports `-Permanent` (user-level) or session-only |
| `update_pythonpath.ps1` | Same as above but for `PYTHONPATH` and `py/` directories |
| `vpn_status.ps1` | Check and display VPN connection status |
| `print_var.ps1` | Split and print a semicolon-delimited environment variable (e.g. `PATH`) one entry per line |
| `create_link.ps1` | Create a symbolic link. Auto-derives the link name from the target leaf. Self-elevates if admin rights are required |
| `enable_long_path_support.ps1` | Enable Windows long-path support (>260 chars) via registry. Requires admin — self-elevates automatically. Run once per machine |

**Examples:**

```powershell
# Navigate to the repo root
repo

# Open current directory in VS Code via envoy
envoy-code.ps1

# Show PATH entries, one per line
print_var.ps1 $env:PATH

# Add workspace bin dirs to PATH permanently
update_path.ps1 -WorkspaceRoot R:\repo -Permanent

# Create a symlink in the current directory
create_link.ps1 -Target V:\repo\some_lib\py\some_lib

# Enable long paths (one-time, admin)
enable_long_path_support.ps1
```

### PowerShell Profile (`pwsh/config/`)

A ready-to-use PowerShell profile with:

- **Oh-My-Posh** — a prompt theme engine with a custom GT theme (`custom.omp.json`)
- **Terminal Icons** — adds file-type icons to `Get-ChildItem` / `ls` output
- **PSReadLine** AI prediction** — list-view command suggestions (PowerShell 7.2+)

**One-time setup** — run `_create_profile_symlink.ps1` to symlink the profile into
`$PROFILE`. This script self-elevates if needed:

```powershell
pwsh\config\_create_profile_symlink.ps1
```

After running, any new PowerShell session will load the profile automatically.

### GitHub Management (`pwsh/github/`)

PowerShell scripts and a module for managing GitHub teams, repository access, and
CODEOWNERS files via the GitHub CLI (`gh`).

See **[pwsh/github/README.md](pwsh/github/README.md)** for full documentation.

**Key capabilities:**
- `Get-GitHubRepos` — list repos in an org
- `Add-GitHubTeamToRepos` — grant team access to multiple repos at once
- `Remove-GitHubTeamFromRepos` — revoke team access
- `Update-GitHubCodeowners` — bulk-update CODEOWNERS files
- `Find-GitHubReposByCodeowner` — search repos by owner entry

**Prerequisites:** `gh` CLI installed and authenticated:

```powershell
winget install --id GitHub.cli
gh auth login
```

---

## Context Menu Items

Installed automatically by `setup.ps1`. Re-running `setup.ps1` updates registry entries
to the current repo location (useful after moving the repo).

Each item has standalone `install.ps1` and `uninstall.ps1` scripts inside its directory.

### Open with Envoy Code (`context_menu/EnCode/`)

Right-click any file, folder, or background → **Open with Envoy Code**

Calls `pwsh\envoy-code.ps1`, which runs `envoy vscode <path>` to open the item in VS Code
through the envoy launcher.

Registered on: File, Directory, Directory Background

### Copy As Path (`context_menu/CopyPathToClipboard/`)

Right-click any file or folder → **Copy As Path**

Copies the full absolute path of the selected item to the clipboard.

Registered on: File, Directory, Directory Background

### to_unix / to_windows (`context_menu/to_unix_to_windows/`)

Right-click any file, folder, or background → **to_unix** or **to_windows**

Converts the path currently in the clipboard between Windows (`\`) and Unix (`/`) formats.
The result is placed back on the clipboard.

Registered on: File, Directory, Directory Background

> **Note:** On Windows 11, `setup.ps1` also enables the classic (Windows 10-style)
> context menu so all entries are visible on first right-click without clicking
> "Show more options".

---

## Python Utilities (`py/`)

Standalone Python scripts. Some are invoked by CMD wrappers in `cmd/`; others are run
directly.

| Script | Description |
|--------|-------------|
| `normpath.py` | Normalize a file path between Windows and Unix formats. Reads from the Windows clipboard when no `--path` argument is given; writes result back to clipboard. CLI built with `click`. |
| `persistent_copy.py` | Robust file copy with retry logic for network or locked files |
| `print_env.py` | Pretty-print environment variables |
| `cleanup_branches.py` | Run `blgit cleanup` on every local git repo found via `gt.gitutils`. Reports per-repo pass/fail |
| `repos_to_main.py` | Iterate all local repos and switch any that are not on `main` to `main`, then pull |

**`normpath.py` usage:**

```batch
:: Normalize path supplied as argument
normpath.bat --path "C:/some/unix/path"

:: Normalize whatever is in the clipboard
normpath.bat
normpath.bat --unix     :: force Unix output
normpath.bat --force    :: skip path validation
```

---

## Python Startup (`pyinit/`)

`pyinit_startup.py` is registered as `PYTHONSTARTUP` via [`envoy_env/python_env.json`](envoy_env/python_env.json).
It runs automatically when Python is launched inside an Envoy bundle, giving every
interactive session a pre-configured environment.

---

## Envoy Environment (`envoy_env/`)

`python_env.json` defines environment variable overrides applied when an Envoy bundle
activates this repo:

```json
{
    "+=PYTHONSTARTUP": "${__BUNDLE__}/pyinit/pyinit_startup.py"
}
```

The `+=` prefix appends to the variable rather than replacing it.

---

## ContextMenu PowerShell Module

`pwsh/modules/ContextMenu/ContextMenu.psm1` provides a reusable, registry-based API for
adding and removing Windows Explorer context menu entries. It is imported automatically by
`setup.ps1` and by each item's `install.ps1` / `uninstall.ps1`.

**Exported functions:**

| Function | Description |
|----------|-------------|
| `Register-ContextMenuItem` | Add an entry for all specified scopes. Idempotent |
| `Unregister-ContextMenuItem` | Remove an entry from all specified scopes. Idempotent |
| `Test-ContextMenuItem` | Return `$true` if the entry exists for all scopes |
| `Enable-ClassicContextMenu` | Restore the Windows 10-style full context menu in Windows 11 |
| `Disable-ClassicContextMenu` | Revert to the Windows 11 modern context menu |
| `Restart-WindowsExplorer` | Safely restart Explorer to apply registry changes |

**Scopes:**

| Scope | Registry root |
|-------|--------------|
| `File` | `HKCU:\Software\Classes\*\shell` |
| `Directory` | `HKCU:\Software\Classes\Directory\shell` |
| `Background` | `HKCU:\Software\Classes\Directory\background\shell` |

**Adding a new context menu entry:**

```powershell
Import-Module ContextMenu -Force

$entry = @{
    Name        = 'MyTool'
    DisplayName = 'Open with My Tool'
    Command     = '"C:\tools\mytool.exe" "%V"'
    Icon        = 'C:\tools\mytool.ico'   # optional
    Scopes      = @('File', 'Directory', 'Background')
}

Register-ContextMenuItem -Entry $entry
Restart-WindowsExplorer
```

> **Note:** The `File` scope key contains a literal `*` character. The module handles this
> correctly using `-LiteralPath` and the .NET `Microsoft.Win32.Registry` API to avoid
> PowerShell wildcard expansion.

---

## Re-running Setup After Moving the Repo

If you move or rename the repo directory, simply run `setup.ps1` again from the new
location:

```powershell
.\setup.ps1
```

`setup.ps1` reads the previous install path from `HKCU:\Software\gt-devtools\InstallPath`.
If the current `$PSScriptRoot` differs from the stored path, it:

1. Removes the stale `cmd\` and `pwsh\` entries from `PATH`.
2. Removes the stale `pwsh\modules\` entry from `PSModulePath`.
3. Adds the new paths.
4. Overwrites `InstallPath` and `DEV_TOOLS_ROOT` with the new location.
5. Re-installs all context menu entries with updated absolute paths.

---

## Contributing

### Adding a new CMD script

1. Place the `.bat` / `.cmd` file in `cmd/`.
2. Use `func.cmd` for standard flag handling:
   ```batch
   call %~dp0func.cmd :check_help_flag "%~1" && goto :SHOW_HELP
   ```
3. Implement a `:SHOW_HELP` label with clear usage text.
4. Update the [CMD Scripts](#cmd-scripts-cmd) table in this README.

### Adding a new PowerShell script

1. Place the `.ps1` file in `pwsh/`.
2. Add a `.SYNOPSIS` / `.DESCRIPTION` comment block.
3. Update the [PowerShell Scripts](#powershell-scripts-pwsh) table in this README.

### Adding a new context menu item

1. Create a subdirectory under `context_menu/` (e.g. `context_menu/MyTool/`).
2. Add `install.ps1` and `uninstall.ps1` using the `ContextMenu` module. Follow the
   pattern in existing items.
3. Add the item name to the `$contextMenuItems` array in `setup.ps1`.
4. Update the [Context Menu Items](#context-menu-items) section in this README.

See the [ContextMenu module documentation](#contextmenu-powershell-module) for the
`Register-ContextMenuItem` API.

---

## License

Part of the GT Tools collection.
