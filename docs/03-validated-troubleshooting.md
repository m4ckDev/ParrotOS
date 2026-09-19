# 03 - Validated Troubleshooting History

This is the failure chain that was actually diagnosed on the reference machine.

## Symptom: boot lands on TTY

LightDM initially appeared active, but the graphical desktop did not appear.

Useful checks:

```bash
systemctl status lightdm --no-pager -l
sudo journalctl -u lightdm -b --no-pager -n 100
tail -n 100 ~/.xsession-errors
sudo tail -n 100 /var/log/lightdm/lightdm.log
```

The session logs showed X11 utilities such as `xrdb` and `xhost` unable to open a display while LightDM had been creating a Wayland display server. Installed session files confirmed both Plasma X11 and Wayland existed.

## Symptom: LightDM restart hangs

After attempting to restart LightDM, old Wayland processes remained alive:

```text
kwin_wayland_wrapper
kwin_wayland
Xwayland
plasmashell
```

Those stale processes were terminated before restarting LightDM cleanly.

## Symptom: after reboot LightDM fails immediately

Journal showed:

```text
Failed to open log file ... Read-only file system
Fatal server error:
Cannot move old log file /var/log/Xorg.0.log to /var/log/Xorg.0.log.old
```

`findmnt` confirmed `/` was mounted `ro`. The kernel command line contained `noautomount`; removing that custom GRUB argument restored the expected read/write root mount.

## Symptom: repeated NVIDIA DRM kernel warnings

With forced `nvidia-current-drm modeset=1`, the kernel emitted warnings from:

```text
nv_drm_revoke_modeset_permission
```

Removing the custom forced-KMS override returned the system to a warning-free X11 state.

## Symptom: MediaTek UBSAN warning every boot

Kernel output showed:

```text
UBSAN: array-index-out-of-bounds
drivers/net/wireless/mediatek/mt76/mt7921/mcu.c
```

`modinfo mt7921_common` exposed `disable_clc`. Setting `disable_clc=1` removed the warning on the reference kernel while preserving Wi-Fi scanning.

## Symptom: failed services at every boot

Three pentest/network services were enabled without valid runtime configuration:

```text
hostapd-wpe.service
isc-dhcp-server.service
sslh.service
```

They were disabled because they were not intended to run permanently.

## Symptom: monitor sleep / black screens

System sleep targets were masked and X11 DPMS was disabled. After persistence was added, `xset q` reported:

```text
Standby: 0
Suspend: 0
Off: 0
DPMS is Disabled
```

## Benign/non-blocking messages still observed

The following remained but were not associated with boot failure in the validated stable state:

- Western Digital My Passport SES diagnostic-page/enclosure messages.
- KDE PowerDevil/ddcutil connector-name warnings for several I2C buses.
- OBEX request for the absent GNOME Evolution source registry.

The important stable-state signals are checked by `scripts/verify-stable-state.sh`.