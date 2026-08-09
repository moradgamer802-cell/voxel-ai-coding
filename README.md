# VOXEL — OpenCode Termux (Ready-to-Use AI Coding CLI)

OpenCode (AI coding agent) Termux er jonno fully customized — install korlei chole.
Native Android aarch64 build, **no proot, no glibc, no container**.

## Requirements

| Item | Detail |
|------|--------|
| Phone | ARM64 (aarch64) — modern phone gulo |
| Termux | **F-Droid version** (`https://f-droid.org/en/packages/com.termux/`) |
| Internet | ~160MB download |

> Play Store er Termux kaj korbe NA — F-Droid theke install korun.

## Install (one click)

```bash
curl -fsSL https://raw.githubusercontent.com/moradgamer802-cell/voxel/main/install.sh | bash
```

Na, locally:

```bash
git clone <apnar-repo-url> "$HOME/voxel"
bash "$HOME/voxel/install.sh"
```

## What it installs

1. **VOXEL binary** — `guysoft/opencode-termux` latest native Android build
   (SHA256 verified), command: **`voxel`** (`$PREFIX/bin/voxel`)
2. **Config** — `~/.config/opencode/opencode.json`: default agent, model, permission
3. **Custom agent** — `bangla` (Bangla/Banglish e kotha bole)
4. **Slash commands** — `/dekho`, `/review`, `/fix`, `/model`, `/approve`, `/safe`, `/voxel`
5. **Theme** — `bangladeshi` (flag green/red), select: voxel er vitore `/theme`
6. **Skills** — website-builder, ui-ux-responsive, react-next, project-structure, clean-code

## Settings Tool (`oc-settings`)

`oc-settings` installer thekei `$PREFIX/bin` e install hoy — model tier + permission switch

| Command | Kaj |
|---------|-----|
| `oc-settings` | Menu (model select) |
| `oc-settings model` | Model tier popup: Max/Mid/Ultra/Tiny/custom |
| `oc-settings model max` | Tiers: `max`(default), `mid`, `ultra`, `tiny` (direct) |
| `oc-settings auto on` | Auto-approve ON — bash/edit prompt chhara chole |
| `oc-settings auto off` | Ask-mode (safe), prompt abar ashbe |
| `oc-settings models` | Zen free model list dekhao |

Slash command thekeo: `/model` (tier select), `/approve` (auto-approve on), `/safe` (auto-approve off).
**Permission change er por voxel restart koro** — config load hoy startup e.

## AI Provider (OpenCode Zen — zero config)

Installer e **OpenCode Zen API key age thekei built-in** — kichu jamate hobe na.
Display name **`voxel`** (alias provider), actual service OpenCode Zen.
Default model: `voxel/deepseek-v4-flash-free` (Max default), small model: `voxel/ling-3.0-tiny-free`.

- Free models: `deepseek-v4-flash-free`, `mimo-v2.5-free`, `ling-3.0-*`, `nemotron-3-ultra-free` etc. (`oc-settings models`)
- Nijer key thakle: `ZEN_API_KEY=<key> bash install.sh` (key override korbe)
- Model change: `~/.config/opencode/opencode.json` e `"model"` field

⚠️ Note: installer e default key repo te ache (public repo). Nijer security er jonno chaile
`ZEN_API_KEY` env diye override korun, na repo private korun.

## Customization

| Kono jinish | Ki koro |
|------|---------|
| Agent | `~/.config/opencode/agent/bangla.md` edit koro |
| Command | `~/.config/opencode/command/*.md` add/edit koro |
| Theme | `~/.config/opencode/themes/bangladeshi.json` edit koro |
| Config | `~/.config/opencode/opencode.json` edit koro |

**Config change er por voxel restart koro** — config load hoy startup e.

## Compatible phones

| Item | Detail |
|------|--------|
| Phone | **aarch64 (ARM64)** only — 32-bit (armv7) phone e kaj korbe NA (openCode binary Bun runtime e build; Bun er Android build shudhu 64-bit) |
| Android | 7.0+ |
| Termux | **F-Droid version** required (Play Store wala not supported) |

## Troubleshooting

- `voxel: command not found` → `pkg install ripgrep` + Termux restart
- `Bad system call` → purono glibc build thakle; `bash install.sh` abar chalale
  native build e switch hobe
- Model error → `source ~/.bashrc` (OPENCODE_API_KEY check: `echo $OPENCODE_API_KEY`),
  key change: `ZEN_API_KEY=<new> bash install.sh` ar `oc-settings apply`
- `voxel` e "cannot execute: required file not found" → purono broken wrapper
  (`~/.opencode/bin/opencode`) confirm: `ls -la ~/.opencode/bin/`; installer auto-fix kore
  (`.bak` e move), notun terminal khule `voxel` run korun