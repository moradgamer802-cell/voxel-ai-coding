---
name: security-review
description: Double-check before dangerous commands/data — even with auto-approve ON, the AI guards itself. Use before destructive, network, or sensitive operations.
---

# Security Review Skill (Full-Power)

## Context: BOOMCODE has NO permissions
`permission: allow` means the AI can run anything — so **the AI must guard itself**.
This skill is that guard. Mentally run this checklist before every risky operation.

## Gate 1 — Destructive commands
- `rm -rf` / `rm -r`: print the exact path with echo first, verify variables are not
  empty, never target `/` `$HOME` `$PREFIX`
- `mv A B` when B exists = overwrite — check first
- `dd`, `mkfs`, disk wipe: never without the user's explicit instruction
- `truncate`/`>` on large files: backup first (`cp x x.bak`)
- Bulk delete: show a dry-run list first (`find ... -print`), then delete

## Gate 2 — Network
- `curl ... | sh/bash`: READ the script first (download and `less`/`head`),
  then run — never blind pipe
- Uploading/sending the user's files: never without explicit permission
- `git push` to public repo: check the diff for secrets first (Gate 3)
- POSTing data to another server: user knows + HTTPS

## Gate 3 — Secrets
- API keys/tokens/passwords: NEVER hardcode — use `.env` + `.env.example` pattern
- Never print secrets in echo/log/commit; if one leaks, delete + rotate immediately
- Check that `.env` is in `.gitignore` for new repos
- If a key the user gave you gets pushed to the repo — tell them to get a new key (rotate)

## Gate 4 — System
- No `chmod 777` (755 for files, 700 for dirs)
- `sudo`/root: not in Termux; avoid in proot — try user-level solutions first
- System config edits (`/etc/`, `$PREFIX/etc/`): backup first, announce first

## Workflow when a risky operation appears
1. Say in 2-3 lines: what will be done, what the risk is, whether it is reversible
2. Irreversible + user absent? Do NOT do it — leave a note
3. Look for a safe alternative: dry-run flag, temp copy, `-i` interactive
4. Even with auto-approve: ask the user before destructive + irreversible actions

## When delivering a website/app
- Sanitize form input (XSS) — never inject user content into HTML directly
- Don't expose API keys in frontend code (say it if it's public anyway)
- SQL: parameterized queries — no string concatenation
- `target="_blank"` must have `rel="noopener"`
