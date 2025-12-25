# 📖 SnakeUSBIP Usage Guide

> **v2.0.0** - This documentation applies to the WPF (.NET 9) version. The interface is similar to v1.x but with improved performance.

## Main Interface

```
╔═══════════════════════════════════════════════════════════════════╗
║ 🦊 SnakeFoxu   USB/IP Manager   [ENG] [🔄 Update]      🟡 🟢 🔴  ║
╠═══════════════════════════════════════════════════════════════════╣
║  Server:   ┌──────────────┐ ┌────────┐┌──────┐┌─────┐┌─────────┐  ║
║            │192.168.1.100 │ │🔍 Scan ││🔄List││🖥️SSH││🌐 VPN  │  ║
║            └──────────────┘ └────────┘└──────┘└─────┘└─────────┘  ║
╠═══════════════════════════════════════════════════════════════════╣
║  📡 USB Hubs (3)                                                  ║
║   ├─ 🖥️ 192.168.1.100 (2)                                        ║
║   │   ├─ 📱 1-1.2: Arduino Uno (2341:0043)                        ║
║   │   └─ 🖨️ 1-1.4: HP LaserJet (03f0:002a)                       ║
║   └─ 🖥️ 192.168.1.101 (1)                                        ║
║       └─ 💾 1-1.1: SanDisk USB (0781:5567)                        ║
║                                                                   ║
║  ✅ Connected Devices (1)                                         ║
║   └─ 🔌 Port 00: Arduino Uno ← 192.168.1.100                      ║
║                                                                   ║
║  ⭐ Favorites (2)                                                 ║
║   ├─ 🖨️ 1-1.4 @ 192.168.1.100                                    ║
║   └─ 💾 1-1.1 @ 192.168.1.101                                     ║
╠═══════════════════════════════════════════════════════════════════╣
║ 📋 Activity Log                                        [Clear]    ║
╠───────────────────────────────────────────────────────────────────╣
║ [14:32:15] ✅ Connected: Arduino Uno (1-1.2) from 192.168.1.100   ║
║ [14:32:10] 🔍 Scanning network 192.168.1.0/24...                  ║
║ [14:32:12] ✅ 2 server(s) found                                   ║
╠═══════════════════════════════════════════════════════════════════╣
║  ✓ Ready        Drivers: ✅ Installed       [Install][Uninstall] ║
╚═══════════════════════════════════════════════════════════════════╝
```

## Main Actions

| Button | Description |
|--------|-------------|
| 🔍 Scan | Find USB/IP servers on your local network (port 3240) |
| 🔄 List | Show USB devices available on the server |
| 🖥️ SSH | Open SSH configuration for Raspberry Pi |
| 🌐 VPN | Connect to remote servers via Tailscale/ZeroTier |

## Context Menu (Right-Click)

```
        ┌─────────────────────────┐
        │ 🔌 Connect              │
        │ ❌ Disconnect           │
        ├─────────────────────────┤
        │ ⭐ Add to Favorites     │
        │ ❌ Remove from Favorites│
        │ 🗑️ Remove server        │
        ├─────────────────────────┤
        │ ✏️ Rename               │ 🆕 v2.0
        │ 📋 Properties           │
        └─────────────────────────┘
```

| Option | Description |
|--------|-------------|
| 🔌 Connect | Attach the remote USB device to your PC |
| ❌ Disconnect | Release the connected USB device |
| ⭐ Add to Favorites | Save device for quick reconnection |
| ❌ Remove from Favorites | Remove from favorites list |
| 🗑️ Remove server | Remove server from tree |
| ✏️ Rename | Assign a custom name to the device (🆕 v2.0) |
| 📋 Properties | Show detailed info (VID:PID, manufacturer, etc.) |

## Keyboard Shortcuts

- **Double-click** on device → Connect
- **Enter** in IP field → List devices
- **F5** → Refresh list

## Favorites

Favorites are saved in `config.json` and can auto-reconnect on startup.

## Activity Log

The bottom panel shows real-time event history:

| Icon | Type | Description |
|------|------|-------------|
| ✅ | Success | Successful connections, servers found, drivers OK |
| ❌ | Error | Connection failures, timeouts, unavailable devices |
| 🔍 | Info | Scans in progress, informational operations |
| ⚠️ | Warning | Minor issues, incomplete configuration |

## System Tray

- When **minimized**, the app hides to system tray (🦊 icon)
- **Double-click** the icon to restore the window
- **Right-click** for quick menu: Scan Network, Show Window, Exit
- The app runs in background until you click "Exit"

## Language Toggle

Use the **[🌐 ENG]** or **[🌐 ESP]** button in the title bar to switch between English and Spanish. The setting is saved automatically.

## Driver Status Bar

```
║  ✓ Ready        Drivers: ✅ Installed       [Install][Uninstall] ║
```

- **Install** - Install USB/IP drivers
- **Uninstall** - Remove drivers (may require restart)

> ⚠️ **Important:** First driver installation may require Windows restart.

---

## Troubleshooting

### "No server found"
1. Verify USB/IP server is running: `sudo usbipd` on Linux
2. Check that port 3240 is open in firewall
3. Verify you're on the same subnet (e.g., 192.168.1.x)

### "Error connecting device"
1. Ensure drivers are installed (check status bar)
2. Device must be "bound" on server: `sudo usbip bind -b X-X`
3. Run SnakeUSBIP as Administrator

### "Device connected but not working"
1. Check Device Manager for additional driver needs
2. Some USB 3.0 devices may not be compatible
3. Try another USB port on the server

---

## More Information

- **[README.md](../README.md)** - Installation and features
- **[RASPBERRY_PI_SERVER_EN.md](RASPBERRY_PI_SERVER_EN.md)** - Raspberry Pi server setup
- **[VPN_INTERNET_EN.md](VPN_INTERNET_EN.md)** - VPN connection guide
- **[CHANGELOG.md](../CHANGELOG.md)** - Version history
