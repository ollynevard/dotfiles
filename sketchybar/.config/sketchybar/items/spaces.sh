#!/usr/bin/env bash

source "$CONFIG_DIR/icon_map.sh"

sketchybar --add event aerospace_workspace_change

spaces=$(aerospace list-workspaces --all)
focusedSpaceId=$(aerospace list-workspaces --focused)

echo "SPACES ITEM"
echo "  spaces: $spaces"
echo "  focusedSpaceId: $focusedSpaceId"

for sid in $spaces; do
    echo "    sid: $sid"
    backgroundDrawing=off
    backgroundBorderColor="$TRANSPARENT"

    if [ "$focusedSpaceId" == "$sid" ]; then
        backgroundDrawing=on
        backgroundBorderColor="$WHITE"
    fi

    applications=$(aerospace list-windows --format '%{app-name}' --workspace "$sid")
    label=""

    while IFS= read -r application; do
        if [ -z "$application" ]; then
            break
        fi
        __icon_map "$application"
        label+="$icon_result"
    done <<< "$applications"
    echo "    label: $label"

    sketchybar \
        --add item "space.$sid" left \
        --subscribe "space.$sid" aerospace_workspace_change \
        --subscribe "space.$sid" mouse.clicked \
        --subscribe "space.$sid" front_app_switched \
        --subscribe "space.$sid" space_windows_change \
        --set "space.$sid" \
            background.border_color="$backgroundBorderColor" \
            background.color="$BACKGROUND_1" \
            background.drawing="$backgroundDrawing" \
            background.height=30 \
            background.padding_left=0 \
            background.padding_right=10 \
            icon.padding_left=10 \
            icon.padding_right=10 \
            icon="$sid" \
            label="$label" \
            label.font.family=sketchybar-app-font \
            label.font.style=regular \
            label.font.size=16.0 \
            label.padding_left=0 \
            label.padding_right=10 \
            script="$CONFIG_DIR/plugins/aerospace.sh"
done
