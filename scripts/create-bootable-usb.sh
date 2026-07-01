#!/usr/bin/env bash
#
# Create a bootable USB drive from NexusOS ISO
#
# Usage: sudo ./create-bootable-usb.sh /path/to/nexusos.iso /dev/sdX
#
# WARNING: This will erase ALL data on the target device!

set -euo pipefail

if [ $# -ne 2 ]; then
    echo "Usage: $0 <iso-file> <device>"
    echo ""
    echo "Example:"
    echo "  sudo $0 out/nexusos-2026.07.01.iso /dev/sdb"
    echo ""
    echo "Find your device with: lsblk"
    exit 1
fi

ISO="$1"
DEVICE="$2"

if [ ! -f "$ISO" ]; then
    echo "Error: ISO file not found: $ISO"
    exit 1
fi

if [ ! -b "$DEVICE" ]; then
    echo "Error: Not a block device: $DEVICE"
    echo "Available devices:"
    lsblk -d -o NAME,SIZE,MODEL | grep -v loop
    exit 1
fi

echo "ISO:     $ISO"
echo "Device:  $DEVICE"
echo ""
echo "WARNING: ALL DATA ON $DEVICE WILL BE DESTROYED!"
echo ""
read -p "Are you sure? Type 'yes' to continue: " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

echo "Unmounting any mounted partitions..."
sudo umount "${DEVICE}"* 2>/dev/null || true

echo "Writing ISO to ${DEVICE}..."
sudo dd if="$ISO" of="$DEVICE" bs=4M status=progress oflag=sync
sync

echo ""
echo "Done! Bootable USB created at ${DEVICE}"
echo "Boot from this USB to install NexusOS."
