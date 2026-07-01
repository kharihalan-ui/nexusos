#!/usr/bin/env bash
#
# NexusOS Post-Installation Setup
# Run after first boot to complete configuration
#

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
cmd()  { echo -e "${CYAN}[RUN]${NC} $1"; }

log "========================================="
log "  NexusOS Post-Install Setup"
log "  Min RAM: 512MB | Recommended: 2GB"
log "========================================="

# --- Update system ---
log "Updating system..."
sudo pacman -Syu --noconfirm

# --- Install AUR helper (yay) ---
if ! command -v yay &>/dev/null; then
    log "Installing yay (AUR helper)..."
    cd /tmp
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay-bin
fi

# --- Install optional AUR packages ---
log "Installing AUR packages..."
yay -S --noconfirm --needed \
    dxvk-bin \
    vkd3d-proton-bin \
    whitesur-cursor-theme

# --- Configure ZRAM (compressed RAM swap) ---
log "Setting up ZRAM swap..."
echo "zram" | sudo tee /etc/modules-load.d/zram.conf
echo 'options zswap zswap_enabled=1 compressor=lz4 max_pool_percent=25' | sudo tee /etc/modprobe.d/zswap.conf

# --- Wine configuration ---
log "Configuring Wine for Windows app support..."
if [ ! -d ~/.wine ]; then
    log "Creating Wine prefix (this may take a moment)..."
    wineboot -u 2>/dev/null || true
    sleep 3
    log "Installing core components..."
    winetricks -q corefonts vcrun2022 2>/dev/null || true
fi

# --- Set compositor to picom (lightweight) ---
log "Setting up picom compositor..."
mkdir -p ~/.config
cat > ~/.config/picom.conf << 'EOF'
backend = "glx";
vsync = true;
fading = true;
fade-delta = 5;
fade-in-step = 0.03;
fade-out-step = 0.03;
shadow = true;
shadow-radius = 12;
shadow-offset-x = -5;
shadow-offset-y = -5;
shadow-opacity = 0.3;
corner-radius = 8;
rounded-corners-exclude = [
  "class_g = 'Plank'"
];
EOF

# --- Enable autostart for picom ---
cat > ~/.config/autostart/picom.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=picom
Exec=picom --config ~/.config/picom.conf
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
X-XFCE-Autostart-enabled=true
EOF

# --- Firefox preferences ---
log "Setting Firefox preferences..."
mkdir -p ~/.mozilla
cat > ~/.mozilla/firefox-user.js << 'EOF'
user_pref("browser.startup.homepage", "about:blank");
user_pref("browser.search.defaultenginename", "DuckDuckGo");
user_pref("browser.urlbar.suggest.history", false);
user_pref("media.autoplay.default", 5);
EOF

# --- AppImage support ---
mkdir -p ~/Applications
log "AppImage support ready (save apps to ~/Applications)"

# --- Flatpak support ---
log "Setting up Flatpak..."
sudo pacman -S --noconfirm --needed flatpak 2>/dev/null || true
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true

# --- Enable TRIM (SSD optimization) ---
sudo systemctl enable --now fstrim.timer 2>/dev/null || true

# --- File manager right-click: Run with Wine ---
mkdir -p ~/.local/share/Thunar
cp /etc/skel/.config/Thunar/uca.xml ~/.local/share/Thunar/uca.xml 2>/dev/null || true

# --- Done ---
log ""
log "========================================="
log "  Setup complete!"
log "========================================="
log ""
log "Quick tips:"
log "  - Super+E: File manager"
log "  - Super+T: Terminal"
log "  - Super+F: Firefox"
log "  - Right-click .exe > 'Run with Wine'"
log "  - Or: wine /path/to/app.exe"
log ""
log "System monitoring:"
log "  - htop    (process viewer)"
log "  - stats   (memory, swap, CPU)"
log "  - fastfetch (system info)"
log ""
log "Welcome to NexusOS!"
