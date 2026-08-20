#!/usr/bin/env bash
# ============================================================
#  ZYVO — one-line installer
#  Install: curl -fsSL https://raw.githubusercontent.com/
#           zyvo9/zyvo/main/install.sh | bash
#      or:  pip install zyvo && zyvo        (same installer)
#
#  When run by the pip bootstrap, the ZYVO layer is already on
#  disk at $ZYVO_BOOT and is used instead of downloading it.
#
#  Shows a SINGLE live progress line:
#    [██████░░░░░░░░░░░░░░] 32% | 9.4/29.1 MB | 1.1 MB/s | downloading core
#  Everything else is logged to a file; errors print the log tail.
#  Safe to re-run (idempotent): existing tools/binaries are skipped.
# ============================================================
set -e
umask 022

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------
GH_REPO="${GH_REPO:-zyvo9/zyvo}"
CORE_REPO="guysoft/opencode-termux"
API="https://api.github.com"
CORE_API="$API/repos/$CORE_REPO"
ZEN_KEY_DEFAULT="${ZEN_API_KEY:-sk-PKOWRt2391BL0MP3W90yaG8qx4vofQJQgigJreBBYjrArj0lwuU1HkWUqOHgDGHP}"
OPENCODE_INSTALL_URL="https://opencode.ai/install"
AARCH64_MATCH="android-aarch64"

PREFIX="${PREFIX:-}"
# Termux detection is intentionally broad: some devices/ROMs start the
# installer without PREFIX exported, or with pkg missing from PATH.
TERMUX_ROOT="/data/data/com.termux/files/usr"
if [ -z "$PREFIX" ] && [ -d "$TERMUX_ROOT" ]; then
    PREFIX="$TERMUX_ROOT"
    export PREFIX
fi
if [ -n "$TERMUX_VERSION" ] || { [ -n "$PREFIX" ] && [ -d "$PREFIX/bin" ] && \
   { [ -x "$PREFIX/bin/pkg" ] || [ -x "$PREFIX/bin/apt" ] || [ -d "$PREFIX/etc/termux" ]; }; }; then
    ENV_KIND="termux"
elif [ "$(uname -o 2>/dev/null)" = "Android" ]; then
    # Android shell outside Termux (adb, other terminal apps)
    ENV_KIND="android"
else
    case "$(uname -s 2>/dev/null)" in
        Linux)                      ENV_KIND="linux" ;;
        Darwin)                     ENV_KIND="macos" ;;
        FreeBSD|OpenBSD|NetBSD|DragonFly) ENV_KIND="bsd" ;;
        SunOS|AIX)                  ENV_KIND="unix" ;;
        MINGW*|MSYS*|CYGWIN*|Windows_NT) ENV_KIND="windows" ;;
        *)                          ENV_KIND="posix" ;;   # never a dead end
    esac
fi
# iSH / Alpine on iOS, chromeOS crostini, WSL — all behave like linux
[ -n "$WSL_DISTRO_NAME" ] && ENV_KIND="linux"

RAW_ARCH="$(uname -m)"
# Normalize the many names Android/Termux report for the same CPU.
case "$RAW_ARCH" in
    aarch64|arm64|armv8b|armv8|arm64-v8a|evbarm) ARCH="aarch64" ;;
    armv8l|armv7l|armv7|armv7a|armv6l|arm|armhf|armel|armeabi-v7a) ARCH="arm" ;;   # 32-bit userland
    x86_64|amd64|x64) ARCH="x86_64" ;;
    i686|i386|i586|x86|ia32) ARCH="i686" ;;
    riscv64|ppc64le|ppc64|s390x|mips|mips64|mips64el|loongarch64) ARCH="$RAW_ARCH" ;;
    *) ARCH="${RAW_ARCH:-unknown}" ;;
esac

TMP="$(mktemp -d)"
LOG="$TMP/install.log"
trap 'rm -rf "$TMP"' EXIT

# ------------------------------------------------------------
# Single-line progress UI
# ------------------------------------------------------------
TTY=0; [ -t 1 ] && TTY=1
PROG=0
STATUS="starting"
SPEED=0

sizeMB() { awk -v b="$1" 'BEGIN{ printf "%.1f MB", b/1048576 }'; }
speed()  { awk -v b="$1" 'BEGIN{
    if (b >= 1048576) printf "%.1f MB/s", b/1048576
    else if (b >= 1024) printf "%.1f KB/s", b/1024
    else printf "%d B/s", b }'; }

bar() { # <pct> -> 20-char bar
    local pct=$1 filled empty i s=""
    [ "$pct" -gt 100 ] && pct=100
    filled=$(( pct * 20 / 100 )); empty=$(( 20 - filled ))
    i=0; while [ $i -lt $filled ]; do s="${s}█"; i=$((i+1)); done
    i=0; while [ $i -lt $empty ]; do s="${s}░"; i=$((i+1)); done
    printf '%s' "$s"
}

draw() {
    if [ "$TTY" = 1 ]; then
        printf "\r\033[K  [%s] %3d%% | %s" "$(bar "$PROG")" "$PROG" "$STATUS"
    else
        printf "[%3d%%] %s\n" "$PROG" "$STATUS"
    fi
}
status() { STATUS="$1"; draw; }
bump()   { PROG="$1"; draw; }
log()    { printf '%s\n' "$*" >> "$LOG" 2>/dev/null || true; }
run()    { "$@" >> "$LOG" 2>&1; }

run_bg() { # <label> <cmd...> — run in background, animate the status line
    local label="$1"; shift
    "$@" >> "$LOG" 2>&1 &
    local pid=$! i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i % 10) + 1 ))
        STATUS="$label $(spinner "$i")"
        draw; sleep 0.12
    done
    wait "$pid" || return 1
    STATUS="$label"
    draw
}

spinner() { # <tick 1-10> -> braille frame (POSIX sh compatible)
    case $(( $1 % 10 )) in
        1) printf '⠋';; 2) printf '⠙';; 3) printf '⠹';; 4) printf '⠸';;
        5) printf '⠼';; 6) printf '⠴';; 7) printf '⠦';; 8) printf '⠧';;
        9) printf '⠇';; *) printf '⠏';;
    esac
}

download_file() { # <url> <out> <label> — live %, MB + speed on the same line
    local url="$1" out="$2" label="$3"
    local total=0 got=0 last=0 t0 t1 pct pid
    total="$(curl -sIL --connect-timeout 10 --max-time 20 "$url" \
        | awk 'tolower($1)=="content-length:"{n=$2} END{print n+0}')"
    t0="$(date +%s)"; last=0
    curl -fLsS --retry 3 --retry-delay 2 -C - --connect-timeout 15 --max-time 900 -o "$out" "$url" >> "$LOG" 2>&1 &
    pid=$!
    while kill -0 "$pid" 2>/dev/null; do
        got="$( { [ -f "$out" ] && wc -c < "$out" || true; } 2>/dev/null | awk '{print $1+0}')"
        t1="$(date +%s)"
        if [ "$t1" -gt "$t0" ]; then
            SPEED=$(( (got - last) / (t1 - t0) )); last="$got"; t0="$t1"
        fi
        if [ "$total" -gt 0 ]; then
            PROG=$(( 10 + got * 55 / total ))
        fi
        if [ "$total" -gt 0 ]; then
            STATUS="$label $(sizeMB "$got")/$(sizeMB "$total") $(speed "$SPEED")"
        else
            STATUS="$label $(sizeMB "$got")"
        fi
        draw; sleep 0.25
    done
    if wait "$pid"; then
        PROG=65
        STATUS="$label done ($(sizeMB "$(wc -c < "$out" 2>/dev/null || echo 0)"))"
        draw; return 0
    fi
    return 1
}

fatal() {
    printf "\r\033[K\n  ${C_R}✖ ERROR${C_N} %s\n" "$1" 2>/dev/null || printf "\n  ✖ ERROR %s\n" "$1"
    [ -n "$2" ] && printf "  → %s\n" "$2"
    [ -s "$LOG" ] && { printf "  ${C_D}last log lines:${C_N}\n"; tail -n 5 "$LOG"; }
    exit 1
}

# colors (only for the final summary + errors)
C_G=$'\033[32m'; C_C=$'\033[36m'; C_Y=$'\033[33m'; C_R=$'\033[31m'; C_D=$'\033[2m'; C_B=$'\033[1m'; C_N=$'\033[0m'

cmd_exists() { command -v "$1" >/dev/null 2>&1; }
sys_has_python() { cmd_exists python3 || cmd_exists python; }

# ------------------------------------------------------------
# JSON getters (python preferred; sed fallback)
# ------------------------------------------------------------
json_tag() { # <url> -> tag_name
    local url="$1"
    if cmd_exists python3; then
        python3 - "$url" <<'PY' 2>/dev/null
import json, sys, urllib.request
try:
    with urllib.request.urlopen(sys.argv[1], timeout=20) as r:
        print(json.load(r).get("tag_name", ""))
except Exception:
    pass
PY
    elif sys_has_python; then
        python - "$url" <<'PY' 2>/dev/null
import json, sys, urllib.request
try:
    with urllib.request.urlopen(sys.argv[1], timeout=20) as r:
        print(json.load(r).get("tag_name", ""))
except Exception:
    pass
PY
    else
        curl -fsSL --connect-timeout 8 --max-time 20 "$url" 2>/dev/null \
            | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1
    fi
}
json_asset_url() { # <url> <match> -> first .zip asset URL
    local url="$1" match="$2"
    if cmd_exists python3; then
        python3 - "$url" "$match" <<'PY' 2>/dev/null
import json, sys, urllib.request
try:
    with urllib.request.urlopen(sys.argv[1], timeout=30) as r:
        rel = json.load(r)
    for a in rel.get("assets", []):
        n = a.get("name", "")
        if sys.argv[2] in n and n.endswith(".zip"):
            print(a["browser_download_url"]); break
except Exception:
    pass
PY
    elif sys_has_python; then
        python - "$url" "$match" <<'PY' 2>/dev/null
import json, sys, urllib.request
try:
    with urllib.request.urlopen(sys.argv[1], timeout=30) as r:
        rel = json.load(r)
    for a in rel.get("assets", []):
        n = a.get("name", "")
        if sys.argv[2] in n and n.endswith(".zip"):
            print(a["browser_download_url"]); break
except Exception:
    pass
PY
    else
        curl -fsSL --connect-timeout 10 --max-time 30 "$url" 2>/dev/null \
            | grep -o "https://[^\"]*${match}\.zip" | head -n1
    fi
}

# ------------------------------------------------------------
# Step 1 — environment + paths
# ------------------------------------------------------------
setup_env() {
    status "checking environment"
    case "$ENV_KIND" in
        termux)
            BIN_DIR="$PREFIX/bin"; STAMP_DIR="$PREFIX/libexec/opencode"; LIB_DIR="$PREFIX/lib";;
        *)
            # linux, macos, android, bsd, unix, windows (git-bash/msys), posix
            BIN_DIR="${ZYVO_BIN_DIR:-$HOME/.local/bin}"
            STAMP_DIR="$HOME/.local/libexec/zyvo"; LIB_DIR="$HOME/.local/lib/zyvo"
            mkdir -p "$BIN_DIR" "$STAMP_DIR" "$LIB_DIR" 2>/dev/null || {
                # read-only or exotic $HOME — keep going in a writable place
                BIN_DIR="${TMPDIR:-/tmp}/zyvo/bin"; STAMP_DIR="${TMPDIR:-/tmp}/zyvo/libexec"
                LIB_DIR="${TMPDIR:-/tmp}/zyvo/lib"
                mkdir -p "$BIN_DIR" "$STAMP_DIR" "$LIB_DIR"
            };;
    esac
    # No hard stop for 32-bit / uncommon CPUs any more: those devices fall
    # back to the Node (npm) build of the core, which is architecture neutral.
    if [ -n "$ZYVO_FORCE_NODE" ]; then
        NATIVE_CORE=0
        status "forced Node core (ZYVO_FORCE_NODE)"
        bump 2
        return
    fi
    case "$ENV_KIND/$ARCH" in
        termux/aarch64|termux/x86_64|linux/aarch64|linux/x86_64|macos/aarch64|macos/x86_64) NATIVE_CORE=1 ;;
        *)
            NATIVE_CORE=0
            printf "\r\033[K  ${C_Y}!${C_N} %s CPU has no native core build — using the Node build\n" "$RAW_ARCH"
            ;;
    esac
    status "environment ok ($ENV_KIND/$RAW_ARCH)"
    bump 2
}

# ------------------------------------------------------------
# Universal package installer — works on every mainstream package
# manager; silently succeeds as a no-op when none is usable.
# ------------------------------------------------------------
SUDO=""
if [ "$(id -u 2>/dev/null)" != "0" ] && [ "$ENV_KIND" != "termux" ] && cmd_exists sudo; then
    SUDO="sudo"
fi

pm_install() { # <packages...>
    [ $# -gt 0 ] || return 0
    local label="installing deps"
    if [ "$ENV_KIND" = "termux" ] && cmd_exists pkg; then
        run_bg "$label (pkg)"     pkg install -y "$@" && return 0
    fi
    if cmd_exists apt-get;  then run_bg "$label (apt)"     $SUDO apt-get install -y "$@"        && return 0; fi
    if cmd_exists dnf;      then run_bg "$label (dnf)"     $SUDO dnf install -y "$@"            && return 0; fi
    if cmd_exists yum;      then run_bg "$label (yum)"     $SUDO yum install -y "$@"            && return 0; fi
    if cmd_exists zypper;   then run_bg "$label (zypper)"  $SUDO zypper --non-interactive install "$@" && return 0; fi
    if cmd_exists pacman;   then run_bg "$label (pacman)"  $SUDO pacman -Sy --noconfirm "$@"    && return 0; fi
    if cmd_exists apk;      then run_bg "$label (apk)"     $SUDO apk add --no-cache "$@"        && return 0; fi
    if cmd_exists xbps-install; then run_bg "$label (xbps)" $SUDO xbps-install -Sy "$@"         && return 0; fi
    if cmd_exists emerge;   then run_bg "$label (emerge)"  $SUDO emerge -q "$@"                 && return 0; fi
    if cmd_exists opkg;     then run_bg "$label (opkg)"    $SUDO opkg install "$@"              && return 0; fi
    if cmd_exists brew;     then run_bg "$label (brew)"    brew install "$@"                    && return 0; fi
    if cmd_exists port;     then run_bg "$label (port)"    $SUDO port -N install "$@"           && return 0; fi
    if cmd_exists pkg_add;  then run_bg "$label (pkg_add)" $SUDO pkg_add "$@"                   && return 0; fi
    if cmd_exists pacapt;   then run_bg "$label (pacapt)"  $SUDO pacapt -S --noconfirm "$@"     && return 0; fi
    if cmd_exists choco;    then run_bg "$label (choco)"   choco install -y "$@"                && return 0; fi
    if cmd_exists winget;   then run_bg "$label (winget)"  winget install --silent "$@"         && return 0; fi
    return 1
}

# ------------------------------------------------------------
# Step 2 — dependencies (auto-install missing, skip existing)
# ------------------------------------------------------------
setup_deps() {
    status "checking dependencies"
    cmd_exists curl || cmd_exists wget \
        || pm_install curl \
        || fatal "missing required tool: curl" "Install curl (or wget) with your package manager, then rerun."
    cmd_exists tar || pm_install tar \
        || fatal "missing required tool: tar" "Install tar with your package manager, then rerun."
    local WANT="python3 ripgrep unzip git openssh" MISSING="" p
    for p in $WANT; do
        if [ "$p" = "openssh" ]; then
            cmd_exists ssh || MISSING="$MISSING openssh"
        else
            cmd_exists "$p" || MISSING="$MISSING $p"
        fi
    done

    if [ -n "$MISSING" ]; then
        pm_install $MISSING || warn_deps "$MISSING"
    else
        status "dependencies ok (skip)"
    fi
    bump 10
}
warn_deps() {
    printf "\r\033[K  ${C_Y}!${C_N} could not auto-install:$1 — continuing with what exists\n"
    STATUS="dependencies partial"
}

# ------------------------------------------------------------
# Step 3 — core engine (delta aware)
# ------------------------------------------------------------
install_portable_node() { # last resort: official Node tarball into $LIB_DIR
    local nver="v22.14.0" nos narch url
    case "$ENV_KIND" in
        macos) nos="darwin" ;;
        linux|android|termux|posix) nos="linux" ;;
        *) return 1 ;;
    esac
    case "$ARCH" in
        aarch64) narch="arm64" ;;
        x86_64)  narch="x64" ;;
        arm)     narch="armv7l" ;;
        ppc64le) narch="ppc64le" ;;
        s390x)   narch="s390x" ;;
        *) return 1 ;;
    esac
    url="https://nodejs.org/dist/$nver/node-$nver-$nos-$narch.tar.gz"
    status "downloading Node runtime ($narch)"
    download_file "$url" "$TMP/node.tar.gz" "downloading node" || return 1
    mkdir -p "$LIB_DIR/node"
    tar -xzf "$TMP/node.tar.gz" -C "$LIB_DIR/node" --strip-components=1 >> "$LOG" 2>&1 || return 1
    PATH="$LIB_DIR/node/bin:$PATH"; export PATH
    cmd_exists npm
}

setup_core_npm() { # architecture-neutral fallback (32-bit ARM, x86, odd ROMs)
    status "preparing Node core (no native build for $RAW_ARCH)"
    if ! cmd_exists npm; then
        if [ "$ENV_KIND" = "termux" ]; then
            pm_install nodejs-lts || pm_install nodejs || true
        else
            pm_install nodejs npm || pm_install nodejs || pm_install node || true
        fi
    fi
    cmd_exists npm || install_portable_node || true
    if ! cmd_exists npm; then
        fatal "could not install Node for $ENV_KIND/$RAW_ARCH" \
            "Install Node.js manually (e.g. pkg install nodejs-lts / apt install nodejs npm), then rerun."
    fi

    mkdir -p "$BIN_DIR" "$STAMP_DIR" "$LIB_DIR"
    run_bg "installing core (npm)" npm install -g opencode-ai \
        || fatal "npm core install failed" "Check your internet, then rerun."

    local target="" c nroot nprefix
    nroot="$(npm root -g 2>/dev/null)"
    nprefix="$(npm config get prefix 2>/dev/null)"
    for c in \
        "$(command -v opencode 2>/dev/null)" \
        "$nprefix/bin/opencode" \
        "$nprefix/opencode" \
        "$nroot/opencode-ai/bin/opencode" \
        "$nroot/opencode-ai/bin/opencode.exe" \
        "$LIB_DIR/node/bin/opencode"
    do
        [ -n "$c" ] && [ -x "$c" ] && { target="$c"; break; }
    done
    [ -n "$target" ] || fatal "core binary missing after npm install" \
        "Run: npm install -g opencode-ai  and check its output."

    # shim so every launcher path keeps working unchanged
    printf '#!/usr/bin/env sh\nPATH="%s:$PATH"; export PATH\nexec "%s" "$@"\n' \
        "$LIB_DIR/node/bin" "$target" > "$STAMP_DIR/opencode.bin"
    chmod 755 "$STAMP_DIR/opencode.bin"
    printf 'npm' > "$STAMP_DIR/zyvo-core-kind"
    status "core installed (node build)"
    bump 70
}

setup_core() {
    if [ "${NATIVE_CORE:-1}" != "1" ]; then
        setup_core_npm
        return
    fi
    if [ "$ENV_KIND" = "termux" ]; then
        local tag installed zip_url
        status "checking core version"
        tag="$(json_tag "$CORE_API/releases/latest")"
        installed=""
        [ -f "$STAMP_DIR/zyvo-core-version" ] && installed="$(tr -d '[:space:]' < "$STAMP_DIR/zyvo-core-version" 2>/dev/null)"
        if [ -n "$tag" ] && [ "$tag" = "$installed" ] && [ -x "$STAMP_DIR/opencode.bin" ]; then
            status "core up-to-date ($tag) — 0 MB"
            bump 70
            return
        fi
        [ -n "$installed" ] && status "core update: $installed → ${tag:-latest}"

        if [ "$ARCH" = "x86_64" ]; then
            zip_url="$(json_asset_url "$CORE_API/releases/latest" "android-x86_64")"
            [ -n "$zip_url" ] || zip_url="$(json_asset_url "$CORE_API/releases/latest" "$AARCH64_MATCH")"
        else
            zip_url="$(json_asset_url "$CORE_API/releases/latest" "$AARCH64_MATCH")"
        fi
        if [ -z "$zip_url" ]; then
            # release has no matching Android build — stay installable
            setup_core_npm
            return
        fi

        if ! download_file "$zip_url" "$TMP/core.zip" "downloading core"; then
            printf "\r\033[K  ${C_Y}!${C_N} native core download failed — trying the Node build\n"
            setup_core_npm
            return
        fi

        # checksum when available
        if curl -fsSL --retry 2 --connect-timeout 10 --max-time 30 -o "$TMP/SHA256SUMS" "${zip_url%/*}/SHA256SUMS" 2>/dev/null; then
            local expected actual
            expected="$(grep "$(basename "$zip_url")" "$TMP/SHA256SUMS" | awk '{print $1}' | head -n1)"
            actual="$(sha256sum "$TMP/core.zip" | awk '{print $1}')"
            if [ -n "$expected" ] && [ "$expected" != "$actual" ]; then
                fatal "checksum mismatch — download corrupted" "Rerun the installer."
            fi
            status "integrity ok (SHA256)"
        fi
        bump 68
        run_bg "extracting core" bash -c "cd '$TMP' && unzip -oq core.zip" \
            || fatal "couldn't extract the core zip" "Rerun the installer."
        [ -f "$TMP/opencode.bin" ] || [ -f "$TMP/opencode" ] \
            || fatal "core zip has no binary" "The release format changed — report it."

        mkdir -p "$BIN_DIR" "$STAMP_DIR" "$LIB_DIR"
        if [ -f "$TMP/opencode.bin" ]; then install -m755 "$TMP/opencode.bin" "$STAMP_DIR/opencode.bin"
        else install -m755 "$TMP/opencode" "$STAMP_DIR/opencode.bin"; fi
        for lib in libtagfix.so libopentui.so libc++_shared.so librust_pty_arm64.so; do
            [ -f "$TMP/$lib" ] && install -m644 "$TMP/$lib" "$LIB_DIR/$lib" 2>/dev/null || true
        done
        [ -e "$PREFIX/bin/opencode" ] && mv "$PREFIX/bin/opencode" "$PREFIX/bin/opencode.bak" 2>/dev/null || true
        # last safety net: some 32-bit/older kernels cannot exec the native
        # binary even when the CPU name looked right — fall back silently.
        if ! "$STAMP_DIR/opencode.bin" --version >/dev/null 2>&1; then
            printf "\r\033[K  ${C_Y}!${C_N} native core cannot run on this device — using the Node build\n"
            setup_core_npm
            return
        fi
        [ -n "$tag" ] && printf '%s' "$tag" > "$STAMP_DIR/zyvo-core-version"
        printf 'native' > "$STAMP_DIR/zyvo-core-kind"
        status "core installed"
        bump 70
    else
        local tag installed check
        tag="$(json_tag "$API/repos/$GH_REPO/releases/latest" 2>/dev/null)"
        installed=""
        [ -f "$STAMP_DIR/zyvo-core-version" ] && installed="$(tr -d '[:space:]' < "$STAMP_DIR/zyvo-core-version" 2>/dev/null)"
        check="$HOME/.opencode/bin/opencode"
        if [ -n "$tag" ] && [ "$tag" = "$installed" ] && [ -x "$check" ]; then
            status "core up-to-date ($tag) — 0 MB"
            bump 70
            return
        fi
        if ! run_bg "installing official core" bash -c \
            "curl -fsSL --retry 3 --connect-timeout 15 --max-time 120 -o '$TMP/oc-install.sh' '$OPENCODE_INSTALL_URL' && bash '$TMP/oc-install.sh'"; then
            printf "\r\033[K  ${C_Y}!${C_N} official core installer failed — using the Node build\n"
            setup_core_npm
            return
        fi
        if [ ! -x "$check" ]; then
            setup_core_npm
            return
        fi
        cp "$check" "$STAMP_DIR/opencode.bin"; chmod 755 "$STAMP_DIR/opencode.bin"
        if ! "$STAMP_DIR/opencode.bin" --version >/dev/null 2>&1; then
            setup_core_npm
            return
        fi
        [ -n "$tag" ] && printf '%s' "$tag" > "$STAMP_DIR/zyvo-core-version"
        status "core installed (official)"
        bump 70
    fi
}

# ------------------------------------------------------------
# Step 4 — ZYVO layer (wrapper, config, skills, commands)
# ------------------------------------------------------------
setup_layer() {
    # pip/bootstrap route: layer already on disk — skip network fetch
    if [ -n "$ZYVO_BOOT" ] && [ -d "$ZYVO_BOOT/scripts" ] && [ -d "$ZYVO_BOOT/config" ]; then
        status "zyvo layer ready (pip bootstrap)"
        rm -rf "$TMP"/* 2>/dev/null || true
        cp -a "$ZYVO_BOOT/." "$TMP/"
        bump 75
    else
    status "downloading zyvo layer"
    if curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 120 \
        -o "$TMP/layer.tar.gz" "https://codeload.github.com/$GH_REPO/tar.gz/refs/heads/main" 2>/dev/null; then
        tar -xzf "$TMP/layer.tar.gz" -C "$TMP" --strip-components=1 2>/dev/null \
            && [ -d "$TMP/config" ] && [ -d "$TMP/skills" ] || { rm -rf "$TMP"/* 2>/dev/null || true; }
    fi
    if [ ! -d "$TMP/config" ]; then
        run_bg "fetching zyvo layer (git)" bash -c \
            "git clone --depth 1 -q 'https://github.com/$GH_REPO.git' '$TMP/src' && mv '$TMP/src'/* '$TMP/' && rm -rf '$TMP/src'" \
            || fatal "couldn't download the ZYVO layer" "Check your internet and rerun."
    fi
    bump 75
    fi

    # wrapper + helpers
    install_script "$TMP/scripts/zyvo" "$BIN_DIR/zyvo"
    [ -f "$TMP/scripts/zyvo-menu" ]     && install_script "$TMP/scripts/zyvo-menu" "$BIN_DIR/zyvo-menu"
    [ -f "$TMP/scripts/zyvo-browser" ]  && install_script "$TMP/scripts/zyvo-browser" "$BIN_DIR/zyvo-browser"
    [ -f "$TMP/scripts/zyvo-vision" ]   && install_script "$TMP/scripts/zyvo-vision" "$BIN_DIR/zyvo-vision"
    [ -f "$TMP/scripts/zyvo-uninstall" ] && install_script "$TMP/scripts/zyvo-uninstall" "$BIN_DIR/zyvo-uninstall"
    [ -f "$TMP/scripts/oc-settings.sh" ] && install_script "$TMP/scripts/oc-settings.sh" "$BIN_DIR/oc-settings"
    [ -f "$TMP/scripts/patch-brand.py" ] && install -m644 "$TMP/scripts/patch-brand.py" "$LIB_DIR/patch-brand.py"

    # config + skills (merge, never clobber)
    local CONFIG_DIR="$HOME/.config/opencode"
    mkdir -p "$CONFIG_DIR/agent" "$CONFIG_DIR/command" "$CONFIG_DIR/themes" "$CONFIG_DIR/skills"
    if sys_has_python; then
        if [ -f "$CONFIG_DIR/opencode.json" ]; then
            cp -f "$TMP/config/opencode.json" "$TMP/opencode.json.new" 2>/dev/null || true
            merge_json "$CONFIG_DIR/opencode.json" "$TMP/opencode.json.new"
            rm -f "$TMP/opencode.json.new"
        else
            cp -f "$TMP/config/opencode.json" "$CONFIG_DIR/opencode.json"
        fi
    else
        [ -f "$CONFIG_DIR/opencode.json" ] || cp -f "$TMP/config/opencode.json" "$CONFIG_DIR/opencode.json"
    fi
    # also strip stale model keys from opencode.jsonc (oc-settings writes both)
    if sys_has_python && [ -f "$CONFIG_DIR/opencode.jsonc" ]; then
        if cmd_exists python3; then _py=python3; else _py=python; fi
        "$_py" - "$CONFIG_DIR/opencode.jsonc" <<'PYC' 2>/dev/null || true
import json, sys
p = sys.argv[1]
try:
    d = json.load(open(p))
except Exception:
    sys.exit(0)
c = False
for k in ("model", "small_model"):
    if k in d:
        del d[k]; c = True
a = d.get("agent")
if isinstance(a, dict) and isinstance(a.get("build"), dict) and "model" in a["build"]:
    del a["build"]["model"]; c = True
if c:
    json.dump(d, open(p, "w"), indent=2)
PYC
    fi
    [ -f "$TMP/config/tui.json" ] && cp -f "$TMP/config/tui.json" "$CONFIG_DIR/tui.json" 2>/dev/null || true
    cp -f "$TMP"/config/agent/*.md    "$CONFIG_DIR/agent/"   2>/dev/null || true
    cp -f "$TMP"/config/command/*.md  "$CONFIG_DIR/command/" 2>/dev/null || true
    cp -f "$TMP"/config/themes/*.json "$CONFIG_DIR/themes/"  2>/dev/null || true
    cp -rf "$TMP"/skills/*            "$CONFIG_DIR/skills/"  2>/dev/null || true

    status "config + skills installed"
    bump 85

    # rc file: PATH + provider key
    local rc="$HOME/.bashrc"
    [ "$ENV_KIND" != "termux" ] && [ ! -f "$HOME/.bashrc" ] && [ -f "$HOME/.profile" ] && rc="$HOME/.profile"
    if ! grep -q 'ZYVO PATH' "$rc" 2>/dev/null; then
        printf '# ZYVO PATH\ncase ":$PATH:" in *":%s:"*) ;; *) export PATH="%s:$PATH";; esac\n' \
            "$BIN_DIR" "$BIN_DIR" >> "$rc"
    fi
    if ! grep -q "OPENCODE_API_KEY" "$rc" 2>/dev/null; then
        printf '\n# ZYVO AI\nexport OPENCODE_API_KEY="%s"\n' "$ZEN_KEY_DEFAULT" >> "$rc"
    fi
    status "provider + PATH ready"
    bump 95
}

install_script() { # $1 src $2 dest — shebang rewritten for non-Termux
    if [ "$ENV_KIND" = "termux" ]; then
        install -m755 "$1" "$2"
    else
        sed '1s|^#!.*|#!/usr/bin/env bash|' "$1" > "$2" && chmod 755 "$2"
    fi
}

brand_logo() { # put the ZYVO brand logo into the core binary
    # patch-brand.py replaces the "OPENCODE" pixel-art wordmark with the
    # "ZYVO" design, same byte length (layout stays intact — no crash),
    # on every install/update. Runs after the layer is on disk (the
    # script ships in the layer). Idempotent — safe on already-branded
    # binaries (missing rows are skipped).
    [ -f "$LIB_DIR/patch-brand.py" ] || return 0
    [ -f "$STAMP_DIR/opencode.bin" ] || return 0
    sys_has_python || return 0
    local py
    if cmd_exists python3; then py=python3; else py=python; fi
    status "branding logo (ZYVO)"
    if ! run "$py" "$LIB_DIR/patch-brand.py" "$STAMP_DIR/opencode.bin" "$STAMP_DIR/opencode.bin"; then
        log "brand_logo: failed (ignored — binary untouched)"
    fi
    status "brand logo applied"
}

merge_json() { # $1 user config $2 repo config — merge with force-keys
    local py
    if cmd_exists python3; then py=python3; else py=python; fi
    "$py" - "$1" "$2" <<'PY'
import json, sys
user_path, repo_path = sys.argv[1], sys.argv[2]
try:
    user = json.load(open(user_path))
except Exception:
    user = {}
try:
    repo = json.load(open(repo_path))
except Exception:
    repo = {}
# these always come from the repo — ZYVO's core defaults must win
# (provider, permissions), otherwise an old install keeps stale values
FORCE = {"provider", "permission", "agent"}
for k, v in repo.items():
    if k in FORCE or k not in user:
        user[k] = v
# model defaults are intentionally NOT forced — ZYVO uses whatever model
# the user picked (opencode's own default). Remove stale deepseek keys
# left by older versions so the picker falls back to the stock default.
for k in ("model", "small_model"):
    user.pop(k, None)
json.dump(user, open(user_path, "w"), indent=2)
PY
}

# ------------------------------------------------------------
# Step 5 — verify
# ------------------------------------------------------------
verify_install() {
    status "verifying"
    bump 97
    if [ ! -x "$BIN_DIR/zyvo" ]; then
        fatal "wrapper missing at $BIN_DIR/zyvo" "Rerun the installer."
    fi
    if [ -f "$STAMP_DIR/opencode.bin" ]; then
        status "verifying core"
    else
        fatal "core binary missing at $STAMP_DIR/opencode.bin" "Rerun the installer."
    fi
    VERSION="$("$BIN_DIR/zyvo" --version 2>&1 || true)"
    bump 99
    STATUS="verify ok"
    draw
}

# ------------------------------------------------------------
# entry
# ------------------------------------------------------------
if [ "${1:-}" = "uninstall" ]; then
    shift # drop "uninstall"; remaining args pass through (POSIX)
    if [ -n "$ZYVO_BOOT" ] && [ -f "$ZYVO_BOOT/scripts/zyvo-uninstall" ]; then
        exec sh "$ZYVO_BOOT/scripts/zyvo-uninstall" "$@"
    fi
    SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo "$PWD")"
    if [ -f "$SCRIPT_DIR/scripts/zyvo-uninstall" ]; then
        exec sh "$SCRIPT_DIR/scripts/zyvo-uninstall" "$@"
    fi
    curl -fsSL --retry 2 --connect-timeout 15 --max-time 60 \
        -o "$TMP/zyvo-uninstall" "https://raw.githubusercontent.com/$GH_REPO/main/scripts/zyvo-uninstall" \
        && exec sh "$TMP/zyvo-uninstall" "$@"
    echo "couldn't fetch the uninstaller" >&2
    exit 1
fi

setup_env
setup_deps
setup_core
setup_layer
brand_logo
verify_install

# ---- done ----
PROG=100; STATUS="done ✔"
draw
printf "\n\n"
printf "  ${C_G}${C_B}⚡ ZYVO READY${C_N}   ${C_D}%s · %s · install time ~%ss${C_N}\n" "$ENV_KIND" "$ARCH" "$SECONDS"
printf "  ${C_B}zyvo${C_N}              start the AI (full-power)\n"
printf "  ${C_B}zyvo preview${C_N}      open a page in the browser\n"
printf "  ${C_B}zyvo update${C_N}       delta update\n"
printf "  ${C_B}zyvo session${C_N}      session menu (↑↓ to pick)\n"
printf "  ${C_B}zyvo doctor${C_N}       health check\n"
printf "  ${C_B}zyvo backup${C_N}       backup config + projects\n"
printf "  ${C_B}zyvo uninstall${C_N}    remove ZYVO (keeps projects)\n"
if [ -n "$ZYVO_BOOT" ]; then
    printf "  ${C_D}installed via pip — update layer with:${C_N} ${C_B}zyvo install${C_N}\n"
fi
printf "\n  ${C_D}open a new shell, then run:${C_N} ${C_B}zyvo${C_N}\n\n"