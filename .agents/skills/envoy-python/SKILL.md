---
name: envoy-python
description: Run Python code and manage packages via the envoy environment dispatcher. Use when running scripts, tests, REPL sessions, module invocations (`-m`), or installing packages with pip. Always prefer `envoy python` over bare `python`/`pip` to ensure the correct runtime (executable + libs + modules) is used.
license: Proprietary
compatibility: Requires the `envoy` (or `en`) CLI and a registered Python command to be installed and on PATH.
metadata:
  tool: envoy
---

# Run Python via Envoy

## When to Use This Skill
* Running Python code — scripts, tests, REPL, or module invocations (`-m`).
* Installing or managing Python packages via `pip`.
* Always prefer `envoy` over bare `python`/`pip` to ensure the correct runtime.

## Quick Reference

### Discover Available Commands
```powershell
en --list                          # Show all registered commands with source bundles
en --info python                   # Show env file chain and config for Python command
en --which python                  # Resolve the actual Python executable path
```

### Run Python Commands
| Task | Command |
|---|---|
| Run a script | `en python script.py` |
| Run a module | `en python -m pytest tests/` |
| Inline code | `en python -c "print('hello')"` |
| Interactive REPL | `en python` |

### Package Management with pip
| Task | Command |
|---|---|
| Install (user-level) | `en python -m pip install --user <package>` |
| List installed packages | `en python -m pip list` |
| Show package info | `en python -m pip show <package>` |
| Upgrade a package | `en python -m pip install --upgrade <package>` |

Always use `envoy python -m pip` rather than bare `pip`.

### Debug Environment Issues
```powershell
en --verbose python script.py     # Full env assembly log
en --trace PYTHONPATH python      # Trace variable resolution
en -i python                      # Inherit system PATH (bypass closed mode)
```

### Error Handling
* If `en` / `envoy` is not found on PATH, the dispatcher may not be installed — ask the user for setup guidance.
* If a command doesn't exist in `--list`, do not guess; ask the user which command to use.
