---
name: envoy-dispatch
description: Dispatch commands via the envoy environment dispatcher. Use when running any command through `en` or `envoy` — Python, Unreal, VS Code, or custom project commands. Always prefer envoy over bare executables to ensure the correct concatenated runtime is used.
license: Proprietary
compatibility: Requires the `envoy` (or `en`) CLI to be installed and on PATH.
metadata:
  tool: envoy
---

# Dispatch Commands via Envoy

## When to Use This Skill
* Running any command through the envoy environment dispatcher — not just Python, but any registered command (`unreal`, `vscode`, custom project commands).
* Always prefer `envoy` over bare executables.

## Quick Reference

### Discover and Inspect Commands
```powershell
en --list                          # List all available commands with source bundles
en --info <command>                # Show env file chain, executable, and config
en --which <command>               # Resolve the actual executable path envoy will use
```

### Dispatch a Command
```powershell
en <command> [args ...]
```
Flags go **before** the command name; everything after is passed verbatim to the child process.

| Task | Example |
|---|---|
| Run with args | `en unreal MyGame.uproject` |
| Open editor | `en vscode .` |
| Verbose output | `en -v <command>` |

### Override Discovery
```powershell
en -c /path/to/commands.json <command>    # Use a specific commands.json
en -b /path/to/bundles.json --list        # Use a specific bundles config
```

### Debug Issues
```powershell
en --verbose <command> args       # Full env assembly log
en --trace VAR <command>          # Trace how a variable is resolved
en -i <command>                   # Inherit system PATH (bypass closed mode)
en --ignore-config <command>      # Skip user config for this run
```

### Error Handling
* If `en` / `envoy` is not found on PATH, the dispatcher may not be installed — ask the user for setup guidance.
* If a command doesn't exist in `--list`, do not guess; ask the user which command to use.
