#!/usr/bin/env bash

popup_pid="$1"

while kill -0 "$popup_pid" 2>/dev/null; do
    sleep 0.2

    active_class=$(hyprctl -j activewindow 2>/dev/null |
        jq -r '.class // empty')

    if [[ "$active_class" != "yad" ]]; then
        kill "$popup_pid" 2>/dev/null
        exit 0
    fi
done
