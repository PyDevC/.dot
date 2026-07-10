#!/usr/bin/env bash

theme="style_9"
dir="$HOME/.config/rofi/launchers/colorful"

rofi -no-lazy-grab -show drun -modi "drun,window" -theme "$dir/$theme"
