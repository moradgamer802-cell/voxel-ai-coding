#!/data/data/com.termux/files/usr/bin/bash
# VOXEL — ready-to-use AI coding CLI installer
# Native Android aarch64 build (guysoft/opencode-termux), no proot, no glibc.
set -e

REPO="guysoft/opencode-termux"
GH_REPO="${GH_REPO:-moradgamer802-cell/voxel-ai-coding}"
DEFAULT_ZEN_KEY="${ZEN_API_KEY:-sk-PKOWRt2391BL0MP3W90yaG8qx4vofQJQgigJreBBYjrArj0lwuU1HkWUqOHgDGHP}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config/opencode"

# ---------- animation (progress bar) ----------
GREEN='\033[32m'; CYAN='\033[36m'; DIM='\033[2m'; RED='\033[31m'; BOLD='\033[1m'; RESET='\033[0m'
BAR_CUR=0

now() { date +%s; }

bar() { # bar <pct> <label>  — [████░░░░░░░░░] 42%
    local pct=$1 label="$2"
    [ "$pct" -gt 100 ] && pct=100
    [ "$pct" -lt 0 ] && pct=0
    local filled=$((pct/10)) rest=$((10-pct/10)) i=0 f="" e=""
    while [ $i -lt "$filled" ]; do f="${f}██"; i=$((i+1)); done
    i=0
    while [ $i -lt "$rest" ]; do e="${e}░░"; i=$((i+1)); done
    printf "\r\033[2K${BOLD}[${GREEN}%s${RESET}${DIM}%s${RESET}]${RESET} ${CYAN}%3d%%${RESET}  %s   " "$f" "$e" "$pct" "$label"
}

barsettle() { # barsettle <pct> <label> — instant tick + DONE line
    local pct=$1 label="$2"
    bar "$pct" "$label"
    BAR_CUR=$pct
    printf "\r\033[2K${BOLD}[${GREEN}%s${RESET}${DIM}%s${RESET}]${RESET} ${CYAN}%3d%%${RESET}  ${GREEN}${BOLD}[DONE]${RESET} ${GREEN}%s${RESET}\n" \
        "$(bar_filled "$pct")" "$(bar_empty "$pct")" "$pct" "$label"
}

barspin() { # barspin <target%> <label> <cmd...> — animated progress while task runs
    local target=$1 label="$2"; shift 2
    "$@" >/dev/null 2>&1 &
    local pid=$! start=
    start=$(now)
    local cur=$BAR_CUR
    while kill -0 "$pid" 2>/dev/null; do
        [ "$cur" -lt "$target" ] || cur="$target"
        if [ "$cur" -lt "$target" ]; then
            # smooth: delta halves each tick — never stalls short of target
            cur=$(( target - (target - cur) * 3 / 4 ))
            [ "$cur" -ge "$target" ] && cur="$target"
        fi
        bar "$cur" "$label"
        sleep 0.1
    done
    wait "$pid"; local rc=$?
    local el=$(( $(now) - start ))
    # settle animation to target
    while [ "$cur" -lt "$target" ]; do
        cur=$((cur+1)); bar "$cur" "$label"; sleep 0.02
    done
    BAR_CUR=$target
    if [ "$rc" -eq 0 ]; then
        printf "\r\033[2K${BOLD}[${GREEN}%s${RESET}${DIM}%s${RESET}]${RESET} ${CYAN}%3d%%${RESET}  ${BOLD}${GREEN}[DONE]${RESET} ${GREEN}%s${RESET}  ${DIM}(%ss)${RESET}\n" \
            "$(bar_filled "$target")" "$(bar_empty "$target")" "$target" "$label" "$el"
    else
        printf "\r\033[2K${RED}[FAIL${RESET} ] %s (rc=%s, %ss)\n" "$label" "$rc" "$el"
    fi
    return $rc
}

bar_filled() { local i=0 f=""; while [ "$i" -lt "$(( $1 / 10 ))" ]; do f="${f}██"; i=$((i+1)); done; printf '%s' "$f"; }
bar_empty()  { local i=0 e=""; while [ "$i" -lt "$(( 10 - $1 / 10 ))" ]; do e="${e}░░"; i=$((i+1)); done; printf '%s' "$e"; }

banner() { # VOXEL — plain ASCII (box glyphs render ulta-palta on some Termux fonts)
    local lines
    if command -v figlet >/dev/null 2>&1; then
        mapfile -t lines < <(figlet -w 120 VOXEL)
    else
        lines=(
            'V   V    OOOO    X   X    EEEEE   L        '
            'V   V   O   O    X   X    E       L        '
            'V   V   O   O     X      EEEE    L        '
            'V   V   O   O    X   X    E       L        '
            ' V V     OOOO    X   X    EEEEE   LLLLL   '
        )
    fi
    echo
    for ln in "${lines[@]}"; do
        printf "${GREEN}${BOLD}%s${RESET}\n" "$ln"
        sleep 0.05
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

# ---------- [1] environment ----------
bar 0 "Installing VOXEL AI..."
if [ -z "$PREFIX" ] || [ ! -d "$PREFIX" ]; then
    printf "\r\033[2K${RED}[ERR]${RESET} Installer must run inside Termux (F-Droid version).\n"
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
    echo "  INFO: apnar arch: $ARCH — $ZIP_MATCH asset try korbo"
fi
echo "  Termux OK: $PREFIX (arch: $ARCH)"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
INSTALL_START="$(now)"

# ---------- [2] download core ----------
bar "$BAR_CUR" "Downloading core..."
ZIP_URL="$(curl -fsSL --connect-timeout 10 --max-time 30 "https://api.github.com/repos/$REPO/releases/latest" | grep -o "https://[^\"]*${ZIP_MATCH}\.zip" | head -n1)"
if [ -z "$ZIP_URL" ]; then
    printf "\r\033[2K${RED}[ERR]${RESET} $ARCH er jonno build nai — shudhu aarch64/arm64 release ache (upstream Bun 32-bit nai).\n"
    echo "       Env override: VOXEL_ARCH=aarch64 bash install.sh"
    exit 1
fi
SUMS_URL="${ZIP_URL%/*}/SHA256SUMS"
echo "  from: $ZIP_URL"
barspin 40 "Downloading core..." curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 -o "$TMP/opencode.zip" "$ZIP_URL"
curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 60 -o "$TMP/SHA256SUMS" "$SUMS_URL" 2>/dev/null
EXPECTED="$(grep "$(basename "$ZIP_URL")" "$TMP/SHA256SUMS" | awk '{print $1}' | head -n1)"
ACTUAL="$(sha256sum "$TMP/opencode.zip" | awk '{print $1}')"
if [ -n "$EXPECTED" ] && [ "$EXPECTED" != "$ACTUAL" ]; then
    echo; echo "ERROR: SHA256 mismatch — download corrupted, aborted."
    exit 1
fi
barsettle 45 "Verifying integrity (SHA256)"

# ---------- [2.5] native libs (45→55) ----------
extract_one() { # $1=zip $2=file → $TMP
    if command -v unzip >/dev/null 2>&1; then
        (cd "$TMP" && unzip -o -q "$1" "$2")
    elif command -v busybox >/dev/null 2>&1; then
        (cd "$TMP" && busybox unzip -o -q "$1" "$2")
    else
        return 1
    fi
}
if [ ! -f "$PREFIX/lib/libc++_shared.so" ]; then
    if extract_one "$TMP/opencode.zip" libc++_shared.so; then
        barspin 55 "Bootstrapping native libs" install -m644 "$TMP/libc++_shared.so" "$PREFIX/lib/libc++_shared.so"
    else
        echo "  unzip/busybox nai — Termux repo theke libc++ deb..."
        PKG_INDEX="$TMP/packages-index"
        curl -fsSL --retry 3 --connect-timeout 10 --max-time 60 -o "$PKG_INDEX" \
            "https://packages-cf.termux.dev/apt/termux-main/dist;avage/stable/main/binary-aarch64/Packages" || true
        DEB_PATH="$(awk '/^Package: libc\+\+$/{found=1} found && /^Filename:/{print $2; exit}' "$PKG_INDEX" /dev/null 2>/dev/null)"
        if [ -n "$DEB_PATH" ]; then
            curl -fsSL --retry 3 --connect-timeout 10 --max-time 120 -o "$TMP/libc.deb" "https://packages-cf.termux.dev/apt/termux-main/$DEB_PATH"
            md() { mkdir -p "$TMP/root"; dpkg-deb -x "$TMP/libc.deb" "$TMP/root"; }
            barspin 55 "Extracting libc++ package" md
            install -m644 "$TMP/root/data/data/com.termux/files/usr/lib/libc++_shared.so" "$PREFIX/lib/" 2>/dev/null \
                && echo "  libc++ installed (deb)"
        else
            echo "  WARNING: bootstrap fail — 'pkg install -y libc++' nija chalano."
        fi
    fi
else
    barsettle 55 "Native libs — already present"
fi

# ---------- [3] dependencies (55→70) ----------
needs_update() { # apt lists last 12h fresh → skip (faster reinstall)
    local d="$PREFIX/var/lib/apt/lists"
    [ -d "$d" ] || return 0
    find "$d" -type f -newermt "-12 hours" 2>/dev/null | grep -q . && return 1 || return 0
}
if command -v pkg >/dev/null 2>&1; then
    if [ "$(id -u)" = "0" ]; then
        echo "  WARNING: pkg as root chole na — existing deps check korbo..."
    else
        if needs_update; then
            barspin 60 "Updating package index" pkg update -y || true
        else
            barsettle 60 "Package index — fresh (skip update)"
        fi
        barspin 70 "Installing dependencies" pkg install -y ripgrep git curl unzip tar libc++ figlet
    fi
else
    echo "  WARNING: pkg nai — existing deps check..."
fi
for dep in rg git curl unzip tar; do
    command -v "$dep" >/dev/null 2>&1 || { echo; echo "ERROR: $dep missing — pkg install -y $dep"; exit 1; }
done
barsettle 70 "Dependencies OK"

# ---------- [source] (70→75) ----------
if [ ! -d "$SCRIPT_DIR/config" ] || [ ! -d "$SCRIPT_DIR/skills" ]; then
    barspin 75 "Resolving VOXEL source" git clone --depth 1 "https://github.com/$GH_REPO.git" "$TMP/source" || {
        echo; echo "ERROR: config repo clone hoyni. Locally: bash install.sh"; exit 1
    }
    SCRIPT_DIR="$TMP/source"
else
    barsettle 75 "Source OK (local)"
fi

# ---------- [4] core install (75→88) ----------
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
    if [ ! -f "$PREFIX/lib/libc++_shared.so" ]; then install -m644 libc++_shared.so "$PREFIX/lib/"; fi
    if [ -f librust_pty_arm64.so ]; then install -m644 librust_pty_arm64.so "$PREFIX/lib/"; fi
    if [ -e "$PREFIX/bin/opencode" ]; then mv "$PREFIX/bin/opencode" "$PREFIX/bin/opencode.bak" 2>/dev/null; fi
}
barspin 88 "Installing voxel core" install_core
echo "  voxel -> $PREFIX/bin/voxel"

# ---------- [5] config (88→94) ----------
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
barspin 94 "Installing config + skills" install_config
echo "  oc-settings -> $PREFIX/bin/oc-settings"

# ---------- [6] provider (94→96) ----------
if ! grep -q "OPENCODE_API_KEY\|OPENCODE_ZEN_API_KEY" "$HOME/.bashrc" 2>/dev/null; then
    printf 'export OPENCODE_API_KEY="%s"\n' "$DEFAULT_ZEN_KEY" >> "$HOME/.bashrc"
    barsettle 96 "Setting up AI provider (Zen zero-config)"
else
    barsettle 96 "AI provider — already configured"
fi

# ---------- [7] cleanup + verify (96→100) ----------
STALE_CANDIDATES="$HOME/.opencode/bin/opencode $HOME/.opencode/bin/opencode.bak $PREFIX/bin/opencode.bak"
for f in $STALE_CANDIDATES; do
    if [ ! -L "$f" ] && [ ! -f "$f" ]; then continue; fi
    if ! "$f" --version >/dev/null 2>&1; then
        mv "$f" "$f.bak.old" 2>/dev/null && echo "  stale wrapper -> .bak.old"
    fi
done
OTHER_VOXEL="$(command -v voxel 2>/dev/null || true)"
if [ -n "$OTHER_VOXEL" ] && [ "$OTHER_VOXEL" != "$PREFIX/bin/voxel" ]; then
    echo "  NOTICE: 'voxel' onno path thekeo: $OTHER_VOXEL — check PATH"
fi
barsettle 97 "Cleaning up"

if ! VERSION="$("$PREFIX/bin/voxel" --version 2>&1)"; then
    echo "  ERROR: voxel choltese na. 'bash install.sh' abar chalao."
    exit 1
fi

# ---------- FINAL: 100% ----------
bar 100 "VOXEL AI Ready!"
sleep 0.4
printf "\r\033[2K${GREEN}${BOLD}[████████████████████] 100%% VOXEL AI Ready! ${RESET}✓  ${DIM}(%ss total)${RESET}\n" "$(( $(now) - INSTALL_START ))"