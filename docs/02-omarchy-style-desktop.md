# 02 - Omarchy-Style Desktop on Parrot

## What this build is

Omarchy itself currently uses Arch Linux, Hyprland and Quickshell. Parrot officially supports i3 as a window-manager option. This repository therefore uses a two-phase strategy:

- **Phase 1 - validated:** i3 + Rofi + Picom + Polybar + Dunst + Kitty + Feh on the known-good X11/NVIDIA base.
- **Phase 2 - future:** Hyprland + Quickshell after the NVIDIA/Wayland stack is separately validated.

This keeps Parrot tools, APT, repositories and security workflow underneath.

## Install

```bash
bash scripts/install-omarchy-layer.sh
```

Packages installed:

```text
i3-wm
i3status
i3lock
rofi
picom
kitty
feh
dunst
polybar
x11-xserver-utils
jq
```

## Theme philosophy

The included setup mirrors the workflow rather than copying Omarchy source files:

- dark background
- red accent
- keyboard-first app launching
- minimal chrome
- tiling by default
- small gaps
- transparent/composited terminal windows
- compact top bar
- workspaces 1-9
- fast SUPER-key bindings

## Keybindings

| Keys | Action |
|---|---|
| `Super+Enter` | Kitty terminal |
| `Super+Space` | Rofi application launcher |
| `Super+Shift+Q` | Close focused window |
| `Super+1..9` | Switch workspace |
| `Super+Shift+1..9` | Move window to workspace |
| `Super+H/J/K/L` | Focus left/down/up/right |
| `Super+Shift+H/J/K/L` | Move window |
| `Super+F` | Fullscreen |
| `Super+Shift+Space` | Toggle floating |
| `Super+R` | Resize mode |
| `Super+Shift+C` | Reload i3 config |
| `Super+Shift+R` | Restart i3 |

## Wallpaper

The repository does not ship the user's wallpaper. Put your own image at:

```text
~/Pictures/omarchy-parrot-wallpaper.png
```

The included i3 autostart script loads it automatically if present.

## Plasma fallback

Do not delete Plasma while building the new desktop.

The stable fallback remains `plasmax11`. During testing, disable LightDM autologin if you need to select i3 interactively, or create a separate local LightDM override only after i3 is confirmed working.

To return to the validated Plasma default:

```bash
sudo install -m 644 configs/lightdm/99-plasma-x11.conf /etc/lightdm/lightdm.conf.d/99-plasma-x11.conf
sudo systemctl restart lightdm
```

## Why not force Hyprland immediately?

The tested NVIDIA 550.163.01 stack generated kernel warnings when DRM KMS was forced. Hyprland/Wayland normally expects a healthier DRM/KMS path than this reference build currently provides. The repo therefore preserves a stable X11 path and treats Hyprland as a later compatibility milestone.

## Official references

- Parrot desktops: https://parrotsec.org/docs/configuration/desktop-environments/
- Omarchy welcome/manual: https://github.com/omacom/omarchy/blob/quattro/manual/01-welcome-to-omarchy.md
- Omarchy shell: https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md