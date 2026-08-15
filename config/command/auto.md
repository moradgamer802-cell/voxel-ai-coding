---
description: Auto-approve ON — bash/edit/webfetch prompt chhara, like other CLIs.
agent: build
---

Auto-approve permission ON koro. $ARGUMENTS

1. `oc-settings auto on` chalai koro (bash/edit/webfetch = allow hoye jabe config e).
2. Config check: `grep -A3 '"permission"' ~/.config/opencode/opencode.json` e "allow" ase nai dekho.
3. Check hoye gele only "done ✓" likho — prompt ar ashbe na (zyvo restart er por theke).
4. Sudhu ekta session er jonno chaile user ke bolo: `zyvo --yolo` diye start koro (`/session`) — auto-off hoy exit e.
5. Warning: auto-approve ON thakle AI joto kichhu chaibe chalaite parbe — sensitive command e satark thako. Band: /safe.
