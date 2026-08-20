---
description: Toggle YOLO mode — AI gives options/choices before every step (on) or works freely (off).
agent: build
---

Toggle YOLO mode. $ARGUMENTS

YOLO MODE = the AI gives you OPTIONS before doing anything.

- `/yolo on`  → AI presents 3-4 choices/options before every major step. You pick, it does.
- `/yolo off` → Normal mode. AI works freely — best judgment, no options, no questions. (Default.)
- `/yolo`     → Show current mode + toggle.

## When YOLO is ON (options mode):
- Before editing a file → present 2-4 approaches: "Option 1: do X, Option 2: do Y, Option 3: do Z — which one?"
- Before choosing a tech/framework → list the options with pros/cons, let the user pick
- Before making a design decision → show alternatives with a short reason for each
- Before picking a fix strategy → "I see 3 ways to fix this: A) ..., B) ..., C) ... — which one?"
- Before structuring a project → show layout options
- Every major step = present choices, wait for the user's pick, then execute

## When YOLO is OFF (default — normal mode):
- Work freely — read, edit, run, build, fix — no options, no questions
- Pick the best approach yourself and just do it
- Only stop if the requirement is genuinely ambiguous and you cannot guess at all
- This is how ZYVO normally works — fast, no interruptions

State the mode change clearly when toggled. The mode persists for the entire chat session.
