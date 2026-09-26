#!/bin/sh
# Project: uac-systemd (Cleanup & Uninstall Script)
# Completely removes uac-systemd and all generated session files.

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "[!] Error: This script must be run with root privileges (e.g., sudo ./remove.sh)" >&2
    exit 1
fi

echo "[*] Stopping and disabling UAC systemd units..."
systemctl stop uac-sync.path 2>/dev/null || true
systemctl stop uac-sync.service 2>/dev/null || true
systemctl disable uac-sync.path 2>/dev/null || true
systemctl disable uac-sync.service 2>/dev/null || true

echo "[*] Removing Systemd files..."
rm -f /etc/systemd/system/uac-sync.service
rm -f /etc/systemd/system/uac-sync.path
systemctl daemon-reload

echo "[*] Removing system wrappers and profile settings..."
rm -f /usr/local/bin/sudo
rm -f /usr/local/bin/pkexec
rm -f /etc/profile.d/99-uac-wrapper.sh

echo "[*] Removing UAC modules and configurations..."
rm -rf /usr/local/bin/uac
rm -rf /etc/uac

echo "[*] Removing auto-generated permission rules..."
rm -f /etc/sudoers.d/99-uac-passwordless
rm -f /etc/polkit-1/rules.d/49-uac-passwordless.rules

echo "[*] Cleaning up temporary UAC cache files..."
rm -f /tmp/.uac_sudo_* 2>/dev/null || true
rm -f /tmp/.uac_pk_* 2>/dev/null || true

echo "[+] uac-systemd has been completely removed from the system!"
echo "[!] Note: Please restart your terminal, or run 'unalias sudo pkexec 2>/dev/null && hash -r' to revert your current session."
