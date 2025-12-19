<#
.SYNOPSIS
    SnakeUSBIP - USB over IP Client for Windows
    
.DESCRIPTION
    Native Windows GUI client for USB/IP protocol.
    Share USB devices over network between Windows and Linux.
    
    Features:
    - Auto-discovery of USB/IP servers in LAN
    - Connect/disconnect USB devices remotely
    - Tailscale/ZeroTier VPN support
    - Multi-language (ES/EN)
    - System tray integration
    - Automatic driver installation
    
.NOTES
    Author: SnakeFoxU
    License: GPL-3.0
    Version: 1.7.0
    
    Tech Stack:
    - PowerShell 5.1+ with Windows Forms
    - usbip-win2 drivers (kernel-mode)
    - Native Win32 API
    
.LINK
    https://github.com/Snakefoxu/SnakeUSBIP
#>

#Requires -Version 5.1

# Application metadata
$script:APP_NAME = "SnakeUSBIP"
$script:APP_VERSION = "1.7.0"
$script:GITHUB_REPO = "Snakefoxu/SnakeUSBIP"

# This is a placeholder for GitHub language detection
# Full source code is distributed as compiled executable
# Download from: https://github.com/Snakefoxu/SnakeUSBIP/releases

Write-Host "╔══════════════════════════════════════════════════════════════╗"
Write-Host "║  SnakeUSBIP v$script:APP_VERSION - USB over IP Client for Windows  ║"
Write-Host "║  https://github.com/Snakefoxu/SnakeUSBIP                     ║"
Write-Host "╚══════════════════════════════════════════════════════════════╝"
Write-Host ""
Write-Host "This repository contains pre-compiled binaries."
Write-Host "Download the portable ZIP or installer from Releases."
<#
.SYNOPSIS
    SnakeUSBIP - USB over IP Client for Windows
.DESCRIPTION
    Native Windows client for USB/IP protocol. 
    Allows sharing USB devices over network between Windows AND Linux.
    
    Features:
    - Auto-discovery of USB/IP servers in LAN
    - Connect/disconnect USB devices remotely
    - Support for Tailscale/ZeroTier VPN
    - Multi-language (ES/EN)
    - System tray integration
    - Driver management
    
.NOTES
    Author: SnakeFoxU
    License: GPL-3.0
    Repository: https://github.com/Snakefoxu/SnakeUSBIP
    
    Tech Stack:
    - PowerShell 5.1+ with Windows Forms
    - usbip-win2 drivers (kernel-mode)
    - Native Win32 API calls
    
.LINK
    https://github.com/Snakefoxu/SnakeUSBIP
#>

# Main application code is not included in this repository
# Download the portable ZIP or installer from Releases

$AppVersion = "1.7.0"
$AppName = "SnakeUSBIP"

Write-Host "==============================================="
Write-Host "  $AppName v$AppVersion"
Write-Host "  USB over IP Client for Windows"
Write-Host "==============================================="
Write-Host ""
Write-Host "This is a placeholder file for GitHub language detection."
Write-Host "Download the full application from:"
Write-Host "  https://github.com/Snakefoxu/SnakeUSBIP/releases"
