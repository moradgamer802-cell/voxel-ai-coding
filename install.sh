#!/data/data/com.termux/files/usr/bin/bash
# ZYVO — ready-to-use AI coding CLI installer
# Native Android aarch64 build (guysoft/opencode-termux), no proot, no glibc.
set -e

REPO="guysoft/opencode-termux"
GH_REPO="${GH_REPO:-moradgamer802-cell/voxel-ai-coding}"
DEFAULT_ZEN_KEY="${ZEN_API_KEY:-sk-PKOWRt2391BL0MP3W90yaG8qx4vofQJQgigJreBBYjrArj0lwuU1HkWUqOHgDGHP}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config/opencode"

# ---------- helpers ----------
GREEN='\033[32m'; CYAN='\033[36m'; DIM='\033[2m'; RED='\033[31m'; BOLD='\033[1m'; RESET='\033[0m'

now() { date +%s; }
say()   { printf "${GREEN}${BOLD}✓${RESET} %s\n" "$1"; }
info()  { printf "  %s\n" "$1"; }
fatal() { printf "${RED}${BOLD}[ERR]${RESET} %s\n" "$1"; exit 1; }
warn()  { printf "${YELLOW}${BOLD}[!!]${RESET} %s\n" "$1"; }

sizeMB() { # bytes -> "2.4 MB"
    awk -v b="$1" 'BEGIN{ printf "%.1f MB", b/1048576 }'
}
speed() { # bytes/sec -> "1.2 MB/s"
    awk -v b="$1" 'BEGIN{
        if (b >= 1048576) printf "%.1f MB/s", b/1048576
        else if (b >= 1024)  printf "%.1f KB/s", b/1024
        else                 printf "%d B/s", b
    }'
}

# live download progress:  ZYVO AI downloading ▼ 2.4 MB / 9.5 MB [████░░░░░░] 24%  1.2 MB/s
dlprogress() { # <url> <out>
    local url="$1" out="$2"
    local total=0 curl_pid got last=0 t0 t1 speedb=0 pct filled empty i f e
    total="$(curl -sIL --connect-timeout 10 --max-time 20 "$url" \
        | awk 'tolower($1)=="content-length:"{n=$2} END{print n+0}')"
    curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 -o "$out" "$url" &
    curl_pid=$!
    t0="$(now)" got=0
    while kill -0 "$curl_pid" 2>/dev/null; do
        got="$(wc -c < "$out" 2>/dev/null || echo 0)"
        t1="$(now)"
        speedb=0
        [ "$t1" -gt "$t0" ] && speedb=$(( (got - last) / (t1 - t0) ))
        last="$got"; t0="$t1"
        if [ "$total" -gt 0 ]; then
            pct=$(( got * 100 / total )); [ "$pct" -gt 100 ] && pct=100
            filled=$((pct/10)); empty=$((10-filled))
            f=""; i=0; while [ $i -lt $filled ]; do f="${f}█"; i=$((i+1)); done
            e=""; i=0; while [ $i -lt $empty ]; do e="${e}░"; i=$((i+1)); done
            printf "\r${BOLD}ZYVO AI ${CYAN}▼${RESET} downloading  %s / %s  [%s%s] %3d%%  %s   " \
                "$(sizeMB "$got")" "$(sizeMB "$total")" "$f" "$e" "$pct" "$(speed "$speedb")"
        else
            printf "\r${BOLD}ZYVO AI ${CYAN}▼${RESET} downloading  %s   " "$(sizeMB "$got")"
        fi
        sleep 0.25
    done
    wait "$curl_pid" || return 1
    echo
    say "downloaded ($(sizeMB "$(wc -c < "$out")"))"
}

# ---------- banner ----------
banner() { # ZYVO — embedded figlet "big" art (font-independent, always renders)
    local lines=(
        '__      ________   ________ _'
        '\ \    / / __ \ \ / /  ____| |     '
        ' \ \  / / |  | \ V /| |__  | |     '
        '  \ \/ /| |  | |> < |  __| | |     '
        '   \  / | |__| / . \| |____| |____ '
        '    \/   \____/_/ \_\______|______|'
    )
    echo
    for ln in "${lines[@]}"; do
        printf "${GREEN}${BOLD}%s${RESET}\n" "$ln"
        sleep 0.07
    done
    echo
}

echo
banner
printf "${BOLD}=====================================${RESET}\n"
printf "${BOLD}  ZYVO — OpenCode Termux Installer${RESET}\n"
printf "${BOLD}  (ready-to-use AI coding CLI)${RESET}\n"
printf "${BOLD}=======================================${RESET}\n"
echo

# ---------- [1] environment ----------
if [ -z "$PREFIX" ] || [ ! -d "$PREFIX" ]; then
    fatal "Installer must run inside Termux (F-Droid version)."
    echo "Play Store er Termux kaj korbe na — F-Droid theke install korun:"
    echo "  https://f-droid.org/en/packages/com.termux/"
    exit 1
fi
ARCH="${ZYVO_ARCH:-$(uname -m)}"
case "$ARCH" in
    aarch64|arm64) ZIP_MATCH="android-aarch64";;
    *) ZIP_MATCH="android-$ARCH";;
esac
if [ "$ARCH" != "aarch64" ] && [ "$ARCH" != "arm64" ]; then
    info "apnar arch: $ARCH — $ZIP_MATCH asset try korbo"
fi
info "Termux OK: $PREFIX (arch: $ARCH)"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
INSTALL_START="$(now)"

# ---------- [2] download core (live progress) ----------
ZIP_URL="$(curl -fsSL --connect-timeout 10 --max-time 30 "https://api.github.com/repos/$REPO/releases/latest" | grep -o "https://[^\"]*${ZIP_MATCH}\.zip" | head -n1)"
if [ -z "$ZIP_URL" ]; then
    fatal "$ARCH er jonno build nai — shudhu aarch64/arm64 release ache (upstream Bun 32-bit nai)."
    echo "       Env override: ZYVO_ARCH=aarch64 bash install.sh"
    exit 1
fi
SUMS_URL="${ZIP_URL%/*}/SHA256SUMS"

dlprogress "$ZIP_URL" "$TMP/opencode.zip" || {
    echo
    fatal "download fail — internet/connection check korun (retry hoyeche)."
    exit 1
}

# checksum — backend (quiet)
if curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 60 -o "$TMP/SHA256SUMS" "$SUMS_URL" 2>/dev/null; then
    EXPECTED="$(grep "$(basename "$ZIP_URL")" "$TMP/SHA256SUMS" | awk '{print $1}' | head -n1)"
    ACTUAL="$(sha256sum "$TMP/opencode.zip" | awk '{print $1}')"
    if [ -n "$EXPECTED" ] && [ "$EXPECTED" != "$ACTUAL" ]; then
        fatal "SHA256 mismatch — download corrupted, aborted."
        exit 1
    fi
fi
say "integrity verified (SHA256)"

# ---------- [3] native libs (backend, quiet) ----------
extract_one() { # $1=zip $2=file -> $TMP
    if command -v unzip >/dev/null 2>&1; then
        (cd "$TMP" && unzip -o -q "$1" "$2")
    elif command -v busybox >/dev/null 2>&1; then
        (cd "$TMP" && busybox unzip -o -q "$1" "$2")
    else
        return 1
    fi
}
if [ ! -f "$PREFIX/lib/libc++_shared.so" ]; then
    info "libc++ binary lib nai — extracting from package..."
    if extract_one "$TMP/opencode.zip" libc++_shared.so; then
        install -m644 "$TMP/libc++_shared.so" "$PREFIX/lib/libc++_shared.so"
        say "native libs installed"
    else
        info "unzip nai — Termux repo theke libc++ deb namabo..."
        PKG_INDEX="$TMP/packages-index"
        curl -fsSL --retry 3 --connect-timeout 10 --max-time 60 -o "$PKG_INDEX" \
            "https://packages-cf.termux.dev/apt/termux-main/dist;avage/stable/main/binary-aarch64/Packages" || true
        DEB_PATH="$(awk '/^Package: libc\+\+$/{found=1} found && /^Filename:/{print $2; exit}' "$PKG_INDEX" /dev/null 2>/dev/null)"
        if [ -n "$DEB_PATH" ]; then
            curl -fsSL --retry 3 --connect-timeout 10 --max-time 120 -o "$TMP/libc.deb" \
                "https://packages-cf.termux.dev/apt/termux-main/$DEB_PATH"
            md() { mkdir -p "$TMP/root"; dpkg-deb -x "$TMP/libc.deb" "$TMP/root"; }
            md
            install -m644 "$TMP/root/data/data/com.termux/files/usr/lib/libc++_shared.so" "$PREFIX/lib/" 2>/dev/null \
                && say "libc++ installed (deb)"
        else
            info "WARNING: bootstrap fail — 'pkg install -y libc++' nija chalano."
        fi
    fi
else
    info "native libs — already present"
fi

# ---------- [4] dependencies (backend, quiet) ----------
needs_update() { # apt lists last 12h fresh -> skip (faster reinstall)
    local d="$PREFIX/var/lib/apt/lists"
    [ -d "$d" ] || return 0
    find "$d" -type f -newermt "-12 hours" 2>/dev/null | grep -q . && return 1 || return 0
}
if command -v pkg >/dev/null 2>&1; then
    if [ "$(id -u)" = "0" ]; then
        info "WARNING: pkg as root chole na — existing deps check korbo..."
    else
        if needs_update; then
            info "updating package index (backend)..."
            pkg update -y >/dev/null 2>&1 || true
        else
            info "package index — fresh (skip update)"
        fi
        info "installing dependencies (ripgrep git curl unzip tar libc++ figlet python3)..."
        if ! pkg install -y ripgrep git curl unzip tar libc++ figlet python3 >"$TMP/pkg.log" 2>&1; then
            echo
            tail -n 5 "$TMP/pkg.log"
            fatal "pkg install fail — internet check korun, then 'bash install.sh' abar chalao."
            exit 1
        fi
    fi
else
    info "WARNING: pkg nai — existing deps check..."
fi
for dep in rg git curl unzip tar; do
    command -v "$dep" >/dev/null 2>&1 || fatal "$dep missing — pkg install -y $dep"
done
say "dependencies OK"

# ---------- [5] source (backend, quiet) ----------
if [ ! -d "$SCRIPT_DIR/config" ] || [ ! -d "$SCRIPT_DIR/skills" ]; then
    info "resolving ZYVO source..."
    git clone --depth 1 -q "https://github.com/$GH_REPO.git" "$TMP/source" || {
        fatal "config repo clone hoyni. Locally: bash install.sh"
        exit 1
    }
    SCRIPT_DIR="$TMP/source"
fi
say "source resolved"

# ---------- [6] core install (backend, quiet) ----------
install_core() {
    cd "$TMP"
    unzip -o -q opencode.zip
    mkdir -p "$PREFIX/bin" "$PREFIX/libexec/opencode" "$PREFIX/lib"
    if [ -f "$SCRIPT_DIR/scripts/zyvo" ]; then
        install -m755 "$SCRIPT_DIR/scripts/zyvo" "$PREFIX/bin/zyvo"
    else
        install -m755 opencode "$PREFIX/bin/zyvo"
    fi
    if [ -f "$SCRIPT_DIR/scripts/patch-brand.py" ]; then
        if command -v python3 >/dev/null 2>&1; then
            python3 "$SCRIPT_DIR/scripts/patch-brand.py" opencode.bin opencode.bin.zyvo 2>/dev/null \
                && mv opencode.bin.zyvo opencode.bin
        else
            warn "python3 nai — ZYVO branding patch skip hobe (baki sob thik chalbe)"
        fi
    fi
    install -m755 opencode.bin "$PREFIX/libexec/opencode/opencode.bin"
    install -m644 libtagfix.so libopentui.so "$PREFIX/lib/"
    if [ ! -f "$PREFIX/lib/libc++_shared.so" ]; then install -m644 libc++_shared.so "$PREFIX/lib/"; fi
    if [ -f librust_pty_arm64.so ]; then install -m644 librust_pty_arm64.so "$PREFIX/lib/"; fi
    if [ -e "$PREFIX/bin/opencode" ]; then mv "$PREFIX/bin/opencode" "$PREFIX/bin/opencode.bak" 2>/dev/null; fi
}
info "installing zyvo core..."
install_core
say "core installed → $PREFIX/bin/zyvo"

# ---------- [7] config + skills (backend, quiet) ----------
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
info "installing config + skills..."
install_config
say "config + skills installed (open $CONFIG_DIR)"

# ---------- [8] provider (quiet) ----------
if ! grep -q "OPENCODE_API_KEY\|OPENCODE_ZEN_API_KEY" "$HOME/.bashrc" 2>/dev/null; then
    printf 'export OPENCODE_API_KEY="%s"\n' "$DEFAULT_ZEN_KEY" >> "$HOME/.bashrc"
    say "AI provider configured (Zen zero-config)"
else
    info "AI provider — already configured"
fi

# ---------- [9] cleanup + verify ----------
STALE_CANDIDATES="$HOME/.opencode/bin/opencode $HOME/.opencode/bin/opencode.bak $PREFIX/bin/opencode.bak"
for f in $STALE_CANDIDATES; do
    if [ ! -L "$f" ] && [ ! -f "$f" ]; then continue; fi
    if ! "$f" --version >/dev/null 2>&1; then
        mv "$f" "$f.bak.old" 2>/dev/null && info "stale wrapper -> .bak.old"
    fi
done
OTHER_ZYVO="$(command -v zyvo 2>/dev/null || true)"
if [ -n "$OTHER_ZYVO" ] && [ "$OTHER_ZYVO" != "$PREFIX/bin/zyvo" ]; then
    info "NOTICE: 'zyvo' onno path thekeo: $OTHER_ZYVO — check PATH"
fi

info "verifying..."
if ! VERSION="$("$PREFIX/bin/zyvo" --version 2>&1)"; then
    fatal "zyvo choltese na. 'bash install.sh' abar chalao."
    exit 1
fi

# ---------- FINAL ----------
echo
printf "${GREEN}${BOLD}[██████████] 100%%  ZYVO AI Ready! ${RESET}✓  ${DIM}(%ss total)${RESET}\n" "$(( $(now) - INSTALL_START ))"
echo
printf "${BOLD}Chalano:${RESET}  zyvo            # AI — /storage/emulated/0 theke kaj\n"
printf "${BOLD}Settings:${RESET}  oc-settings\n"
printf "${BOLD}Version:${RESET}   %s\n" "$VERSION"
echo