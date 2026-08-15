# ZYVO — OpenCode (Ready-to-Use AI Coding CLI)

OpenCode (AI coding agent) ke fully customized — **install korlei chole**.
Termux e native Android build (no proot, no glibc), ar Ubuntu proot / Debian /
Chromebook / WSL / macOS eo auto install hoy.

## Install (one command)

```bash
curl -fsSL https://raw.githubusercontent.com/moradgamer802-cell/zyvo-ai-coding/main/install.sh | bash
```

> **Termux:** F-Droid version (Play Store wala kaj korbe NA).
> **Onno jayga:** Ubuntu proot (Andronix/UserLAnd), Debian, WSL, macOS — same command.

## Phone / device support

| Device | Kivabe chole |
|--------|--------------|
| ARM64 phone (99% Android) + Termux | Native bionic build — fastest, no proot |
| x86_64 emulator/Chromebook + Termux | Native build release hole auto; na hole Ubuntu proot e chalao |
| Ubuntu/Debian proot (jekono phone) | Official linux-arm64 build auto-install |
| WSL / desktop Linux / macOS | Official build auto-install |
| 32-bit phone (armv7) | Binary nai — installer clear message dekhabe |

## Permission system (4 option)

Jokhon AI kono kaj kore (command/file edit/web), permission ashe:

| Option | Kaj |
|--------|-----|
| **Allow** | Ekbar allow — TUI prompt e chapo |
| **Always Allow** | bash/edit/webfetch sob **persistent** allow: `oc-settings perm allow` (ba `/approve`) |
| **Deny** | Ekbar reject — TUI prompt e; bash **sob deny** (readonly): `oc-settings perm deny` |
| **Always Allow (session)** | `zyvo --yolo` diye start — **ei session e ar KONO permission prompt ashbe na**, exit korle auto safe-mode |

```bash
zyvo --yolo          # session mode: kono prompt nai, exit e auto safe
zyvo -y              # short version
oc-settings perm     # interactive menu (ask / always / deny / session)
/perm  /session  /approve  /safe   # in-chat commands
```

## Overview

| Item | Detail |
|------|--------|
| Command | **`zyvo`** — AI chole, default workdir `/storage/emulated/0` (document/downloads e direkt kaj) |
| AI Provider | **OpenCode Zen — zero config** (key age thekei built-in, kichu jamate hobe na) |
| Language | **Banglish** e kotha bole (default agent `build`) |
| Commands | `/dekho`, `/review`, `/fix`, `/model`, `/perm`, `/session`, `/approve`, `/safe`, `/zyvo` + 9 skills |

## Use

```bash
zyvo                 # AI start — ekhuni kaj korte parbe (ask-mode, safe)
zyvo --yolo          # session mode — permission prompt chhara
oc-settings          # model tier + permission menu
```

| Command | Kaj |
|---------|-----|
| `oc-settings model` | Model tier: `max` (default) / `mid` / `ultra` / `tiny` |
| `oc-settings perm` | Permission menu: ask / always allow / deny / session |
| `oc-settings auto on` | Always-allow ON (persistent) |
| `oc-settings auto off` | Ask-mode (safe) |
| `oc-settings models` | Zen free model list |

> Model/permission change er por **zyvo restart** koro (`--yolo` session baade — o to temp config).

## Reinstall / Update

Same install command abar chalao — sob auto-update hoy.
**User settings preserve hoy**: model choice, permission mode, provider key —
update e config merge hoy, overwrite na.

## Troubleshooting

- `zyvo: command not found` → `pkg install ripgrep` + Termux restart
- Model error → `source ~/.bashrc` (key check: `echo $OPENCODE_API_KEY`)
- Install fail → internet check kore `bash install.sh` abar chalao (download resume hoy)
- 32-bit phone → binary exist kore na; 64-bit device ba proot use koro

---

*Full details (customization, keys, phones) repo e investigation er jonno file gulo dekhene —
installer, config, scripts sob open source.*
