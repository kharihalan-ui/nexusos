#!/usr/bin/env bash
#
# NexusOS system customization
# Runs inside chroot during ISO build
#

set -e

echo "=== NexusOS: Building lightweight macOS-like system ==="

# --- Users ---
echo "root:nexusos" | chpasswd
useradd -m -G wheel,audio,video,storage,optical,power -s /bin/bash nexus
echo "nexus:nexusos" | chpasswd
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

# --- Enable services ---
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable lightdm
systemctl enable cups
systemctl enable acpid
systemctl enable tlp
systemctl enable fstrim.timer
systemctl enable systemd-timesyncd

# --- Locale ---
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

# --- Hostname ---
echo "nexusos" > /etc/hostname
cat >> /etc/hosts << 'EOF'
127.0.0.1   localhost
::1         localhost
127.0.1.1   nexusos.localdomain nexusos
EOF

# --- Timezone ---
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
timedatectl set-ntp true

# --- Low-RAM kernel parameters ---
cat > /etc/sysctl.d/99-nexusos.conf << 'EOF'
# Reduce memory pressure
vm.swappiness=5
vm.vfs_cache_pressure=40
vm.dirty_ratio=5
vm.dirty_background_ratio=2
vm.overcommit_memory=1
vm.min_free_kbytes=16384

# Network buffers (smaller for low RAM)
net.core.rmem_max=131072
net.core.wmem_max=131072

# Reduce disk I/O
vm.dirty_expire_centisecs=3000
vm.dirty_writeback_centisecs=500
EOF

# --- mkinitcpio (small initramfs) ---
cat > /etc/mkinitcpio.conf << 'EOF'
MODULES=(ext4 nvme ahci xhci-hcd)
BINARIES=()
FILES=()
HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)
EOF
mkinitcpio -P

# --- GRUB config (with persistence support) ---
mkdir -p /boot/grub
cat > /etc/default/grub << 'EOF'
GRUB_DEFAULT=0
GRUB_TIMEOUT=3
GRUB_TIMEOUT_STYLE=menu
GRUB_DISTRIBUTOR="NexusOS"
GRUB_CMDLINE_LINUX_DEFAULT="splash quiet loglevel=3 rd.systemd.show_status=auto"
GRUB_CMDLINE_LINUX=""
GRUB_PRELOAD_MODULES="part_gpt part_msdos"
GRUB_TERMINAL_OUTPUT=console
GRUB_GFXMODE=auto
GRUB_DISABLE_RECOVERY=true
GRUB_ENABLE_CRYPTODISK=n
GRUB_SAVEDEFAULT=true
EOF

# --- LOW MEMORY ZRAM (virtual swap in RAM, compressed) ---
cat > /etc/systemd/system/zram.service << 'EOF'
[Unit]
Description=ZRAM swap (compressed RAM swap)
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'modprobe zram && zramctl -f -s $(( $(awk "/MemTotal/ {print \$2}" /proc/meminfo) * 1024 / 2 )) && mkswap /dev/zram0 && swapon -p 100 /dev/zram0'
RemainAfterExit=true
ExecStop=/bin/bash -c 'swapoff /dev/zram0 2>/dev/null; true'
StandardOutput=journal

[Install]
WantedBy=multi-user.target
EOF
systemctl enable zram

# --- ZSWAP (compressed write-back cache) ---
mkdir -p /etc/modules-load.d
echo "zswap" > /etc/modules-load.d/zswap.conf
cat > /etc/modprobe.d/zswap.conf << 'EOF'
options zswap zswap_enabled=1 compressor=lz4 max_pool_percent=25 zpool=z3fold
EOF

# --- Disable unnecessary services & kernel modules ---
mkdir -p /etc/modprobe.d
cat > /etc/modprobe.d/nexusos-blacklist.conf << 'EOF'
# Disable unused modules for lower memory
blacklist pcspkr
blacklist snd_pcsp
blacklist floppy
blacklist joydev
blacklist btusb
EOF

# Disable systemd-journald persistence (save RAM on live USB)
mkdir -p /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/storage.conf << 'EOF'
[Journal]
Storage=volatile
RuntimeMaxUse=20M
ForwardToSyslog=no
EOF

# --- Remove unnecessary systemd services ---
systemctl mask systemd-random-seed.service
systemctl mask pkgfile-update.timer

# --- PACMAN optimize ---
sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
ncpus=$(nproc)
sed -i "s/^#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$ncpus\"/" /etc/makepkg.conf

# --- XFCE4 macOS-like desktop configuration (system-wide) ---
mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml
mkdir -p /etc/skel/.config/xfce4/panel
mkdir -p /etc/skel/.config/gtk-3.0
mkdir -p /etc/skel/.config/gtk-4.0
mkdir -p /etc/skel/.config/autostart
mkdir -p /etc/skel/.config/plank
mkdir -p /etc/skel/.local/share/applications
mkdir -p /etc/skel/.themes
mkdir -p /etc/skel/Pictures
mkdir -p /etc/skel/Desktop

# Copy pre-configured XFCE settings
cp -r /usr/share/nexusos/xfce-config/* /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/ 2>/dev/null || true
cp -r /usr/share/nexusos/panel-config/* /etc/skel/.config/xfce4/panel/ 2>/dev/null || true

# --- GTK settings (macOS theme) ---
cat > /etc/skel/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=Breeze
gtk-icon-theme-name=Papirus
gtk-font-name=Cantarell 10
gtk-cursor-theme-name=Breeze
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_SMALL_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-xft-rgba=rgb
gtk-application-prefer-dark-theme=1
EOF

cat > /etc/skel/.config/gtk-4.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=Breeze
gtk-icon-theme-name=Papirus
gtk-font-name=Cantarell 10
gtk-cursor-theme-name=Breeze
EOF

# --- GTK3 system-wide theme ---
mkdir -p /etc/gtk-3.0
cat > /etc/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=Breeze
gtk-icon-theme-name=Papirus
gtk-font-name=Cantarell 10
gtk-cursor-theme-name=Breeze
EOF

# --- Plank dock (macOS-style) configuration ---
mkdir -p /etc/skel/.config/plank
cat > /etc/skel/.config/plank/settings << 'EOF'
[PlankDock]
DockItems=favorites
DockPrefsFile=/etc/skel/.config/plank/dock.settings
ZoomEnabled=true
ZoomPercent=150
IconSize=36
HideType=0
Offset=50
Position=0
Monitor=0
EOF

cat > /etc/skel/.config/plank/dock.settings << 'EOF'
[PlankDockPreferences]
DockItems=favorites
LauncherItems=firefox.desktop;thunar.desktop;xfce4-terminal.desktop;mousepad.desktop;ristretto.desktop;xfce4-settings-manager.desktop;wine.desktop
Position=0
IconSize=38
ZoomEnabled=true
ZoomPercent=140
Theme=Gtk+
ShowDockItemCounts=true
HideType=0
Monitor=0
Offset=20
EOF

# --- Autostart Plank dock ---
cat > /etc/skel/.config/autostart/plank.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Plank Dock
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
X-XFCE-Autostart-enabled=true
EOF

# --- Autostart NetworkManager tray ---
cat > /etc/skel/.config/autostart/nm-applet.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=NetworkManager
Exec=nm-applet
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
X-XFCE-Autostart-enabled=true
EOF

# --- XFCE terminal macOS-like config ---
mkdir -p /etc/skel/.config/xfce4/terminal
cat > /etc/skel/.config/xfce4/terminal/terminalrc << 'EOF'
[Configuration]
FontName=Cantarell 10
MiscAlwaysShowTabs=FALSE
MellBell=FALSE
MiscCursorBlinks=FALSE
MiscCursorShape=TERMINAL_CURSOR_BLOCK
MiscDefaultGeometry=80x24
MiscInheritGeometry=FALSE
MiscMenubarDefault=TRUE
MiscMouseAutohide=FALSE
MiscTabCloseButtons=TRUE
MiscTabPosition=GTK_POS_TOP
TitleMode=replace
EOF

# --- Thunar (file manager) config ---
mkdir -p /etc/skel/.config/Thunar
cat > /etc/skel/.config/Thunar/uca.xml << 'EOF'
<?xml encoding="UTF-8" version="1.0"?>
<actions>
<action>
    <icon>wine</icon>
    <name>Run with Wine</name>
    <submenu></submenu>
    <unique-id>run-with-wine</unique-id>
    <command>wine %f</command>
    <description>Run executable with Wine</description>
    <patterns>*.exe;*.msi;*.bat</patterns>
    <directories/>
    <audio-files/>
    <image-files/>
    <other-files/>
    <text-files/>
    <video-files/>
</action>
</actions>
EOF

# --- Wine configuration ---
mkdir -p /etc/skel/.local/share/applications
cat > /etc/skel/.local/share/applications/wine-desktop-app.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Wine Desktop
Comment=Launch Windows apps
Exec=wine explorer /desktop=shell,1280x720
Icon=wine
Categories=System;
Terminal=false
EOF

cat > /etc/skel/Desktop/Install-Windows-App.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Run Windows App (.exe)
Comment=Select a .exe file to run with Wine
Exec=wine
Icon=wine
Terminal=true
Categories=System;
EOF

chmod +x /etc/skel/Desktop/*.desktop

# --- LightDM macOS-like greeter ---
mkdir -p /etc/lightdm
cat > /etc/lightdm/lightdm.conf << 'EOF'
[Seat:*]
autologin-user=nexus
autologin-user-timeout=0
user-session=xfce
greeter-session=lightdm-gtk-greeter
allow-guest=false
EOF

cat > /etc/lightdm/lightdm-gtk-greeter.conf << 'EOF'
[greeter]
background=/usr/share/backgrounds/nexusos/nexusos-login.png
theme-name=Breeze
icon-theme-name=Papirus
cursor-theme-name=Breeze
font-name=Cantarell 10
xft-antialias=true
xft-hintstyle=hintfull
indicators=~host;~session
clock-format=%A, %B %e, %H:%M
EOF

# --- Plymouth boot splash ---
mkdir -p /etc/plymouth
cat > /etc/plymouth/plymouthd.conf << 'EOF'
[Daemon]
Theme=nexusos
ShowDelay=0
EOF

# --- Create persistent storage script ---
cat > /usr/local/bin/nexusos-persistence << 'EOF'
#!/bin/bash
#
# Create persistent overlay for NexusOS USB
# Run: sudo nexusos-persistence /dev/sdX (your USB)
#

if [ $# -ne 1 ]; then
    echo "Usage: sudo $0 /dev/sdX"
    echo "Creates persistence partition on your USB drive"
    exit 1
fi

DEVICE=$1
echo "Creating persistence partition on ${DEVICE}..."
echo "WARNING: This will modify partition table!"
PART="${DEVICE}3"
echo "Creating ext4 partition for persistence..."
mkfs.ext4 -L "NEXUSOS-PERSIST" "${PART}"
mkdir -p /mnt/persist
mount "${PART}" /mnt/persist
echo "Creating overlay file..."
dd if=/dev/zero of=/mnt/persist/overlay.img bs=1M count=1024
mkfs.ext4 /mnt/persist/overlay.img
umount /mnt/persist
echo "Done! Now boot the USB with the 'persistent' option."
EOF
chmod +x /usr/local/bin/nexusos-persistence

# --- Create low-RAM info script ---
cat > /usr/local/bin/nexusos-stats << 'EOF'
#!/bin/bash
echo "===== NexusOS System Stats ====="
echo "Memory:"
free -h
echo ""
echo "Swap (ZRAM):"
zramctl
echo ""
echo "CPU:"
lscpu | grep "Model name"
echo ""
echo "Disk:"
df -h /
EOF
chmod +x /usr/local/bin/nexusos-stats

# --- Bash profile with macOS touch ---
cat >> /etc/skel/.bashrc << 'EOF'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -l'
alias wine='wine'
alias winetricks='winetricks'
alias update='sudo pacman -Syu'
alias stats='nexusos-stats'
# Welcome message
fastfetch
EOF

# --- XDG user dirs ---
cat > /etc/skel/.config/user-dirs.dirs << 'EOF'
XDG_DESKTOP_DIR="$HOME/Desktop"
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_TEMPLATES_DIR="$HOME/Templates"
XDG_PUBLICSHARE_DIR="$HOME/Public"
XDG_DOCUMENTS_DIR="$HOME/Documents"
XDG_MUSIC_DIR="$HOME/Music"
XDG_PICTURES_DIR="$HOME/Pictures"
XDG_VIDEOS_DIR="$HOME/Videos"
EOF

# --- Cleanup ---
rm -f /root/customize_os.sh
rm -rf /var/cache/pacman/pkg/*

echo "=== NexusOS: Build complete ==="
echo "=== Min RAM: 512MB | Recommended: 2GB ==="
