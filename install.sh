#!/data/data/com.termux/files/usr/bin/bash
# VOXEL — ready-to-use AI coding CLI installer
# Native Android aarch64 build (guysoft/opencode-termux), no proot, no glibc.
set -e

REPO="guysoft/opencode-termux"
GH_REPO="${GH_REPO:-moradgamer802-cell/voxel-ai-coding}"
DEFAULT_ZEN_KEY="${ZEN_API_KEY:-sk-PKOWRt2391BL0MP3W90yaG8qx4vofQJQgigJreBBYjrArj0lwuU1HkWUqOHgDGHP}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config/opencode"

# ---------- animation helpers ----------
GREEN='\033[32m'; CYAN='\033[36m'; DIM='\033[2m'; RED='\033[31m'; BOLD='\033[1m'; RESET='\033[0m'
SPIN=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

now() { date +%s; }

spin() { # spin <label> <cmd...> — spinner + elapsed time (15s+ por "loading Xs")
    local label="$1"; shift
    "$@" >/dev/null 2>&1 &
    local pid=$!
    local i=0 start=
    start=$(now)
    while kill -0 $pid 2>/dev/null; do
        local el=$(( $(now) - start ))
        if [ "$el" -ge 120 ]; then
            printf "\r\033[2K${CYAN}%s${RESET} %s ${DIM}(loading... %ss)${RESET} ${RED}${BOLD}(stuck? Ctrl+C → bash install.sh abar — safe resume)${RESET}" "${SPIN[i++ % 10]}" "$label" "$el"
        elif [ "$el" -ge 15 ]; then
            printf "\r\033[2K${CYAN}%s${RESET} %s ${DIM}(loading... %ss)${RESET}" "${SPIN[i++ % 10]}" "$label" "$el"
        else
            printf "\r\033[2K${CYAN}%s${RESET} %s" "${SPIN[i++ % 10]}" "$label"
        fi
        sleep 0.12
    done
    wait $pid; local rc=$?
    local el=$(( $(now) - start ))
    if [ $rc -eq 0 ]; then
        printf "\r\033[2K${GREEN}${BOLD}[DONE]${RESET} ${GREEN}%s${RESET} ${DIM}(%ss)${RESET}\n" "$label" "$el"
    else
        printf "\r\033[2K${RED}${BOLD}[FAIL]${RESET} %s (rc=$rc, %ss)\n" "$label" "$el"
    fi
    return $rc
}

banner() { # VOXEL logo — line by line, green glow
    local lines=(
        '██╗    ██╗ ██████╗  ██╗  ██╗ ███████╗ ██╗'
        '██║    ██║ ██╔══██╗ ╚██╗██╔╝ ██╔════╝ ██║'
        '██║    ██║ ██║  ██║  ╚███╔╝  ███████╗ ██║'
        '╚██╗  ██╔╝ ██║  ██║  ██╔██╗  ╚════██║ ██║'
        ' ╚██████╔╝ ╚██████╔╝ ██╔╝ ██╗ ███████╔╝ ███████╗'
        '  ╚═══╝   ╚═════╝ ╚═╝  ╚═╝ ╚══════╝ ╚══════╝'
    )
    echo
    for ln in "${lines[@]}"; do
        printf "${GREEN}${BOLD}%s${RESET}\n" "$ln"
        sleep 0.08
    done
    echo
}

echo
banner
printf "${BOLD}=====================================${RESET}\n"
printf "${BOLD}  VOXEL — OpenCode Termux Installer${RESET}\n"
printf "${BOLD}  (ready-to-use AI coding CLI)${RESET}\n"
printf "${BOLD}=======================================${RESET}\n"
echo

echo "[1/7] Checking Termux environment..."
if [ -z "$PREFIX" ] || [ ! -d "$PREFIX" ]; then
    echo "ERROR: Installer must run inside Termux (F-Droid version)."
    echo "Play Store er Termux kaj korbe na — F-Droid theke install korun:"
    echo "  https://f-droid.org/en/packages/com.termux/"
    exit 1
fi
ARCH="${VOXEL_ARCH:-$(uname -m)}"
case "$ARCH" in
    aarch64|arm64) ZIP_MATCH="android-aarch64";;
    *) ZIP_MATCH="android-$ARCH";;
esac
if [ "$ARCH" != "aarch64" ] && [ "$ARCH" != "arm64" ]; then
    echo "INFO: apnar arch: $ARCH — try korbo release e $ZIP_MATCH asset ache na"
fi
echo "Termux OK: $PREFIX (arch: $ARCH)"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
INSTALL_START="$(now)"

STEP=0
head_step() { # [NN%] label
    STEP=$((STEP+1))
    local pct=$((STEP*100/9))
    printf "\n${BOLD}[${GREEN}%3d%%${RESET}${BOLD}]${RESET} %s\n" "$pct" "$1"
}

head_step "Downloading VOXEL core (${ZIP_MATCH})"
ZIP_URL="$(curl -fsSL --connect-timeout 10 --max-time 30 "https://api.github.com/repos/$REPO/releases/latest" | grep -o "https://[^\"]*${ZIP_MATCH}\.zip" | head -n1)"
if [ -z "$ZIP_URL" ]; then
    echo "ERROR: $ARCH er jonno opencode build nai — shudhu aarch64/arm64 release ache."
    echo "       (upstream Bun runtime Android build shudhu 64-bit — 32-bit phone supported nai)"
    echo "       Env override: VOXEL_ARCH=aarch64 bash install.sh (jodi nijer zip thake)"
    exit 1
fi
SUMS_URL="${ZIP_URL%/*}/SHA256SUMS"
echo "Downloading: $ZIP_URL"
echo "  (progress bar — 0%..100%)"
curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 --progress-bar -o "$TMP/opencode.zip" "$ZIP_URL"
curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 60 --progress-bar -o "$TMP/SHA256SUMS" "$SUMS_URL"
EXPECTED="$(grep "$(basename "$ZIP_URL")" "$TMP/SHA256SUMS" | awk '{print $1}' | head -n1)"
ACTUAL="$(sha256sum "$TMP/opencode.zip" | awk '{print $1}')"
if [ -n "$EXPECTED" ] && [ "$EXPECTED" != "$ACTUAL" ]; then
    echo "ERROR: SHA256 mismatch — download corrupted, aborted."
    exit 1
fi
spin "Verifying checksum (SHA256)" true
echo "Download OK (SHA256 verified)"

echo "[2.5/7] Checking native libraries..."
extract_one() {
    # $1=zip, $2=file -> extracted into $TMP
    if command -v unzip >/dev/null 2>&1; then
        (cd "$TMP" && unzip -o -q "$1" "$2")
    elif command -v busybox >/dev/null 2>&1; then
        (cd "$TMP" && busybox unzip -o -q "$1" "$2")
    else
        return 1
    fi
}
if [ ! -f "$PREFIX/lib/libc++_shared.so" ]; then
    head_step "Checking native libraries — libc++ bootstrap"
    if extract_one "$TMP/opencode.zip" libc++_shared.so; then
        spin "Bootstrapping libc++ from release" install -m644 "$TMP/libc++_shared.so" "$PREFIX/lib/libc++_shared.so"
        echo "  Bootstrap OK (from opencode zip)"
    else
        echo "  unzip/busybox nai — Termux repo theke libc++ deb neya hocche..."
        PKG_INDEX="$TMP/packages-index"
        curl -fsSL --retry 3 --connect-timeout 10 --max-time 60 -o "$PKG_INDEX" \
            "https://packages-cf.termux.dev/apt/termux-main/dists/stable/main/binary-aarch64/Packages" || true
        DEB_PATH="$(awk '/^Package: libc\+\+$/{found=1} found && /^Filename:/{print $2; exit}' "$PKG_INDEX" 2>/dev/null)"
        if [ -n "$DEB_PATH" ]; then
            curl -fsSL --retry 3 --connect-timeout 10 --max-time 120 -o "$TMP/libc.deb" "https://packages-cf.termux.dev/apt/termux-main/$DEB_PATH"
            md() { mkdir -p "$TMP/root"; dpkg-deb -x "$TMP/libc.deb" "$TMP/root"; }
            spin "Extracting libc++ package" md
            install -m644 "$TMP/root/data/data/com.termux/files/usr/lib/libc++_shared.so" "$PREFIX/lib/" 2>/dev/null \
                && echo "  Bootstrap OK (from libc++ deb)"
        else
            echo "  WARNING: bootstrap fail — 'pkg install -y libc++' nije chalano. Tarpore abar bash install.sh."
        fi
    fi
else
    head_step "Checking native libraries — OK"
fi

head_step "Installing dependencies"
needs_update() { # apt lists last 12h e fresh thakle skip (faster re-install)
    local d="$PREFIX/var/lib/apt/lists"
    [ -d "$d" ] || return 0
    find "$d" -type f -newermt "-12 hours" 2>/dev/null | grep -q . && return 1 || return 0
}
if command -v pkg >/dev/null 2>&1; then
    if [ "$(id -u)" = "0" ]; then
        echo "  WARNING: pkg as root chole na (dev container?) — existing dependencies check korbo..."
    else
        if needs_update; then
            spin "Updating package index" pkg update -y || true
        else
            echo "  (package list 12h er moddhe fresh — update skip, faster)"
        fi
        spin "Installing ripgrep git curl unzip tar" pkg install -y ripgrep git curl unzip tar libc++
    fi
else
    echo "  WARNING: pkg not found — existing dependencies check korbo..."
fi
for dep in rg git curl unzip tar; do
    command -v "$dep" >/dev/null 2>&1 || { echo "ERROR: $dep missing. Termux e: pkg install -y $dep"; exit 1; }
done
echo "  Dependencies OK"

head_step "Resolving install source"
if [ ! -d "$SCRIPT_DIR/config" ] || [ ! -d "$SCRIPT_DIR/skills" ]; then
    echo "  One-click mode: config repo theke clone korte hobe..."
    spin "Cloning voxel config repo" git clone --depth 1 "https://github.com/$GH_REPO.git" "$TMP/source" || {
        echo "ERROR: config repo clone hoyni. Locally clone kore: bash install.sh"
        exit 1
    }
    SCRIPT_DIR="$TMP/source"
fi
echo "  Source OK: $SCRIPT_DIR"

install_core() {
    cd "$TMP"
    unzip -o -q opencode.zip
    mkdir -p "$PREFIX/libexec/opencode" "$PREFIX/lib"
    if [ -f "$SCRIPT_DIR/scripts/voxel" ]; then
        install -m755 "$SCRIPT_DIR/scripts/voxel" "$PREFIX/bin/voxel"
    else
        install -m755 opencode "$PREFIX/bin/voxel"
    fi
    install -m755 opencode.bin "$PREFIX/libexec/opencode/opencode.bin"
    install -m644 libtagfix.so libopentui.so "$PREFIX/lib/"
    if [ ! -f "$PREFIX/lib/libc++_shared.so" ]; then
        install -m644 libc++_shared.so "$PREFIX/lib/"
    fi
    if [ -f librust_pty_arm64.so ]; then
        install -m644 librust_pty_arm64.so "$PREFIX/lib/"
    fi
    if [ -e "$PREFIX/bin/opencode" ]; then
        mv "$PREFIX/bin/opencode" "$PREFIX/bin/opencode.bak" 2>/dev/null
    fi
}
head_step "Installing voxel core (bin/libs)"
spin "Installing voxel binary + libs" install_core
echo "  voxel -> $PREFIX/bin/voxel"

install_config() {
    mkdir -p "$CONFIG_DIR/agent" "$CONFIG_DIR/command" "$CONFIG_DIR/themes" "$CONFIG_DIR/skills"
    if [ -f "$CONFIG_DIR/opencode.json" ] || [ -f "$CONFIG_DIR/opencode.jsonc" ]; then
        cp -n "$CONFIG_DIR/opencode.json" "$CONFIG_DIR/opencode.json.bak" 2>/dev/null || true
        cp -n "$CONFIG_DIR/opencode.jsonc" "$CONFIG_DIR/opencode.jsonc.bak" 2>/dev/null || true
    fi
    install -m644 "$SCRIPT_DIR/config/opencode.json" "$CONFIG_DIR/opencode.json"
    install -m644 "$SCRIPT_DIR/config/agent/"*.md "$CONFIG_DIR/agent/" 2>/dev/null || true
    install -m644 "$SCRIPT_DIR/config/command/"*.md "$CONFIG_DIR/command/" 2>/dev/null || true
    install -m644 "$SCRIPT_DIR/config/themes/"*.json "$CONFIG_DIR/themes/" 2>/dev/null || true
    cp -rn "$SCRIPT_DIR/skills/"* "$CONFIG_DIR/skills/" 2>/dev/null || true
    if [ -f "$SCRIPT_DIR/scripts/oc-settings.sh" ]; then
        install -m755 "$SCRIPT_DIR/scripts/oc-settings.sh" "$PREFIX/bin/oc-settings"
    fi
}
head_step "Installing config, agent, commands, theme"
spin "Installing config + skills" install_config
echo "  oc-settings -> $PREFIX/bin/oc-settings"

head_step "Setting up AI provider (OpenCode Zen + default key)"
if ! grep -q "OPENCODE_API_KEY\|OPENCODE_ZEN_API_KEY" "$HOME/.bashrc" 2>/dev/null; then
    printf 'export OPENCODE_API_KEY="%s"\n' "$DEFAULT_ZEN_KEY" >> "$HOME/.bashrc"
    echo "  Zen default key -> ~/.bashrc (zero config)"
    echo "  NOTE: nijer key thakle: ZEN_API_KEY=<key> bash install.sh"
else
    echo "  OPENCODE_API_KEY already set — OK"
fi

head_step "Cleaning stale wrappers"
STALE_CANDIDATES="$HOME/.opencode/bin/opencode $HOME/.opencode/bin/opencode.bak $PREFIX/bin/opencode.bak"
for f in $STALE_CANDIDATES; do
    if [ -L "$f" ] || [ -f "$f" ]; then
        if ! "$f" --version >/dev/null 2>&1; then
            mv "$f" "$f.bak.old" 2>/dev/null && echo "  broken stale wrapper ($f) -> .bak.old"
        fi
    fi
done
STALE="$HOME/.opencode/bin/opencode"
if [ -e "$STALE" ] && ! "$STALE" --version >/dev/null 2>&1; then
    mv "$STALE" "$STALE.bak" 2>/dev/null && echo "  stale wrapper -> .bak"
fi
# kono onno ~/bin or ~/.local/bin e purono voxel ache kino (confusing PATH)
OTHER_VOXEL="$(command -v voxel 2>/dev/null || true)"
if [ -n "$OTHER_VOXEL" ] && [ "$OTHER_VOXEL" != "$PREFIX/bin/voxel" ]; then
    echo "  NOTICE: 'voxel' onno path thekeo milche: $OTHER_VOXEL"
    echo "          PATH order thik kin- check: 'which voxel' → tarpor '$PREFIX/bin/voxel --version'"
fi

head_step "Verifying install"
if ! VERSION="$("$PREFIX/bin/voxel" --version 2>&1)"; then
    echo "  ERROR: voxel choltese na. 'bash install.sh' abar chalao."
    exit 1
fi
echo "  voxel v$VERSION — ready!  (command: $(command -v voxel))"

echo
printf "${GREEN}${BOLD}  [##########] 100%%  VOXEL install complete!${RESET}  ${DIM}(%ss total)${RESET}\n" "$(( $(now) - INSTALL_START ))"
echo "============================================"
echo "1) Run     : voxel    (notun terminal e, or: hash -r)"
echo "2) Model   : FREE zen model voxel/deepseek-v4-flash-free (Max default)"
echo "              oc-settings model  -> max/mid/ultra/tiny popup"
echo "3) Theme   : voxel vitore /theme -> 'bangladeshi'"
echo "4) Commands: /approve  /safe  /model  /dekho  /review  /fix  /voxel"
echo "5) Agent   : 'DeshiDev' — English default (Bangla likhle Bangla reply)"
echo "6) Perms   : /approve -> auto-approve ON | /safe -> ask-mode"
echo
echo "NOTE: config change korle voxel restart koro."