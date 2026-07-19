---
name: envoy-debug
description: Troubleshoot envoy environment issues, debug command execution, or inspect assembled environments. Use when a command dispatched via `en` behaves unexpectedly — wrong Python version, missing modules, incorrect PATH, or unknown command behavior.
license: Proprietary
compatibility: Requires the `envoy` (or `en`) CLI to be installed and on PATH.
metadata:
  tool: envoy
---

# Troubleshooting Envoy Environment Issues

## When to Use This Skill
* A command dispatched via `envoy` behaves unexpectedly (wrong Python version, missing modules, incorrect PATH).
* Need to inspect how envoy assembles an environment before running a command.

## Diagnostic Commands

### List and Inspect Commands
```powershell
en --list                          # Show all available commands with source bundles
en --info <command>                # Show full env file chain, executable, and config
en --which <command>               # Resolve the actual executable path envoy will use
```

### Trace Environment Variables
```powershell
en --trace PYTHONPATH <command>    # Trace PYTHONPATH resolution through env files
en --trace PATH <command>          # Trace PATH assembly
```

### Verbose Execution Logging
```powershell
en --verbose <command> args        # Emit detailed logging for bundle discovery, command loading, and executable resolution
```

### Bypass Config or Environment
```powershell
en --ignore-config <command>       # Run without reading any user config values
en -i <command>                    # Inherit the full system environment (overrides closed mode)
```

### Inspect User Config
```powershell
en --list-configs                  # Show all configurable settings with descriptions and current values
en --get-config                    # Print all user config values
en --get-config <KEY>              # Print a specific setting
```

## Environment Variables
| Variable | Description |
|---|---|
| `ENVOY_BNDL_ROOTS` | Semicolon-separated root directories for bundle auto-discovery |
| `ENVOY_ALLOWLIST` | Semicolon- or comma-separated variable names to pass through in closed mode |
| `ENVOY_USER_CONFIG` | Override path to the user config file (useful for testing) |

## Common Debugging Patterns

**Wrong Python version?** → Run `en --which python`, then `en --trace PATH python`.

**Missing module import?** → Run `en --trace PYTHONPATH python`, or `en -i python` to compare with system Python.

**Command not found in `--list`?** → Check that `ENVOY_BNDL_ROOTS` points to the correct bundle roots and that the bundle's `.envoy/commands.json` is valid.
