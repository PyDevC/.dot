#!/bin/bash
CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/skwd-wall/colors.json"
OUTPUT_FILE="$HOME/.config/waybar/colors.css"

if [ ! -f "$CACHE_FILE" ]; then
    echo "skwd-wall colors.json not found at $CACHE_FILE"
    exit 1
fi

FG=$(python3 -c "import json; d=json.load(open('$CACHE_FILE')); print(d.get('primary', '#ffffff'))")
FG_INACTIVE=$(python3 -c "import json; d=json.load(open('$CACHE_FILE')); print(d.get('surfaceVariantText', '#999999'))")
BG=$(python3 -c "import json; d=json.load(open('$CACHE_FILE')); print(d.get('surfaceContainer', '#000000'))")

cat > "$OUTPUT_FILE" << EOF
@define-color foreground $FG;
@define-color foreground-inactive $FG_INACTIVE;
@define-color background $BG;
EOF

pkill -USR2 waybar 2>/dev/null
