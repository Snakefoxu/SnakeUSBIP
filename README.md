# 🦊 SnakeUSBIP - Free USB/IP Client for Windows

🌐 **Language / Idioma:** **English** | [Español](README_ES.md)

**v2.0.0** | [Download Latest](https://github.com/Snakefoxu/SnakeUSBIP/releases/latest) | [📖 User Manual](docs/USAGE_EN.md) | [🌐 VPN Connection](docs/VPN_INTERNET_EN.md)

**Share and connect USB devices over network (LAN/WiFi/Internet) easily.**
Transform any Linux device into a Virtual USB Hub accessible from Windows 10 and 11. Compatible with **Raspberry Pi, Orange Pi, Banana Pi, OpenWRT routers, CrealityBox** and any ARM/x86 board running Linux.

[![Version](https://img.shields.io/badge/version-2.0.0-blue?style=flat-square)](https://github.com/SnakeFoxu/SnakeUSBIP/releases/latest)
[![.NET](https://img.shields.io/badge/.NET-9.0-purple?style=flat-square&logo=dotnet)](https://dotnet.microsoft.com/)
[![GitHub Downloads](https://img.shields.io/github/downloads/SnakeFoxu/SnakeUSBIP/total?style=flat-square&logo=github&label=downloads)](https://github.com/SnakeFoxu/SnakeUSBIP/releases)
[![GitHub Stars](https://img.shields.io/github/stars/SnakeFoxu/SnakeUSBIP?style=flat-square&logo=github&color=yellow)](https://github.com/SnakeFoxu/SnakeUSBIP/stargazers)
[![License](https://img.shields.io/badge/license-GPL%20v3-green?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Windows-x64%20%7C%20ARM64-0078D6?style=flat-square&logo=windows)](https://github.com/SnakeFoxu/SnakeUSBIP)

## 🎬 Video Tutorial

<a href="https://www.youtube.com/watch?v=mETEs9INlq4">
  <img src="youtube_thumbnail.png" width="50%" alt="Video Tutorial">
</a>

▶️ **[Watch full tutorial on YouTube](https://www.youtube.com/watch?v=mETEs9INlq4)** (Spanish audio, visual guide)

## 🆕 What's New in v2.0

- 🏗️ **Complete Rewrite** - Migrated from PowerShell to .NET 9 (C# / WPF)
- ⚡ **Ultra-Fast** - Native GUI with instant response times
- ✏️ **Rename Devices** - Assign custom names to USB devices (saved permanently)
- 📚 **Updated Database** - December 2025 `usb.ids` (+17,000 new devices)
- 🐛 **Bug Fixes** - Hardware ID conflicts resolved, cleaner logs

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

### Option 1: Portable (Recommended)
1. Download from [Releases](https://github.com/Snakefoxu/SnakeUSBIP/releases/latest):
   - **Windows x64**: `SnakeUSBIP-v2.0.0-x64.zip`
   - **Windows ARM64**: `SnakeUSBIP-v2.0.0-arm64.zip` (Surface Pro X, etc.)
2. Extract the ZIP to any folder
3. Run `SnakeUSBIP.exe` as Administrator
4. Done!

### Option 2: Installer (x64 only)
1. Download `SnakeUSBIP_Setup_v2.0.0.exe` from [Releases](https://github.com/Snakefoxu/SnakeUSBIP/releases/latest)
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

## 📄 License

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
