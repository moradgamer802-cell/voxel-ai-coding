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
| **Always Allow** | bash/edit/webfetch sob **persistent** allow: `oc-settings perm allow` |
| **Deny** | Ekbar reject — TUI prompt e; bash **sob deny** (readonly): `oc-settings perm deny` |
| **Always Allow (session)** | In-chat **`/auto`** (ba `/approve`) — **ei session e ar KONO permission prompt ashbe na**; zyvo band korle auto safe-mode. Start theke chaile: `zyvo --yolo` |

```bash
/auto                # in-chat: session mode ON — ekhuni ar prompt nai
zyvo --yolo          # session mode from start (temp config, zero-trace)
zyvo -y              # short version
oc-settings perm     # interactive menu (ask / always / deny / session)
/perm  /session  /safe   # in-chat commands
```

## Overview

| Item | Detail |
|------|--------|
| Command | **`zyvo`** — AI chole, default workspace `/storage/emulated/0/zyvo` (dedicated folder — fast, phone halka thake). Onno folder e: `zyvo /storage/emulated/0/Documents` |
| AI Provider | **OpenCode Zen — zero config** (key age thekei built-in, kichu jamate hobe na) |
| Language | **Banglish** e kotha bole (default agent `build`) |
| Commands | `/dekho`, `/review`, `/fix`, `/model`, `/perm`, `/session`, `/approve`, `/safe`, `/zyvo` + 9 skills |

## Use

```bash
zyvo                 # AI start — ekhuni kaj korte parbe (ask-mode, safe)
zyvo --yolo          # session mode — permission prompt chhara
zyvo session         # session list
zyvo session proj1   # notun/resume session "proj1" — zyvo/proj1/ folder e
oc-settings          # model tier + permission menu
```

### Sessions (alada alada kaj)

Prottek session er nijer folder + nijer chat history:

```
/storage/emulated/0/zyvo/
├── seson1/     ← zyvo session seson1  (file + kotha ekhanei jome)
└── seson2/     ← zyvo session seson2
```

`zyvo session seson1` dile sei session er kotha-motto abar shuru —
age ki bolse chilo AI mone rakhbe (`--continue`). Naam e sudhu
`a-z 0-9 . _ -` jabe.

| Command | Kaj |
|---------|-----|
| `oc-settings model` | Model tier: `max` (default) / `mid` / `ultra` / `tiny` |
| `oc-settings perm` | Permission menu: ask / always allow / deny / session |
| `oc-settings auto on` | Session mode ON (ei session e prompt nai) |
| `oc-settings auto off` | Safe mode (session off + ask) |
| `oc-settings models` | Zen free model list |

> Model/permission change er por **zyvo restart** koro (`--yolo` session baade — o to temp config).

## Reinstall / Update

Same install command abar chalao — sob auto-update hoy.
**User settings preserve hoy**: model choice, permission mode, provider key —
update e config merge hoy, overwrite na.

## Performance (phone lag / gorom hole)

Phone gorom + lag er main karon chilo storage-root (`/storage/emulated/0`) e
kaj kora — hajar hajar file (DCIM, WhatsApp, Android/) scan + snapshot
tracking e CPU oghan hoy. Ekhon:

- **Dedicated workspace** — default `/storage/emulated/0/zyvo` (auto-create).
  AI ekhane kaj kore, puro storage tala-peete hoy na
- **Snapshot off** (`snapshot: false`) — storage-root e alada git repo chalano
  band. Undo lagle on korte paro config e
- **Watcher ignore** — DCIM/Pictures/WhatsApp/Android... watch kora hoy na
- **Autoupdate off + share disabled** — background network/CPU kaj nai

Extra tips: `Ctrl+K` chaple TUI animation band (battery boro boro bache),
specific folder e kaj: `zyvo /storage/emulated/0/Documents`.

## Troubleshooting

- `zyvo: command not found` → `pkg install ripgrep` + Termux restart
- Model error → `source ~/.bashrc` (key check: `echo $OPENCODE_API_KEY`)
- Install fail → internet check kore `bash install.sh` abar chalao (download resume hoy)
- 32-bit phone → binary exist kore na; 64-bit device ba proot use koro

---

*Full details (customization, keys, phones) repo e investigation er jonno file gulo dekhene —
installer, config, scripts sob open source.*
