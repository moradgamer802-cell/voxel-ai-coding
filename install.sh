#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  ZYVO installer — the one-command AI coding CLI setup
#  Install:  curl -fsSL https://raw.githubusercontent.com/
#            zyvo9/zyvo-ai-coding/main/install.sh | bash
#  Usage:    install.sh [uninstall]
#
#  Designed from scratch with three goals:
#    1. NEVER silently fail — every step reports OK / SKIP / ERROR
#    2. Idempotent — safe to re-run, updates in place
#    3. Minimal dependencies — only curl + tar are mandatory
# ============================================================
set -e
umask 022

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------
GH_REPO="${GH_REPO:-zyvo9/zyvo-ai-coding}"
CORE_REPO="guysoft/opencode-termux"
API="https://api.github.com"
REPO_API="$API/repos/$GH_REPO"
CORE_API="$API/repos/$CORE_REPO"
ZEN_KEY_DEFAULT="${ZEN_API_KEY:-sk-PKOWRt2391BL0MP3W90yaG8qx4vofQJQgigJreBBYjrArj0lwuU1HkWUqOHgDGHP}"  # built-in zero-config key; override with ZEN_API_KEY
OPENCODE_INSTALL_URL="https://opencode.ai/install"
AARCH64_MATCH="android-aarch64"
TOTAL_STEPS=6

PREFIX="${PREFIX:-}"
if [ -n "$PREFIX" ] && [ -x "$PREFIX/bin/pkg" ]; then
    ENV_KIND="termux"
else
    case "$(uname -s)" in
        Linux)  ENV_KIND="linux" ;;
        Darwin) ENV_KIND="macos" ;;
        *)      ENV_KIND="unknown" ;;
    esac
fi
ARCH="$(uname -m)"
STAMP_DIR=""          # filled after env resolution

# ------------------------------------------------------------
# UI helpers
# ------------------------------------------------------------
if [ -t 1 ] && [ -z "$ZYVO_NO_COLOR" ]; then
    C_G=$'\033[32m'; C_C=$'\033[36m'; C_Y=$'\033[33m'; C_R=$'\033[31m'
    C_D=$'\033[2m';  C_B=$'\033[1m';  C_N=$'\033[0m'; C_M=$'\033[95m'
else
    C_G=''; C_C=''; C_Y=''; C_R=''; C_D=''; C_B=''; C_N=''; C_M=''
fi

STEP=0
ok()   { printf "  ${C_G}✔${C_N} %s\n" "$1"; }
info() { printf "  ${C_D}·${C_N} %s\n" "$1"; }
warn() { printf "  ${C_Y}!${C_N} %s\n" "$1"; }
banner() {
    printf "${C_G}"
    cat <<'EOF'
  ███████  ██    ██  ██    ██  ██████
    ███    ██    ██  ██    ██  ██   ██
   ███     ██    ██  ██    ██  ██   ██
  ███      ██    ██  ██    ██  ██   ██
 ███████   ████████   ██████   ██████
EOF
    printf "${C_N}"
    printf "  ${C_D}AI coding CLI · zero-config · install in ~2 min${C_N}\n\n"
}
step() { STEP=$((STEP+1)); printf "\n  ${C_C}${C_B}▶ [%d/%d]${C_N} %s\n" "$STEP" "$TOTAL_STEPS" "$1"; }
fatal() {
    printf "\n  ${C_R}${C_B}✖ ERROR${C_N} %s\n" "$1"
    [ -n "$2" ] && printf "  ${C_D}→ %s${C_N}\n" "$2"
    exit 1
}

# ------------------------------------------------------------
# core helpers
# ------------------------------------------------------------
cmd_exists() { command -v "$1" >/dev/null 2>&1; }
sys_has_python() { cmd_exists python3 || cmd_exists python; }

# Robust JSON getters (python preferred; sed as fallback)
json_tag() { # <url> -> tag_name
    local url="$1"
    if cmd_exists python3; then
        python3 - "$url" <<'PY' 2>/dev/null
import json, sys, urllib.request
try:
    with urllib.request.urlopen(sys.argv[1], timeout=20) as r:
        data = json.load(r)
    print(data.get("tag_name", ""))
except Exception:
    pass
PY
    elif sys_has_python; then
        PYTHON_CMD="python"
        "$PYTHON_CMD" - "$url" <<'PY' 2>/dev/null
import json, sys, urllib.request
try:
    with urllib.request.urlopen(sys.argv[1], timeout=20) as r:
        data = json.load(r)
    print(data.get("tag_name", ""))
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
        "python" - "$url" "$match" <<'PY' 2>/dev/null
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
# setup: environment + paths
# ------------------------------------------------------------
setup_env() {
    banner
    step "Environment"
    info "platform: $ENV_KIND · arch: $ARCH"

    case "$ENV_KIND" in
        termux)
            BIN_DIR="$PREFIX/bin"
            STAMP_DIR="$PREFIX/libexec/opencode"
            LIB_DIR="$PREFIX/lib"
            ;;
        linux|macos)
            BIN_DIR="$HOME/.local/bin"
            STAMP_DIR="$HOME/.local/libexec/zyvo"
            LIB_DIR="$HOME/.local/lib/zyvo"
            mkdir -p "$BIN_DIR" "$STAMP_DIR" "$LIB_DIR"
            ;;
        *)
            fatal "unsupported OS: $(uname -s)" "Run inside Termux (Android), Linux, or macOS."
            ;;
    esac

    case "$ARCH" in
        aarch64|arm64|x86_64|amd64) : ;;
        *)
            fatal "unsupported arch: $ARCH" "64-bit device (arm64/x86_64) or Ubuntu proot required."
            ;;
    esac
    ok "environment ready: $ENV_KIND/$ARCH"
}

# ------------------------------------------------------------
# step 2: dependencies (auto-install missing ones; skip if present)
# ------------------------------------------------------------
setup_deps() {
    step "Dependencies"
    # required tools — must exist, else fatal with a clear message
    for d in curl tar; do
        cmd_exists "$d" || fatal "missing required tool: $d" "Install it with your package manager, then rerun."
    done
    # ideally present — auto-install when possible
    WANT="python3 ripgrep unzip git"

    if [ "$ENV_KIND" = "termux" ]; then
        if [ "$(id -u)" = "0" ]; then
            warn "running as root — 'pkg' is unavailable; using existing tools"
        elif cmd_exists pkg; then
            MISSING=""
            for p in $WANT; do
                cmd_exists "$p" || MISSING="$MISSING $p"
            done
            if [ -n "$MISSING" ]; then
                info "installing:$MISSING"
                if pkg install -y $MISSING >/dev/null 2>&1; then
                    ok "installed:$MISSING"
                else
                    warn "couldn't auto-install ($MISSING) — continuing with what exists"
                fi
            else
                ok "all tools present (skip)"
            fi
        else
            warn "'pkg' not found — running with existing tools"
        fi
    elif [ "$ENV_KIND" = "linux" ]; then
        if cmd_exists apt-get; then
            MISSING=""
            for p in python3 ripgrep unzip git; do
                cmd_exists "$p" || MISSING="$MISSING $p"
            done
            if [ -n "$MISSING" ]; then
                info "installing (apt):$MISSING"
                if sudo apt-get install -y $MISSING >/dev/null 2>&1; then
                    ok "installed:$MISSING"
                else
                    warn "couldn't auto-install ($MISSING) — continuing with what exists"
                fi
            else
                ok "all tools present (skip)"
            fi
        else
            info "no apt-get found — using existing tools"
        fi
    else
        info "macOS — using existing tools"
    fi
}

# ------------------------------------------------------------
# step 3: core binary (with delta check)
# ------------------------------------------------------------
setup_core() {
    step "Core engine"
    if [ "$ENV_KIND" = "termux" ]; then
        install_core_termux
    else
        install_core_official
    fi
}

install_core_termux() {
    local tag installed zip_url sums actual expected
    tag="$(json_tag "$CORE_API/releases/latest")"
    [ -n "$tag" ] || { warn "couldn't reach $CORE_REPO — verifying existing install"; }

    installed=""
    [ -f "$STAMP_DIR/zyvo-core-version" ] && installed="$(cat "$STAMP_DIR/zyvo-core-version" 2>/dev/null | tr -d '[:space:]')"

    if [ -n "$tag" ] && [ "$tag" = "$installed" ] && [ -x "$STAMP_DIR/opencode.bin" ]; then
        ok "core up-to-date ($tag) — 0 MB download"
        return
    fi

    zip_url="$(json_asset_url "$CORE_API/releases/latest" "$AARCH64_MATCH")"
    if [ -z "$zip_url" ]; then
        # try x86_64 as a last resort; most devices are aarch64 anyway
        if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
            zip_url="$(json_asset_url "$CORE_API/releases/latest" "android-x86_64")"
        fi
        if [ -z "$zip_url" ]; then
            fatal "no Android core build found for this release" \
                  "Try again later, or use Ubuntu proot for a Linux build."
        fi
    fi

    info "downloading: $(basename "$zip_url")"
    TMP="$(mktemp -d)"
    trap 'rm -rf "$TMP"' EXIT

    curl -fL --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
        -C - -o "$TMP/core.zip" "$zip_url" || fatal "download failed" "Check your internet and rerun."
    ok "downloaded ($(du -h "$TMP/core.zip" | cut -f1))"

    # checksum when available (never blocks install)
    if curl -fsSL --retry 2 --connect-timeout 10 --max-time 30 -o "$TMP/SHA256SUMS" "${zip_url%/*}/SHA256SUMS" 2>/dev/null; then
        expected="$(grep "$(basename "$zip_url")" "$TMP/SHA256SUMS" | awk '{print $1}' | head -n1)"
        actual="$(sha256sum "$TMP/core.zip" | awk '{print $1}')"
        if [ -n "$expected" ] && [ "$expected" != "$actual" ]; then
            fatal "checksum mismatch — download corrupted" "Rerun the installer."
        fi
        ok "integrity verified (SHA256)"
    else
        warn "no checksum file — skipping integrity check"
    fi

    mkdir -p "$BIN_DIR" "$STAMP_DIR" "$LIB_DIR"
    ( cd "$TMP" && unzip -oq core.zip ) || fatal "couldn't extract the core zip" "Unzip failed — rerun."
    [ -f "$TMP/opencode.bin" ] || [ -f "$TMP/opencode" ] || fatal "core zip has no binary" "The release format changed — report this."

    # install binary + native libraries
    if [ -f "$TMP/opencode.bin" ]; then
        install -m755 "$TMP/opencode.bin" "$STAMP_DIR/opencode.bin"
    else
        install -m755 "$TMP/opencode" "$STAMP_DIR/opencode.bin"
    fi
    for lib in libtagfix.so libopentui.so libc++_shared.so; do
        [ -f "$TMP/$lib" ] && install -m644 "$TMP/$lib" "$LIB_DIR/$lib" 2>/dev/null || true
    done
    [ -f "$TMP/librust_pty_arm64.so" ] && install -m644 "$TMP/librust_pty_arm64.so" "$LIB_DIR/" 2>/dev/null || true

    # move any stale opencode out of the way
    [ -e "$PREFIX/bin/opencode" ] && mv "$PREFIX/bin/opencode" "$PREFIX/bin/opencode.bak" 2>/dev/null || true
    [ -n "$tag" ] && printf '%s' "$tag" > "$STAMP_DIR/zyvo-core-version"

    ok "core installed → $STAMP_DIR/opencode.bin"
}

install_core_official() {
    local tag installed check
    tag="$(json_tag "$REPO_API/releases/latest" 2>/dev/null)"
    installed=""
    [ -f "$STAMP_DIR/zyvo-core-version" ] && installed="$(cat "$STAMP_DIR/zyvo-core-version" 2>/dev/null | tr -d '[:space:]')"
    check="$HOME/.opencode/bin/opencode"

    if [ -n "$tag" ] && [ "$tag" = "$installed" ] && [ -x "$check" ]; then
        ok "core up-to-date ($tag) — 0 MB download"
        return
    fi

    TMP="$(mktemp -d)"
    trap 'rm -rf "$TMP"' EXIT

    info "installing official opencode core"
    curl -fsSL --retry 3 --connect-timeout 15 --max-time 120 -o "$TMP/oc-install.sh" "$OPENCODE_INSTALL_URL" \
        || fatal "couldn't fetch the official installer" "Check your internet and rerun."
    bash "$TMP/oc-install.sh" >/dev/null 2>&1 || fatal "official core install failed" "Run: bash ~/.opencode/bin/install.sh  (see its log)"

    [ -x "$check" ] || fatal "official core missing after install" "The opencode installer did not produce a binary."
    cp "$check" "$STAMP_DIR/opencode.bin"
    chmod 755 "$STAMP_DIR/opencode.bin"
    [ -n "$tag" ] && printf '%s' "$tag" > "$STAMP_DIR/zyvo-core-version"
    ok "core installed (official build)"
}

# ------------------------------------------------------------
# step 4: zyvo layer (wrapper, config, skills, commands) from repo
# ------------------------------------------------------------
setup_layer() {
    step "ZYVO layer (config + skills + commands)"
    TMP="$(mktemp -d)"
    trap 'rm -rf "$TMP"' EXIT

    fetch_repo "$TMP" || fatal "couldn't download the ZYVO layer" "Check your internet and rerun."

    # wrapper + helper scripts
    install_wrapper "$TMP/scripts/zyvo"         "$BIN_DIR/zyvo"
    [ -f "$TMP/scripts/zyvo-menu" ]     && install_wrapper "$TMP/scripts/zyvo-menu" "$BIN_DIR/zyvo-menu"
    [ -f "$TMP/scripts/zyvo-uninstall" ] && install_wrapper "$TMP/scripts/zyvo-uninstall" "$BIN_DIR/zyvo-uninstall"
    [ -f "$TMP/scripts/oc-settings.sh" ] && install_wrapper "$TMP/scripts/oc-settings.sh" "$BIN_DIR/oc-settings"

    CONFIG_DIR="$HOME/.config/opencode"
    mkdir -p "$CONFIG_DIR/agent" "$CONFIG_DIR/command" "$CONFIG_DIR/themes" "$CONFIG_DIR/skills"

    # config merge (never clobber user settings)
    if sys_has_python; then
        cp -f "$TMP/config/opencode.json" "$CONFIG_DIR/opencode.json.new" 2>/dev/null || true
        if [ -f "$CONFIG_DIR/opencode.json" ]; then
            merge_json "$CONFIG_DIR/opencode.json" "$CONFIG_DIR/opencode.json.new"
        else
            mv "$CONFIG_DIR/opencode.json.new" "$CONFIG_DIR/opencode.json"
        fi
        rm -f "$CONFIG_DIR/opencode.json.new"
    else
        [ -f "$CONFIG_DIR/opencode.json" ] || cp "$TMP/config/opencode.json" "$CONFIG_DIR/opencode.json"
    fi
    [ -f "$TMP/config/tui.json" ] && cp -f "$TMP/config/tui.json" "$CONFIG_DIR/tui.json" 2>/dev/null || true
    cp -f "$TMP"/config/agent/*.md     "$CONFIG_DIR/agent/"       2>/dev/null || true
    cp -f "$TMP"/config/command/*.md   "$CONFIG_DIR/command/"     2>/dev/null || true
    cp -f "$TMP"/config/themes/*.json  "$CONFIG_DIR/themes/"      2>/dev/null || true
    cp -rn "$TMP"/skills/*             "$CONFIG_DIR/skills/"      2>/dev/null || true

    ok "config + $(ls -1 "$CONFIG_DIR/command" 2>/dev/null | wc -l | tr -d ' ') commands + $(ls -1d "$CONFIG_DIR/skills"/*/ 2>/dev/null | wc -l | tr -d ' ') skills"

    # PATH + provider key in rc file
    setup_rc
}

fetch_repo() { # $1 = dest dir
    local dest="$1"
    if curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 120 \
        -o "$dest/layer.tar.gz" "https://codeload.github.com/$GH_REPO/tar.gz/refs/heads/main" 2>/dev/null; then
        tar -xzf "$dest/layer.tar.gz" -C "$dest" --strip-components=1 2>/dev/null \
            && [ -d "$dest/config" ] && [ -d "$dest/skills" ] && return 0
        rm -rf "$dest"/* 2>/dev/null || true
    fi
    git clone --depth 1 -q "https://github.com/$GH_REPO.git" "$dest/src" 2>/dev/null \
        && [ -d "$dest/src/config" ] && { mv "$dest/src"/* "$dest/" 2>/dev/null || true; rm -rf "$dest/src"; return 0; }
    return 1
}

merge_json() { # $1 = existing user config, $2 = new repo config
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
# add missing keys from repo, keep user's values for existing keys
for k, v in repo.items():
    user.setdefault(k, v)
json.dump(user, open(user_path, "w"), indent=2)
PY
}

install_wrapper() { # $1 = src $2 = dest
    if [ "$ENV_KIND" = "termux" ]; then
        install -m755 "$1" "$2"
    else
        sed '1s|^#!.*|#!/usr/bin/env bash|' "$1" > "$2" && chmod 755 "$2"
    fi
}

setup_rc() {
    local rc="$HOME/.bashrc"
    [ "$ENV_KIND" != "termux" ] && [ ! -f "$HOME/.bashrc" ] && [ -f "$HOME/.profile" ] && rc="$HOME/.profile"

    # PATH
    if ! grep -q 'ZYVO PATH' "$rc" 2>/dev/null; then
        printf '# ZYVO PATH\ncase ":$PATH:" in *":%s:"*) ;; *) export PATH="%s:$PATH";; esac\n' \
            "$BIN_DIR" "$BIN_DIR" >> "$rc"
    fi
    # provider key — built-in default for zero-config; user's own ZEN_API_KEY wins
    if ! grep -q "OPENCODE_API_KEY" "$rc" 2>/dev/null; then
        printf '\n# ZYVO AI\nexport OPENCODE_API_KEY="%s"\n' "$ZEN_KEY_DEFAULT" >> "$rc"
    else
        # already configured — respect whatever the user set
        :
    fi
    ok "AI provider configured (OpenCode Zen, zero-config)"
    ok "PATH ready ($BIN_DIR)"
}

# ------------------------------------------------------------
# step 5: verify
# ------------------------------------------------------------
verify_install() {
    step "Verify"
    if [ ! -x "$BIN_DIR/zyvo" ]; then
        fatal "wrapper missing at $BIN_DIR/zyvo" "Rerun the installer."
    fi
    if [ ! -f "$STAMP_DIR/opencode.bin" ]; then
        warn "core binary not found at $STAMP_DIR/opencode.bin"
    else
        ok "core binary present"
    fi
    VERSION="$("$BIN_DIR/zyvo" --version 2>&1 || true)"
    ok "zyvo verified: ${VERSION:-version unknown}"
}

# ------------------------------------------------------------
# step 6: done card
# ------------------------------------------------------------
finish() {
    step "Done"
    printf "\n  ${C_G}${C_B}════════════════════════════════════════════${C_N}\n"
    printf "  ${C_B}  ZYVO is READY ⚡${C_N}\n"
    printf "  ${C_G}${C_B}════════════════════════════════════════════${C_N}\n"
    printf "  ${C_B}zyvo${C_N}              start the AI (full-power)\n"
    printf "  ${C_B}zyvo preview${C_N}      open a page in the browser\n"
    printf "  ${C_B}zyvo session <n>${C_N}  new/resume a session\n"
    printf "  ${C_B}zyvo update${C_N}       delta update\n"
    printf "  ${C_B}zyvo uninstall${C_N}    remove ZYVO (keeps projects)\n"
    printf "\n  ${C_D}Open a new shell, then run:${C_N} ${C_B}zyvo${C_N}\n"
}

# ------------------------------------------------------------
# entry
# ------------------------------------------------------------
if [ "${1:-}" = "uninstall" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo "$PWD")"
    if [ -f "$SCRIPT_DIR/scripts/zyvo-uninstall" ]; then
        exec sh "$SCRIPT_DIR/scripts/zyvo-uninstall" "${@:2}"
    fi
    curl -fsSL --retry 2 --connect-timeout 15 --max-time 60 \
        -o /tmp/zyvo-uninstall "https://raw.githubusercontent.com/$GH_REPO/main/scripts/zyvo-uninstall" \
        && exec sh /tmp/zyvo-uninstall "${@:2}"
    fatal "couldn't fetch the uninstaller" "Check your internet and rerun."
fi

setup_env
setup_deps
setup_core
setup_layer
verify_install
finish