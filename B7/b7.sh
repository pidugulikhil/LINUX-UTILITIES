#!/bin/bash

# Detect the primary display name (like eDP-1, HDMI-1, etc.)
DISPLAY_NAME=$(xrandr | grep " connected" | awk '{print $1}')

# Function to set brightness
set_brightness() {
    local value=$1
    brightness=$(awk "BEGIN { print $value / 100 }")
    xrandr --output "$DISPLAY_NAME" --brightness "$brightness"
}

# Function to open slider
open_slider() {
    current_brightness=$(xrandr --verbose | grep -i brightness | head -n1 | awk '{print int($2 * 100)}')
    current_brightness=${current_brightness:-100}

    # Use --skip-taskbar and --sticky for popup-like behavior
    yad --scale \
        --title="Adjust Brightness" \
        --text="Scroll or Drag to Adjust Brightness" \
        --min-value=10 \
        --max-value=100 \
        --step=1 \
        --value="$current_brightness" \
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
            if [[ "$value" =~ ^[0-9]+$ ]]; then
                set_brightness "$value"
            fi
        done
}

# Export functions
export -f open_slider
export -f set_brightness
export DISPLAY_NAME

# Start tray icon
yad --notification \
    --image=display-brightness-symbolic \
    --text="Brightness" \
    --command="bash -c open_slider"
