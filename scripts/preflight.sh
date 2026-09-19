#!/usr/bin/env bash
set -u

echo '== ParrotOS preflight ==' 
echo
printf 'Kernel: '; uname -r
printf 'Session: '; printf '%s\n' "${XDG_SESSION_TYPE:-unknown}"
printf 'Default target: '; systemctl get-default
printf 'LightDM: '; systemctl is-active lightdm 2>/dev/null || true
printf 'Root mount: '; findmnt -no OPTIONS /
echo
echo '== Graphics ==' 
lspci -k | grep -A3 -E 'VGA|3D|Display' || true
echo
if command -v nvidia-smi >/dev/null 2>&1; then nvidia-smi --query-gpu=name,driver_version --format=csv,noheader; fi
if [ -r /sys/module/nvidia_drm/parameters/modeset ]; then printf 'NVIDIA DRM modeset: '; cat /sys/module/nvidia_drm/parameters/modeset; elif sudo -n true 2>/dev/null; then printf 'NVIDIA DRM modeset: '; sudo cat /sys/module/nvidia_drm/parameters/modeset; fi
echo
echo '== Failed units ==' 
systemctl --failed --no-pager || true
echo
echo '== Network ==' 
nmcli device status 2>/dev/null || true
echo
echo '== Relevant kernel warnings ==' 
sudo journalctl -b -k --no-pager 2>/dev/null | grep -iE 'NVRM: Xid|nvidia-drm.*WARNING|UBSAN|array-index-out-of-bounds' | tail -n 30 || true