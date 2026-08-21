---
name: ask-install
description: >
  Install guard for every task. Whenever a tool, package, library, or
  dependency is missing — or becomes needed mid-work (pkg, pip, npm, apt,
  curl-downloaded tools, any installer) — the AI STOPS and asks the user
  first in plain words: what is missing, why it is needed, and "should I
  install it?". Never install anything silently. Use on any task where
  something needs installing or setting up.
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion, Skill
---

# ask-install

Nothing gets installed behind the user's back. Ask first, always.

## The rule

While working, if you find something missing — or the task now needs a new
tool/package/library — do NOT install it yourself. Instead:

1. **Stop and tell the user, in three simple lines:**
   - what is missing (name, one plain-words meaning)
   - why it is needed for their task (one line)
   - "Should I install it?" — plus a rough size/time estimate when known
2. **Wait for the answer.** "No" means no — do not install; instead offer an
   alternative path that avoids it (skip the feature, use what is already
   there, or change approach).
3. **On yes:** install it, then confirm in one line ("ffmpeg installed ✅ —
   continuing"). If the install fails, show the real error honestly and
   suggest the next step (retry, reinstall, or an alternative).

## What counts as "installing" (all of these need asking)

- `pkg install …` / `apt install …` / `apt-get …` (Termux/Linux packages)
- `pip install …` / `pip3 install …` (Python libraries)
- `npm install …` / `npx …` (Node packages)
- downloading and running any tool via `curl`/`wget`
- anything else that brings NEW software onto the device

## Exceptions (no need to ask again)

- The user already said yes for this exact thing earlier in the same session.
- The user explicitly ordered the install themselves ("install ffmpeg").
- Updating files inside the project, or using tools that are already
  installed — none of that is an install.

## Style

Beginner-friendly, short sentences. Never blame the user or the tool;
just say what happened and what comes next.
