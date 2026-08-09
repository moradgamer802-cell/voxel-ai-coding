#!/data/data/com.termux/files/usr/bin/bash
# oc-settings — OpenCode model tier + permission switcher
# Usage:
#   oc-settings            (menu)
#   oc-settings model      (menu: default/mid/max)
#   oc-settings model <tier>
#   oc-settings auto on    (enable auto-approve permissions)
#   oc-settings auto off   (disable auto-approve, ask mode)
#   oc-settings apply      (config abar likhe, restart required)
set -e

CONFIG_DIR="${HOME}/.config/opencode"
CONFIG="${CONFIG_DIR}/opencode.json"
AGENT="bangla"
USERNAME="deshi-dev"

MODEL="${OPENCODE_MODEL:-opencode/deepseek-v4-flash-free}"
SMALL="${OPENCODE_SMALL_MODEL:-opencode/ling-3.0-tiny-free}"
PERM="ask"

saved_model() {
    [ -f "$CONFIG" ] && sed -n 's/.*"model"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG" | head -n1
}
saved_small() {
    [ -f "$CONFIG" ] && sed -n 's/.*"small_model"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CONFIG" | head -n1
}

[ -z "$saved_model" ] && MODEL="$(saved_model || true)"
MODEL="$(saved_model || echo "$MODEL")"
SMALL="$(saved_small || echo "$SMALL")"

write_config() {
    mkdir -p "$CONFIG_DIR"
    if [ "$PERM" = "allow" ]; then
        PERM_RULE='"bash": "allow", "edit": "allow"'
    else
        PERM_RULE='"bash": "ask", "edit": "ask"'
    fi
    cat > "$CONFIG" <<EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "username": "$USERNAME",
  "model": "$MODEL",
  "small_model": "$SMALL",
  "default_agent": "$AGENT",
  "permission": {
    $PERM_RULE
  }
}
EOF
    echo
    echo "Config updated: $CONFIG"
    echo "  model:       $MODEL"
    echo "  small_model: $SMALL"
    echo "  permission:  $PERM"
    echo "NOTE: opencode restart koro (config load hoy startup e)."
}

pick_model() {
    local prev="$1"
    local TIER_ARG="${2:-}"
    case "$TIER_ARG" in
        tiny|default|fast) MODEL="opencode/ling-3.0-tiny-free"; SMALL="$MODEL"; return;;
        mid|medium|flash) MODEL="opencode/deepseek-v4-flash-free"; SMALL="opencode/ling-3.0-tiny-free"; return;;
        max|strong|ultra) MODEL="opencode/nemotron-3-ultra-free"; SMALL="opencode/ling-3.0-tiny-free"; return;;
        *) ;;
    esac
    echo
    echo "  Model tier select koro:"
    echo "  1) Default (fast)  : opencode/deepseek-v4-flash-free"
    echo "  2) Medium (balanced): opencode/mimo-v2.5-free"
    echo "  3) Max (strong)    : opencode/nemotron-3-ultra-free"
    echo "  4) Tiny (smallest) : opencode/ling-3.0-tiny-free"
    echo "  5) Custom ID        (e.g. opencode/gpt-5.5)"
    echo -n "  [1-5, Enter kibore thakbe - $prev]: "
    read -r CHOICE
    case "$CHOICE" in
        1) MODEL="opencode/deepseek-v4-flash-free"
           SMALL="opencode/ling-3.0-tiny-free";;
        2) MODEL="opencode/mimo-v2.5-free"
           SMALL="opencode/ling-3.0-tiny-free";;
        3) MODEL="opencode/nemotron-3-ultra-free"
           SMALL="opencode/ling-3.0-tiny-free";;
        4) MODEL="opencode/ling-3.0-tiny-free"
           SMALL="opencode/ling-3.0-tiny-free";;
        5) echo -n "  Model ID: "; read -r CUSTOM
           [ -n "$CUSTOM" ] && MODEL="$CUSTOM"
           echo -n "  Small Model ID (Enter thakbe): "; read -r CSMALL
           [ -n "$CSMALL" ] && SMALL="$CSMALL";;
        *) echo "  Purono thaklo.";;
    esac
}

case "${1:-}" in
    model|mid|default)
        pick_model "$MODEL" "${2:-}"
        write_config
        ;;
auto)
        case "${2:-on}" in
            on|1|allow) PERM="allow";;
            off|0|no|ask) PERM="ask";;
            *) echo "Usage: oc-settings auto on|off"; exit 1;;
        esac
        write_config
        ;;
    apply)
        write_config
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