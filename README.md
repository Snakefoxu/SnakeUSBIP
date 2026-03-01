# 🦊 SnakeUSBIP - Free USB/IP Client for Windows

🌐 **Language / Idioma:** **English** | [Español](README_ES.md)

**v2.0.4** | [Download Latest](https://github.com/Snakefoxu/SnakeUSBIP/releases/latest) | [📖 User Manual](docs/USAGE_EN.md) | [🌐 VPN Connection](docs/VPN_INTERNET_EN.md) | [🖥️ Windows Server](https://github.com/SnakeFoxu/SnakeUSBIP-Server)

**Share and connect USB devices over network (LAN/WiFi/Internet) easily.**
Transform any Linux device into a Virtual USB Hub accessible from Windows 10 and 11. Compatible with **Raspberry Pi, Orange Pi, Banana Pi, OpenWRT routers, CrealityBox** and any ARM/x86 board running Linux.

[![GitHub Downloads](https://img.shields.io/github/downloads/SnakeFoxu/SnakeUSBIP/total?style=flat-square&logo=github&color=blue)](https://github.com/SnakeFoxu/SnakeUSBIP/releases)
[![GitHub Stars](https://img.shields.io/github/stars/SnakeFoxu/SnakeUSBIP?style=flat-square&logo=github&color=yellow)](https://github.com/SnakeFoxu/SnakeUSBIP/stargazers)
[![License](https://img.shields.io/github/license/SnakeFoxu/SnakeUSBIP?style=flat-square&color=green)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%2010%2F11%20(x64%20%26%20ARM64)-lightgrey?style=flat-square&logo=windows)](https://github.com/SnakeFoxu/SnakeUSBIP)

## 🎬 Video Tutorial

<a href="https://youtu.be/tICyZ-5VeWc">
  <img src="docs/demo.gif" width="50%" alt="Video Tutorial">
</a>

▶️ **[Watch full tutorial on YouTube](https://youtu.be/tICyZ-5VeWc)** (Spanish audio, visual guide)

## 🆕 What's New in v2.0.4

- 📦 **Hybrid Portable Mode** - ZIP releases store config locally, installer uses AppData
- 📚 **Updated USB Database** - February 2026 `usb.ids` with latest devices
- 🔧 **Improved Installer** - Option to install USB/IP drivers during setup
- © **Updated Copyright** - 2025-2026

### Previous: v2.0.2
- ️ **Complete Rewrite** - Migrated from PowerShell to .NET 9 (C# / WPF)
- 🔔 **Hybrid Notifications** - Custom popups + BalloonTips
- 💾 **Device Persistence** - Remembers connected devices

## ✨ Features

- 🔍 **Auto-Discovery** - Scan for USB/IP servers on your local network
- 🌐 **Internet Connection** - Connect via Tailscale/ZeroTier (NAT traversal)
- 🔌 **Easy Connection** - Connect/disconnect devices with one click
- ⭐ **Favorites** - Save devices for quick reconnection
- 📋 **Activity Log** - History of connections, scans, and errors
- 🖥️ **Built-in SSH** - Configure Raspberry Pi servers directly
- 📋 **Detailed Info** - VID:PID and manufacturer for each device
- 🎨 **Modern GUI** - Native WPF interface with dark/light themes
- 🌐 **Multi-language** - English and Spanish
- 🔄 **Auto-update** - Detects new versions from GitHub

## 📦 Installation

### Option 1: Portable 
1. Download from [Releases](https://github.com/Snakefoxu/SnakeUSBIP/releases/latest):
   - **Windows x64**: `SnakeUSBIP-v2.0.4-x64.zip`
   - **Windows ARM64**: `SnakeUSBIP-v2.0.4-arm64.zip` (Surface Pro X, etc.)
2. Extract the ZIP to any folder
3. Run `SnakeUSBIP.exe` as Administrator
4. Done!

### Option 2: Installer (x64 only) (Recommended)
1. Download `SnakeUSBIP_Setup_v2.0.4.exe` from [Releases](https://github.com/Snakefoxu/SnakeUSBIP/releases/latest)
2. Run the installer as Administrator
3. Follow the installation wizard

### ⚠️ ARM64 Users
ARM64 drivers are **test-signed**. See `README_ARM64.md` in the ZIP for instructions to enable Windows Test Mode.

## 🚀 Quick Start

1. **Scan** - Click `🔍 Scan` to find servers
2. **List** - Click `🔄 List` to see available devices
3. **Connect** - Double-click a device or right-click → Connect
4. **Disconnect** - Right-click → Disconnect

### 🌐 Internet Connection (VPN)

1. Install **[Tailscale](https://tailscale.com/download)** on Windows and your server
2. Click `🌐 VPN` to see peers with active USB/IP
3. Select a remote server and connect

See [docs/VPN_INTERNET_EN.md](docs/VPN_INTERNET_EN.md) for complete guide.

## 🐧 USB/IP Server (Linux)

Works on **any Linux device** with USB ports:

| Device | Compatibility |
|--------|---------------|
| 🍓 Raspberry Pi (all models) | ✅ Recommended |
| 🍊 Orange Pi / Banana Pi | ✅ |
| 📦 Arduino Yún / similar | ✅ |
| 📡 OpenWRT Routers | ✅ |
| 🖨️ CrealityBox (OpenWRT) | ✅ |
| 💻 Any Linux PC | ✅ |
| 🖥️ x86/ARM Server | ✅ |

See [docs/RASPBERRY_PI_SERVER_EN.md](docs/RASPBERRY_PI_SERVER_EN.md) for complete instructions.

## 🖥️ USB/IP Server (Windows) - NEW!

**SnakeUSBIP Server** is a GUI wrapper for [usbipd-win](https://github.com/dorssel/usbipd-win) that makes sharing USB devices from Windows simple.

### Features
- 🔧 **Auto-installation** of usbipd-win driver
- 📤 **One-click Share/Stop** for USB devices
- 🔒 **Single UAC prompt** at startup (no popups during use)
- 📛 **Descriptive device names** via WMI enrichment
- 🗑️ **Uninstall option** to clean up drivers

### Download
Download `SnakeUSBIP-Server-v2.2.zip` from [Releases](https://github.com/Snakefoxu/SnakeUSBIP/releases/latest)

### Quick Setup
1. Extract the ZIP
2. Run `SnakeUSBIP-Server.exe` as Administrator
3. Click **Share** on any USB device
4. Use SnakeUSBIP client to connect from another PC

**Quick setup (Debian/Ubuntu/Raspbian):**
```bash
sudo apt update && sudo apt install -y linux-tools-generic hwdata
sudo modprobe usbip_host
sudo usbipd -D
sudo usbip list -l
sudo usbip bind -b 1-1.4  # Replace with your bus-id
```

**OpenWRT:**
```bash
opkg update && opkg install usbip-server kmod-usb-ohci
usbipd -D
```

## 🎯 What can I do with my device?

Have a spare **Raspberry Pi, Orange Pi or CrealityBox**? Turn them into a remote USB Hub!

| Device | Use Case |
|--------|----------|
| 🖨️ **CrealityBox** | Share your 3D printer over network. Connect from any PC without cables |
| 🍓 **Raspberry Pi** | Central USB hub: scanners, license dongles, card readers |
| 🍊 **Orange Pi** | Compact and affordable USB server for office |
| 📡 **OpenWRT Router** | Share USB storage or printer from your router |
| 🔐 **License Dongle** | Share USB software keys (AutoCAD, etc.) between PCs |

## 📁 Structure

```
SnakeUSBIP/
├── SnakeUSBIP.exe      # Main application (.NET 9 WPF)
├── usbipw.exe          # USB/IP client
├── devnode.exe         # Device manager
├── libusbip.dll        # USB/IP library
├── drivers/            # USB/IP drivers (WHLK certified x64)
├── usb.ids             # USB database (Dec 2025)
├── CleanDrivers.ps1    # Driver cleanup script
└── Logo-SnakeFoxU-con-e.ico  # App icon
```

## ⚙️ Requirements

- Windows 10/11
- Administrator privileges
- Local network with USB/IP server

## �️ Roadmap

Planned features for future releases:

| Feature | Description | Status |
|---------|-------------|--------|
| 🔄 **Smart Reconnect** | Auto-reconnect with exponential backoff when connection drops | Planned |
| 📋 **Connection Profiles** | Save complete configs (server + device + VPN) as named profiles | Planned |
| 🔔 **Enhanced Tray** | Quick connect/disconnect from system tray with status indicators | Planned |
| 🩺 **Network Diagnostics** | Built-in connection tester (ping, latency, port check on TCP 3240) | Planned |
| 📊 **Device Dashboard** | Device type icons, real-time bandwidth and latency monitoring | Planned |
| 🧙 **Setup Wizard** | First-run guide: install drivers → scan → connect first device | Planned |
| 🌐 **Tailscale/ZeroTier API** | Auto-detect VPN peers with active USB/IP servers | Planned |
| 🌍 **More Languages** | German, French, Portuguese (community contributions welcome!) | Planned |
| 📱 **Android Companion** | Monitor USB/IP connections from your phone | Exploring |
| 🔌 **OctoPrint/Klipper Plugin** | Auto-configure USB/IP on Raspberry Pi with mDNS discovery | Exploring |

> 💡 **Have a feature idea?** Open an [Issue](https://github.com/Snakefoxu/SnakeUSBIP/issues) or start a [Discussion](https://github.com/Snakefoxu/SnakeUSBIP/discussions)!

## �📄 License

GPL v3 (GNU General Public License) - See [LICENSE](LICENSE)

## 🙏 Credits

This project wouldn't be possible without the work of:

| Project | Author | Contribution |
|---------|--------|--------------|
| [usbip-win2](https://github.com/vadimgrn/usbip-win2) | **Vadim Grn** | Microsoft-signed USB/IP drivers (WHLK certified). Core of the Windows client. |
| [OctoWrt](https://github.com/ihrapsa/OctoWrt) | **ihrapsa** | Original OpenWrt guide for CrealityBox. Inspiration for embedded device support. |
| [OctoWrt Fork](https://github.com/shivajiva101/OctoWrt) | **ShivaJiva** | Active OctoWrt maintenance. Updated releases for CrealityBox. |
| [USB/IP](https://www.kernel.org/doc/html/latest/usb/usbip_protocol.html) | **Linux Kernel** | Original USB/IP protocol |
| **SnakeUSBIP** | **SnakeFoxu** | .NET WPF GUI, VPN integration, documentation |

### Special Thanks

- 🦊 **Vadim Grn** - For the signed drivers that make USB/IP possible on Windows without test mode
- 🐙 **OctoWrt Community** - For showing the CrealityBox can be much more than a paperweight
- 🐧 **Linux USB/IP Team** - For creating the protocol that makes all this possible
