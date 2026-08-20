---
description: Open a website/app in the browser (local or instant public HTTPS live link).
agent: build
---

The user wants to SEE/OPEN a website or web app in the browser. $ARGUMENTS

1. Find the project/HTML folder (containing index.html) — from $ARGUMENTS or the project root.
2. Determine the mode:
   - **Public link / Share mode** (if $ARGUMENTS contains "share", "public", "link", or user wants to view on other devices):
     Run: `zyvo preview --share <folder>`
     (Starts background server + creates an instant live public HTTPS link + auto-opens in browser)
   - **Local preview mode** (default):
     Run: `zyvo preview <folder>`
     (Starts background local server at http://localhost:8080 + auto-opens in browser)

3. Tell the user:
   - The clickable link (Local URL / Public HTTPS URL)
   - The page opened automatically in their phone/device browser
   - To get a shareable public link anytime: `zyvo preview --share <folder>` (or `/open public`)

4. Never open HTML files with `file://` URLs because browsers block scripts and CSS. Always use `zyvo preview`.