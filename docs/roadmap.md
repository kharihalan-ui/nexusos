# NexusOS Roadmap

**Target:** Min 512MB RAM · Recommended 2GB RAM · USB boot with persistence

## Phase 1 — Foundation (Months 1-2)
- [x] Build system (archiso profile)
- [x] Package selection (lightweight XFCE + Wine)
- [x] Boot configs (GRUB, systemd-boot, isolinux)
- [ ] First bootable ISO builds correctly
- [ ] Live session boots on 512MB VM
- [ ] Networking works (Wi-Fi, Ethernet)

## Phase 2 — macOS Look (Months 2-4)
- [x] XFCE top panel (macOS menu bar style)
- [x] Plank dock at bottom
- [x] WhiteSur GTK theme (macOS look)
- [ ] Custom wallpaper (macOS-style gradient)
- [ ] macOS-like window controls (traffic lights)
- [ ] Custom icon theme
- [ ] macOS cursor theme
- [ ] Boot splash screen (Plymouth)
- [ ] LightDM macOS-style login screen

## Phase 3 — Low-RAM Optimization (Months 4-6)
- [x] ZRAM swap (compressed RAM)
- [x] zswap configuration
- [x] Kernel tweaks (swappiness=5, etc.)
- [x] Minimal systemd services
- [ ] Test on real 512MB hardware
- [ ] Compile custom lightweight kernel
- [ ] Profile and optimize memory usage

## Phase 4 — Windows Compatibility (Months 6-8)
- [x] Wine pre-installed
- [x] Right-click "Run with Wine"
- [x] Winetricks for DLL/runtime install
- [ ] DXVK for DirectX games
- [ ] Proton for Steam
- [ ] Bottles (GUI Windows app manager)
- [ ] .exe file association
- [ ] Auto-run Wine setup on first boot

## Phase 5 — USB Persistence (Months 8-10)
- [x] GRUB persistent USB boot entry
- [x] Persistence script (create-persistence.sh)
- [ ] Overlay filesystem tuning
- [ ] Test live persistence workflow
- [ ] Auto-detect persistence partition

## Phase 6 — Polish & Release (Months 10-12)
- [ ] Custom installer (Calamares)
- [ ] System settings app (macOS-like)
- [ ] App store (Pamac or Octopi)
- [ ] Release ISO publicly
- [ ] Documentation website
