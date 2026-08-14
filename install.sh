#!/data/data/com.termux/files/usr/bin/bash
# ZYVO — ready-to-use AI coding CLI installer
# Native Android aarch64 build (guysoft/opencode-termux), no proot, no glibc.
# Fully automatic: dependencies, native libs, storage, source, config, provider.
set -e

REPO="guysoft/opencode-termux"
GH_REPO="${GH_REPO:-moradgamer802-cell/zyvo-ai-coding}"
DEFAULT_ZEN_KEY="${ZEN_API_KEY:-sk-PKOWRt2391BL0MP3W90yaG8qx4vofQJQgigJreBBYjrArj0lwuU1HkWUqOHgDGHP}"
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo "$PWD")"
CONFIG_DIR="$HOME/.config/opencode"
DEPS="ripgrep curl unzip tar libc++ figlet python3 openssl git"
TOTAL_STEPS=9
STEP_NO=0
WARNINGS=0
SKIPPED=""

# ---------- ui ----------
if [ -t 1 ] && [ -z "$ZYVO_NO_COLOR" ]; then
    GREEN=$'\033[32m'; CYAN=$'\033[36m'; DIM=$'\033[2m'; RED=$'\033[31m'
    YELLOW=$'\033[33m'; BOLD=$'\033[1m'; RESET=$'\033[0m'; MAG=$'\033[35m'
    TTY=1
else
    GREEN=''; CYAN=''; DIM=''; RED=''; YELLOW=''; BOLD=''; RESET=''; MAG=''
    TTY=0
fi
ANIM=1; [ -n "$ZYVO_NO_ANIM" ] && ANIM=0; [ "$TTY" = 0 ] && ANIM=0

now() { date +%s; }
say()   { printf "  ${GREEN}${BOLD}✓${RESET} %s\n" "$1"; }
info()  { printf "  ${DIM}·${RESET} %s\n" "$1"; }
warn()  { WARNINGS=$((WARNINGS+1)); printf "  ${YELLOW}${BOLD}!${RESET} %s\n" "$1"; }
skip()  { SKIPPED="$SKIPPED\n    - $1"; warn "$1"; }
fatal() {
    echo
    printf "${RED}${BOLD}  ┌ INSTALL FAIL ─────────────────────────${RESET}\n"
    printf "${RED}${BOLD}  │${RESET} %s\n" "$1"
    [ -n "$2" ] && printf "${RED}${BOLD}  │${RESET} ${DIM}fix:${RESET} %s\n" "$2"
    printf "${RED}${BOLD}  └───────────────────────────────────────${RESET}\n"
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

step() { # <title>
    STEP_NO=$((STEP_NO+1))
    local pct=$(( (STEP_NO-1) * 100 / TOTAL_STEPS ))
    echo
    printf "${CYAN}${BOLD}[%d/%d]${RESET} ${BOLD}%s${RESET}  ${DIM}[%s] %d%%${RESET}\n" \
        "$STEP_NO" "$TOTAL_STEPS" "$1" "$(bar $pct)" "$pct"
}

spin() { # <label> <cmd...>  — quiet run with spinner, log at $TMP/last.log
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
        printf "\r  ${MAG}%s${RESET} %s   " "$(printf '%s' "$frames" | cut -c $i)" "$label"
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

dlprogress() { # <url> <out>  — live download bar
    local url="$1" out="$2"
    local total=0 curl_pid got last=0 t0 t1 speedb=0 pct
    total="$(curl -sIL --connect-timeout 10 --max-time 20 "$url" \
        | awk 'tolower($1)=="content-length:"{n=$2} END{print n+0}')"
    curl -fLsS --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 -o "$out" "$url" &
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
            printf "\r  ${CYAN}▼${RESET} %s / %s  [%s] %3d%%  ${DIM}%s${RESET}   " \
                "$(sizeMB "$got")" "$(sizeMB "$total")" "$(bar $pct)" "$pct" "$(speed "$speedb")"
        elif [ "$TTY" = 1 ]; then
            printf "\r  ${CYAN}▼${RESET} %s   " "$(sizeMB "$got")"
        fi
        sleep 0.25
    done
    wait "$curl_pid" || return 1
    [ "$TTY" = 1 ] && printf "\r\033[K"
    say "core package downloaded ($(sizeMB "$(wc -c < "$out")"))"
}

banner() {
    local lines=(
        ' ________     ____      ______  '
        '|___  /\ \   / /\ \    / / __ \ '
        '   / /  \ \_/ /  \ \  / / |  | |'
        '  / /    \   /    \ \/ /| |  | |'
        ' / /__    | |      \  / | |__| |'
        '/_____|   |_|       \/   \____/ '
    )
    echo
    for ln in "${lines[@]}"; do
        printf "${GREEN}${BOLD}%s${RESET}\n" "$ln"
        [ "$ANIM" = 1 ] && sleep 0.06
    done
}

MODE="install"
[ -x "$PREFIX/bin/zyvo" ] && MODE="update"

banner
printf "${DIM}  OpenCode Termux · AI coding CLI · Banglish${RESET}\n"
printf "${DIM}  mode:${RESET} ${BOLD}%s${RESET}  ${DIM}·  auto-install: everything${RESET}\n" "$MODE"

# ---------- [1] environment ----------
step "environment check"
if [ -z "$PREFIX" ] || [ ! -d "$PREFIX" ]; then
    fatal "Termux (F-Droid version) er bahire chalano jabe na." \
          "F-Droid theke Termux install koro: https://f-droid.org/en/packages/com.termux/"
fi
ARCH="${ZYVO_ARCH:-$(uname -m)}"
case "$ARCH" in
    aarch64|arm64) ZIP_MATCH="android-aarch64";;
    *) ZIP_MATCH="android-$ARCH"; warn "arch $ARCH — official build aarch64 only, try korbo";;
esac
FREE_KB="$(df -k "$HOME" 2>/dev/null | awk 'NR==2{print $4+0}')"
if [ -n "$FREE_KB" ] && [ "$FREE_KB" -lt 307200 ]; then
    warn "free space kom (~$((FREE_KB/1024)) MB) — 300 MB+ rakho"
fi
say "Termux OK · arch $ARCH · prefix $PREFIX"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
INSTALL_START="$(now)"

# storage permission — auto (default workdir /storage/emulated/0)
if [ ! -d "$HOME/storage" ] && command -v termux-setup-storage >/dev/null 2>&1; then
    termux-setup-storage >/dev/null 2>&1 || true
    sleep 2
fi
if [ -d /storage/emulated/0 ] && [ -r /storage/emulated/0 ]; then
    say "storage access OK (/storage/emulated/0)"
else
    skip "storage permission nai — 'termux-setup-storage' chalao (Allow dao)"
fi

# ---------- [2] dependencies (auto, self-healing) ----------
step "dependencies (auto-install)"
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

if ! command -v pkg >/dev/null 2>&1; then
    warn "pkg nai — existing tools diye chalabo"
elif [ "$(id -u)" = "0" ]; then
    warn "root e pkg chole na — existing tools diye chalabo"
else
    if needs_update; then
        spin "package index update korchi" pkg update -y || true
        say "package index updated"
    else
        say "package index fresh (skip)"
    fi
    if spin "installing: $DEPS" pkg_install; then
        say "dependencies installed"
    else
        warn "pkg install fail — index refresh kore abar try korchi"
        if ! spin "retrying" bash -c "pkg update -y; pkg install -y $DEPS"; then
            if switch_official_repo; then
                if spin "official Termux mirror e switch korchi" bash -c "pkg update -y; pkg install -y $DEPS"; then
                    say "dependencies installed (official mirror)"
                else
                    tail -n 8 "$TMP/last.log" 2>/dev/null || true
                    fatal "dependency install fail (official mirror eo)." \
                          "'termux-change-repo' chalao, tarpor installer abar chalao."
                fi
            else
                tail -n 8 "$TMP/last.log" 2>/dev/null || true
                fatal "dependency install fail." "'termux-change-repo' chalao, tarpor abar chalao."
            fi
        fi
    fi
fi

# self-heal: broken linkage (openssl/ngtcp2 symbol error) -> one full upgrade
heal_broken_libs() {
    local out
    out="$(git ls-remote https://github.com/$GH_REPO.git HEAD 2>&1 || true)"
    case "$out" in
        *"cannot locate symbol"*|*"CANNOT LINK"*|*"aborted session"*)
            warn "Termux packages purono (git/openssl mismatch) — auto upgrade korchi"
            spin "pkg upgrade (openssl, git, libngtcp2)" bash -c \
                "pkg update -y; DEBIAN_FRONTEND=noninteractive pkg upgrade -y -o Dpkg::Options::=--force-confold" || true
            say "packages upgraded"
            ;;
    esac
}
if command -v git >/dev/null 2>&1 && command -v pkg >/dev/null 2>&1 && [ "$(id -u)" != "0" ]; then
    heal_broken_libs
fi

for dep in rg curl unzip tar; do
    if ! command -v "$dep" >/dev/null 2>&1 && command -v pkg >/dev/null 2>&1; then
        spin "installing $dep" pkg install -y "$dep" || true
    fi
    command -v "$dep" >/dev/null 2>&1 || fatal "$dep missing." "pkg install -y $dep"
done
command -v python3 >/dev/null 2>&1 || skip "python3 nai — ZYVO branding patch skip hobe"
command -v git >/dev/null 2>&1 || info "git nai — source curl diye namabo (git lagbe na)"
say "all required tools present"

# ---------- [3] core download ----------
step "core package download"
ZIP_URL="$(curl -fsSL --connect-timeout 10 --max-time 30 "https://api.github.com/repos/$REPO/releases/latest" \
    | grep -o "https://[^\"]*${ZIP_MATCH}\.zip" | head -n1)"
[ -n "$ZIP_URL" ] || fatal "$ARCH er jonno build nai (aarch64/arm64 only)." "ZYVO_ARCH=aarch64 bash install.sh"
SUMS_URL="${ZIP_URL%/*}/SHA256SUMS"
dlprogress "$ZIP_URL" "$TMP/opencode.zip" || fatal "download fail — internet check koro." "installer abar chalao"

if curl -fsSL --retry 3 --connect-timeout 15 --max-time 60 -o "$TMP/SHA256SUMS" "$SUMS_URL" 2>/dev/null; then
    EXPECTED="$(grep "$(basename "$ZIP_URL")" "$TMP/SHA256SUMS" | awk '{print $1}' | head -n1)"
    ACTUAL="$(sha256sum "$TMP/opencode.zip" | awk '{print $1}')"
    if [ -n "$EXPECTED" ] && [ "$EXPECTED" != "$ACTUAL" ]; then
        fatal "SHA256 mismatch — download corrupted." "installer abar chalao"
    fi
    say "integrity verified (SHA256)"
else
    warn "SHA256SUMS pawa jayni — integrity check skip"
fi

# ---------- [4] native libs ----------
step "native libraries"
extract_one() {
    if command -v unzip >/dev/null 2>&1; then (cd "$TMP" && unzip -o -q "$1" "$2")
    elif command -v busybox >/dev/null 2>&1; then (cd "$TMP" && busybox unzip -o -q "$1" "$2")
    else return 1; fi
}
if [ ! -f "$PREFIX/lib/libc++_shared.so" ]; then
    if extract_one "$TMP/opencode.zip" libc++_shared.so; then
        install -m644 "$TMP/libc++_shared.so" "$PREFIX/lib/libc++_shared.so"
        say "libc++_shared.so installed"
    elif command -v pkg >/dev/null 2>&1 && spin "libc++ install korchi" pkg install -y libc++; then
        say "libc++ installed (pkg)"
    else
        skip "libc++ install hoyni — 'pkg install -y libc++' nije chalao"
    fi
else
    say "native libs already present"
fi

# ---------- [5] source ----------
step "ZYVO source resolve"
fetch_source() {
    # 1) plain HTTPS tarball (no git — Termux git often has broken TLS helpers)
    for br in main master; do
        if curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 300 \
            -o "$TMP/source.tar.gz" "https://codeload.github.com/$GH_REPO/tar.gz/refs/heads/$br" 2>/dev/null; then
            mkdir -p "$TMP/source"
            tar -xzf "$TMP/source.tar.gz" -C "$TMP/source" --strip-components=1 2>/dev/null \
                && [ -d "$TMP/source/config" ] && return 0
            rm -rf "$TMP/source" "$TMP/source.tar.gz"
        fi
    done
    # 2) zip fallback
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
    # 3) git clone, only if git actually works
    if command -v git >/dev/null 2>&1; then
        git clone --depth 1 -q "https://github.com/$GH_REPO.git" "$TMP/source" 2>/dev/null \
            && [ -d "$TMP/source/config" ] && return 0
        rm -rf "$TMP/source"
    fi
    return 1
}
if [ -d "$SCRIPT_DIR/config" ] && [ -d "$SCRIPT_DIR/skills" ]; then
    say "local source used ($SCRIPT_DIR)"
else
    info "source download korchi (curl)..."
    fetch_source || fatal "source namate parlam na." "internet check koro, ba repo folder theke: bash install.sh"
    SCRIPT_DIR="$TMP/source"
    say "source downloaded"
fi

# ---------- [6] core install ----------
step "zyvo core install"
install_core() {
    cd "$TMP"
    unzip -o -q opencode.zip
    mkdir -p "$PREFIX/bin" "$PREFIX/libexec/opencode" "$PREFIX/lib"
    if [ -f "$SCRIPT_DIR/scripts/zyvo" ]; then
        install -m755 "$SCRIPT_DIR/scripts/zyvo" "$PREFIX/bin/zyvo"
    else
        install -m755 opencode "$PREFIX/bin/zyvo"
    fi
    if [ -f "$SCRIPT_DIR/scripts/patch-brand.py" ] && command -v python3 >/dev/null 2>&1; then
        python3 "$SCRIPT_DIR/scripts/patch-brand.py" opencode.bin opencode.bin.zyvo 2>/dev/null \
            && python3 "$SCRIPT_DIR/scripts/patch-brand.py" opencode.bin.zyvo opencode.bin.zyvo --blank-logo 2>/dev/null \
            && mv opencode.bin.zyvo opencode.bin
    fi
    install -m755 opencode.bin "$PREFIX/libexec/opencode/opencode.bin"
    install -m644 libtagfix.so libopentui.so "$PREFIX/lib/"
    [ -f "$PREFIX/lib/libc++_shared.so" ] || install -m644 libc++_shared.so "$PREFIX/lib/"
    [ -f librust_pty_arm64.so ] && install -m644 librust_pty_arm64.so "$PREFIX/lib/"
    [ -e "$PREFIX/bin/opencode" ] && mv "$PREFIX/bin/opencode" "$PREFIX/bin/opencode.bak" 2>/dev/null
    [ -f "$SCRIPT_DIR/scripts/zyvo-menu" ] && install -m755 "$SCRIPT_DIR/scripts/zyvo-menu" "$PREFIX/bin/zyvo-menu"
    return 0
}
if ! spin "binary + libs install korchi" install_core; then
    tail -n 8 "$TMP/last.log" 2>/dev/null || true
    fatal "core install fail." "installer abar chalao"
fi
say "core installed → $PREFIX/bin/zyvo"

# ---------- [7] config + skills ----------
step "config, commands + skills"
install_config() {
    mkdir -p "$CONFIG_DIR/agent" "$CONFIG_DIR/command" "$CONFIG_DIR/themes" "$CONFIG_DIR/skills"
    [ -f "$CONFIG_DIR/opencode.json" ] && cp -n "$CONFIG_DIR/opencode.json" "$CONFIG_DIR/opencode.json.bak" 2>/dev/null
    install -m644 "$SCRIPT_DIR/config/opencode.json" "$CONFIG_DIR/opencode.json"
    install -m644 "$SCRIPT_DIR/config/tui.json" "$CONFIG_DIR/tui.json" 2>/dev/null || true
    install -m644 "$SCRIPT_DIR/config/agent/"*.md "$CONFIG_DIR/agent/" 2>/dev/null || true
    install -m644 "$SCRIPT_DIR/config/command/"*.md "$CONFIG_DIR/command/" 2>/dev/null || true
    install -m644 "$SCRIPT_DIR/config/themes/"*.json "$CONFIG_DIR/themes/" 2>/dev/null || true
    cp -rn "$SCRIPT_DIR/skills/"* "$CONFIG_DIR/skills/" 2>/dev/null || true
    [ -f "$SCRIPT_DIR/scripts/oc-settings.sh" ] && install -m755 "$SCRIPT_DIR/scripts/oc-settings.sh" "$PREFIX/bin/oc-settings"
    return 0
}
spin "config + skills copy korchi" install_config || warn "config copy e problem hoyeche"
N_CMD="$(ls -1 "$CONFIG_DIR/command"/*.md 2>/dev/null | wc -l | tr -d ' ')"
N_SKILL="$(ls -1d "$CONFIG_DIR/skills"/*/ 2>/dev/null | wc -l | tr -d ' ')"
say "config OK · ${N_CMD} commands · ${N_SKILL} skills"

# ---------- [8] provider + shell ----------
step "AI provider + shell setup"
if ! grep -q "OPENCODE_API_KEY\|OPENCODE_ZEN_API_KEY" "$HOME/.bashrc" 2>/dev/null; then
    printf '\n# ZYVO AI\nexport OPENCODE_API_KEY="%s"\n' "$DEFAULT_ZEN_KEY" >> "$HOME/.bashrc"
    say "AI provider configured (Zen, zero-config)"
else
    say "AI provider already configured"
fi
if ! grep -q 'ZYVO PATH' "$HOME/.bashrc" 2>/dev/null; then
    printf '# ZYVO PATH\ncase ":$PATH:" in *":%s:"*) ;; *) export PATH="%s:$PATH";; esac\n' \
        "$PREFIX/bin" "$PREFIX/bin" >> "$HOME/.bashrc"
fi
export OPENCODE_API_KEY="${OPENCODE_API_KEY:-$DEFAULT_ZEN_KEY}"
say "shell PATH ready"

# ---------- [9] cleanup + verify ----------
step "cleanup + verify"
for f in "$HOME/.opencode/bin/opencode" "$HOME/.opencode/bin/opencode.bak" "$PREFIX/bin/opencode.bak"; do
    [ -e "$f" ] || continue
    "$f" --version >/dev/null 2>&1 || mv "$f" "$f.bak.old" 2>/dev/null || true
done
OTHER_ZYVO="$(command -v zyvo 2>/dev/null || true)"
if [ -n "$OTHER_ZYVO" ] && [ "$OTHER_ZYVO" != "$PREFIX/bin/zyvo" ]; then
    warn "onno path e o 'zyvo' ache: $OTHER_ZYVO — PATH check koro"
fi
VERSION="$("$PREFIX/bin/zyvo" --version 2>&1)" || fatal "zyvo cholche na." "bash install.sh abar chalao"
say "verified"

# ---------- FINAL ----------
echo
printf "${GREEN}${BOLD}  [%s] 100%%  ZYVO AI Ready ✓${RESET}  ${DIM}(%ss)${RESET}\n" "$(bar 100)" "$(( $(now) - INSTALL_START ))"
echo
printf "  ${BOLD}zyvo${RESET}          ${DIM}AI start — workdir /storage/emulated/0${RESET}\n"
printf "  ${BOLD}oc-settings${RESET}   ${DIM}model tier + permission menu${RESET}\n"
printf "  ${BOLD}/dekho /fix /review /model /safe /approve${RESET}  ${DIM}in-chat commands${RESET}\n"
printf "  ${DIM}version: %s · %s commands · %s skills${RESET}\n" "$VERSION" "$N_CMD" "$N_SKILL"
if [ "$WARNINGS" -gt 0 ]; then
    printf "\n  ${YELLOW}${BOLD}%d warning:${RESET}" "$WARNINGS"
    printf "%b\n" "$SKIPPED"
fi
printf "\n  ${DIM}notun shell e:${RESET} source ~/.bashrc  ${DIM}tarpor${RESET} ${BOLD}zyvo${RESET}\n\n"
