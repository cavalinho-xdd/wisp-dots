#!/bin/bash
# Toggle scratchpad, spawn if not exists
if ! hyprctl clients -j | jq -e '.[] | select(.class == "wisp-scratchpad")' > /dev/null; then
    hyprctl eval "hl.dispatch(hl.dsp.exec_cmd('[workspace special:scratchpad silent] kitty --class wisp-scratchpad micro ~/scratchpad.txt'))"
fi
hyprctl eval "hl.dispatch(hl.dsp.workspace.toggle_special('scratchpad'))"
