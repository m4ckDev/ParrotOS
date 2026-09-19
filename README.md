# ParrotOS - Omarchy Feel, Parrot Under the Hood

A reproducible Parrot Security workstation build that keeps Parrot/Debian underneath while adding an Omarchy-inspired keyboard-first desktop.

## Goals

1. Stabilize Parrot first: boot, LightDM, X11, NVIDIA, filesystem, Wi-Fi and display power behavior.
2. Add the Omarchy feel second: tiling, SUPER-key navigation, launcher, terminal, compositor, notifications and a compact status bar.
3. Keep Plasma X11 available as a known-good fallback.

> Reference system: Parrot Security 7.3, Linux 7.0.13+parrot7-amd64, KDE Plasma X11, NVIDIA GeForce RTX 4080 SUPER with NVIDIA 550.163.01, AMD Raphael iGPU, MediaTek MT7922 Wi-Fi.

## Validated stable state

- Root Btrfs filesystem mounts read/write.
- LightDM starts normally.
- Plasma starts on X11.
- NVIDIA proprietary driver is active.
- Forced NVIDIA DRM KMS is disabled on the tested 550.163.01 / 7.0.13 combination.
- No `NVRM: Xid` messages.
- No `nvidia-drm ... WARNING` messages.
- MT7922/MT7921 UBSAN warning removed with the CLC workaround.
- `systemctl --failed` reports zero failed units.
- Sleep/suspend/hibernate/hybrid-sleep are masked.
- X11 DPMS is disabled to prevent monitor power-down/wake issues.

## Start here

```bash
git clone https://github.com/m4ckDev/ParrotOS.git
cd ParrotOS
bash scripts/preflight.sh
```

Then follow:

1. [Stable Parrot baseline](docs/01-stable-parrot-baseline.md)
2. [Omarchy-style desktop](docs/02-omarchy-style-desktop.md)
3. [Validated troubleshooting history](docs/03-validated-troubleshooting.md)
4. [WireGuard notes](docs/04-wireguard.md)

## Omarchy compatibility note

Current Omarchy is an Arch-based desktop built around Hyprland and Quickshell. This repository does **not** install Omarchy over Parrot. The first reproducible desktop layer uses i3, Rofi, Picom, Polybar, Dunst, Kitty and Feh because Parrot officially provides i3 and these packages integrate cleanly with the stable X11 baseline.

A future Hyprland/Quickshell layer is intentionally kept out of the automatic installer until it is validated on this Parrot/NVIDIA stack.

## Install the desktop layer

```bash
bash scripts/install-omarchy-layer.sh
```

The installer backs up existing user configs before applying the included theme.

## Verify the machine

```bash
bash scripts/verify-stable-state.sh
```

## Repository layout

```text
configs/
  autostart/disable-dpms.sh
  dunst/dunstrc
  i3/config
  i3/autostart.sh
  lightdm/99-plasma-x11.conf
  modprobe/mt7921.conf
  picom/picom.conf
  polybar/config.ini
  rofi/config.rasi
docs/
  01-stable-parrot-baseline.md
  02-omarchy-style-desktop.md
  03-validated-troubleshooting.md
  04-wireguard.md
scripts/
  preflight.sh
  install-omarchy-layer.sh
  verify-stable-state.sh
```

## Security

Never commit VPN private keys, WireGuard configs containing secrets, Wi-Fi PSKs, API tokens, SSH private keys, browser profiles, client data, pentest loot or credentials.

## Sources

- Parrot desktop documentation: https://parrotsec.org/docs/configuration/desktop-environments/
- Omarchy manual: https://github.com/omacom/omarchy/blob/quattro/manual/01-welcome-to-omarchy.md
- Omarchy shell architecture: https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md

## Status

The stabilization baseline is validated on the reference system. The i3-based Omarchy-inspired layer is the current reproducible desktop build.