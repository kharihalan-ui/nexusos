#!/usr/bin/env bash
#
# Deploy NexusOS configurations to the live system
# Copies XFCE macOS-like configs, themes, and wallpapers
#

set -euo pipefail

ROOT="${1:-}"
[ -z "$ROOT" ] && { echo "Usage: $0 <rootfs-path>"; exit 1; }

echo "Deploying NexusOS configurations to ${ROOT}..."

# --- Deploy XFCE configs (macOS-like desktop) ---
mkdir -p "${ROOT}/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml"
mkdir -p "${ROOT}/etc/skel/.config/xfce4/panel"

cp -r "${ROOT}/usr/share/nexusos/xfce-config/"* "${ROOT}/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/"
cp -r "${ROOT}/usr/share/nexusos/panel-config/"* "${ROOT}/etc/skel/.config/xfce4/panel/"

# --- Deploy wallpaper ---
mkdir -p "${ROOT}/usr/share/backgrounds/nexusos"
if [ -f "${ROOT}/usr/share/nexusos/plasma-wallpapers/nexusos-wallpaper.jpg" ]; then
    cp "${ROOT}/usr/share/nexusos/plasma-wallpapers/nexusos-wallpaper.jpg" "${ROOT}/usr/share/backgrounds/nexusos/"
fi

# --- Deploy login wallpaper ---
if [ -f "${ROOT}/usr/share/nexusos/plasma-wallpapers/nexusos-login.jpg" ]; then
    cp "${ROOT}/usr/share/nexusos/plasma-wallpapers/nexusos-login.jpg" "${ROOT}/usr/share/backgrounds/nexusos/"
fi

# --- Plymouth boot splash ---
mkdir -p "${ROOT}/usr/share/plymouth/themes/nexusos"
cp "${ROOT}/splash/"* "${ROOT}/usr/share/plymouth/themes/nexusos/" 2>/dev/null || true

echo "Deployment complete."
