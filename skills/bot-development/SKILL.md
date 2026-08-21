---
name: bot-development
description: Build bots — Telegram, WhatsApp, Discord — messaging, commands, automation, buttons. Use when user wants to create a bot or automate something via chat.
---

# Bot Development Skill

## Telegram bot (easiest — free, works great on Termux)
1. Talk to [@BotFather](https://t.me/BotFather) → `/newbot` → get the token
2. Store the token in `.env` — NEVER commit it
3. Python with `python-telegram-bot` (modern version 20+/21+):

```python
import os
from dotenv import load_dotenv
from telegram import Update
from telegram.ext import Application, CommandHandler, ContextTypes

load_dotenv()
TOKEN = os.getenv("BOT_TOKEN")

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("Hello! I am your bot. /help for commands.")

app = Application.builder().token(TOKEN).build()
app.add_handler(CommandHandler("start", start))
app.run_polling()  # stays running — keep the phone awake
```

## WhatsApp (two paths)
- **Beginner path:** no code — use a service (WhatsApp Business API via Meta Cloud API, or a provider like Twilio) — costs/setup involved
- **Automation path (advanced):** a headless browser driver (e.g. playwright) is fragile and against WhatsApp ToS — advise against it; prefer official APIs
- For chat widgets on websites: wa.me links work everywhere — `https://wa.me/<number>?text=...`

## Bot design rules
- **Start with 3 commands**: `/start`, `/help`, one real feature. That's enough
- Async/event-driven — never blocking loops in webhook mode
- **Rate limits**: Telegram allows ~30 msg/sec; add small sleeps for long broadcasts
- Inline keyboards (`InlineKeyboardButton`) beat typing for choices — mobile-friendly
- Long tasks: reply "processing…" first, then edit the message when done
- Log errors to a file; add a `/admin` (owner-only) status command

## Running 24/7 on Termux
- `termux-wake-lock` prevents the CPU from sleeping
- `pkg install termux-services` + `sv-enable` keeps it alive across app restarts
- For real 24/7: a free bot host (Railway/Render free tiers) or user's own VPS
- Simple alternative: a `while True` + `time.sleep` loop with `python3 bot.py` in tmux

## Security
- Token in `.env`, gitignored
- Never log incoming messages that contain secrets
- Validate/escape user input before storing or echoing
- Webhook URL: use a secret path (`/webhook/<token>`) — public bots get scanned instantly