#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icon_map.sh"

getSpaceId() {
    echo "${NAME#*.}"
}

update() {
    SID=$(getSpaceId)


    echo "update"
    echo "  SID: $SID"
    echo "  NAME: $NAME"
    echo "  FOCUSED_WORKSPACE: $FOCUSED_WORKSPACE"
    echo "  SELECTED: $SELECTED"

    if [ "$SID" = "$FOCUSED_WORKSPACE" ]; then
        sketchybar --set "$NAME" background.drawing=on background.border_color="$WHITE"
    else
        sketchybar --set "$NAME" background.drawing=off background.border_color="$TRANSPARENT"
    fi

    applications=$(aerospace list-windows --format '%{app-name}' --workspace "$SID")
    label=""

    while IFS= read -r application; do
        if [ -z "$application" ]; then
            break
        fi
        __icon_map "$application"
        label+="$icon_result"
    done <<< "$applications"

    sketchybar --set "$NAME" label="$label"
}

mouse_clicked() {
    SID=$(getSpaceId)
    echo "mouse_clicked"
    echo "  SENDER: $SENDER"
    echo "  SID: $SID"
    echo "  NAME: $NAME"
    echo "  MODIFIER: $MODIFIER"
    echo "  BUTTON: $BUTTON"
    echo "  INFO: $INFO"
    aerospace workspace "$SID"
}

echo "PLUGIN"

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  *) update
  ;;
esac
