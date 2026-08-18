---
name: python-automation
description: Automate daily tasks with Python — file organization, data processing, CSV/Excel, scraping, bots. Use when user says "write a script", "make this automatic", "organize these files", or wants automation.
---

# Python Automation Skill

## Termux setup
- `pkg install python` → `pip install <package>` works
- To access `/storage/emulated/0/` files, run `termux-setup-storage` first

## Common automation patterns

### File organizer (cleaning Downloads — very common request)
```python
from pathlib import Path
import shutil
FOLDERS = {'.jpg': 'Pictures', '.png': 'Pictures', '.pdf': 'Documents',
           '.mp4': 'Videos', '.mp3': 'Music', '.apk': 'APKs'}
src = Path('/storage/emulated/0/Download')
for f in src.iterdir():
    if f.is_file() and not f.name.startswith('.'):
        dest = src / FOLDERS.get(f.suffix.lower(), 'Others')
        dest.mkdir(exist_ok=True)
        shutil.move(str(f), str(dest / f.name))
```

### CSV → Excel report (openpyxl), bulk rename, folder backup —
same pattern: pathlib + shutil, dry-run first (print what it will do),
then the actual move.

### Web scraping (requests + beautifulsoup4)
- Static pages: requests + bs4
- JS-rendered: playwright (heavy on Termux — desktop/proot is better)
- **Ethics/Rules:** respect robots.txt, `time.sleep(1)` between requests,
  no personal data scraping, no login bypass — public data only

## Script quality rules
- Every script: `if __name__ == '__main__':` pattern
- DRY-RUN flag: `python3 script.py --dry` — shows what will happen before the real run
- Log prints: say what it is doing (file count, skip count)
- On errors, continue to the next file instead of crashing (`try/except` per-file)
- English comments + usage instructions in the docstring

## Scheduled runs (Termux)
- `pkg install cronie termux-services` → crontab
- The Termux app must stay in the background (tell the user to disable battery optimization)
- For simple cases, a `while True: ... time.sleep(3600)` script also works

## Deliver
- The script file + how to run it (one line)
- Confirm before any dangerous operation (delete/move)