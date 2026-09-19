# 04 - WireGuard Notes

The workstation uses a WireGuard interface named `wg0`.

## Check state

```bash
systemctl status wg-quick@wg0 --no-pager
ip address show wg0
ip route
sudo wg show
```

## Start manually

```bash
sudo systemctl start wg-quick@wg0
```

## Enable at boot only after the desktop/network baseline is stable

```bash
sudo systemctl enable wg-quick@wg0
```

On the reference workstation, networking and graphics troubleshooting were performed separately so a WireGuard route/firewall change could not be confused with a display-driver failure.

## Do not commit secrets

Never commit `/etc/wireguard/wg0.conf` or any private key. Documentation should use placeholders only.