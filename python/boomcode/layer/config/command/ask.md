---
description: /ask on — ASK off: AI works freely (run /ask to toggle)
agent: build
---

Toggle ASK mode. One command, real persistent state — it survives restarts. $ARGUMENTS

- ASK ON  = the AI asks before EVERY major step (2-4 options, you pick) and stays strictly on your task
- ASK OFF = the AI works freely — best judgment, no interruptions (default)

State file: `~/.config/boomcode/ask.mode` (on|off). The BOOMCODE launcher re-syncs the
command label and instructions on every start, so this label always shows the
action you can take right now.

Do this now using Bash (`mkdir -p ~/.config/boomcode` first if needed):

1. Read the current state:
   `cat ~/.config/boomcode/ask.mode 2>/dev/null || echo off`
   (missing file or anything other than "on" = OFF)

2. FLIP it:

   Turning ON (was off):
   ```
   echo on > ~/.config/boomcode/ask.mode
   printf 'ASK MODE ON — MANDATORY persistent BOOMCODE instruction.\n1. STAY ON TASK — work ONLY on the user\x27s current request. Never drift to unrelated files, features, or fixes mid-work. Notice something unrelated? List it as an option for LATER — never touch it now.\n2. ASK BEFORE EVERY major step (file edit, tech/framework choice, design decision, fix strategy, project structure): present 2-4 options with a one-line reason each and WAIT for the user to pick. Keep asking at every step — that is the whole point of this mode.\n3. ONE task at a time — finish it or reach a decision point before anything else.\n4. Task DONE -> stop and report. Never start new work on your own.\n5. Unsure what the user wants? ASK — never guess and build.\n' > ~/.config/boomcode/ask-instructions.md
   ```

   Turning OFF (was on):
   ```
   echo off > ~/.config/boomcode/ask.mode
   : > ~/.config/boomcode/ask-instructions.md
   ```

3. Reply with ONE clear line stating the new mode:
   - ON:  `ASK ON ✅ — From now on I'll present 2-4 options before every major step for you to pick, and I'll work strictly on your task. Run /ask again to turn it off.`
   - OFF: `ASK OFF ✅ — I'll work freely again without stopping. Run /ask again to turn it on.`

4. Apply it immediately in this session:
   - Just turned ON  → asking-mode from your very next step (ask before EVERY major step, stay strictly on the user's task, never drift, stop and report when done)
   - Just turned OFF → continue the task freely right away
