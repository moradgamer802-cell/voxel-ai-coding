# ZYVO â€” Ai (Ready-to-Use AI Coding CLI)

<div align="center">

**AI coding CLI for Termux â€” native Android, zero config, free AI models**

[![Platform](https://img.shields.io/badge/platform-Termux%20%7C%20Android%20%7C%20Linux%20%7C%20macOS-006a4e?style=flat-square&logo=linux)](https://github.com/zyvo9/zyvo)
[![PyPI](https://img.shields.io/pypi/v/zyvo.svg?style=flat-square&color=10a37f)](https://pypi.org/project/zyvo)
[![AI](https://img.shields.io/badge/AI-DeepSeek%20free-10a37f?style=flat-square&logo=openai)](https://opencode.ai/zen)
[![Model](https://img.shields.io/badge/model-deepseek--v4--flash--free-0e7665?style=flat-square)](https://opencode.ai/zen)
[![Setup](https://img.shields.io/badge/setup-zero%20config-f42a41?style=flat-square)](https://github.com/zyvo9/zyvo)
[![License](https://img.shields.io/badge/license-MIT-8aa7a3?style=flat-square)](LICENSE)

</div>

ZYVO is a fully customized AI coding agent â€” **install and it just works**.
Native Android build for Termux (no proot, no glibc), with automatic install
on Ubuntu proot / Debian / Chromebook / WSL / macOS as well.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/zyvo9/zyvo/main/install.sh | bash
```

Also on PyPI â€” same installer, layer fetched through pip:

```bash
pip install zyvo && zyvo-boot
```

That's it â€” **one command, zero config**. No `pkg install` needed beforehand:
python, ripgrep, unzip and git are auto-installed if missing, and skipped if
already present. The installer:

- shows a **single live progress line** (`[â–ˆâ–ˆâ–ˆâ–ˆâ–‘â–‘â–‘â–‘] 42% | 18.4/29.1 MB | 1.1 MB/s`)
  for the core download and for every long step, so you always know where it is
- **auto-installs missing dependencies** (`pkg`/`apt`) and skips what you already have
- keeps a **built-in free AI key** (zero config â€” override with `ZEN_API_KEY`)
- is **safe to re-run** â€” updates the core delta-wise (0 MB if nothing changed)
- **resumes interrupted downloads** and verifies the core with SHA256

## Update
```bash
zyvo update
```
> **Termux:** Use the F-Droid version (the Play Store build will NOT work).
> **Other platforms:** Ubuntu proot (Andronix / UserLAnd), Debian, WSL, macOS â€” same command.

## Device support

| Device | How it runs |
|--------|-------------|
| ARM64 phone (99% of Android) + Termux | Native bionic build â€” fastest, no proot |
| x86_64 emulator / Chromebook + Termux | Native build used when available; otherwise runs in Ubuntu proot |
| Ubuntu / Debian proot (any phone) | Official linux-arm64 build auto-installed |
| WSL / desktop Linux / macOS | Official build auto-installed |
| 32-bit phone (armv7) | No binary available â€” installer shows a clear message |

## Full-power mode

The AI works at **full strength**:

- **DeepSeek model by default** (deepseek-v4-flash) â€” stable + fast. Other
  tiers: `oc-settings model lightning|mid` (nemotron-ultra sometimes has
  provider errors â€” experimental)
- **Full-power agent** â€” the AI is instructed to: understand first â†’ plan â†’
  execute step by step â†’ verify by itself â†’ keep going until the WHOLE task
  is done. No placeholders or TODOs are delivered; web search brings in
  current information
- **All tools open** â€” no permissions, web search/fetch enabled â€” nothing
  holds the AI back

## Permissions

**None.** ZYVO shows no permission prompts â€” the AI runs commands, edits
files, and does web work on its own (beginner-friendly design).

## Overview

| Item | Detail |
|------|--------|
| Command | **`zyvo`** â€” opens `default/` project. `zyvo coffee-shop` â†’ opens/creates `zyvo/coffee-shop/` project folder |
| AI Provider | **OpenCode Zen â€” zero config** (key already built in, nothing to set up) |
| Model | **DeepSeek full-power** (deepseek-v4-flash-free) by default â€” stable; lightning/mid tiers also available |
| Language | Speaks **Banglish** (custom full-power agent) |
| Commands | `/explore`, `/review`, `/fix`, `/yolo`, `/zyvo`, `/open` + 20 skills |

## Usage

```bash
zyvo                   # start AI in zyvo/default/ project
zyvo coffee-shop       # open/create zyvo/coffee-shop/ project folder
zyvo ls                # list all project folders
zyvo preview           # local preview + auto-open in browser (http://localhost:8080)
zyvo share             # instant live Public HTTPS link (share with anyone on phone/PC)
zyvo update            # delta update check (0 MB if core is unchanged)
zyvo uninstall         # cleanly remove ZYVO (keeps your projects)
oc-settings            # model tier menu
zyvo-vision <file>     # AI describes any image (free, Gemini-powered)
zyvo-browser <url>     # AI reads a web page and answers questions about it
zyvo-browser search "query"  # real-time web search with AI summary
```

### Vision (see images â€” free)
```bash
zyvo-vision photo.jpg                     # describe an image
zyvo-vision photo.png "Read the error text"  # custom question
```

Powered by Google Gemini (`gemini-3.6-flash`) â€” free, ~60 requests/min, no
rate limit issues. Built-in key â€” zero config; override with `GEMINI_API_KEY`
or `~/.config/zyvo/vision.key`.

### Web Reader & Real-Time Search
```bash
zyvo-browser https://example.com "What does this page say?"  # read any page
zyvo-browser search "termux github"                          # real-time web search
zyvo-browser search "today cricket score" 5                  # top 5 results
```

Fetches a page, strips the HTML and lets the AI answer in detail. Search
mode queries DuckDuckGo in real time and summarizes the results with sources.
Uses `nemotron-3-ultra-free` (fast ~3s, long-text capable) â€” override with
`ZYVO_BROWSER_MODEL=deepseek-v4-flash-free`.

### YOLO mode

```bash
/yolo on             # AI presents 3-4 options before major steps (options mode)
/yolo off            # normal â€” AI works freely, no extra questions (default)
/yolo                # show current mode + toggle
```

When YOLO is **on**, the AI presents 3-4 options/choices before major steps
(editing files, choosing tech, design decisions, bug fixes). When **off**
(default), it works at full speed with no interruptions â€” the way ZYVO
normally works.

### Project folders (separate workspaces)

Each project has its own dedicated folder â€” files from different projects **never mix**:

```
/storage/emulated/0/zyvo/
â”œâ”€â”€ default/         â† zyvo             (when no project name given)
â”œâ”€â”€ coffee-shop/     â† zyvo coffee-shop  (all files + chats live here)
â”œâ”€â”€ telegram-bot/    â† zyvo telegram-bot
â””â”€â”€ portfolio/       â† zyvo portfolio
```

**Start/resume a project:** `zyvo <project-name>` â€” creates the folder automatically if it doesn't exist.  
**List projects:** `zyvo ls`  
Project names may only contain `a-z 0-9 . _ -` (no spaces).

| Command | Purpose |
|---------|---------|
| `oc-settings model` | Model tier: `max` (default) / `lightning` / `mid` / `ultra` (experimental) |
| `oc-settings models` | List Zen free models |

> **Restart `zyvo` after changing the model.**

## Reinstall / Update (delta)

`zyvo update` â€” or just run the same install command again.

**Delta update system:** the core binary carries a version stamp. If the
release is unchanged, the core is **not downloaded again (0 MB)** â€” only the
ZYVO layer (config / skills / commands, a few KB) is refreshed. If the core
changed, a full download happens.

**User settings are preserved:** model choice, provider key â€” updates merge
config, they don't overwrite it.

## Performance (phone lag / heating)

Lag and overheating were mainly caused by working at the storage root
(`/storage/emulated/0`) â€” scanning + snapshot-tracking thousands of files
(DCIM, WhatsApp, Android/) burned CPU. Now:

- **Dedicated workspace** â€” default `/storage/emulated/0/zyvo` (auto-created).
  The AI works there; the whole storage is no longer scanned
- **Snapshot off** (`snapshot: false`) â€” no separate git repo at the storage
  root. You can re-enable it in config if you want undo
- **Watcher ignore** â€” DCIM / Pictures / WhatsApp / Android... are not watched
- **Autoupdate off + sharing disabled** â€” no background network/CPU work

Extra tips: press `Ctrl+K` to disable TUI animations (great for battery),
work in a specific folder with `zyvo /storage/emulated/0/Documents`.

## Troubleshooting

- `zyvo: command not found` â†’ `pkg install ripgrep` + restart Termux
- Model error â†’ `source ~/.bashrc` (check key: `echo $OPENCODE_API_KEY`)
- Install failure â†’ check internet and rerun `bash install.sh` (downloads resume)
- 32-bit phone â†’ no binary available; use a 64-bit device or proot

---

*Full details (customization, keys, device support) â€” the installer,
config, and scripts are all open source in this repo.*
