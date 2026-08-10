---
name: debugging-fixes
description: Systematic debugging — bug khuje berano, root cause dhora, fix kora and verify kora. Use when user reports any problem, error, crash, or unexpected behavior.
---

# Debugging & Fixes Skill

## Method
1. Reproduce — exact steps, capture the error (`--verbose`, logs, exit code)
2. Read the actual error line, not the summary — point to `file:line`
3. Find the root cause, don't patch symptoms (search code, check versions/logs)
4. Make the smallest possible fix
5. Verify: re-run the failing command, confirm original symptom is GONE
6. No new regressions — check related paths still work

## Habits
- State what you tested and what you concluded
- If a fix requires a restart/reinstall, say exactly which command
- If unsure, add a diagnostic step instead of guessing twice
- Keep backups of edited files (`cp x x.bak`) before surgical changes