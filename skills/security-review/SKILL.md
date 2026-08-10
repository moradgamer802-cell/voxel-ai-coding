---
name: security-review
description: Auto-approve chole thakleo dangerous command er age double-check — secrets, rm, network, permissions. Use before destructive or sensitive operations.
---

# Security Review Skill

## Gate before acting (always, even in auto-approve mode)
- **Destructive**: `rm -rf`, `mv` over files, disk wipe, `dd` — verify exact paths twice
- **Network**: `curl ... | sh`, downloads, uploading files, `git push` to public repos
- **Secrets**: API keys, tokens, passwords — never echo, never log, never commit
- **Permissions**: `chmod 777`, running as root/sudo, editing system configs
- **Exfiltration**: sending user files/data anywhere without explicit ask

## If anything is risky
1. Say what the command does in plain words
2. Warn the user if it is irreversible
3. Prefer a safe alternative (dry-run, `-i` flag, copy instead of delete, temp dir)

## Because auto-approve is ON
- Config `permission.bash=allow` means the AI can run anything — so the AI itself must do the guarding
- Sensitive work: ask for permission explicitly even when the system would not prompt