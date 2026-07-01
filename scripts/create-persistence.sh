#!/usr/bin/env bash
#
# Create persistent storage partition for NexusOS USB
# Usage: sudo ./create-persistence.sh /dev/sdX
#
# This creates a 2GB persistence partition on the USB drive
# so all your files and settings survive reboots.
#

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: sudo $0 /dev/sdX"
    echo ""
    echo "Example:"
    echo "  sudo $0 /dev/sdb"
    echo ""
    echo "WARNING: This modifies the USB drive partition table!"
    echo "Make sure you already wrote the ISO to this drive first."
    exit 1
fi

DEVICE="$1"
SIZE="${2:-2048}"  # 2GB default persistence size

if [ ! -b "$DEVICE" ]; then
    echo "Error: Not a block device: $DEVICE"
    lsblk -d -o NAME,SIZE,MODEL | grep -v loop
    exit 1
fi

echo "Device: $DEVICE"
echo "Persistence size: ${SIZE}MB (2GB default)"
echo ""
echo "WARNING: This will modify the partition table on $DEVICE"
echo "Make sure you already wrote the NexusOS ISO to this USB."
echo ""
read -p "Continue? (yes/no): " CONFIRM
[ "$CONFIRM" != "yes" ] && { echo "Aborted."; exit 1; }

# Find the last partition number
PART_COUNT=$(lsblk -nlo NAME "${DEVICE}" | grep -c "${DEVICE##*/}")
echo "Found $PART_COUNT partitions on $DEVICE"

# Create persistence partition after the ISO
echo "Creating persistence partition..."
PART="${DEVICE}$((PART_COUNT + 1))"

sudo parted "${DEVICE}" mkpart primary ext4 "${SIZE}MiB" 100%
sudo mkfs.ext4 -L "NEXUSOS-PERSIST" "${PART}"

# Create the overlay image
mkdir -p /mnt/nexusos-persist
sudo mount "${PART}" /mnt/nexusos-persist
sudo dd if=/dev/zero of=/mnt/nexusos-persist/persistent_NexusOS.img bs=1M count=${SIZE}
sudo mkfs.ext4 /mnt/nexusos-persist/persistent_NexusOS.img
sudo umount /mnt/nexusos-persist

echo ""
echo "Persistence created successfully!"
echo ""
echo "To use it:"
echo "  Boot the USB and select 'NexusOS (Persistent USB)'"
echo "  All your files, apps, and settings will be saved."
echo ""
echo "Partition: ${PART}"
echo "Label:     NEXUSOS-PERSIST"
