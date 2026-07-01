#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="nexusos"
iso_label="NEXUSOS_$(date +%Y%m)"
iso_publisher="NexusOS Project"
iso_application="NexusOS Live/Persistent USB"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
           'uefi-ia32.grub.esp' 'uefi-x64.grub.esp'
           'uefi-ia32.grub.eltorito' 'uefi-x64.grub.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '3' '-b' '256K')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/root/customize_os.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
)
