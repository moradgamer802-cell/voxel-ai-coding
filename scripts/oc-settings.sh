#!/data/data/com.termux/files/usr/bin/bash
# oc-settings — ZYVO model tier + permission switcher
# Usage:
#   oc-settings            (menu)
#   oc-settings model      (menu: max/mid/ultra/tiny)
#   oc-settings model <tier>
#   oc-settings auto on    (enable auto-approve permissions)
#   oc-settings auto off|safe   (disable auto-approve, ask mode)
#   oc-settings apply      (config abar likhe, restart required)
set -e

CONFIG_DIR="${HOME}/.config/opencode"
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
PERM="ask"

saved_model() {
    [ -f "$CONFIG_DIR/opencode.json" ] && sed -n 's/.*"model"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG_DIR/opencode.json" | head -n1
}
saved_small() {
    [ -f "$CONFIG_DIR/opencode.json" ] && sed -n 's/.*"small_model"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG_DIR/opencode.json" | head -n1
}

# Surgical JSON edit: shudhu model/permission keys change hoy, baki sob
# (provider, apiKey, auth) preserve hoy. opencode.json + opencode.jsonc
# duitai update hoy, jate config merge korte na pare.
apply_config() {
    # $1 = bash/edit perm ("ask"|"allow"), $2 = model (""=thakbe), $3 = small_model
    python3 - "$CONFIG_DIR" "$USERNAME" "$AGENT" "$1" "$2" "$3" <<'PY'
import json, os, sys
d, user, agent, perm, model, small = sys.argv[1:7]
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
cfg.setdefault("permission", {})["bash"] = perm
cfg["permission"]["edit"] = perm
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
    echo "  Model tier select koro:"
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

case "${1:-}" in
    model|max|default|mid|medium|ultra|strong|tiny)
        pick_model "$MODEL" "${2:-}"
        apply_config "$PERM" "$MODEL" "$SMALL"
        echo
        echo "Config updated (model+saved settings preserve hoyeche):"
        echo "  model:       $MODEL"
        echo "  small_model: $SMALL"
        echo "NOTE: opencode restart koro (config load hoy startup e)."
        ;;
    auto)
        case "${2:-on}" in
            on|1|allow)
                apply_config "allow" "" ""
                echo
                echo "AUTO-APPROVE ON  (permission: bash/edit = allow)"
                echo "  Warning: AI ekhon joto kichhu chaibe chalaite parbe —"
                echo "  rm -rf, curl|sh, git push... sensitive command e satark thako."
                echo "  Band: oc-settings safe   (ba /safe TUI command)"
                echo "NOTE: zyvo restart korle prompt ar ashbe na."
                ;;
            off|0|no|ask|safe)
                apply_config "ask" "" ""
                echo
                echo "ASK-MODE ON (permission: bash/edit = ask) — secure."
                echo "NOTE: zyvo restart korle prompt abar ashbe."
                ;;
            *) echo "Usage: oc-settings auto on|off|safe"; exit 1;;
        esac
        ;;
    apply)
        apply_config "$PERM" "$(saved_model)" "$(saved_small)"
        echo
        echo "Config re-written (existing model/provider preserved)."
        echo "NOTE: opencode restart koro (config load hoy startup e)."
        ;;
    ls|models|list)
        echo "Free zen models:"
        curl -fsSL -m 15 "https://opencode.ai/zen/v1/models" 2>/dev/null \
            | grep -o '"id":"[^"]*free[^"]*"' | sed 's/.*"id":"\([^"]*\)".*/\1/' || echo "(network problem)"
        ;;
    -h|--help|help|"")
        sed -n '2,10p' "$0"
        ;;
    *)
        echo "Unknown: $1"
        sed -n '2,10p' "$0"
        exit 1
        ;;
esac