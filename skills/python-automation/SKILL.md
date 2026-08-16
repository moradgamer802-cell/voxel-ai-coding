---
name: python-automation
description: Python diye daily kaj automate — file organize, data process, CSV/Excel, scraping, bot. Use when user says "script banao", "kaj ta auto hoy", "file gulake organize koro", or wants automation.
---

# Python Automation Skill

## Termux setup
- `pkg install python` → `pip install <package>` cholbe
- Termux storage: `/storage/emulated/0/` er file accesshte `termux-setup-storage`
  age chalano thakte hobe

## Common automation patterns

### File organizer (Downloads saaf kora — khub common request)
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
same pattern: pathlib + shutil, dry-run first (`print` diye ki korbe dekhao),
tarpor actual move.

### Web scraping (requests + beautifulsoup4)
- Static page: requests + bs4
- JS-rendered: playwright (Termux e heavy — desktop/proot bhalo)
- **Ethics/Rules:** robots.txt respect, har request er majhe `time.sleep(1)`,
  personal data scrape na, login-bypass na — public data only

## Script quality rules
- Har script e: `if __name__ == '__main__':` pattern
- DRY-RUN flag: `python3 script.py --dry` — age dekhbe ki hobe, tarpor asol run
- Log print: ki korche seta bolte thake (file count, skip count)
- Error hole porer file e chole jay, crash na (`try/except` per-file)
- Banglish comments + usage instructions docstring e

## Scheduled run (Termux)
- `pkg install cronie termux-services` → crontab
- Termux app background e thakte hobe (battery optimization off korte bolo)
- Simple hole: `while True: ... time.sleep(3600)` script o cholbe

## Deliver
- Script file + kivabe chalabe (ek line Banglish)
- Kono dangerous operation (delete/move) age confirm kore koro
