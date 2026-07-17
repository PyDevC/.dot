#!/bin/bash
data=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
vol=$(echo "$data" | awk '{print $2}')
int_vol=$(echo "$vol * 100 / 1" | bc)
if echo "$data" | grep -q "MUTED"; then
    echo " MUTED"
    exit 0
fi
filled=$((int_vol / 10))
slider=""
for ((i=0; i<10; i++)); do
    if [ $i -lt $filled ]; then slider="${slider}▰"; else slider="${slider}▱"; fi
done
echo " $slider ${int_vol}%"
