---
name: bash-cli-expert
description: Safe, clean, efficient bash/CLI — Termux/Linux commands, pipes, quoting, one-liners. Use whenever running or writing any shell command or script.
---

# Bash / CLI Expert Skill (Full-Power)

## Termux reality (it runs on the user's phone)
- Paths: `/storage/emulated/0/` = shared storage (FUSE — slow, case-sensitivity
  depends on the backend), `$HOME` = fast private storage
- Heavy IO on shared storage is bad — copy to $HOME, work, copy back when done
- `pkg install <x>` = apt wrapper; `termux-open <file>` opens a file in its default app
- On Android 11+ the `/sdcard` symlink also works; otherwise use `/storage/emulated/0`

## Safety gates (always — the AI guards itself because of auto-approve)
- Read-only first: `ls`, `file`, `grep -n`, `find ... -maxdepth 2`
- `rm -rf` — exact absolute path, stop on empty variables (`set -u`); never target
  `/` or `$HOME`
- `curl | sh` — only if the user explicitly asked
- `mv` will overwrite — check `[ -f dest ]` first
- If destructive, say what you will do first, then do it

## Command hygiene
- One command does one thing; chain with `&&` only when the next step depends on the previous
- In scripts: `set -eu` + `trap 'rm -f "$TMP"' EXIT` for temp files
- After `curl`/`git`/`pkg install`: check exit — `cmd || { echo fail; exit 1; }`
- Long tasks: `timeout 60 cmd` — hang protection
- JSON edits: `python3 - <<'PY'` heredoc — no fragile sed/awk regex
- Search: `rg` (fast, git-aware) — better than recursive grep

## Patterns (power one-liners)
```sh
# folder size ranking
du -sh */ | sort -h
# batch rename (safe preview first)
for f in *.JPG; do mv "$f" "${f%.JPG}.jpg"; done
# find + action, space-safe
find . -name "*.log" -print0 | xargs -0 rm
# quick server
python3 -m http.server 8080
# extract any format
tar -xf x.tar.gz / unzip -q x.zip
```

## Verification
- After changes: run again or check `$?`
- Config edits: `cp x x.bak` first, then `diff x.bak x`
- When delivering a script: test-run it once, then give the user the usage line