
#!/usr/bin/env bash

current=$(powerprofilesctl get)

choice=$(printf "󰓅  Performance\n󰾅  Balanced\n󰌪  Power Saver" |
    rofi -dmenu -i -p "Power Profile" \
    -mesg "Current: $current")

case "$choice" in
    *Performance) powerprofilesctl set performance ;;
    *Balanced) powerprofilesctl set balanced ;;
    *"Power Saver") powerprofilesctl set power-saver ;;
esac
