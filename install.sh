#!/data/data/com.termux/files/usr/bin/bash
# ZYVO — ready-to-use AI coding CLI installer (v3 UI + delta update)
#
# Delta update: core binary er version stamp rakha hoy. Latest release tag
# mile gele core AR download hoy na (0 MB) — shudhu ZYVO layer (config/
# skills/commands — koyek KB) fresh hoy. Core bodlalei full download.
#
# Termux (native aarch64) + glibc Linux (Ubuntu proot/Debian/WSL) + macOS.
set -e

REPO="guysoft/opencode-termux"
GH_REPO="${GH_REPO:-moradgamer802-cell/zyvo-ai-coding}"
DEFAULT_ZEN_KEY="${ZEN_API_KEY:-sk-PKOWRt2391BL0MP3W90yaG8qx4vofQJQgigJreBBYjrArj0lwuU1HkWUqOHgDGHP}"
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo "$PWD")"
CONFIG_DIR="$HOME/.config/opencode"
DEPS="ripgrep curl unzip tar libc++ figlet python3 openssl git"
TOTAL_STEPS=8
STEP_NO=0
WARNINGS=0
SKIPPED=""

# ---------- ui ----------
if [ -t 1 ] && [ -z "$ZYVO_NO_COLOR" ]; then
    GREEN=$'\033[32m'; CYAN=$'\033[36m'; DIM=$'\033[2m'; RED=$'\033[31m'
    YELLOW=$'\033[33m'; BOLD=$'\033[1m'; RESET=$'\033[0m'; MAG=$'\033[35m'
    WHITE=$'\033[97m'
    TTY=1
else
    GREEN=''; CYAN=''; DIM=''; RED=''; YELLOW=''; BOLD=''; RESET=''; MAG=''; WHITE=''
    TTY=0
fi
ANIM=1; [ -n "$ZYVO_NO_ANIM" ] && ANIM=0; [ "$TTY" = 0 ] && ANIM=0

now() { date +%s; }
say()   { printf "    ${GREEN}✓${RESET} %s\n" "$1"; }
info()  { printf "    ${DIM}· %s${RESET}\n" "$1"; }
warn()  { WARNINGS=$((WARNINGS+1)); printf "    ${YELLOW}!${RESET} %s\n" "$1"; }
skip()  { SKIPPED="$SKIPPED\n      · $1"; warn "$1"; }
fatal() {
    echo
    printf "  ${RED}${BOLD}╭─ INSTALL FAIL ──────────────────────────╮${RESET}\n"
    printf "  ${RED}${BOLD}│${RESET} %s\n" "$1"
    [ -n "$2" ] && printf "  ${RED}${BOLD}│${RESET} ${DIM}fix:${RESET} %s\n" "$2"
    printf "  ${RED}${BOLD}╰──────────────────────────────────────────╯${RESET}\n"
    echo
    exit 1
}

bar() { # <pct> -> [████░░░░░░]
    local pct="$1" filled empty f='' e='' i=0
    [ "$pct" -gt 100 ] && pct=100
    [ "$pct" -lt 0 ] && pct=0
    filled=$((pct/10)); empty=$((10-filled))
    while [ $i -lt $filled ]; do f="${f}█"; i=$((i+1)); done
    i=0; while [ $i -lt $empty ]; do e="${e}░"; i=$((i+1)); done
    printf "%s%s" "$f" "$e"
}

STEP_T0=0
step() { # <title>
    STEP_NO=$((STEP_NO+1))
    STEP_T0="$(now)"
    printf "\n  ${CYAN}${BOLD}◇ [%d/%d]${RESET} ${WHITE}${BOLD}%s${RESET}\n" \
        "$STEP_NO" "$TOTAL_STEPS" "$1"
}
step_ok() {
    printf "  ${DIM}└ ok · %ds${RESET}\n" "$(( $(now) - STEP_T0 ))"
}

spin() { # <label> <cmd...> — quiet run with spinner, log at $TMP/last.log
    local label="$1"; shift
    if [ "$ANIM" = 0 ]; then
        info "$label..."
        "$@" >"$TMP/last.log" 2>&1
        return $?
    fi
    "$@" >"$TMP/last.log" 2>&1 &
    local pid=$! i=0 rc=0
    local frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i % 10) + 1 ))
        printf "\r    ${MAG}%s${RESET} ${DIM}%s${RESET}   " "$(printf '%s' "$frames" | cut -c $i)" "$label"
        sleep 0.12
    done
    wait "$pid" || rc=$?
    printf "\r\033[K"
    return $rc
}

sizeMB() { awk -v b="$1" 'BEGIN{ printf "%.1f MB", b/1048576 }'; }
speed() {
    awk -v b="$1" 'BEGIN{
        if (b >= 1048576) printf "%.1f MB/s", b/1048576
        else if (b >= 1024)  printf "%.1f KB/s", b/1024
        else                 printf "%d B/s", b
    }'
}

dlprogress() { # <url> <out> — live download bar (resume + retry built in)
    local url="$1" out="$2"
    local total=0 curl_pid got last=0 t0 t1 speedb=0 pct attempt rc=1
    for attempt in 1 2 3; do
        total="$(curl -sIL --connect-timeout 10 --max-time 20 "$url" \
            | awk 'tolower($1)=="content-length:"{n=$2} END{print n+0}')"
        curl -fLsS --retry 2 --retry-delay 2 -C - --connect-timeout 15 --max-time 900 -o "$out" "$url" &
        curl_pid=$!
        t0="$(now)" got=0
        while kill -0 "$curl_pid" 2>/dev/null; do
            got="$( { [ -f "$out" ] && wc -c < "$out" || true; } 2>/dev/null | awk '{print $1+0}')"
            t1="$(now)"; speedb=0
            if [ "$t1" -gt "$t0" ]; then
                speedb=$(( (got - last) / (t1 - t0) )); last="$got"; t0="$t1"
            fi
            if [ "$TTY" = 1 ] && [ "$total" -gt 0 ]; then
                pct=$(( got * 100 / total )); [ "$pct" -gt 100 ] && pct=100
                printf "\r    ${CYAN}⬇${RESET} %s / %s  ${MAG}[%s]${RESET} %3d%%  ${DIM}%s${RESET}   " \
                    "$(sizeMB "$got")" "$(sizeMB "$total")" "$(bar $pct)" "$pct" "$(speed "$speedb")"
            elif [ "$TTY" = 1 ]; then
                printf "\r    ${CYAN}⬇${RESET} %s   " "$(sizeMB "$got")"
            fi
            sleep 0.25
        done
        if wait "$curl_pid"; then rc=0; break; fi
        warn "download attempt $attempt fail — resume kore abar try korchi"
        sleep 2
    done
    [ "$TTY" = 1 ] && printf "\r\033[K"
    [ "$rc" = 0 ] || return 1
    say "downloaded ($(sizeMB "$(wc -c < "$out")"))"
}

banner() {
    echo
    if [ "$ANIM" = 1 ]; then
        for l in ' ▄▀█ █   █▀▀ █▀█ █ █ █▀█ ▄▀█' ' █▀█ █   █▄▄ █▀▄ █▄█ █▀▄ █▀█'; do
            printf "  ${GREEN}${BOLD}%s${RESET}\n" "$l"; sleep 0.08
        done
    else
        printf "  ${GREEN}${BOLD} ▄▀█ █   █▀▀ █▀█ █ █ █▀█ ▄▀█${RESET}\n"
        printf "  ${GREEN}${BOLD} █▀█ █   █▄▄ █▀▄ █▄█ █▀▄ █▀█${RESET}\n"
    fi
    printf "  ${DIM}AI coding CLI · Banglish · zero-config${RESET}\n"
}

MODE="install"
command -v zyvo >/dev/null 2>&1 && MODE="update"

banner

# ---------- [1] environment ----------
step "environment"
ENV_KIND=""; ARCH="$(uname -m)"; KERNEL="$(uname -s)"
if [ -n "$PREFIX" ] && [ -d "$PREFIX" ] && [ -n "$(command -v pkg 2>/dev/null || true)" ]; then
    ENV_KIND="termux"
elif [ "$KERNEL" = "Linux" ]; then
    ENV_KIND="glibc"
elif [ "$KERNEL" = "Darwin" ]; then
    ENV_KIND="darwin"
fi
[ -n "$ENV_KIND" ] || fatal "ei platform support kore na (Linux/macOS/Termux chalate hobe)." \
      "Termux (F-Droid) ba Ubuntu proot use koro."

case "$ARCH" in
    aarch64|arm64|x86_64|amd64) :;;
    *)
        fatal "phone ta 32-bit ($ARCH) — AI binary ei arch er jonno banano hoy nai." \
              "64-bit (arm64/x86_64) phone ba proot Ubuntu (arm64) e chalano.";;
esac

FREE_KB="$(df -k "$HOME" 2>/dev/null | awk 'NR==2{print $4+0}')"
if [ -n "$FREE_KB" ] && [ "$FREE_KB" -lt 307200 ]; then
    warn "free space kom (~$((FREE_KB/1024)) MB) — 300 MB+ rakho"
fi
info "$ENV_KIND · $ARCH · prefix: ${PREFIX:-user-local}"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
INSTALL_START="$(now)"

if [ "$ENV_KIND" = "termux" ]; then
    BIN_DIR="$PREFIX/bin"
    LIBEXEC_DIR="$PREFIX/libexec/opencode"
    LIB_DIR="$PREFIX/lib"
else
    BIN_DIR="$HOME/.local/bin"
    LIBEXEC_DIR="$HOME/.local/libexec/zyvo"
    LIB_DIR="$HOME/.local/lib/zyvo"
    mkdir -p "$BIN_DIR" "$LIBEXEC_DIR" "$LIB_DIR"
fi
CORE_STAMP="$LIBEXEC_DIR/zyvo-core-version"

if [ "$ENV_KIND" = "termux" ] && [ ! -d "$HOME/storage" ] && command -v termux-setup-storage >/dev/null 2>&1; then
    termux-setup-storage >/dev/null 2>&1 || true
    sleep 2
fi
if [ -d /storage/emulated/0 ] && [ -r /storage/emulated/0 ]; then
    say "storage OK (/storage/emulated/0)"
elif [ -d /sdcard ] && [ -r /sdcard ]; then
    say "storage OK (/sdcard)"
else
    skip "shared storage pawa jayni — Termux e 'termux-setup-storage' chalao"
fi
step_ok

# ---------- [2] dependencies ----------
step "dependencies"
needs_update() {
    local d="$PREFIX/var/lib/apt/lists"
    [ -d "$d" ] || return 0
    find "$d" -type f -newermt "-12 hours" 2>/dev/null | grep -q . && return 1 || return 0
}
switch_official_repo() {
    [ -f "$PREFIX/etc/apt/sources.list" ] || return 1
    grep -q "packages.termux.dev" "$PREFIX/etc/apt/sources.list" 2>/dev/null && return 1
    cp "$PREFIX/etc/apt/sources.list" "$PREFIX/etc/apt/sources.list.zyvo.bak" 2>/dev/null || true
    rm -f "$PREFIX"/etc/apt/sources.list.d/*.list "$PREFIX"/etc/apt/sources.list.d/*.sources 2>/dev/null || true
    echo "deb https://packages.termux.dev/apt/termux-main stable main" > "$PREFIX/etc/apt/sources.list"
    return 0
}
pkg_install() { pkg install -y $DEPS; }
glibc_deps() {
    command -v apt-get >/dev/null 2>&1 || return 1
    spin "apt packages: curl unzip tar python3 git ripgrep" \
        bash -c "apt-get update -y; DEBIAN_FRONTEND=noninteractive apt-get install -y curl unzip tar python3 git ripgrep"
}

if [ "$ENV_KIND" = "termux" ]; then
    if [ "$(id -u)" = "0" ]; then
        warn "root e pkg chole na — existing tools diye chalabo"
    elif ! command -v pkg >/dev/null 2>&1; then
        warn "pkg nai — existing tools diye chalabo"
    else
        if needs_update; then
            spin "package index update" pkg update -y || true
        fi
        if spin "installing: $DEPS" pkg_install; then
            say "dependencies installed"
        else
            warn "pkg install fail — retry (fresh index)"
            if ! spin "retry" bash -c "pkg update -y; pkg install -y $DEPS"; then
                if switch_official_repo && spin "official mirror e switch" bash -c "pkg update -y; pkg install -y $DEPS"; then
                    say "dependencies installed (official mirror)"
                else
                    tail -n 8 "$TMP/last.log" 2>/dev/null || true
                    fatal "dependency install fail." "'termux-change-repo' chalao, tarpor installer abar chalao."
                fi
            fi
        fi
    fi
elif [ "$ENV_KIND" = "glibc" ]; then
    if command -v curl >/dev/null 2>&1 && command -v tar >/dev/null 2>&1; then
        glibc_deps || warn "apt install skip — python3 nile branding patch skip hobe"
    else
        glibc_deps || fatal "curl/tar nai — apt e install koro: apt-get install -y curl tar"
    fi
else
    info "macOS — existing tools use korbo"
fi

heal_broken_libs() {
    local out
    out="$(git ls-remote https://github.com/$GH_REPO.git HEAD 2>&1 || true)"
    case "$out" in
        *"cannot locate symbol"*|*"CANNOT LINK"*|*"aborted session"*)
            warn "Termux packages purono (git/openssl mismatch) — auto upgrade"
            spin "pkg upgrade" bash -c \
                "pkg update -y; DEBIAN_FRONTEND=noninteractive pkg upgrade -y -o Dpkg::Options::=--force-confold" || true
            say "packages upgraded"
            ;;
    esac
}
if [ "$ENV_KIND" = "termux" ] && command -v git >/dev/null 2>&1 && command -v pkg >/dev/null 2>&1 && [ "$(id -u)" != "0" ]; then
    heal_broken_libs
fi

for dep in curl tar; do
    command -v "$dep" >/dev/null 2>&1 || fatal "$dep missing." "install koro: $dep"
done
for dep in rg unzip python3 git; do
    command -v "$dep" >/dev/null 2>&1 || skip "$dep nai — kichhu feature skip hobe"
done
say "required tools present"
step_ok

# ---------- [3] core (DELTA) ----------
step "core engine (delta check)"
gh_latest_tag() { # $1=repo api url
    curl -fsSL --connect-timeout 8 --max-time 20 "$1" 2>/dev/null \
        | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1
}
OC_OFFICIAL_BIN=""
SKIP_CORE=0
LATEST_TAG=""

if [ "$ENV_KIND" = "termux" ]; then
    LATEST_TAG="$(gh_latest_tag "https://api.github.com/repos/$REPO/releases/latest" || true)"
    INSTALLED_TAG=""
    [ -f "$CORE_STAMP" ] && INSTALLED_TAG="$(tr -d '[:space:]' < "$CORE_STAMP")"
    if [ -n "$LATEST_TAG" ] && [ -n "$INSTALLED_TAG" ] && [ "$INSTALLED_TAG" = "$LATEST_TAG" ] \
        && [ -x "$LIBEXEC_DIR/opencode.bin" ]; then
        SKIP_CORE=1
        say "core UP-TO-DATE ($LATEST_TAG) — 0 MB download, skip"
    else
        [ -n "$INSTALLED_TAG" ] && info "core update: $INSTALLED_TAG → ${LATEST_TAG:-latest}"
        case "$ARCH" in
            aarch64|arm64) ZIP_MATCH="android-aarch64";;
            x86_64|amd64)  ZIP_MATCH="android-x86_64";;
        esac
        ZIP_URL="$(curl -fsSL --connect-timeout 10 --max-time 30 "https://api.github.com/repos/$REPO/releases/latest" \
            | grep -o "https://[^\"]*${ZIP_MATCH}\.zip" | head -n1 || true)"
        if [ -z "$ZIP_URL" ]; then
            [ "$ZIP_MATCH" = "android-x86_64" ] && \
                fatal "Termux x86_64 er native build ekhono release hoyni." \
                      "Emulator/Chromebook e Ubuntu proot chalao — sekhane installer auto official build bosabe."
            fatal "$ARCH er jonno native build pawa jayni." "Ubuntu proot e install koro (auto official build)"
        fi
        SUMS_URL="${ZIP_URL%/*}/SHA256SUMS"
        dlprogress "$ZIP_URL" "$TMP/opencode.zip" || fatal "download fail — internet check koro." "installer abar chalao (resume supported)"
        if curl -fsSL --retry 3 --connect-timeout 15 --max-time 60 -o "$TMP/SHA256SUMS" "$SUMS_URL" 2>/dev/null; then
            EXPECTED="$(grep "$(basename "$ZIP_URL")" "$TMP/SHA256SUMS" | awk '{print $1}' | head -n1)"
            ACTUAL="$(sha256sum "$TMP/opencode.zip" 2>/dev/null | awk '{print $1}')"
            if [ -n "$EXPECTED" ] && [ "$EXPECTED" != "$ACTUAL" ]; then
                rm -f "$TMP/opencode.zip"
                fatal "SHA256 mismatch — download corrupted." "installer abar chalao"
            fi
            say "integrity verified (SHA256)"
        else
            warn "SHA256SUMS pawa jayni — integrity check skip"
        fi
    fi
    # version compare — android build vs latest opencode (info only)
    BUILD_VER="$(printf '%s' "${ZIP_URL:-$(basename "$0")}" | grep -oE '[0-9]+(\.[0-9]+)+' | head -n1)"
    OC_LATEST_TAG="$(gh_latest_tag "https://api.github.com/repositories/975734319/releases/latest" || true)"
    OC_LATEST_VER="$(printf '%s' "$OC_LATEST_TAG" | sed 's/[^0-9.]//g')"
    if [ -n "$BUILD_VER" ] && [ -n "$OC_LATEST_VER" ] && [ "$BUILD_VER" != "$OC_LATEST_VER" ]; then
        info "android build: $BUILD_VER · opencode latest: $OC_LATEST_VER — guysoft notun build dile update e auto ashbe"
    fi
else
    LATEST_TAG="$(gh_latest_tag "https://api.github.com/repositories/975734319/releases/latest" || true)"
    INSTALLED_TAG=""
    [ -f "$CORE_STAMP" ] && INSTALLED_TAG="$(tr -d '[:space:]' < "$CORE_STAMP")"
    OC_BIN_CHECK="$HOME/.opencode/bin/opencode"
    if [ -n "$LATEST_TAG" ] && [ -n "$INSTALLED_TAG" ] && [ "$INSTALLED_TAG" = "$LATEST_TAG" ] \
        && [ -x "$OC_BIN_CHECK" ]; then
        SKIP_CORE=1
        say "core UP-TO-DATE ($LATEST_TAG) — 0 MB download, skip"
    else
        if ! curl -fsSL --retry 3 --connect-timeout 15 --max-time 60 -o "$TMP/oc-install.sh" "https://opencode.ai/install" 2>/dev/null; then
            fatal "opencode.ai installer namate parlam na." "internet check koro, tarpor abar chalao"
        fi
        if ! spin "official opencode core install" bash "$TMP/oc-install.sh"; then
            tail -n 8 "$TMP/last.log" 2>/dev/null || true
            fatal "official core install fail." "log dekhe manually: bash $TMP/oc-install.sh"
        fi
        say "official core installed"
    fi
fi
step_ok

# ---------- [4] native libs ----------
step "native libraries"
extract_one() {
    if command -v unzip >/dev/null 2>&1; then (cd "$TMP" && unzip -o -q "$1" "$2" 2>/dev/null)
    elif command -v busybox >/dev/null 2>&1; then (cd "$TMP" && busybox unzip -o -q "$1" "$2" 2>/dev/null)
    else return 1; fi
}
if [ "$ENV_KIND" = "termux" ] && [ "$SKIP_CORE" = 0 ]; then
    if [ ! -f "$LIB_DIR/libc++_shared.so" ]; then
        if extract_one "$TMP/opencode.zip" libc++_shared.so; then
            install -m644 "$TMP/libc++_shared.so" "$LIB_DIR/libc++_shared.so"
            say "libc++_shared.so installed"
        elif command -v pkg >/dev/null 2>&1 && spin "libc++ install" pkg install -y libc++; then
            say "libc++ installed (pkg)"
        else
            skip "libc++ install hoyni — 'pkg install -y libc++' nije chalao"
        fi
    else
        info "native libs already present"
    fi
else
    info "skip (core unchanged / $ENV_KIND)"
fi
step_ok

# ---------- [5] source ----------
step "zyvo layer source"
fetch_source() {
    for br in main master; do
        if curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 300 \
            -o "$TMP/source.tar.gz" "https://codeload.github.com/$GH_REPO/tar.gz/refs/heads/$br" 2>/dev/null; then
            mkdir -p "$TMP/source"
            tar -xzf "$TMP/source.tar.gz" -C "$TMP/source" --strip-components=1 2>/dev/null \
                && [ -d "$TMP/source/config" ] && return 0
            rm -rf "$TMP/source" "$TMP/source.tar.gz"
        fi
    done
    for br in main master; do
        if curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 300 \
            -o "$TMP/source.zip" "https://codeload.github.com/$GH_REPO/zip/refs/heads/$br" 2>/dev/null; then
            rm -rf "$TMP/srcz"; mkdir -p "$TMP/srcz"
            if unzip -o -q "$TMP/source.zip" -d "$TMP/srcz" 2>/dev/null; then
                d="$(find "$TMP/srcz" -maxdepth 1 -mindepth 1 -type d | head -n1)"
                if [ -n "$d" ] && [ -d "$d/config" ]; then
                    rm -rf "$TMP/source"; mv "$d" "$TMP/source"; return 0
                fi
            fi
            rm -rf "$TMP/srcz" "$TMP/source.zip"
        fi
    done
    if command -v git >/dev/null 2>&1; then
        git clone --depth 1 -q "https://github.com/$GH_REPO.git" "$TMP/source" 2>/dev/null \
            && [ -d "$TMP/source/config" ] && return 0
        rm -rf "$TMP/source"
    fi
    return 1
}
if [ -d "$SCRIPT_DIR/config" ] && [ -d "$SCRIPT_DIR/skills" ]; then
    info "local source used ($SCRIPT_DIR)"
else
    fetch_source || fatal "source namate parlam na." "internet check koro, ba repo folder theke: bash install.sh"
    SCRIPT_DIR="$TMP/source"
    say "source downloaded (delta — koyek KB)"
fi
step_ok

# ---------- [6] core install ----------
step "core install"
patch_brand() {
    [ -f "$SCRIPT_DIR/scripts/patch-brand.py" ] && command -v python3 >/dev/null 2>&1 || return 1
    python3 "$SCRIPT_DIR/scripts/patch-brand.py" "$1" "$2" "${@:3}" 2>/dev/null || return 1
}
install_script() { # $1=repo path $2=dest — glibc e shebang rewrite kore
    if [ "$ENV_KIND" = "termux" ]; then
        install -m755 "$1" "$2"
    else
        sed '1s|^#!.*|#!/usr/bin/env bash|' "$1" > "$2" && chmod 755 "$2"
    fi
}
install_core_termux() {
    cd "$TMP"
    unzip -o -q opencode.zip
    mkdir -p "$BIN_DIR" "$LIBEXEC_DIR" "$LIB_DIR"
    if [ -f "$SCRIPT_DIR/scripts/zyvo" ]; then
        install -m755 "$SCRIPT_DIR/scripts/zyvo" "$BIN_DIR/zyvo"
    else
        install -m755 opencode "$BIN_DIR/zyvo"
    fi
    if patch_brand opencode.bin opencode.bin.zyvo; then
        patch_brand opencode.bin.zyvo opencode.bin.zyvo --blank-logo 2>/dev/null || true
        mv opencode.bin.zyvo opencode.bin
    fi
    install -m755 opencode.bin "$LIBEXEC_DIR/opencode.bin"
    install -m644 libtagfix.so libopentui.so "$LIB_DIR/"
    [ -f "$LIB_DIR/libc++_shared.so" ] || install -m644 libc++_shared.so "$LIB_DIR/" 2>/dev/null || true
    [ -f librust_pty_arm64.so ] && install -m644 librust_pty_arm64.so "$LIB_DIR/"
    [ -e "$PREFIX/bin/opencode" ] && mv "$PREFIX/bin/opencode" "$PREFIX/bin/opencode.bak" 2>/dev/null || true
    return 0
}
install_core_official() {
    mkdir -p "$BIN_DIR" "$LIBEXEC_DIR"
    OC_OFFICIAL_BIN="$HOME/.opencode/bin/opencode"
    [ -x "$OC_OFFICIAL_BIN" ] || OC_OFFICIAL_BIN="$(command -v opencode 2>/dev/null || true)"
    [ -n "$OC_OFFICIAL_BIN" ] || return 1
    cp "$OC_OFFICIAL_BIN" "$LIBEXEC_DIR/opencode.bin"
    if patch_brand "$LIBEXEC_DIR/opencode.bin" "$LIBEXEC_DIR/opencode.bin.zyvo"; then
        mv "$LIBEXEC_DIR/opencode.bin.zyvo" "$LIBEXEC_DIR/opencode.bin"
    fi
    chmod 755 "$LIBEXEC_DIR/opencode.bin"
    install_script "$SCRIPT_DIR/scripts/zyvo" "$BIN_DIR/zyvo"
    return 0
}
if [ "$SKIP_CORE" = 1 ]; then
    # core unchanged — shudhu wrapper refresh (binary skip)
    install_script "$SCRIPT_DIR/scripts/zyvo" "$BIN_DIR/zyvo"
    say "binary skip (delta) — wrapper refreshed"
else
    if [ "$ENV_KIND" = "termux" ]; then
        spin "binary + libs install" install_core_termux \
            || { tail -n 8 "$TMP/last.log" 2>/dev/null || true; fatal "core install fail." "installer abar chalao"; }
    else
        spin "wrapper + branding install" install_core_official \
            || { tail -n 8 "$TMP/last.log" 2>/dev/null || true; fatal "core install fail." "installer abar chalao"; }
    fi
    [ -n "$LATEST_TAG" ] && echo "$LATEST_TAG" > "$CORE_STAMP" 2>/dev/null || true
    say "core installed → $LIBEXEC_DIR/opencode.bin"
fi
[ -f "$SCRIPT_DIR/scripts/zyvo-menu" ] && install_script "$SCRIPT_DIR/scripts/zyvo-menu" "$BIN_DIR/zyvo-menu"
step_ok

# ---------- [7] config + skills + provider ----------
step "config, skills + provider"
merge_config() {
    python3 - "$SCRIPT_DIR/config" "$CONFIG_DIR" <<'PY'
import json, os, shutil, sys
src_dir, cfg_dir = sys.argv[1], sys.argv[2]
src = os.path.join(src_dir, "opencode.json")
dst = os.path.join(cfg_dir, "opencode.json")
os.makedirs(cfg_dir, exist_ok=True)
if not os.path.exists(dst):
    shutil.copy2(src, dst)
    sys.exit(0)
try:
    base = json.load(open(dst))
except Exception:
    shutil.copy2(src, dst)
    sys.exit(0)
shutil.copy2(dst, dst + ".bak")
try:
    new = json.load(open(src))
except Exception:
    new = {}
for k in ("username", "model", "small_model", "default_agent"):
    if k not in base and k in new:
        base[k] = new[k]
# dead-model auto-fix: free list theke ling-3.0 sora feleche
if "ling-3.0" in base.get("small_model", ""):
    base["small_model"] = new.get("small_model", "zyvo/laguna-s-2.1-free")
# purono default (flash) → notun full-power default (ultra); custom choice untouched
if base.get("model", "").endswith("deepseek-v4-flash-free") and "model" in new:
    base["model"] = new["model"]
base.setdefault("snapshot", False)
base.setdefault("autoupdate", False)
base.setdefault("share", "disabled")
base.setdefault("watcher", new.get("watcher", {}))
providers = base.setdefault("provider", {})
for pk, pv in new.get("provider", {}).items():
    providers.setdefault(pk, pv)
base["permission"] = {
    "bash": "allow", "edit": "allow", "webfetch": "allow",
    "websearch": "allow", "external_directory": "allow", "doom_loop": "allow",
}
with open(dst, "w") as fh:
    json.dump(base, fh, indent=2)
    fh.write("\n")
PY
}
install_config() {
    mkdir -p "$CONFIG_DIR/agent" "$CONFIG_DIR/command" "$CONFIG_DIR/themes" "$CONFIG_DIR/skills"
    if command -v python3 >/dev/null 2>&1 && [ -f "$SCRIPT_DIR/config/opencode.json" ]; then
        merge_config
    else
        [ -f "$CONFIG_DIR/opencode.json" ] && cp -n "$CONFIG_DIR/opencode.json" "$CONFIG_DIR/opencode.json.bak" 2>/dev/null
        install -m644 "$SCRIPT_DIR/config/opencode.json" "$CONFIG_DIR/opencode.json"
    fi
    install -m644 "$SCRIPT_DIR/config/tui.json" "$CONFIG_DIR/tui.json" 2>/dev/null || true
    install -m644 "$SCRIPT_DIR/config/agent/"*.md "$CONFIG_DIR/agent/" 2>/dev/null || true
    install -m644 "$SCRIPT_DIR/config/command/"*.md "$CONFIG_DIR/command/" 2>/dev/null || true
    install -m644 "$SCRIPT_DIR/config/themes/"*.json "$CONFIG_DIR/themes/" 2>/dev/null || true
    cp -rn "$SCRIPT_DIR/skills/"* "$CONFIG_DIR/skills/" 2>/dev/null || true
    [ -f "$SCRIPT_DIR/scripts/oc-settings.sh" ] && install_script "$SCRIPT_DIR/scripts/oc-settings.sh" "$BIN_DIR/oc-settings"
    return 0
}
spin "config + skills" install_config || warn "config copy e problem hoyeche"

RC_FILE="$HOME/.bashrc"
[ "$ENV_KIND" != "termux" ] && [ ! -f "$HOME/.bashrc" ] && [ -f "$HOME/.profile" ] && RC_FILE="$HOME/.profile"
if ! grep -q "OPENCODE_API_KEY\|OPENCODE_ZEN_API_KEY" "$RC_FILE" 2>/dev/null; then
    printf '\n# ZYVO AI\nexport OPENCODE_API_KEY="%s"\n' "$DEFAULT_ZEN_KEY" >> "$RC_FILE"
    say "AI provider configured (Zen, zero-config)"
else
    info "AI provider already configured"
fi
if ! grep -q 'ZYVO PATH' "$RC_FILE" 2>/dev/null; then
    printf '# ZYVO PATH\ncase ":$PATH:" in *":%s:"*) ;; *) export PATH="%s:$PATH";; esac\n' \
        "$BIN_DIR" "$BIN_DIR" >> "$RC_FILE"
fi
export OPENCODE_API_KEY="${OPENCODE_API_KEY:-$DEFAULT_ZEN_KEY}"

N_CMD="$(ls -1 "$CONFIG_DIR/command"/*.md 2>/dev/null | wc -l | tr -d ' ')"
N_SKILL="$(ls -1d "$CONFIG_DIR/skills"/*/ 2>/dev/null | wc -l | tr -d ' ')"
say "config OK · ${N_CMD} commands · ${N_SKILL} skills"
step_ok

# ---------- [8] verify ----------
step "verify"
if [ "$ENV_KIND" = "termux" ]; then
    for f in "$HOME/.opencode/bin/opencode" "$HOME/.opencode/bin/opencode.bak" "$PREFIX/bin/opencode.bak"; do
        [ -e "$f" ] || continue
        "$f" --version >/dev/null 2>&1 || mv "$f" "$f.bak.old" 2>/dev/null || true
    done
fi
OTHER_ZYVO="$(command -v zyvo 2>/dev/null || true)"
if [ -n "$OTHER_ZYVO" ] && [ "$OTHER_ZYVO" != "$BIN_DIR/zyvo" ]; then
    warn "onno path e o 'zyvo' ache: $OTHER_ZYVO — PATH check koro"
fi
VERSION="$("$BIN_DIR/zyvo" --version 2>&1)" || fatal "zyvo cholche na." "bash install.sh abar chalao"
say "zyvo verified: $VERSION"
step_ok

# ---------- FINAL CARD ----------
ELAPSED=$(( $(now) - INSTALL_START ))
echo
printf "  ${CYAN}╭────────────────────────────────────────────╮${RESET}\n"
printf "  ${CYAN}│${RESET}  ${GREEN}${BOLD}⚡ ZYVO READY${RESET}                                ${CYAN}│${RESET}\n"
printf "  ${CYAN}│${RESET}  ${DIM}%ss · %s/%s · %s${RESET}                     ${CYAN}│${RESET}\n" "$ELAPSED" "$ENV_KIND" "$ARCH" "$MODE"
printf "  ${CYAN}├────────────────────────────────────────────┤${RESET}\n"
printf "  ${CYAN}│${RESET}  ${BOLD}zyvo${RESET}                ${DIM}AI start (full-power)${RESET}   ${CYAN}│${RESET}\n"
printf "  ${CYAN}│${RESET}  ${BOLD}zyvo session <naam>${RESET}  ${DIM}notun/resume session${RESET}    ${CYAN}│${RESET}\n"
printf "  ${CYAN}│${RESET}  ${BOLD}zyvo update${RESET}          ${DIM}delta update check${RESET}       ${CYAN}│${RESET}\n"
printf "  ${CYAN}│${RESET}  ${BOLD}/dekho /fix /review /model /zyvo${RESET}          ${CYAN}│${RESET}\n"
printf "  ${CYAN}│${RESET}  ${DIM}version: %s · %s commands · %s skills${RESET}      ${CYAN}│${RESET}\n" "$VERSION" "$N_CMD" "$N_SKILL"
printf "  ${CYAN}╰────────────────────────────────────────────╯${RESET}\n"
if [ "$WARNINGS" -gt 0 ]; then
    printf "\n  ${YELLOW}${BOLD}%d warning:${RESET}" "$WARNINGS"
    printf "%b\n" "$SKIPPED"
fi
printf "\n  ${DIM}notun shell e:${RESET} source ~/.bashrc  ${DIM}tarpor${RESET} ${BOLD}zyvo${RESET}\n\n"
