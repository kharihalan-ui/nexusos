.PHONY: all clean iso help

all: iso

help:
	@echo "NexusOS Build System"
	@echo ""
	@echo "  make iso      - Build ISO (needs Arch Linux + archiso)"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make test     - Test ISO in QEMU"
	@echo ""
	@echo "System requirements:"
	@echo "  Min RAM:  512 MB"
	@echo "  Rec RAM:  2 GB"
	@echo "  Storage:  10 GB free (for build)"
	@echo ""
	@echo "Prerequisites:"
	@echo "  sudo pacman -S archiso"

iso:
	@echo "Building NexusOS ISO..."
	@sudo bash build.sh all

clean:
	@echo "Cleaning..."
	@rm -rf out/

run: iso
	@echo "Launching in QEMU (2GB RAM)..."
	@qemu-system-x86_64 -enable-kvm -cdrom out/nexusos-*.iso -m 2048

test:
	@echo "To test with 512MB RAM:"
	@echo "  qemu-system-x86_64 -enable-kvm -cdrom out/nexusos-*.iso -m 512"
	@echo ""
	@echo "To test with 2GB RAM:"
	@echo "  qemu-system-x86_64 -enable-kvm -cdrom out/nexusos-*.iso -m 2048"
