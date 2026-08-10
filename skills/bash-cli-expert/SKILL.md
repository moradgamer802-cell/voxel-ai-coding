---
name: bash-cli-expert
description: Safe, clean and efficient bash/CLI work — Termux/Linux command banano, debugging, pipes, quoting, file ops. Use when running or writing any shell command.
---

# Bash / CLI Expert Skill

## Before running commands
- Prefer read-only commands first (`ls`, `file`, `grep -n`) before destructive ones
- Quote user paths with double quotes when they may contain spaces
- Never pipe `curl` straight into `sh` unless the user explicitly asked
- `rm -rf` only with an exact, verified absolute path — never with variables that could be empty

## Command hygiene
- One purpose per command; chain with `&&` only when the next step depends on the previous
- Use `set -e`/`set -u` in scripts; fail loudly instead of continuing
- Check exits codes after `curl`, `git`, `pkg install`, `mv`
- Long-running tasks: use `timeout` so they can't hang forever
- Prefer `rg` over `grep`, `python3 - <<'EOF'` over `sed`/`awk` one-liners when editing JSON

## Verification
- After any change: run the command again or check `$?` / output to confirm success
- Diff before/after (`diff file.bak file`) for config edits whenever feasible