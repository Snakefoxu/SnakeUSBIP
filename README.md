# 🦊 SnakeUSBIP - Free USB/IP Client for Windows

🌐 **Language / Idioma:** **English** | [Español](README_ES.md)

**v1.7.3** | [Download Latest](https://github.com/Snakefoxu/SnakeUSBIP/releases/latest) | [📖 User Manual](docs/USAGE_EN.md) | [🌐 VPN Connection](docs/VPN_INTERNET_EN.md)

**Share and connect USB devices over network (LAN/WiFi/Internet) easily.**
Transform any Linux device into a Virtual USB Hub accessible from Windows 10 and 11. Compatible with **Raspberry Pi, Orange Pi, Banana Pi, OpenWRT routers, CrealityBox** and any ARM/x86 board running Linux. Forget the command line; use our **modern GUI** to connect printers, scanners, and dongles remotely.

[![GitHub Downloads](https://img.shields.io/github/downloads/SnakeFoxu/SnakeUSBIP/total?style=flat-square&logo=github&color=blue)](https://github.com/SnakeFoxu/SnakeUSBIP/releases)
[![GitHub Stars](https://img.shields.io/github/stars/SnakeFoxu/SnakeUSBIP?style=flat-square&logo=github&color=yellow)](https://github.com/SnakeFoxu/SnakeUSBIP/stargazers)
[![License](https://img.shields.io/github/license/SnakeFoxu/SnakeUSBIP?style=flat-square&color=green)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%2010%2F11%20(x64%20%26%20ARM64)-lightgrey?style=flat-square&logo=windows)](https://github.com/SnakeFoxu/SnakeUSBIP)

## 🎬 Video Tutorial

<a href="https://www.youtube.com/watch?v=mETEs9INlq4">
  <img src="youtube_thumbnail.png" width="50%" alt="Video Tutorial">
</a>

▶️ **[Watch full tutorial on YouTube](https://www.youtube.com/watch?v=mETEs9INlq4)** (Spanish audio, visual guide)

## ✨ Features

- 🔍 **Auto-Discovery** - Scan for USB/IP servers on your local network
- 🌐 **Internet Connection** - Connect via Tailscale/ZeroTier (NAT traversal)
- 🔌 **Easy Connection** - Connect/disconnect devices with one click
- ⭐ **Favorites** - Save devices for quick reconnection
- 📋 **Activity Log** - History of connections, scans, and errors
- 🖥️ **Built-in SSH** - Configure Raspberry Pi servers directly
- 📋 **Detailed Info** - VID:PID and manufacturer for each device
- 🎨 **Modern GUI** - macOS-style interface with rounded buttons
- 🌐 **Multi-language** - English and Spanish
- 🔄 **Auto-update** - Detects new versions from GitHub

## 📦 Installation

### Option 1: Portable (Recommended)
1. Download from [Releases](https://github.com/Snakefoxu/SnakeUSBIP/releases/latest):
   - **Windows x64**: `SnakeUSBIP_v1.7.2_Portable.zip`
   - **Windows ARM64**: `SnakeUSBIP_v1.7.2_Portable-ARM64.zip` (Surface Pro X, etc.)
2. Extract the ZIP to any folder
3. Run `SnakeUSBIP.exe` as Administrator
4. Done!

### Option 2: Installer (x64 only)
1. Download `SnakeUSBIP_Setup_v1.7.0.exe` from [Releases](https://github.com/Snakefoxu/SnakeUSBIP/releases/latest)
2. Run the installer as Administrator
3. Follow the installation wizard

### Option 3: From source code
```powershell
# Requires PS2EXE (https://github.com/MScholtes/PS2EXE)
Invoke-PS2EXE -InputFile "SnakeUSBIP.ps1" -OutputFile "SnakeUSBIP.exe" -NoConsole -requireAdmin -iconFile "Logo-SnakeFoxU-con-e.ico"
```

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

### Real example: CrealityBox as USB server
```bash
# 1. SSH into your CrealityBox
ssh root@192.168.1.x

# 2. Install USB/IP
opkg update && opkg install usbip-server kmod-usb-ohci

# 3. Start the server
usbipd -D

# 4. Export the USB printer
usbip list -l          # List devices
usbip bind -b 1-1      # Export printer
```

Now connect from Windows with SnakeUSBIP and your 3D printer appears as if it were locally connected.

## 🚀 Upcoming Updates

**v1.8:**
- 🔄 Auto-Reconnect | 🌙 Dark Mode | 🔔 Notifications

**v2.0:**
- 🗜️ Data Compression | 📈 Performance Dashboard | 🏷️ Nicknames | 🔒 IP Filters

**v2.x:**
- 🖥️ Windows Server | 🐧 Cross-platform Client (Linux/Mac) | 🤖 Auto Detection

## 📁 Structure

```
Portable/
├── SnakeUSBIP.exe      # Main application
├── SnakeUSBIP.ps1      # PowerShell source code
├── usbipw.exe          # USB/IP client
├── devnode.exe         # Device manager
├── libusbip.dll        # USB/IP library
├── drivers/            # USB/IP drivers
├── usb.ids             # USB database
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
| **SnakeUSBIP** | **SnakeFoxu** | PowerShell GUI, VPN integration, documentation |

### Special Thanks

- 🦊 **Vadim Grn** - For the signed drivers that make USB/IP possible on Windows without test mode
- 🐙 **OctoWrt Community** - For showing the CrealityBox can be much more than a paperweight
- 🐧 **Linux USB/IP Team** - For creating the protocol that makes all this possible
