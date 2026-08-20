---
description: Open a website/app in the browser with local URL and temporary public live link.
agent: build
---

The user wants to SEE/OPEN a website or web app in the browser. $ARGUMENTS

1. Find the project/HTML folder (containing index.html) — from $ARGUMENTS or the project root.
2. Run this command in the terminal:
   `zyvo preview <folder>`
   (This starts the background local server at http://localhost:8080, auto-opens the default browser on the phone, and creates a temporary public live HTTPS link).

3. In your response to the user, ALWAYS provide BOTH clickable links:
   - 📱 **Local URL:** `http://localhost:<port>` (opened automatically on device)
   - 🌍 **Temporary Public Live Link:** `<public_url>` (tell the user: "যদি ফোনে অটোমেটিক ব্রাউজার ওপেন না হয় বা অন্য ডিভাইসে দেখতে চাও, তবে এই লিংকে ক্লিক করো")

4. If python3 is missing, install it first: `pkg install python`
5. Never open HTML files directly with `file://` URLs.