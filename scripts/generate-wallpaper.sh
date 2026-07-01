#!/usr/bin/env bash
#
# Generate macOS-style gradient wallpaper for NexusOS
# Needs ImageMagick: sudo pacman -S imagemagick
#
# Usage: ./generate-wallpaper.sh [output] [width] [height]
#

set -euo pipefail

OUTPUT="${1:-nexusos-wallpaper.png}"
WIDTH="${2:-1920}"
HEIGHT="${3:-1080}"

echo "Generating ${WIDTH}x${HEIGHT} wallpaper: ${OUTPUT}"

# macOS Big Sur / Monterey style gradient
convert -size "${WIDTH}x${HEIGHT}" \
    -define gradient:angle=135 \
    gradient:'#1a1a2e-#16213e' \
    -fill 'rgba(255,255,255,0.04)' \
    -draw "circle $((WIDTH*2/3)),$((HEIGHT/3)) $((WIDTH*2/3)),$((HEIGHT/2))" \
    -fill 'rgba(255,255,255,0.02)' \
    -draw "circle $((WIDTH/3)),$((HEIGHT*2/3)) $((WIDTH/3)),$((HEIGHT*3/4))" \
    -fill 'rgba(10,132,255,0.03)' \
    -draw "circle $((WIDTH/2)),$((HEIGHT/2)) $((WIDTH/2)),$((HEIGHT*3/5))" \
    "${OUTPUT}"

echo "Wallpaper saved: ${OUTPUT}"

# Also generate a login screen version (lighter)
OUTPUT_LOGIN="${OUTPUT%.*}-login.${OUTPUT##*.}"
convert -size "${WIDTH}x${HEIGHT}" \
    -define gradient:angle=135 \
    gradient:'#1e1e2e-#181825' \
    "${OUTPUT_LOGIN}"

echo "Login wallpaper saved: ${OUTPUT_LOGIN}"
