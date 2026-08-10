# ZYVO — OpenCode Termux (Ready-to-Use AI Coding CLI)

OpenCode (AI coding agent) ke Termux e fully customized — **install korlei chole**.
Native Android aarch64 build: **no proot, no glibc, no container**.

## Install (one command)

```bash
curl -fsSL https://raw.githubusercontent.com/moradgamer802-cell/voxel-ai-coding/main/install.sh | bash
```

> **Requirement:** Termux **F-Droid version** (Play Store wala kaj korbe NA) — ARM64 phone.

## Overview

| Item | Detail |
|------|--------|
| Command | **`zyvo`** — AI chole, default workdir `/storage/emulated/0` (booster tomader document/downloads e direkt kaj kore) |
| AI Provider | **OpenCode Zen — zero config** (key age thekei built-in, kichu jamate hobe na) |
| Language | **Bangla/Banglish** e kotha bole (default agent `bangla`) |
| Commands | `/dekho`, `/review`, `/fix`, `/model`, `/approve`, `/safe`, `/zyvo` + 5 skills (website-builder, ui-ux, react-next, etc.) |

## Use

```bash
zyvo                 # AI start — ekhuni kaj korte parbe
/theme                # theme change (bangladeshi default)
oc-settings           # model tier + permission menu
```

| Command | Kaj |
|---------|-----|
| `oc-settings model` | Model tier: `max` (default) / `mid` / `ultra` / `tiny` |
| `oc-settings auto on` | Auto-approve ON (prompt chhara chole) |
| `oc-settings auto off` | Ask-mode (safe) |
| `oc-settings models` | Zen free model list |

> Model/permission change er por **zyvo restart** koro.

## Reinstall / Update

Purono version update korar jonno: same install command abar chalao — sob auto-update hoy.

## Troubleshooting

- `zyvo: command not found` → `pkg install ripgrep` + Termux restart
- Model error → `source ~/.bashrc` (key check: `echo $OPENCODE_API_KEY`)
- Install fail → internet check kore `bash install.sh` abar chalao

---

*Full details (customization, keys, phones) repo e investigation er jonno file gulo dekhene —
installer, config, scripts sob open source.*