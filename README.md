# ZYVO — OpenCode (Ready-to-Use AI Coding CLI)

<div align="center">

**AI coding CLI for Termux — native Android, zero config, free AI models**

[![Platform](https://img.shields.io/badge/platform-Termux%20%7C%20Android%20%7C%20Linux%20%7C%20macOS-006a4e?style=flat-square&logo=linux)](https://github.com/zyvo9/zyvo-ai-coding)
[![AI](https://img.shields.io/badge/AI-DeepSeek%20free-10a37f?style=flat-square&logo=openai)](https://opencode.ai/zen)
[![Model](https://img.shields.io/badge/model-deepseek--v4--flash--free-0e7665?style=flat-square)](https://opencode.ai/zen)
[![Setup](https://img.shields.io/badge/setup-zero%20config-f42a41?style=flat-square)](https://github.com/zyvo9/zyvo-ai-coding)
[![License](https://img.shields.io/badge/license-MIT-8aa7a3?style=flat-square)](LICENSE)

</div>

ZYVO is a fully customized AI coding agent — **install and it just works**.
Native Android build for Termux (no proot, no glibc), with automatic install
on Ubuntu proot / Debian / Chromebook / WSL / macOS as well.

## Install

```bash
pkg install python
```

```bash
curl -fsSL https://raw.githubusercontent.com/zyvo9/zyvo-ai-coding/main/install.sh | bash
```
## Update
```bash
zyvo update
```
> **Termux:** Use the F-Droid version (the Play Store build will NOT work).
> **Other platforms:** Ubuntu proot (Andronix / UserLAnd), Debian, WSL, macOS — same command.

## Device support

| Device | How it runs |
|--------|-------------|
| ARM64 phone (99% of Android) + Termux | Native bionic build — fastest, no proot |
| x86_64 emulator / Chromebook + Termux | Native build used when available; otherwise runs in Ubuntu proot |
| Ubuntu / Debian proot (any phone) | Official linux-arm64 build auto-installed |
| WSL / desktop Linux / macOS | Official build auto-installed |
| 32-bit phone (armv7) | No binary available — installer shows a clear message |

## Full-power mode

The AI works at **full strength**:

- **DeepSeek model by default** (deepseek-v4-flash) — stable + fast. Other
  tiers: `oc-settings model lightning|mid` (nemotron-ultra sometimes has
  provider errors — experimental)
- **Full-power agent** — the AI is instructed to: understand first → plan →
  execute step by step → verify by itself → keep going until the WHOLE task
  is done. No placeholders or TODOs are delivered; web search brings in
  current information
- **All tools open** — no permissions, web search/fetch enabled — nothing
  holds the AI back

## Permissions

**None.** ZYVO shows no permission prompts — the AI runs commands, edits
files, and does web work on its own (beginner-friendly design).

## Overview

| Item | Detail |
|------|--------|
| Command | **`zyvo`** — default workspace `/storage/emulated/0/zyvo` (dedicated folder — fast, keeps your phone light). Other folder: `zyvo /storage/emulated/0/Documents` |
| AI Provider | **OpenCode Zen — zero config** (key already built in, nothing to set up) |
| Model | **DeepSeek full-power** (deepseek-v4-flash-free) by default — stable; lightning/mid tiers also available |
| Language | Speaks **Banglish** (custom full-power agent) |
| Commands | `/dekho`, `/review`, `/fix`, `/model`, `/zyvo` + 13 skills |

## Usage

```bash
zyvo                 # start the AI — ready to work right away
zyvo session         # list sessions
zyvo session proj1   # new/resume session "proj1" — stored in zyvo/proj1/
zyvo update          # delta update check (0 MB if core is unchanged)
oc-settings          # model tier menu
```

### Sessions (separate projects)

Each session has its own folder and chat history:

```
/storage/emulated/0/zyvo/
├── seson1/     ← zyvo session seson1  (files + chats live here)
└── seson2/     ← zyvo session seson2
```

`zyvo session seson1` resumes that session's conversation — the AI
remembers what was said before (`--continue`). Names may only contain
`a-z 0-9 . _ -`.

| Command | Purpose |
|---------|---------|
| `oc-settings model` | Model tier: `max` (default) / `lightning` / `mid` / `ultra` (experimental) |
| `oc-settings models` | List Zen free models |

> **Restart `zyvo` after changing the model.**

## Reinstall / Update (delta)

`zyvo update` — or just run the same install command again.

**Delta update system:** the core binary carries a version stamp. If the
release is unchanged, the core is **not downloaded again (0 MB)** — only the
ZYVO layer (config / skills / commands, a few KB) is refreshed. If the core
changed, a full download happens.

**User settings are preserved:** model choice, provider key — updates merge
config, they don't overwrite it.

## Performance (phone lag / heating)

Lag and overheating were mainly caused by working at the storage root
(`/storage/emulated/0`) — scanning + snapshot-tracking thousands of files
(DCIM, WhatsApp, Android/) burned CPU. Now:

- **Dedicated workspace** — default `/storage/emulated/0/zyvo` (auto-created).
  The AI works there; the whole storage is no longer scanned
- **Snapshot off** (`snapshot: false`) — no separate git repo at the storage
  root. You can re-enable it in config if you want undo
- **Watcher ignore** — DCIM / Pictures / WhatsApp / Android... are not watched
- **Autoupdate off + sharing disabled** — no background network/CPU work

Extra tips: press `Ctrl+K` to disable TUI animations (great for battery),
work in a specific folder with `zyvo /storage/emulated/0/Documents`.

## Troubleshooting

- `zyvo: command not found` → `pkg install ripgrep` + restart Termux
- Model error → `source ~/.bashrc` (check key: `echo $OPENCODE_API_KEY`)
- Install failure → check internet and rerun `bash install.sh` (downloads resume)
- 32-bit phone → no binary available; use a 64-bit device or proot

---

*Full details (customization, keys, device support) — the installer,
config, and scripts are all open source in this repo.*
