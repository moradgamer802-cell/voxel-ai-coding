---
name: android-app
description: Basic Android app development from Termux — HTML/JS hybrid apps, webviews, APK building. Use when user wants to make an Android app or turn a website into an app.
---

# Android App Skill (Termux-friendly)

## Honest path first (choose the right level)
- **Fastest / best on phone:** an HTML/JS "hybrid" app packaged as APK — uses the device
  browser engine, works offline, installs like a normal app
- **Real native (Kotlin):** needs Android Studio — too heavy for a phone; recommend a PC
- **Full-power web app:** a mobile-first PWA — installable from the browser, no APK at all

## Path A — Website → APK (best for Termux users)
Tools that work from the phone: **PWA Builder / PWABuilder** (website) or
**Bubblewrap CLI** (needs Node). Simplest reliable flow:
1. Build the site (mobile-first, offline-friendly — see website-builder skill)
2. Add a web manifest (`manifest.json`: name, icons, `display: standalone`)
3. Add a service worker so it works offline
4. Package with PWABuilder (web) or `npm i -g @bubblewrap/cli` on a PC
5. Install the APK/AAB on the phone

PWA alone (no APK) already gives: home-screen icon, fullscreen, offline — good enough for most.

## Path B — Fully offline single-file APK (simple kiosk app)
```html
<!-- app.html — everything in one file: CSS + JS inline -->
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>My App</title>
<style>body{font-family:sans-serif;max-width:600px;margin:auto;padding:16px}</style>
</head>
<body>
  <h1>Hello from my phone-built app!</h1>
  <button onclick="alert('Works offline!')">Tap me</button>
</body>
</html>
```
Serve it locally for testing: `boomcode preview` (starts a server and opens the browser).

## Rules
- **Test on the real phone** — emulator is not available on Termux; use `boomcode preview`
- Keep it **offline-first** — phone users have flaky networks
- **Touch targets 44px+**, font 16px+ (see ui-ux-responsive skill)
- Icons: provide 192px + 512px PNGs (required for manifest)
- Don't promise Google Play publishing — it needs a $25 account + review; side-loading (APK) is fine for personal use
- Never embed real API keys in the app if it will be shared — the APK can be unpacked

## Deliver
- The project folder + how to open/test it (`boomcode preview`)
- If an APK was produced: the file path + “Install from unknown sources is needed” note
- One line on how to publish later if the user insists (Play Console = PC + $25)