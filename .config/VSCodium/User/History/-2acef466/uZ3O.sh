#!/usr/bin/env bash

set -u

refresh_networks() {
    nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan yes |
    awk -F: '{
        connected = ($1 == "*") ? "Connected" : ""
        ssid = $2
        signal = $3
        security = $4
        if (ssid == "") ssid = "(Hidden network)"
        printf "%s\t%s\t%s%%\t%s\n", connected, ssid, signal, security
    }' | sort -r
}

while true; do
    networks=$(refresh_networks)

    choice=$(printf '%s\n' "$networks" |
        yad --list \
            --title="Networks" \
            --text="Available Wi-Fi networks" \
            --column="Status" \
            --column="Network" \
            --column="Signal" \
            --column="Security" \
            --search-column=2 \
            --width=440 \
            --height=520 \
            --geometry=440x520+10+40 \
            --undecorated \
            --on-top \
            --skip-taskbar \
            --button="Refresh:2" \
            --button="Wi-Fi Off/On:3" \
            --button="Connect:0" \
            --button="Close:1" 2>/dev/null)\
            --undecorated \
            --on-top \
            --skip-taskbar \

    status=$?

    case "$status" in
        0)
            ssid=$(printf '%s\n' "$choice" | cut -d'|' -f2)
            if [[ -n "$ssid" && "$ssid" != "(Hidden network)" ]]; then
                nmcli --ask device wifi connect "$ssid"
                yad --info --title="Networks" \
                    --text="Connection request finished for: $ssid" \
                    --timeout=2 2>/dev/null
            fi
            ;;
        2) continue ;;
        3)
            if nmcli radio wifi | grep -q enabled; then
                nmcli radio wifi off
            else
                nmcli radio wifi on
            fi
            ;;
        *) exit 0 ;;
    esac
done
