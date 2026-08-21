#!/data/data/com.termux/files/usr/bin/bash
# oc-settings — BOOMCODE model tier switcher
# Usage:
#   oc-settings            (menu)
#   oc-settings model      (menu: max/mid/ultra/tiny)
#   oc-settings model <tier>
#   oc-settings apply      (rewrites the config)
set -e

CONFIG_DIR="${HOME}/.config/opencode"
AGENT="build"
USERNAME="boomcode-dev"

# Model ids are passed to the Zen API WITHOUT a provider prefix — the
# API only knows bare ids like "deepseek-v4-flash-free" (a prefixed
# "boomcode/deepseek-..." gets rejected with "not valid type").

MODEL="deepseek-v4-flash-free"
SMALL="laguna-s-2.1-free"

saved_model() {
    [ -f "$CONFIG_DIR/opencode.json" ] && sed -n 's/.*"model"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG_DIR/opencode.json" | head -n1
}
saved_small() {
    [ -f "$CONFIG_DIR/opencode.json" ] && sed -n 's/.*"small_model"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG_DIR/opencode.json" | head -n1
}

# Surgical JSON edit: only the model keys change; everything else
# (provider, apiKey, auth, permission) is preserved. Both opencode.json and
# opencode.jsonc are updated so config merging can't override the choice.
apply_model() { # $1 = model, $2 = small_model
    python3 - "$CONFIG_DIR" "$USERNAME" "$AGENT" "$1" "$2" <<'PY'
import json, os, sys
d, user, agent, model, small = sys.argv[1:6]
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
    # tier ladder: Low -> Mid -> High (default) -> Ultra -> Ultra+ (highest free)
    local prev="$1"
    local TIER_ARG="${2:-}"
    case "$TIER_ARG" in
        low|light|lightning|fast) MODEL="nemotron-3.5-lightning-free"; SMALL="laguna-s-2.1-free"; return;;
        mid|medium) MODEL="mimo-v2.5-free"; SMALL="laguna-s-2.1-free"; return;;
        high|max|flash|default|full) MODEL="deepseek-v4-flash-free"; SMALL="laguna-s-2.1-free"; return;;
        ultra|strong) MODEL="nemotron-3-ultra-free"; SMALL="laguna-s-2.1-free"; return;;
        ultra+|ultraplus|ultrahigher|higher) MODEL="x-preview-f-free"; SMALL="laguna-s-2.1-free"; return;;
        *) ;;
    esac
    echo
    echo "  Select a model tier (Low -> Mid -> High -> Ultra -> Ultra+):"
    echo "  1) Low      : nemotron-3.5-lightning-free [fastest, lightest]"
    echo "  2) Mid      : mimo-v2.5-free [balanced]"
    echo "  3) High     : deepseek-v4-flash-free [default — full-power, stable]"
    echo "  4) Ultra    : nemotron-3-ultra-free [biggest open model — some provider errors reported]"
    echo "  5) Ultra+   : x-preview-f-free [highest tier — frontier preview model]"
    echo "  6) Custom ID (e.g. gpt-5.5)"
    echo -n "  [1-6, Enter keeps - $prev]: "
    read -r CHOICE || CHOICE=0
    case "$CHOICE" in
        1) MODEL="nemotron-3.5-lightning-free"
           SMALL="laguna-s-2.1-free";;
        2) MODEL="mimo-v2.5-free"
           SMALL="laguna-s-2.1-free";;
        3) MODEL="deepseek-v4-flash-free"
           SMALL="laguna-s-2.1-free";;
        4) MODEL="nemotron-3-ultra-free"
           SMALL="laguna-s-2.1-free"
           echo "  Note: provider errors have been reported for this model — if it fails, run: oc-settings model high" ;;
        5) MODEL="x-preview-f-free"
           SMALL="laguna-s-2.1-free"
           echo "  Note: Ultra+ is a preview model — bleeding-edge, may change or rate-limit." ;;
        6) echo -n "  Model ID: "; read -r CUSTOM
           [ -n "$CUSTOM" ] && MODEL="$CUSTOM"
           echo -n "  Small Model ID (Enter keeps current): "; read -r CSMALL
           [ -n "$CSMALL" ] && SMALL="$CSMALL";;
        *) echo "  Keeping the current selection.";;
    esac
}

case "${1:-}" in
    model|ultra|ultra+|ultraplus|ultrahigher|higher|strong|max|flash|fast|lightning|low|light|mid|medium|default|high)
        pick_model "$MODEL" "${2:-}"
        apply_model "$MODEL" "$SMALL"
        echo
        echo "Config updated (model + saved settings preserved):"
        echo "  model:       $MODEL"
        echo "  small_model: $SMALL"
        echo "NOTE: restart boomcode (config is loaded at startup)."
        ;;
    apply)
        apply_model "$(saved_model)" "$(saved_small)"
        echo
        echo "Config re-written (existing model/provider preserved)."
        echo "NOTE: restart boomcode (config is loaded at startup)."
        ;;
    ls|models|list)
        echo "Free zen models:"
        curl -fsSL -m 15 "https://opencode.ai/zen/v1/models" 2>/dev/null \
            | grep -o '"id":"[^"]*free[^"]*"' | sed 's/.*"id":"\([^"]*\)".*/\1/' || echo "(network problem)"
        ;;
    -h|--help|help)
        sed -n '2,9p' "$0"
        ;;
    "")
        echo
        echo "  BOOMCODE settings"
        echo "  1) Model tier    (max / mid / ultra / tiny)"
        echo "  2) Free models list"
        echo -n "  [1-2]: "
        read -r CHOICE || CHOICE=""
        case "$CHOICE" in
            1) pick_model "$MODEL"; apply_model "$MODEL" "$SMALL"
               echo; echo "  model: $MODEL — restart boomcode.";;
            2) "$0" models;;
            *) echo "  Bye.";;
        esac
        ;;
    *)
        echo "Unknown: $1"
        sed -n '2,9p' "$0"
        exit 1
        ;;
esac