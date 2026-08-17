# ZYVO — OpenCode (Ready-to-Use AI Coding CLI)

OpenCode (AI coding agent) ke fully customized — **install korlei chole**.
Termux e native Android build (no proot, no glibc), ar Ubuntu proot / Debian /
Chromebook / WSL / macOS eo auto install hoy.

## Install (command)
```bash
pkg install python
```
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

## Full-power mode

AI tar **puro shokti** diye kaj kore:

- **DeepSeek model default** (deepseek-v4-flash) — stable + fast. Onno tier:
  `oc-settings model lightning|mid` (nemotron-ultra te kichu somoy provider error ashe — experimental)
- **Full-power agent** — AI ke bala geche: age bujho → plan → step-by-step
  execute → nije verify → PURO kaj sesh na howa porjonto thaimo na.
  Placeholder/TODO delivered kore na, web search kore current info anta pare
- **Sob tool khola** — permission nai, web search/fetch on — AI er hate kono bdha nai

## Permission

**Nai.** ZYVO te kono permission prompt ashe na — AI nije-i sob command,
file edit, web kaj chalay (beginner-friendly design).

## Overview

| Item | Detail |
|------|--------|
| Command | **`zyvo`** — AI chole, default workspace `/storage/emulated/0/zyvo` (dedicated folder — fast, phone halka thake). Onno folder e: `zyvo /storage/emulated/0/Documents` |
| AI Provider | **OpenCode Zen — zero config** (key age thekei built-in, kichu jamate hobe na) |
| Model | **DeepSeek full-power** (deepseek-v4-flash-free) default — stable; lightning/mid tier o ache |
| Language | **Banglish** e kotha bole (custom full-power agent) |
| Commands | `/dekho`, `/review`, `/fix`, `/model`, `/zyvo` + 13 skills |

## Use

```bash
zyvo                 # AI start — ekhuni kaj korte parbe
zyvo session         # session list
zyvo session proj1   # notun/resume session "proj1" — zyvo/proj1/ folder e
zyvo update          # delta update check (core same hole 0 MB)
oc-settings          # model tier menu
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
| `oc-settings model` | Model tier: `max` (default) / `lightning` / `mid` / `ultra` (experimental) |
| `oc-settings models` | Zen free model list |

> Model change er por **zyvo restart** koro.

## Reinstall / Update (delta)

`zyvo update` — ba same install command abar chalao.

**Delta update system:** core binary er version stamp thake. Release same
thakle core **ar download hoy na (0 MB)** — shudhu ZYVO layer (config/
skills/commands, koyek KB) fresh hoy. Core sathei bodlale full download.

**User settings preserve hoy**: model choice, provider key —
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
