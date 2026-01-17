# Thingino Installers

**Easy-to-use SD card installers for flashing Thingino firmware on supported IP cameras**

This repository provides pre-built SD card images that make it simple to install [Thingino](https://thingino.com) open-source firmware on various IP camera models. Each installer creates a bootable SD card that will automatically flash your camera and when possible create a backup of the original firmware for easy reversal. Some cameras require disassembly and doing a flash glitch to start the process, which is explained in the documentation for cameras that require it, and demonstrated in the videos.

## 🎯 What is This Repository For?

- **End Users**: Download ready-to-use SD card installers for your specific camera model
- **Developers**: Build custom installers using the included build scripts
- **Tinkerers**: Access tools and assets for creating Thingino firmware images

## 📋 Before You Start - Important Information

### ⚠️ Read This First

1. **Camera-Specific Instructions**: Each camera model has its own subdirectory with specific installation instructions. **Always follow the README in your camera's folder** - this overrides any general guidance or video instructions.

2. **Backup Creation**: Soe some devices, the installation process automatically creates a backup of your original firmware. **Save this backup file** - it's unique to your specific camera and required for reverting to stock firmware. If the README for your cam doesn't state that the process is reversible, the installer does NOT create a backup and threfore installing Thingino is a one-way street. If you need to be able to revert, you will need to use a flash programmer to make a backup of your firmware before flashing Thingino!

3. **Firmware Updates**: The installers contain firmware images that are updated approximately weekly. After installation, perform a full firmware upgrade through the web interface or SSH to get the latest features and security updates.

4. **Reversible Process**: Installation is fully reversible for some cams, using the backup created during the process. See your camera's specific README for reversal instructions.

### 🎥 Video Tutorials & Support

- **Installation Videos**: Available for each supported model at [WL Tech Blog YouTube Channel](https://www.youtube.com/@wltechblog)
- **Community Support**: Join the [Hacker's Homestead Discord](https://discord.gg/s6yJzhS4hD) for help and troubleshooting

## 🎯 About Thingino

Thingino is an open-source firmware replacement for Ingenic-powered devices, primarily IP cameras. It provides:
- Enhanced privacy and security
- Local control without cloud dependencies
- Advanced features and customization options
- Active community development and support

**Learn More**: [Thingino Homepage](https://thingino.com) | [Thingino Firmware Repository](https://github.com/themactep/thingino-firmware)

## 📱 Supported Camera Models

This repository includes installers for the following camera models:

| Brand | Model | Installer Directory |
|-------|-------|-------------------|
| AOQEE | C1 | `aoqee-c1/` |
| AOSU | C5L | `aosu-c5l/` |
| Cinnado | D1 | `cinnado-d1/` |
| Galayou | G7 | `galayou-g7/` |
| Galayou | Y4 | `galayou-y4/` |
| JOOAN | A2R-U | `jooan-a2r-u/` |
| JOOAN | A6M-U | `jooan-a6m-u/` |
| JOOAN | Q3R | `jooan-q3r/` |
| Sonoff | B1P (CAM Outdoor) | `sonoff-b1p/` |
| Sonoff | PT2 (CAM Pan-Tilt 2) | `sonoff-pt2/` |
| Sonoff | Slim Gen 2 | `sonoff-slim-gen-2/` |
| SZT | CT213 | `szt-ct213/` |
| Wansview | G6 | `wansview-g6/` |
| Wansview | W7 | `wansview-w7/` |
| WUUK | Y0310 | `wuuk-y0310/` |
| WUUK | Y0510 | `wuuk-y0510/` |
| Wyze | Cam V2 | `wyze-cam-2/` |
| Wyze | Cam V3 | `wyze-cam-3/` |
| Wyze | Cam Pan V1 | `wyze-cam-pan-v1/` |
| Wyze | Cam Pan V2 | `wyze-cam-pan-v2/` |

> **Note**: Some models may have multiple variants with different chipsets or WiFi modules. Check your camera's specific directory for the correct installer.


### For Developers (Building Custom Installers)

The included `make_installers.sh` script creates all installer images with firmware caching for speed and version pinning.

**Requirements**: Linux host (or Docker for other platforms)

#### Building on Linux
```bash
./make_installers.sh all
```

You can also specity a specific target to build, for example:
```bash
./make_installers.sh wyze_cam_2
```

Running without an argument will display the available targets.


## ⚖️ Legal & Warranty Disclaimer

**This is a hobbyist project provided "as-is" without warranty of any kind.**

- Instructions and tools are best-effort and tested on specific device purchases
- Future hardware/software revisions may cause compatibility issues
- While camera "bricking" is unlikely, it can happen and recovery may require additional tools

**For support**: Join our Discord community rather than filing individual bug reports - collaborative troubleshooting is more effective for this type of project.
