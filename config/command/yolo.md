---
description: Toggle YOLO mode — AI asks before every action (on) or works freely (off).
agent: build
---

Toggle YOLO mode. $ARGUMENTS

YOLO MODE = the AI ASKS before doing anything.

- `/yolo on`  → AI asks for confirmation before every major action.
- `/yolo off` → Normal mode. AI works freely — no extra questions, no confirms. (This is the default.)
- `/yolo`     → Show current mode + toggle.

## When YOLO is ON (ask-first mode):
- Before editing any file → "I'll edit <file> to do <change> — should I go ahead?"
- Before running a command that changes something → confirm first
- Before making a design or architecture decision → present options, let the user pick
- Before installing a package or dependency → ask
- Before deleting or overwriting anything → always ask
- Simple reads, greps, listing files, exploring the project → no need to ask

## When YOLO is OFF (default — normal mode):
- Work freely — read, edit, run, build, fix — no extra questions
- Use your best judgment for all decisions
- Only stop if the requirement is genuinely ambiguous and you cannot guess at all
- This is how ZYVO normally works

State the mode change clearly when toggled. The mode persists for the entire chat session.
