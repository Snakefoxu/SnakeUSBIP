# Project Status: SnakeUSBIP

## ✅ Current Version: 2.0.0 [2025-12-26]

> **New architecture:** Completely migrated from PowerShell to .NET 9 (C# / WPF)

### Implemented Features

#### Version 2.0 (WPF)
- ✅ **.NET 9 Architecture** - Native performance, ultra-fast GUI
- ✅ **VS Code Dark+ Theme** - Professional blue-accented dark mode
- ✅ **Rename Devices** - Persistent custom names (stored in config.json)
- ✅ **Updated Database** - usb.ids December 2025 (+17K devices)
- ✅ **ARM64 Support** - Windows on ARM (test-signed drivers)
- ✅ **Dynamic Version Check** - Reads version from assembly, not hardcoded

#### Inherited from v1.x (PowerShell)
- ✅ USB/IP Connect/Disconnect
- ✅ Auto-Discovery (subnet scanning port 3240)
- ✅ TreeView GUI with context menu
- ✅ Favorites System with auto-reconnection
- ✅ VID:PID device information
- ✅ Device counters "(X)" in each node
- ✅ Tooltips on hover
- ✅ System Tray (minimize to tray)
- ✅ Multiple servers simultaneously
- ✅ Multi-language (English/Spanish)
- ✅ Auto-update from GitHub
- ✅ Portable & Installer (x64 WHQL + ARM64)
- ✅ Activity Log with timestamps
- ✅ VPN Connection (Tailscale/ZeroTier)
- ✅ SSH Configuration dialog
- ✅ **Toast Notifications** (connect/disconnect events via system tray)
- ✅ **Auto-reconnect** when connection drops (ConnectionMonitorService)

### ⚠️ Known Limitations

| Issue | Reason |
|-------|--------|
| "Unknown Publisher" in UAC | App not code-signed (requires ~$75/year certificate) |
| ARM64 requires Test Mode | Drivers are test-signed, not WHQL certified |

### Pending (Roadmap)
- [ ] USB data compression (requires protocol changes)
- [ ] Performance dashboard
- [ ] Additional languages (Portuguese, French, German)

---

## 📦 Release Artifacts

| File | Size | Platform |
|------|------|----------|
| `SnakeUSBIP-v2.0.0-x64.zip` | 67.5 MB | Windows x64 Portable |
| `SnakeUSBIP-v2.0.0-arm64.zip` | 63.1 MB | Windows ARM64 Portable |
| `SnakeUSBIP_Setup_v2.0.0.exe` | 66.9 MB | Windows x64 Installer |

---

## 🔗 Links
- **GitHub:** https://github.com/Snakefoxu/SnakeUSBIP
- **YouTube:** https://www.youtube.com/watch?v=mETEs9INlq4
- **Documentation:** [docs/](../docs/)
