#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
stamp=$(date +%Y%m%d-%H%M%S)
backup="$HOME/.config/parrotos-backup-$stamp"

echo '[1/3] Installing desktop packages...'
sudo apt update
sudo apt install -y i3-wm i3status i3lock rofi picom kitty feh dunst polybar x11-xserver-utils jq

echo "[2/3] Backing up existing configs to $backup"
mkdir -p "$backup"
for d in i3 rofi picom polybar dunst; do
  if [ -e "$HOME/.config/$d" ]; then cp -a "$HOME/.config/$d" "$backup/"; fi
done

echo '[3/3] Installing Omarchy-inspired user configs...'
install -Dm644 "$repo_root/configs/i3/config" "$HOME/.config/i3/config"
install -Dm755 "$repo_root/configs/i3/autostart.sh" "$HOME/.config/i3/autostart.sh"
install -Dm644 "$repo_root/configs/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
install -Dm644 "$repo_root/configs/picom/picom.conf" "$HOME/.config/picom/picom.conf"
install -Dm644 "$repo_root/configs/polybar/config.ini" "$HOME/.config/polybar/config.ini"
install -Dm644 "$repo_root/configs/dunst/dunstrc" "$HOME/.config/dunst/dunstrc"
install -Dm755 "$repo_root/configs/autostart/disable-dpms.sh" "$HOME/.config/autostart-scripts/disable-dpms.sh"

echo
echo 'Installed. Keep Plasma X11 as your fallback. Log out and select the i3 session from LightDM to test.'