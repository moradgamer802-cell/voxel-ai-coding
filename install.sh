#!/data/data/com.termux/files/usr/bin/bash
# OpenCode Termux — ready-to-use AI coding CLI installer
# Native Android aarch64 build (guysoft/opencode-termux), no proot, no glibc.
set -e

REPO="guysoft/opencode-termux"
GH_REPO="${GH_REPO:-moradgamer802-cell/opencode-termux}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config/opencode"

echo
echo "====================================="
echo "  OpenCode Termux Installer"
echo "  (ready-to-use AI coding CLI)"
echo "====================================="
echo

echo "[1/7] Checking Termux environment..."
if [ -z "$PREFIX" ] || [ ! -d "$PREFIX" ]; then
    echo "ERROR: Installer must run inside Termux (F-Droid version)."
    echo "Play Store er Termux kaj korbe na — F-Droid theke install korun:"
    echo "  https://f-droid.org/en/packages/com.termux/"
    exit 1
fi
ARCH="$(uname -m)"
if [ "$ARCH" != "aarch64" ]; then
    echo "ERROR: Shudhu aarch64 (ARM64) supported. Apnar arch: $ARCH"
    exit 1
fi
echo "Termux OK: $PREFIX (arch: $ARCH)"

echo "[2/7] Installing dependencies..."
if command -v pkg >/dev/null 2>&1; then
    if [ "$(id -u)" = "0" ]; then
        echo "WARNING: pkg as root chole na (dev container?) — existing dependencies check korbo..."
    else
        pkg update -y
        pkg install -y ripgrep git curl unzip tar
    fi
else
    echo "WARNING: pkg not found — existing dependencies check korbo..."
fi
for dep in rg git curl unzip tar; do
    command -v "$dep" >/dev/null 2>&1 || { echo "ERROR: $dep missing. Termux e: pkg install -y $dep"; exit 1; }
done
echo "Dependencies OK"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "[2.5/7] Resolving install source..."
if [ ! -d "$SCRIPT_DIR/config" ] || [ ! -d "$SCRIPT_DIR/skills" ]; then
    echo "One-click mode: install.sh curl|bash cholche — config repo theke clone korte hobe..."
    git clone --depth 1 "https://github.com/$GH_REPO.git" "$TMP/source" || {
        echo "ERROR: config repo clone hoyni. Locally clone kore: bash install.sh"
        exit 1
    }
    SCRIPT_DIR="$TMP/source"
fi
echo "Source OK: $SCRIPT_DIR"

echo "[3/7] Downloading latest OpenCode (Android aarch64)..."
ZIP_URL="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep -o 'https://[^"]*android-aarch64\.zip' | head -n1)"
if [ -z "$ZIP_URL" ]; then
    echo "ERROR: Release zip khuje pai nai. Internet connection check korun."
    exit 1
fi
SUMS_URL="${ZIP_URL%/*}/SHA256SUMS"
echo "Downloading: $ZIP_URL"
curl -fsSL --retry 3 -o "$TMP/opencode.zip" "$ZIP_URL"
curl -fsSL --retry 3 -o "$TMP/SHA256SUMS" "$SUMS_URL"
EXPECTED="$(grep "$(basename "$ZIP_URL")" "$TMP/SHA256SUMS" | awk '{print $1}' | head -n1)"
ACTUAL="$(sha256sum "$TMP/opencode.zip" | awk '{print $1}')"
if [ -n "$EXPECTED" ] && [ "$EXPECTED" != "$ACTUAL" ]; then
    echo "ERROR: SHA256 mismatch — download corrupted, aborted."
    exit 1
fi
echo "Download OK (SHA256 verified)"

echo "[4/7] Installing opencode..."
cd "$TMP"
unzip -o -q opencode.zip
mkdir -p "$PREFIX/libexec/opencode" "$PREFIX/lib"
install -m755 opencode "$PREFIX/bin/opencode"
install -m755 opencode.bin "$PREFIX/libexec/opencode/opencode.bin"
install -m644 libtagfix.so libc++_shared.so libopentui.so "$PREFIX/lib/"
if [ -f librust_pty_arm64.so ]; then
    install -m644 librust_pty_arm64.so "$PREFIX/lib/"
fi
echo "opencode installed -> $PREFIX/bin/opencode"

echo "[5/7] Installing config, agent, commands, theme..."
mkdir -p "$CONFIG_DIR/agent" "$CONFIG_DIR/command" "$CONFIG_DIR/themes" "$CONFIG_DIR/skills"
if [ -f "$CONFIG_DIR/opencode.json" ] || [ -f "$CONFIG_DIR/opencode.jsonc" ]; then
    cp -n "$CONFIG_DIR/opencode.json" "$CONFIG_DIR/opencode.json.bak" 2>/dev/null || true
    cp -n "$CONFIG_DIR/opencode.jsonc" "$CONFIG_DIR/opencode.jsonc.bak" 2>/dev/null || true
    echo "Purono config backup kora hoyeche (*.bak)"
fi
install -m644 "$SCRIPT_DIR/config/opencode.json" "$CONFIG_DIR/opencode.json"
install -m644 "$SCRIPT_DIR/config/agent/"*.md "$CONFIG_DIR/agent/" 2>/dev/null || true
install -m644 "$SCRIPT_DIR/config/command/"*.md "$CONFIG_DIR/command/" 2>/dev/null || true
install -m644 "$SCRIPT_DIR/config/themes/"*.json "$CONFIG_DIR/themes/" 2>/dev/null || true
cp -rn "$SCRIPT_DIR/skills/"* "$CONFIG_DIR/skills/" 2>/dev/null || true
echo "Config + agent + commands + theme + skills installed"

echo "[6/7] Setting up free AI provider (OpenRouter)..."
if ! grep -q "OPENROUTER_API_KEY" "$HOME/.bashrc" 2>/dev/null; then
    echo "OpenRouter free API key: openrouter.ai e (free) account kore Models -> API Keys theke key nin."
    echo -n "Free API key paste korun (skip korte Enter): "
    read -r KEY
    if [ -n "$KEY" ]; then
        echo "export OPENROUTER_API_KEY=\"$KEY\"" >> "$HOME/.bashrc"
        echo "API key save hoyeche ($HOME/.bashrc)"
    else
        echo "Key skip. Pore ekhane pathan: export OPENROUTER_API_KEY=...  (then: source ~/.bashrc)"
    fi
else
    echo "OPENROUTER_API_KEY already set — OK"
fi

echo "[7/7] Verifying install..."
opencode --version || { echo "ERROR: opencode choltese na. 'pkg reinstall' try korun."; exit 1; }

echo
echo "====================================="
echo "  Done! OpenCode Termux ready!"
echo "====================================="
echo "1) Run:       opencode   (notun terminal e: source ~/.bashrc)"
echo "2) Model:     free deepseek-chat (OpenRouter). /models diye free model select korun"
echo "3) Theme:     opencode er vitore /theme -> 'bangladeshi' select korun"
echo "4) Commands:  /dekho  /review  /fix   (apnar custom slash commands)"
echo "5) Agent:     'bangla' default agent — Bangla/Banglish e kotha bole"
echo "6) Help:      opencode er vitore /help"
echo
echo "NOTE: config change korle opencode restart korte hobe."
