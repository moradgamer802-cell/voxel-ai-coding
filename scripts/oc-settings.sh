#!/data/data/com.termux/files/usr/bin/bash
# oc-settings — ZYVO model tier + permission switcher
# Usage:
#   oc-settings                 (menu)
#   oc-settings model           (menu: max/mid/ultra/tiny)
#   oc-settings model <tier>
#   oc-settings perm            (menu: ask / always allow / deny / session)
#   oc-settings perm ask        (sob ask — safe default)
#   oc-settings perm allow      (Always Allow — bash/edit/webfetch persistent allow)
#   oc-settings perm deny       (bash deny — AI command chalate parbe na, read-only)
#   oc-settings auto on         (config-mode session allow — --safe run er jonno)
#   oc-settings auto off        (safe: session off + ask mode)
#   oc-settings session on      (in-chat session mode ON — /auto er kaj)
#   oc-settings session off     (restore — purano permission mode e fire)
#   oc-settings safe            (session off + ask mode — full safe)
#   oc-settings apply           (config abar likhe, restart required)
set -e

CONFIG_DIR="${HOME}/.config/opencode"
STATE_FILE="$CONFIG_DIR/zyvo-session-state.json"
BAK_FILE="$CONFIG_DIR/opencode.json.zyvo-session-bak"
AGENT="build"
USERNAME="deshi-dev"

# Model prefix follows the config that is already in use (opencode|zyvo),
# so existing provider/auth setup kichhu na bhenge.
MODEL_PREFIX="zyvo"
if [ -f "$CONFIG_DIR/opencode.json" ]; then
    CUR="$(sed -n 's/.*"model"[[:space:]]*:[[:space:]]*"\([^\/]*\)\/.*/\1/p' "$CONFIG_DIR/opencode.json" | head -n1)"
    [ -n "$CUR" ] && MODEL_PREFIX="$CUR"
fi

MODEL="${MODEL_PREFIX}/deepseek-v4-flash-free"
SMALL="${MODEL_PREFIX}/ling-3.0-tiny-free"

saved_model() {
    [ -f "$CONFIG_DIR/opencode.json" ] && sed -n 's/.*"model"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG_DIR/opencode.json" | head -n1
}
saved_small() {
    [ -f "$CONFIG_DIR/opencode.json" ] && sed -n 's/.*"small_model"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG_DIR/opencode.json" | head -n1
}

# Surgical JSON edit: shudhu model/permission keys change hoy, baki sob
# (provider, apiKey, auth) preserve hoy. opencode.json + opencode.jsonc
# duitai update hoy, jate config merge korte na pare.
apply_perms() {
    # $1 = bash perm, $2 = edit perm, $3 = webfetch perm ("ask"|"allow"|"deny")
    # $4 = model (""=thakbe), $5 = small_model
    python3 - "$CONFIG_DIR" "$USERNAME" "$AGENT" "$1" "$2" "$3" "$4" "$5" <<'PY'
import json, os, sys
d, user, agent, pb, pe, pw, model, small = sys.argv[1:9]
files = [os.path.join(d, "opencode.json"), os.path.join(d, "opencode.jsonc")]
cfg = {}
for f in files:
    if os.path.exists(f):
        try:
            cfg = json.load(open(f))
            break
        except Exception:
            continue
cfg.setdefault("username", user)
cfg.setdefault("default_agent", agent)
cfg.setdefault("permission", {})["bash"] = pb
cfg["permission"]["edit"] = pe
cfg["permission"]["webfetch"] = pw
if model:
    cfg["model"] = model
if small:
    cfg["small_model"] = small
os.makedirs(d, exist_ok=True)
for f in files:
    with open(f, "w") as fh:
        json.dump(cfg, fh, indent=2)
        fh.write("\n")
PY
}

apply_config() { # back-compat wrapper: $1 = bash/edit perm, $2 = model, $3 = small
    apply_perms "$1" "$1" "$1" "$2" "$3"
}

current_perm() {
    [ -f "$CONFIG_DIR/opencode.json" ] && \
        sed -n 's/.*"bash"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG_DIR/opencode.json" | head -n1
}

perm_read() { # $1=key (bash|edit|webfetch)
    [ -f "$CONFIG_DIR/opencode.json" ] && \
        sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$CONFIG_DIR/opencode.json" | head -n1
}

session_active() {
    echo "${OPENCODE_CONFIG:-}" | grep -q "zyvo-session-perm.json" && return 0
    [ -f "$STATE_FILE" ] && return 0
    return 1
}

session_on() {
    if echo "${OPENCODE_CONFIG:-}" | grep -q "zyvo-session-perm.json"; then
        echo "ALREADY ON (yolo mode)"
        return 0
    fi
    if [ -f "$STATE_FILE" ]; then
        echo "ALREADY ON"
        return 0
    fi
    command -v python3 >/dev/null 2>&1 || { echo "ERROR: python3 lagbe (pkg install python3)"; return 1; }
    local pb pe pw
    pb="$(perm_read bash)"; [ -z "$pb" ] && pb=ask
    pe="$(perm_read edit)"; [ -z "$pe" ] && pe=ask
    pw="$(perm_read webfetch)"; [ -z "$pw" ] && pw=ask
    mkdir -p "$CONFIG_DIR"
    printf '{\n  "bash": "%s",\n  "edit": "%s",\n  "webfetch": "%s",\n  "pid": %s\n}\n' \
        "$pb" "$pe" "$pw" "${ZYVO_PID:-0}" > "$STATE_FILE"
    [ -f "$CONFIG_DIR/opencode.json" ] && cp "$CONFIG_DIR/opencode.json" "$BAK_FILE"
    apply_perms allow allow allow "" ""
    echo "SESSION ON"
    echo "HINT: jodi prompt ekhono ashe — zyvo ekbar restart (config save kora ache, restart er por prompt ashbe na)"
}

session_restore() {
    if [ ! -f "$STATE_FILE" ] && [ ! -f "$BAK_FILE" ]; then
        echo "OFF (session mode chalu chilo na)"
        return 0
    fi
    if [ -f "$STATE_FILE" ] && command -v python3 >/dev/null 2>&1; then
        python3 - "$CONFIG_DIR" "$STATE_FILE" <<'PY'
import json, os, sys
d, state = sys.argv[1], sys.argv[2]
try:
    vals = json.load(open(state))
except Exception:
    vals = {}
targets = [os.path.join(d, "opencode.json")]
jsonc = os.path.join(d, "opencode.jsonc")
if os.path.exists(jsonc):
    targets.append(jsonc)
for cfgp in targets:
    cfg = {}
    try:
        cfg = json.load(open(cfgp))
    except Exception:
        pass
    perm = cfg.setdefault("permission", {})
    for k in ("bash", "edit", "webfetch"):
        if k in vals:
            perm[k] = vals[k]
    cfg["permission"] = perm
    with open(cfgp, "w") as fh:
        json.dump(cfg, fh, indent=2)
        fh.write("\n")
PY
        rm -f "$STATE_FILE" "$BAK_FILE"
        echo "RESTORED"
    elif [ -f "$BAK_FILE" ]; then
        mv "$BAK_FILE" "$CONFIG_DIR/opencode.json"
        rm -f "$STATE_FILE"
        echo "RESTORED (backup theke)"
    else
        rm -f "$STATE_FILE" "$BAK_FILE"
        apply_perms ask ask ask "" "" >/dev/null
        echo "RESTORED (default ask)"
    fi
}

session_info() {
    echo
    echo "  SESSION PERMISSION — ei session e prompt ashbe kina"
    echo "  ─────────────────────────────────────────────"
    if echo "${OPENCODE_CONFIG:-}" | grep -q "zyvo-session-perm.json"; then
        echo "  Status: AUTO-ALLOW ON (zyvo default mode)"
        echo "  Kono permission prompt ashbe na."
        echo "  Prompt chaile: zyvo --safe diye chalao."
    elif [ -f "$STATE_FILE" ]; then
        echo "  Status: AUTO-ALLOW ON (config mode — oc-settings auto on)"
        echo "  Zyvo exit korle auto restore hobe."
    else
        echo "  Status: PROMPT MODE (zyvo --safe / global config ask)"
        echo "  Allow once / Always allow / Reject dialog ashbe."
        echo "  Auto-allow e firte: normal zyvo diye chalao."
        echo "  Sob session e allow chaile: oc-settings perm allow"
    fi
}

perm_menu() {
    echo
    echo "  Permission mode select koro  [config: $(current_perm || echo '?')]"
    echo "  (zyvo normal mode = auto-allow; ei config --safe mode e kaj kore)"
    echo "  1) Ask (safe)           — sob kaj e prompt korbe"
    echo "  2) Always Allow         — bash/edit/webfetch permanent allow (prompt chhara)"
    echo "  3) Deny bash (readonly) — AI command chalate parbe na (read/edit kaj kore)"
    echo "  4) Session status       — ekhon prompt ashbe kina"
    echo -n "  [1-4]: "
    read -r CHOICE || CHOICE=""
    case "$CHOICE" in
        1) perm_apply ask;;
        2) perm_apply allow;;
        3) perm_apply deny;;
        4) session_info; return;;
        *) echo "  Kichhu change hoy nai."; return;;
    esac
}

perm_apply() {
    case "$1" in
        ask)
            apply_perms ask ask ask "" ""
            echo
            echo "  ASK-MODE ON (bash/edit/webfetch = ask) — secure, sob kaj e prompt ashbe."
            ;;
        allow)
            apply_perms allow allow allow "" ""
            echo
            echo "  ALWAYS ALLOW ON  (bash/edit/webfetch = allow — persistent)"
            echo "  Warning: AI ekhon joto kichhu chaibe chalaite parbe —"
            echo "  rm -rf, curl|sh, git push... sensitive command e satark thako."
            echo "  Band: oc-settings perm ask   (ba /safe TUI command)"
            ;;
        deny)
            apply_perms deny ask ask "" ""
            echo
            echo "  DENY-BASH ON — AI shell command chalate parbe na (file read/edit kaj kore)."
            echo "  Faka ashte: oc-settings perm ask"
            ;;
        *) echo "Usage: oc-settings perm ask|allow|deny"; exit 1;;
    esac
    echo "  NOTE: zyvo restart korle effect hobe (config startup e load hoy)."
}

pick_model() {
    local prev="$1"
    local TIER_ARG="${2:-}"
    case "$TIER_ARG" in
        max|default|flash) MODEL="${MODEL_PREFIX}/deepseek-v4-flash-free"; SMALL="${MODEL_PREFIX}/ling-3.0-tiny-free"; return;;
        mid|medium) MODEL="${MODEL_PREFIX}/mimo-v2.5-free"; SMALL="${MODEL_PREFIX}/ling-3.0-tiny-free"; return;;
        ultra|strong) MODEL="${MODEL_PREFIX}/nemotron-3-ultra-free"; SMALL="${MODEL_PREFIX}/ling-3.0-tiny-free"; return;;
        tiny) MODEL="${MODEL_PREFIX}/ling-3.0-tiny-free"; SMALL="$MODEL"; return;;
        *) ;;
    esac
    echo
    echo "  Model tier select karo:"
    echo "  1) Max (default)    : ${MODEL_PREFIX}/deepseek-v4-flash-free"
    echo "  2) Mid (balanced)   : ${MODEL_PREFIX}/mimo-v2.5-free"
    echo "  3) Ultra (strong)   : ${MODEL_PREFIX}/nemotron-3-ultra-free"
    echo "  4) Tiny (smallest)  : ${MODEL_PREFIX}/ling-3.0-tiny-free"
    echo "  5) Custom ID        (e.g. ${MODEL_PREFIX}/gpt-5.5)"
    echo -n "  [1-5, Enter thakbe - $prev]: "
    read -r CHOICE || CHOICE=0
    case "$CHOICE" in
        1) MODEL="${MODEL_PREFIX}/deepseek-v4-flash-free"
           SMALL="${MODEL_PREFIX}/ling-3.0-tiny-free";;
        2) MODEL="${MODEL_PREFIX}/mimo-v2.5-free"
           SMALL="${MODEL_PREFIX}/ling-3.0-tiny-free";;
        3) MODEL="${MODEL_PREFIX}/nemotron-3-ultra-free"
           SMALL="${MODEL_PREFIX}/ling-3.0-tiny-free";;
        4) MODEL="${MODEL_PREFIX}/ling-3.0-tiny-free"
           SMALL="${MODEL_PREFIX}/ling-3.0-tiny-free";;
        5) echo -n "  Model ID: "; read -r CUSTOM
           [ -n "$CUSTOM" ] && MODEL="$CUSTOM"
           echo -n "  Small Model ID (Enter thakbe): "; read -r CSMALL
           [ -n "$CSMALL" ] && SMALL="$CSMALL";;
        *) echo "  Purono thaklo.";;
    esac
}

main_menu() {
    echo
    echo "  ZYVO settings  [perm: $(current_perm || echo '?')]"
    echo "  1) Model tier    (max / mid / ultra / tiny)"
    echo "  2) Permission    (ask / always allow / deny / session)"
    echo "  3) Session mode  (always allow — ei session only)"
    echo "  4) Free models list"
    echo -n "  [1-4]: "
    read -r CHOICE || CHOICE=""
    case "$CHOICE" in
        1) pick_model "$MODEL"; apply_perms "$(current_perm || echo ask)" "$(current_perm || echo ask)" "$(current_perm || echo ask)" "$MODEL" "$SMALL"
           echo; echo "  model: $MODEL / small: $SMALL — restart koro.";;
        2) perm_menu;;
        3) session_info;;
        4) "$0" models;;
        *) echo "  Bye.";;
    esac
}

case "${1:-}" in
    model|max|default|mid|medium|ultra|strong|tiny)
        pick_model "$MODEL" "${2:-}"
        PERM_NOW="$(current_perm || echo ask)"
        apply_perms "$PERM_NOW" "$PERM_NOW" "$PERM_NOW" "$MODEL" "$SMALL"
        echo
        echo "Config updated (model+saved settings preserve hoyeche):"
        echo "  model:       $MODEL"
        echo "  small_model: $SMALL"
        echo "NOTE: opencode restart koro (config load hoy startup e)."
        ;;
    perm|permission)
        if [ -n "${2:-}" ]; then perm_apply "$2"; else perm_menu; fi
        ;;
    session)
        case "${2:-}" in
            on) session_on ;;
            off|restore) session_restore ;;
            status) session_info ;;
            *) session_info ;;
        esac
        ;;
    safe)
        session_restore >/dev/null 2>&1 || true
        perm_apply ask
        echo "  (session mode + always-allow duitai off — sob prompt abar ashbe)"
        ;;
    auto)
        case "${2:-on}" in
            on|1|allow|session)
                session_on
                ;;
            off|0|no|ask|safe)
                session_restore >/dev/null 2>&1 || true
                perm_apply ask
                ;;
            *) echo "Usage: oc-settings auto on|off"; exit 1;;
        esac
        ;;
    apply)
        PERM_NOW="$(current_perm || echo ask)"
        apply_perms "$PERM_NOW" "$PERM_NOW" "$PERM_NOW" "$(saved_model)" "$(saved_small)"
        echo
        echo "Config re-written (existing model/provider preserved)."
        echo "NOTE: opencode restart koro (config load hoy startup e)."
        ;;
    ls|models|list)
        echo "Free zen models:"
        curl -fsSL -m 15 "https://opencode.ai/zen/v1/models" 2>/dev/null \
            | grep -o '"id":"[^"]*free[^"]*"' | sed 's/.*"id":"\([^"]*\)".*/\1/' || echo "(network problem)"
        ;;
    -h|--help|help)
        sed -n '2,17p' "$0"
        ;;
    "")
        main_menu
        ;;
    *)
        echo "Unknown: $1"
        sed -n '2,17p' "$0"
        exit 1
        ;;
esac
