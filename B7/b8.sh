#!/bin/bash

# Detect the primary display name (like eDP-1, HDMI-1, etc.)
DISPLAY_NAME=$(xrandr | grep " connected" | awk '{print $1}')
AUTOSTART_DIR="$HOME/.config/autostart"
AUTOSTART_FILE="$AUTOSTART_DIR/brightness_tray.desktop"
SCRIPT_PATH="$(realpath "$0")"

# --- [1] ADD TO AUTOSTART IF NOT ALREADY ---
if [ ! -f "$AUTOSTART_FILE" ]; then
    mkdir -p "$AUTOSTART_DIR"
    cat > "$AUTOSTART_FILE" <<EOF
[Desktop Entry]
Type=Application
Exec=$SCRIPT_PATH
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Brightness Tray
Comment=Autostart Brightness Tray App
EOF
    echo "✅ Added to startup: $AUTOSTART_FILE"
fi

# --- [2] SET BRIGHTNESS FUNCTION ---
set_brightness() {
    local value=\$1
    brightness=\$(awk "BEGIN { print \$value / 100 }")
    xrandr --output "$DISPLAY_NAME" --brightness "\$brightness"
}

# --- [3] OPEN SLIDER FUNCTION ---
open_slider() {
    current_brightness=\$(xrandr --verbose | grep -i brightness | head -n1 | awk '{print int(\$2 * 100)}')
    current_brightness=\${current_brightness:-100}

    yad --scale \
        --title="Adjust Brightness" \
        --text="Scroll or Drag to Adjust Brightness" \
        --min-value=10 \
        --max-value=100 \
        --step=5 \
        --value="\$current_brightness" \
        --mouse \
        --on-top \
        --skip-taskbar \
        --no-buttons \
        --undecorated \
        --sticky \
        --width=250 \
        --print-partial \
        --timeout=5 \
        --timeout-indicator=top \
        --close-on-unfocus | while read -r value; do
            if [[ "\$value" =~ ^[0-9]+$ ]]; then
                set_brightness "\$value"
            fi
        done
}

# Export for bash -c
export -f open_slider
export -f set_brightness
export DISPLAY_NAME

# --- [4] START TRAY ICON ---
yad --notification \
    --image=display-brightness-symbolic \
    --text="Brightness" \
    --command="bash -c open_slider"
