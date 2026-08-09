# OpenCode Termux — Ready-to-Use AI Coding CLI

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
curl -fsSL https://raw.githubusercontent.com/moradgamer802-cell/opencode-termux/main/install.sh | bash
```

Na, locally:

```bash
git clone <apnar-repo-url> "$HOME/opencode-termux"
bash "$HOME/opencode-termux/install.sh"
```

## What it installs

1. **opencode binary** — `guysoft/opencode-termux` latest native Android build
   (SHA256 verified), `$PREFIX/bin/opencode`
2. **Config** — `~/.config/opencode/opencode.json`: default agent, model, permission
3. **Custom agent** — `bangla` (Bangla/Banglish e kotha bole)
4. **Slash commands** — `/dekho`, `/review`, `/fix`
5. **Theme** — `bangladeshi` (flag green/red), select: opencode er vitore `/theme`
6. **Skills** — website-builder, ui-ux-responsive, react-next, project-structure, clean-code

## AI Provider (free)

Installer OpenRouter free API key jiggasha korbe — **free** (openrouter.ai e free account,
credit card lagbe na). Free models: `deepseek-chat:free` (default), Gemini Flash free, etc.

- `/models` diye free model select korun
- Model change: `~/.config/opencode/opencode.json` e `"model"` field

## Customization

| Kono jinish | Ki koro |
|------|---------|
| Agent | `~/.config/opencode/agent/bangla.md` edit koro |
| Command | `~/.config/opencode/command/*.md` add/edit koro |
| Theme | `~/.config/opencode/themes/bangladeshi.json` edit koro |
| Config | `~/.config/opencode/opencode.json` edit koro |

**Config change er por opencode restart koro** — config load hoy startup e.

## Troubleshooting

- `opencode: command not found` → `pkg install ripgrep` + Termux restart
- `Bad system call` → purono glibc build thakle; `bash install.sh` abar chalale
  native build e switch hobe
- Model error → `source ~/.bashrc` (API key nahole), `opencode auth login` er bodole
  `export OPENROUTER_API_KEY=...`