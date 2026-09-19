#!/usr/bin/env bash
set -u
fail=0

echo '== Stable-state verification ==' 

root_opts=$(findmnt -no OPTIONS /)
echo "Root: $root_opts"
case ",$root_opts," in *,rw,*) ;; *) echo 'FAIL: root is not read/write'; fail=1;; esac

lightdm=$(systemctl is-active lightdm 2>/dev/null || true)
echo "LightDM: $lightdm"
[ "$lightdm" = active ] || fail=1

echo "Session: ${XDG_SESSION_TYPE:-unknown}"

failed_count=$(systemctl --failed --no-legend 2>/dev/null | sed '/^[[:space:]]*$/d' | wc -l)
echo "Failed units: $failed_count"
[ "$failed_count" -eq 0 ] || fail=1

if [ -e /sys/module/nvidia_drm/parameters/modeset ]; then
  kms=$(sudo cat /sys/module/nvidia_drm/parameters/modeset 2>/dev/null || echo unknown)
  echo "NVIDIA DRM modeset: $kms"
fi

warnings=$(sudo journalctl -b -k --no-pager 2>/dev/null | grep -iE 'NVRM: Xid|nvidia-drm.*WARNING|UBSAN|array-index-out-of-bounds' || true)
if [ -n "$warnings" ]; then
  echo 'FAIL: relevant kernel warnings found:'
  echo "$warnings" | tail -n 30
  fail=1
else
  echo 'Relevant kernel warnings: none'
fi

if command -v xset >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
  xset q | grep -A4 DPMS || true
fi

exit "$fail"