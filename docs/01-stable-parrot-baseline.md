# 01 - Stable Parrot Baseline

Apply fixes only when the matching problem exists on your machine.

## 1. Preflight

```bash
bash scripts/preflight.sh
```

## 2. Root filesystem must be read/write

Check:

```bash
findmnt -no OPTIONS /
```

Expected output begins with `rw,`.

On the reference machine the kernel command line contained `noautomount`, which caused the Btrfs root filesystem to remain read-only. LightDM/Xorg then failed because they could not rotate or create log files.

Check the current kernel command line:

```bash
cat /proc/cmdline
```

If `noautomount` is present, find where it is injected:

```bash
sudo grep -Rni -- 'noautomount' /etc/default /etc/kernel /boot 2>/dev/null
```

On the reference system it came from `/etc/default/grub.d/grub.cfg`.

Back up the file, remove only the `noautomount` argument, rebuild GRUB, and reboot:

```bash
sudo cp /etc/default/grub.d/grub.cfg /etc/default/grub.d/grub.cfg.bak
sudo sed -i 's/ noautomount//g' /etc/default/grub.d/grub.cfg
sudo update-grub
sudo reboot
```

Verify:

```bash
findmnt -no OPTIONS /
systemctl status systemd-remount-fs.service --no-pager -l
```

## 3. LightDM / Plasma X11 fallback

List installed sessions:

```bash
grep -RniE '^(Name|Exec|TryExec)=' /usr/share/xsessions /usr/share/wayland-sessions 2>/dev/null | grep -Ei 'plasma|kf6'
```

The reference system had both Plasma X11 and Plasma Wayland installed, but LightDM's packaged default pointed at `kde-plasma-kf6`. The stable session was `plasmax11`.

Local override:

```bash
sudo install -d -m 755 /etc/lightdm/lightdm.conf.d
sudo install -m 644 configs/lightdm/99-plasma-x11.conf /etc/lightdm/lightdm.conf.d/99-plasma-x11.conf
```

Restart only after confirming the file:

```bash
cat /etc/lightdm/lightdm.conf.d/99-plasma-x11.conf
sudo systemctl restart lightdm
```

Verify:

```bash
echo $XDG_SESSION_TYPE
systemctl is-active lightdm
```

Expected: `x11` and `active`.

## 4. NVIDIA

Identify the driver:

```bash
lspci -k | grep -A3 -E 'VGA|3D|Display'
nvidia-smi
```

Reference system: RTX 4080 SUPER using NVIDIA 550.163.01.

Important: forcing `nvidia-current-drm modeset=1` caused repeated kernel warnings on this exact driver/kernel combination. The tested stable state is:

```bash
sudo cat /sys/module/nvidia_drm/parameters/modeset
```

Expected on the reference build:

```text
N
```

If you previously created `/etc/modprobe.d/nvidia-drm-modeset.conf` to force KMS, remove that custom override and rebuild initramfs:

```bash
sudo rm -f /etc/modprobe.d/nvidia-drm-modeset.conf
sudo update-initramfs -u
sudo reboot
```

Check for NVIDIA faults:

```bash
sudo journalctl -b -k | grep -iE 'NVRM: Xid|nvidia-drm.*WARNING' | tail -n 50
```

No output is the desired state.

## 5. MediaTek MT7922 / MT7921 UBSAN workaround

Reference adapter:

```text
MediaTek MT7922
driver: mt7921e
```

Kernel 7.0.13 emitted an array-index UBSAN warning from `drivers/net/wireless/mediatek/mt76/mt7921/mcu.c`.

The module exposes a `disable_clc` parameter:

```bash
modinfo mt7921_common | grep -i clc
```

Apply the included workaround:

```bash
sudo install -m 644 configs/modprobe/mt7921.conf /etc/modprobe.d/mt7921.conf
sudo update-initramfs -u
sudo reboot
```

Verify:

```bash
sudo journalctl -b -k | grep -iE 'UBSAN|mt7921|array-index-out-of-bounds' | tail -n 30
nmcli device wifi list ifname wlp9s0
```

On the reference machine the UBSAN warning disappeared and Wi-Fi scanning continued to work.

## 6. Remove an unused Broadcom STA DKMS module

The system had `broadcom-sta-dkms` installed even though no Broadcom PCI or USB adapter existed. Both `wl` and the MediaTek driver were loaded.

Check before removing anything:

```bash
lspci -nn | grep -i broadcom
lsusb | grep -i broadcom
dpkg -l | grep -Ei 'broadcom|bcmwl|broadcom-sta'
```

Only if no Broadcom hardware exists:

```bash
sudo apt purge -y broadcom-sta-dkms
sudo reboot
```

Verify that `wl` is gone:

```bash
lsmod | grep -E '^(mt7921e|mt7921_common|mt792x_lib|mt76|wl)\b'
```

## 7. Disable unused boot services

The reference system had three services enabled but unconfigured:

- `hostapd-wpe.service`
- `isc-dhcp-server.service`
- `sslh.service`

If you are not using them as persistent services:

```bash
sudo systemctl disable --now hostapd-wpe.service isc-dhcp-server.service sslh.service
sudo systemctl reset-failed
```

Verify:

```bash
systemctl --failed --no-pager
```

## 8. Prevent sleep / black-screen wake failures

The reference workstation intentionally never sleeps.

Mask system sleep targets:

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

Disable X11 display power management immediately:

```bash
xset s off -dpms
```

Persist it:

```bash
mkdir -p ~/.config/autostart-scripts
install -m 755 configs/autostart/disable-dpms.sh ~/.config/autostart-scripts/disable-dpms.sh
```

Verify:

```bash
xset q | grep -A4 DPMS
```

Expected: `DPMS is Disabled`.

## 9. tty1 race workaround used on the reference system

The reference machine briefly exposed tty1 while the X11 desktop was already active on VT1. After verifying LightDM and the graphical target were healthy, `getty@tty1.service` was disabled:

```bash
sudo systemctl disable --now getty@tty1.service
```

Do this only if you have another recovery TTY available such as Ctrl+Alt+F2/F3. Undo with:

```bash
sudo systemctl enable --now getty@tty1.service
```

## 10. Final verification

```bash
bash scripts/verify-stable-state.sh
```