
#!/usr/bin/env bash

# Compact audio popup for Waybar + Hyprland
set -u

get_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null |
        awk '{v=$2*100; printf "%d", (v<0?0:(v>100?100:v))}'
}

is_muted() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null |
        grep -q MUTED
}

while true; do
    volume=$(get_volume)
    muted=$(is_muted && echo TRUE || echo FALSE)

    result=$(yad --scale \
        --title="Audio" \
        --text="Volume: ${volume}%$([ "$muted" = TRUE ] && echo ' (muted)')" \
        --min-value=0 \
        --max-value=100 \
        --step=5 \
        --value="$volume" \
        --print-partial \
        --width=300 \
        --height=120 \
        --geometry=300x120+80+45 \
        --undecorated \
        --on-top \
        --skip-taskbar \
        --button="−:10" \
        --button="Mute:11" \
        --button="+:12" \
        --button="Close:1" 2>/dev/null)



    status=$?

    case "$status" in
        0|1) exit 0 ;;
        10)
            wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
            ;;
        11)
            wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
            ;;
        12)
            wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
            ;;
        *)
            exit 0
            ;;
    esac

    # Apply the slider's selected value when YAD returns one.
    if [[ "$result" =~ ^[0-9]+$ ]]; then
        wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ \
            "$((result))%"
    fi
done