---
description: Open a page in the browser (local server) — show the user their website/app visually.
agent: build
---

The user wants to SEE a page in the browser. $ARGUMENTS

1. Find the folder that contains the page (index.html) — $ARGUMENTS if given, else look at the project structure
2. Run this command in the terminal:
   `zyvo preview <folder>`
   (it starts a local server at http://localhost:8080 and auto-opens the browser — scripts, CSS and fetch work there, unlike opening the file directly)
3. Tell the user:
   - The page is at **http://localhost:8080**
   - If the browser did not open automatically, they run `zyvo preview <folder>` again
   - To stop the server: press Ctrl+C in the terminal
4. If python3 is missing, install it first: `pkg install python`

Never open HTML files with `termux-open` or a file manager for this purpose — browsers block scripts/CSS on file:// URLs and the page looks broken. Always use `zyvo preview`.