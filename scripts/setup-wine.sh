#!/usr/bin/env bash
#
# Quick Wine setup for Windows app compatibility
# Run after fresh install
#

set -euo pipefail

echo "=== NexusOS Wine Setup ==="

# Install Wine packages
sudo pacman -S --noconfirm --needed wine wine-mono wine-gecko winetricks

# Create Wine prefix
export WINEPREFIX="${HOME}/.wine"
echo "Creating default Wine prefix..."
wineboot -u 2>/dev/null || true
sleep 2

# Install essential Windows components
echo "Installing core fonts and VC++ runtimes..."
winetricks -q corefonts vcrun2022 2>/dev/null || true

# Add right-click integration for Thunar
mkdir -p "${HOME}/.config/Thunar"
cat > "${HOME}/.config/Thunar/uca.xml" << 'EOF'
<?xml encoding="UTF-8" version="1.0"?>
<actions>
<action>
    <icon>wine</icon>
    <name>Run with Wine</name>
    <unique-id>run-with-wine</unique-id>
    <command>wine %f</command>
    <description>Run executable with Wine</description>
    <patterns>*.exe;*.msi;*.bat</patterns>
    <other-files/>
</action>
</actions>
EOF

echo ""
echo "=== Wine is ready! ==="
echo "Run any .exe:  wine /path/to/app.exe"
echo "Or right-click > Run with Wine in Thunar"
echo "Or use Bottles for app management"
