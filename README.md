# BOOMCODE

**Your app, BLAM, done!** — AI coding CLI for Termux.

## Install

**Termux (Android):**
```bash
curl -fsSL https://raw.githubusercontent.com/zyvo9/boomcode/main/install.sh | bash
```

**PyPI (any platform):**
```bash
pip install boomcode
```

Then run:
```bash
boomcode
```

## Features

- **Zero config** — installs and works in one command, free AI models included
- **Native Android** — built for Termux, ARM64, no root, no proot
- **Talks plainly** — describe what you want in plain words, it builds the whole thing
- **Builds complete projects** — websites, apps, bots, scripts — end to end
- **Sees images and videos** — drop a screenshot or clip, it understands it
- **Live preview** — `boomcode preview` opens your site on the phone with a public link
- **Projects stay separate** — `boomcode <name>` gives each idea its own folder and chat history
- **Ask mode** — `/ask` makes the AI check in with you before every big step

## Daily commands

| Command | What it does |
|---|---|
| `boomcode` | start (opens your `default/` project) |
| `boomcode coffee-shop` | open/create a project folder |
| `boomcode session` | list projects |
| `boomcode preview` | local + public live preview |
| `boomcode update` | delta update (0 MB if the core is unchanged) |
| `boomcode doctor` | health check |
| `boomcode uninstall` | remove (keeps your projects) |
