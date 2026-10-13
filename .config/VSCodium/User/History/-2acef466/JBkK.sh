#!/usr/bin/env bash

set -u

while true; do
    wifi_list=$(
        nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY \
            device wifi list --rescan yes 2>/dev/null |
        while IFS=: read -r active ssid signal security; do
            [[ -z "$ssid" ]] && continue

            connected=""
            [[ "$active" == "*" ]] && connected="✓"

            # Escape YAD's list separator.
            ssid=${ssid//|/ }
            security=${security//|/ }

            printf '%s|%s|%s|%s\n' \
                "$connected" "$ssid" "${signal:-0}" "${security:--}"
        done
    )

    [[ -z "$wifi_list" ]] && wifi_list=" |No networks found|0|-"

    selected=$(
        yad --list \
            --title="Network Connections" \
            --text="Available Wi-Fi networks" \
            --column="Connected" \
            --column="Network" \
            --column="Signal:NUM" \
            --column="Security" \
            --separator="|" \
            --print-column=2 \
            --width=460 \
            --height=350 \
            --undecorated \
            --on-top \
            --skip-taskbar \
            --button="Connect:0" \
            --button="Disconnect:2" \
            --button="Refresh:3" \
            --button="Close:1" \
            <<< "$wifi_list" 2>/dev/null
    )
    status=$?

    case "$status" in
        0)
            [[ -z "$selected" ]] && continue

            if ! nmcli --wait 10 device wifi connect "$selected" \
                2>/dev/null; then

                password=$(yad --entry \
                    --title="Wi-Fi Password" \
                    --text="Enter password for: $selected" \
                    --hide-text \
                    --width=320 2>/dev/null) || continue

                nmcli --wait 20 device wifi connect "$selected" \
                    password "$password" || \
                    yad --error \
                        --text="Could not connect to $selected" \
                        2>/dev/null
            fi
            ;;
        2)
            nmcli device disconnect "$(nmcli -t -f DEVICE,TYPE device |
                awk -F: '$2=="wifi"{print $1; exit}')" 2>/dev/null
            ;;
        3)
            continue
            ;;
        *)
            exit 0
            ;;
    esac
done