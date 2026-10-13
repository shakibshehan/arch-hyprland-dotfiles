#!/bin/bash

updates=$(checkupdates 2>/dev/null | wc -l)

if [ "$updates" -eq 0 ]; then
    echo '{"text":"󰮯 0","tooltip":"Arch Linux is up to date"}'
else
    echo "{\"text\":\"󰮯 $updates\",\"tooltip\":\"$updates package updates available\"}"
fi
