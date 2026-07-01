# NexusOS

**macOS look · Windows compatibility · Ultra-lightweight**

A fast, macOS-inspired Linux distribution that runs on **512MB RAM minimum / 2GB recommended**, boots from USB with persistence, and runs Windows .exe files out of the box.

## System Requirements

| | Minimum | Recommended |
|---|---|---|
| **RAM** | 512 MB | 2 GB |
| **CPU** | 1 GHz single-core | 2 GHz dual-core |
| **Storage** | 4 GB (USB) | 8 GB+ (USB/SSD) |
| **Graphics** | VESA-compatible | Vulkan-capable |

## Features

- **macOS desktop** — XFCE + Plank dock themed to look like macOS (WhiteSur GTK theme)
- **Runs from USB** — Full persistence support; all changes saved
- **Low RAM optimized** — ZRAM swap, zswap, kernel tweaks, minimal services
- **Windows .exe support** — Wine pre-installed, right-click "Run with Wine"
- **Arch Linux base** — Rolling releases, AUR access, fastest package manager

## Download

Download the latest ISO from [pearos.xyz/downloads](https://pearos.xyz/downloads) or build it:

```bash
sudo pacman -S archiso git
git clone <this-repo> nexusos
cd nexusos
sudo make iso
```

Output: `out/nexusos-*.iso` (~1.2GB)

## Create Bootable USB

### Linux
```bash
sudo ./scripts/create-bootable-usb.sh out/nexusos-*.iso /dev/sdX
```

### Windows
Use **Rufus** (recommended) or **BalenaEtcher**.

## USB Persistence

After writing the ISO to USB, create a persistence partition to save your files and settings:

```bash
# On Linux, after writing the ISO:
sudo ./scripts/create-persistence.sh /dev/sdX
```

This creates a persistent overlay so all changes survive reboots.

## Boot Options

| Menu Entry | When to use |
|---|---|
| **Live** | Standard boot, runs entirely in RAM |
| **Persistent USB** | Boot with saved data (requires persistence setup) |
| **Safe Mode / 512MB RAM** | For very low-RAM machines (512 MB) |
| **Minimal** | Terminal only, no desktop (rescue mode) |

## Running Windows Apps

```
Right-click any .exe > "Run with Wine"
or
wine /path/to/app.exe
or
Open Bottles (GUI manager)
```

## Performance

Under 512MB RAM:
- Desktop idle: ~180-220 MB
- Firefox browsing: ~350-450 MB
- Running a .exe via Wine: ~280-400 MB

Under 2GB RAM (recommended):
- Desktop idle: ~200 MB
- Multiple apps + Wine: ~800 MB-1.2 GB

## Project Structure

```
nexusos/
├── profiledef.sh
├── packages.x86_64
├── pacman.conf
├── build.sh
├── Makefile
├── airootfs/
│   └── root/customize_os.sh
├── efiboot/
├── grub/
├── isolinux/
├── splash/
├── scripts/
│   ├── install.sh
│   ├── setup-wine.sh
│   ├── deploy-configs.sh
│   ├── generate-wallpaper.sh
│   ├── create-persistence.sh
│   └── create-bootable-usb.sh
└── airootfs/usr/share/nexusos/
    ├── xfce-config/      # XFCE macOS-like desktop config
    ├── panel-config/      # Panel layout
    ├── gtk-theme/         # GTK theme overrides
    └── plasma-wallpapers/ # Default wallpapers
```
