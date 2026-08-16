---
name: bash-cli-expert
description: Safe, clean, efficient bash/CLI — Termux/Linux command banano, pipes, quoting, one-liners. Use whenever running or writing any shell command or script.
---

# Bash / CLI Expert Skill (Full-Power)

## Termux reality (user er phone e cholbe)
- Paths: `/storage/emulated/0/` = shared storage (FUSE — slow, case-sensitive-ish
  per backend), `$HOME` = fast private storage
- Heavy IO shared storage e bhalo na — copy to $HOME, kaj sesh e copy back
- `pkg install <x>` = apt wrapper; `termux-open <file>` diye file default app e khule
- Android 11+ e `/sdcard` symlink o kaj kore; na thakle `/storage/emulated/0`

## Safety gates (always — auto-approve er karone AI nije guard)
- Read-only age: `ls`, `file`, `grep -n`, `find ... -maxdepth 2`
- `rm -rf` — exact absolute path, variable empty hole `set -u` e atko; `/` ba
  `$HOME` kkhono target na
- `curl | sh` — user explicitly na chaile na
- `mv` overwrite korbe — age `[ -f dest ]` check
- Destructive hole age bolo ki korbe, tarpor koro

## Command hygiene
- Ek command ek kaj; `&&` chain korba jokhon porer step ager er upor nirbhor
- Script e: `set -eu` + `trap 'rm -f "$TMP"' EXIT` temp file er jonno
- `curl`/`git`/`pkg install` er por exit check: `cmd || { echo fail; exit 1; }`
- Long task: `timeout 60 cmd` — hang protection
- JSON edit: `python3 - <<'PY'` heredoc — fragile sed/awk regex na
- Search: `rg` (fast, git-aware) — recursive grep er cheye

## Patterns (power one-liners)
```sh
# folder size rank
du -sh */ | sort -h
# batch rename (safe preview age)
for f in *.JPG; do mv "$f" "${f%.JPG}.jpg"; done
# find + action, space-safe
find . -name "*.log" -print0 | xargs -0 rm
# quick server
python3 -m http.server 8080
# extract any format
tar -xf x.tar.gz / unzip -q x.zip
```

## Verification
- Change er por: abar chalao ba `$?` check
- Config edit: `cp x x.bak` age, `diff x.bak x` porer
- Script deliver korle: ekbar test run koro, tarpor user ke usage line dao
