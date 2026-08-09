#!/data/data/com.termux/files/usr/bin/bash
# OpenCode Termux — ready-to-use AI coding CLI installer
# Native Android aarch64 build (guysoft/opencode-termux), no proot, no glibc.
set -e

REPO="guysoft/opencode-termux"
GH_REPO="${GH_REPO:-moradgamer802-cell/voxel}"
DEFAULT_ZEN_KEY="${ZEN_API_KEY:-sk-PKOWRt2391BL0MP3W90yaG8qx4vofQJQgigJreBBYjrArj0lwuU1HkWUqOHgDGHP}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config/opencode"

echo
echo "██╗    ██╗ ██████╗  ██╗  ██╗ ███████╗ ██╗"
echo "██║    ██║ ██╔══██╗ ╚██╗██╔╝ ██╔════╝ ██║"
echo "██║    ██║ ██║  ██║  ╚███╔╝  ███████╗ ██║"
echo "╚██╗  ██╔╝ ██║  ██║  ██╔██╗  ╚════██║ ██║"
echo " ╚██████╔╝ ╚██████╔╝ ██╔╝ ██╗ ███████╔╝ ███████╗"
echo "  ╚═══╝   ╚═════╝ ╚═╝  ╚═╝ ╚══════╝ ╚══════╝"
echo "====================================="
echo "  VOXEL — OpenCode Termux Installer"
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

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "[2/7] Downloading latest OpenCode (Android aarch64)..."
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

echo "[2.5/7] Checking native libraries..."
extract_one() {
    # $1=zip, $2=file -> cwd
    if command -v unzip >/dev/null 2>&1; then
        unzip -o -q "$1" "$2"
    elif command -v busybox >/dev/null 2>&1; then
        busybox unzip -o -q "$1" "$2"
    else
        return 1
    fi
}
if [ ! -f "$PREFIX/lib/libc++_shared.so" ]; then
    echo "libc++_shared.so missing — bootstrap (apt er jonno dorkar)..."
    if extract_one "$TMP/opencode.zip" libc++_shared.so; then
        install -m644 "$TMP/libc++_shared.so" "$PREFIX/lib/libc++_shared.so"
        echo "Bootstrap OK (from opencode zip)"
    else
        echo "unzip/busybox nai — Termux repo theke libc++ deb neya hocche..."
        PKG_INDEX="$TMP/packages-index"
        curl -fsSL --retry 3 -o "$PKG_INDEX" \
            "https://packages-cf.termux.dev/apt/termux-main/dists/stable/main/binary-aarch64/Packages" || true
        DEB_PATH="$(awk '/^Package: libc\+\+$/{found=1} found && /^Filename:/{print $2; exit}' "$PKG_INDEX" 2>/dev/null)"
        if [ -n "$DEB_PATH" ]; then
            curl -fsSL --retry 3 -o "$TMP/libc.deb" "https://packages-cf.termux.dev/apt/termux-main/$DEB_PATH"
            md() { mkdir -p "$TMP/root"; dpkg-deb -x "$TMP/libc.deb" "$TMP/root"; }
            md
            install -m644 "$TMP/root/data/data/com.termux/files/usr/lib/libc++_shared.so" "$PREFIX/lib/" 2>/dev/null \
                && echo "Bootstrap OK (from libc++ deb)"
        else
            echo "WARNING: bootstrap fail — 'pkg install -y libc++' nije chalano. Agamikal: tarpore abar bash install.sh."
        fi
    fi
else
    echo "libc++_shared.so already present — OK"
fi

echo "[3/7] Installing dependencies..."
if command -v pkg >/dev/null 2>&1; then
    if [ "$(id -u)" = "0" ]; then
        echo "WARNING: pkg as root chole na (dev container?) — existing dependencies check korbo..."
    else
        pkg update -y
        pkg install -y ripgrep git curl unzip tar libc++
    fi
else
    echo "WARNING: pkg not found — existing dependencies check korbo..."
fi
for dep in rg git curl unzip tar; do
    command -v "$dep" >/dev/null 2>&1 || { echo "ERROR: $dep missing. Termux e: pkg install -y $dep"; exit 1; }
done
echo "Dependencies OK"

echo "[2.6] Resolving install source..."
if [ ! -d "$SCRIPT_DIR/config" ] || [ ! -d "$SCRIPT_DIR/skills" ]; then
    echo "One-click mode: install.sh curl|bash cholche — config repo theke clone korte hobe..."
    git clone --depth 1 "https://github.com/$GH_REPO.git" "$TMP/source" || {
        echo "ERROR: config repo clone hoyni. Locally clone kore: bash install.sh"
        exit 1
    }
    SCRIPT_DIR="$TMP/source"
fi
echo "Source OK: $SCRIPT_DIR"

echo "[4/7] Installing opencode..."
cd "$TMP"
unzip -o -q opencode.zip
mkdir -p "$PREFIX/libexec/opencode" "$PREFIX/lib"
install -m755 opencode "$PREFIX/bin/opencode"
install -m755 opencode.bin "$PREFIX/libexec/opencode/opencode.bin"
install -m644 libtagfix.so libopentui.so "$PREFIX/lib/"
if [ ! -f "$PREFIX/lib/libc++_shared.so" ]; then
    install -m644 libc++_shared.so "$PREFIX/lib/"
fi
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
if [ -f "$SCRIPT_DIR/scripts/oc-settings.sh" ]; then
    install -m755 "$SCRIPT_DIR/scripts/oc-settings.sh" "$PREFIX/bin/oc-settings"
    echo "oc-settings installed -> $PREFIX/bin/oc-settings"
fi
echo "Config + agent + commands + theme + skills installed"

echo "[6/7] Setting up AI provider (OpenCode Zen, default key)..."
if ! grep -q "OPENCODE_API_KEY\|OPENCODE_ZEN_API_KEY" "$HOME/.bashrc" 2>/dev/null; then
    echo "export OPENCODE_API_KEY=\"$DEFAULT_ZEN_KEY\"" >> "$HOME/.bashrc"
    echo "OpenCode Zen default key save hoyeche ($HOME/.bashrc)"
    echo "NOTE: nijer key thakle: ZEN_API_KEY=<key> bash install.sh"
else
    echo "OPENCODE_API_KEY already set — OK"
fi

echo "[6.5/7] Checking stale opencode wrappers..."
STALE="$HOME/.opencode/bin/opencode"
if [ -e "$STALE" ] || [ -L "$STALE" ]; then
    if "$STALE" --version >/dev/null 2>&1; then
        echo "OK: purono wrapper ($STALE) kaj korche — rakha holo"
    else
        mv "$STALE" "$STALE.bak" 2>/dev/null && echo "Stale broken wrapper ($STALE) -> $STALE.bak (new ekhon use hobe)"
    fi
fi

echo "[7/7] Verifying install..."
"$PREFIX/bin/opencode" --version || { echo "ERROR: opencode choltese na. 'bash install.sh' abar try korun."; exit 1; }
echo "OK: opencode ready at $PREFIX/bin/opencode"

echo
echo "====================================="
echo "  Done! VOXEL ready!"
echo "====================================="
echo "1) Run:       opencode   (notun terminal e: source ~/.bashrc)"
echo "2) Model:     FREE zen model: deepseek-v4-flash-free (default). /models diye change korun"
echo "3) Theme:     opencode er vitore /theme -> 'bangladeshi' select korun"
echo "4) Commands:  /dekho  /review  /fix  /model  /auto  /safe   (apnar custom slash commands)"
echo "5) Agent:     'bangla' default agent — Bangla/Banglish e kotha bole"
echo "6) API key:   OpenCode Zen default key already set — zero config"
echo "7) Settings:  oc-settings model (default/mid/max/tiny) | oc-settings auto on|off (auto-approve)"
echo
echo "NOTE: config change korle opencode restart korte hobe. Notun terminal khulo (na hash -r)."