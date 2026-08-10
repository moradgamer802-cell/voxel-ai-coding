---
name: git-workflow
description: Clean, safe git usage — commits, branches, pull, push, conflict resolve. Use for any git-related task.
---

# Git Workflow Skill

## Rules
- Never commit unless the user asked (or it's part of the agreed task)
- Before committing: `git status`, `git diff`, `git log --oneline -5` — stage only intended files
- Never commit secrets/keys (`.env`, API keys) — check diffs
- Small, focused commits with messages matching repo style
- Never force-push, never amend other people's commits, never rewrite history unless asked
- Pull before push; resolve conflicts by reading both sides, not by picking one blindly
- On failure, fix forward with a new commit — do not amend a failed commit

## Common flows
- New work: `git checkout -b <topic>` then one commit per logical change
- Update: `git pull --ff-only` (or fetch + merge)
- Undo local mess: `git stash` / `git checkout -- <file>` — confirm which file first