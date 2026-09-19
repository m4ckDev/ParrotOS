#!/bin/sh
pkill picom 2>/dev/null || true
picom --config "$HOME/.config/picom/picom.conf" -b
pkill dunst 2>/dev/null || true
dunst -config "$HOME/.config/dunst/dunstrc" &
pkill polybar 2>/dev/null || true
polybar main -c "$HOME/.config/polybar/config.ini" &
xset s off -dpms
wallpaper="$HOME/Pictures/omarchy-parrot-wallpaper.png"
[ -f "$wallpaper" ] && feh --no-fehbg --bg-fill "$wallpaper"
exit 0