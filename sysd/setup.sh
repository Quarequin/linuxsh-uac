#!/bin/sh
# Project: uac-systemd (Setup Script)
# Installs modular UAC framework for passwordless users using assets.

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "[!] Error: This script must be run with root privileges (e.g., sudo ./setup.sh)" >&2
    exit 1
fi

echo "[*] Installing uac-systemd..."

# 1. Create directory structure
mkdir -p /usr/local/bin/uac
mkdir -p /etc/uac

# 2. Copy configurations and scripts from asset folder
cp ./asset/usr/local/bin/uac/uac.conf /usr/local/bin/uac/uac.conf
chmod 0644 /usr/local/bin/uac/uac.conf

cp ./asset/usr/local/bin/uac/libuac /usr/local/bin/uac/libuac
chmod +x /usr/local/bin/uac/libuac

cp asset/usr/local/bin/uac/syncuac /usr/local/bin/uac/syncuac
chmod +x /usr/local/bin/uac/syncuac

# 3. Install System Wrappers
cp ./asset/usr/local/bin/sudo /usr/local/bin/sudo
chmod +x /usr/local/bin/sudo

cp ./asset/usr/local/bin/pkexec /usr/local/bin/pkexec
chmod +x /usr/local/bin/pkexec

# 4. Install Shell Profile
cp ./asset/etc/profile.d/99-uac-wrapper.sh /etc/profile.d/99-uac-wrapper.sh
chmod 0644 /etc/profile.d/99-uac-wrapper.sh

# 5. Install Systemd Units
cp ./asset/etc/systemd/system/uac-sync.service /etc/systemd/system/uac-sync.service
cp ./asset/etc/systemd/system/uac-sync.path /etc/systemd/system/uac-sync.path

# 6. Enable Services and Run Initial Sync
systemctl daemon-reload
systemctl enable --now uac-sync.service
systemctl enable --now uac-sync.path
/usr/local/bin/uac/syncuac

echo "[+] uac-systemd installed and activated successfully!"
echo "[!] Note: Please restart your terminal or run 'source /etc/profile.d/99-uac-wrapper.sh && hash -r' to apply changes immediately."
