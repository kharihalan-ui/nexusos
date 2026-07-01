#!/usr/bin/env bash
#
# NexusOS Build Script
# Creates bootable ISO with macOS look + Windows compat
# System requirements: min 512MB RAM, recommended 2GB
#
# Prerequisites: archiso (pacman -S archiso)
# Usage: sudo ./build.sh [all|clean|build]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="/tmp/nexusos-build"
OUTPUT_DIR="${SCRIPT_DIR}/out"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[BUILD]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Clean build artifacts
clean() {
    log "Cleaning previous build..."
    rm -rf "${WORK_DIR}"
    mkdir -p "${WORK_DIR}" "${OUTPUT_DIR}"
}

# Check dependencies
check_deps() {
    log "Checking dependencies..."
    command -v mkarchiso &>/dev/null || err "archiso not installed. Run: sudo pacman -S archiso"
    command -v pacman &>/dev/null || err "Must run on Arch Linux"
}

# Build the ISO image
build_iso() {
    log "Building NexusOS ISO..."
    log "This takes 15-30 minutes on modern hardware."
    warn "Target: 512MB RAM min / 2GB recommended"

    cd "${SCRIPT_DIR}"

    # Copy profile to work directory
    mkdir -p "${WORK_DIR}/profile"
    cp -r \
        profiledef.sh \
        packages.x86_64 \
        pacman.conf \
        airootfs \
        efiboot \
        grub \
        splash \
        "${WORK_DIR}/profile/"

    # Build with archiso
    mkarchiso -v -w "${WORK_DIR}/iso-work" -o "${OUTPUT_DIR}" "${WORK_DIR}/profile"

    # Show result
    local iso_file
    iso_file=$(ls "${OUTPUT_DIR}/nexusos-"*.iso 2>/dev/null || true)
    if [ -n "$iso_file" ]; then
        log "Build successful!"
        ls -lh "$iso_file"
    else
        err "Build failed - ISO not found"
    fi
}

# Create checksums
checksum() {
    log "Creating checksums..."
    cd "${OUTPUT_DIR}"
    sha256sum nexusos-*.iso > nexusos-iso.sha256
    log "Checksum: $(cat nexusos-iso.sha256)"
}

# Main dispatch
case "${1:-all}" in
    clean)
        clean
        ;;
    build)
        check_deps
        build_iso
        ;;
    checksum)
        checksum
        ;;
    all)
        check_deps
        clean
        build_iso
        checksum
        log "Done! ISO in ${OUTPUT_DIR}/"
        log "Size: $(du -h "${OUTPUT_DIR}/nexusos-"*.iso | cut -f1)"
        ;;
    *)
        echo "Usage: $0 {clean|build|checksum|all}"
        echo ""
        echo "  clean     - Remove build artifacts"
        echo "  build     - Build the ISO"
        echo "  checksum  - Create SHA256"
        echo "  all       - Clean + build + checksum"
        exit 1
        ;;
esac
