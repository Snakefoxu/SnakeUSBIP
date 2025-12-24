#Requires -Version 5.1
<#
.SYNOPSIS
    Control Taller - USB/IP Device Manager GUI
.DESCRIPTION
    Aplicacion nativa Windows Forms para gestionar conexiones USB/IP.
    Incluye autodescubrimiento de servidores en la subred local.
    Usa drivers usbip.
.NOTES
    Autor: SnakeFoxu 2025
    Requiere: Windows 10/11, usbip instalado
#>

# ============================================
# AUTO-ELEVACION A ADMINISTRADOR
# ============================================
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $scriptPath = $MyInvocation.MyCommand.Path
    if (-not $scriptPath) {
        $scriptPath = $PSCommandPath
    }
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

# ============================================
# CARGAR ENSAMBLADOS DE WINDOWS FORMS
# ============================================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================================
# CONFIGURACION
# ============================================
$script:USBIP_PORT = 3240
$script:SCAN_TIMEOUT_MS = 300
$script:BUSID_DEFAULT = "1-1"
$script:APP_VERSION = "1.8.0"
$script:GITHUB_REPO = "Snakefoxu/SnakeUSBIP"

# ============================================
# SISTEMA DE LOG DE ACTIVIDAD
# ============================================
$script:ActivityLog = [System.Collections.ArrayList]::new()
$script:MaxLogEntries = 100

# ============================================
# SISTEMA MULTI-IDIOMA
# ============================================
# Detectar idioma del sistema automáticamente (español si el sistema está en español, inglés por defecto)
$script:Language = if ([System.Globalization.CultureInfo]::CurrentUICulture.TwoLetterISOLanguageName -eq "es") { "es" } else { "en" }

$script:Translations = @{
    "es" = @{
        # Botones principales
        "btn_scan"               = "🔍 Escanear"
        "btn_refresh"            = "🔄 Listar"
        "btn_ssh"                = "🖥️ SSH"
        "btn_install_drivers"    = "Instalar"
        "btn_uninstall_drivers"  = "Desinstalar"
        "btn_update"             = "🔄 Actualizar"
        
        # Labels
        "lbl_server"             = "Servidor:"
        
        # TreeView
        "node_hubs"              = "📡 USB Hubs"
        "node_connected"         = "✅ Dispositivos Conectados"
        "node_favorites"         = "⭐ Favoritos"
        
        # Estados
        "status_ready"           = "✓ Listo"
        "status_scanning"        = "Escaneando..."
        "status_listing"         = "Listando dispositivos en"
        "status_connecting"      = "Conectando"
        "status_disconnecting"   = "Desconectando"
        "status_servers_found"   = "servidor(es) encontrado(s)"
        "status_devices_found"   = "dispositivo(s)"
        "status_no_server"       = "No se encontró servidor en la subred"
        "status_error"           = "Error"
        
        # Menú contextual
        "menu_connect"           = "🔌 Conectar"
        "menu_disconnect"        = "❌ Desconectar"
        "menu_add_favorite"      = "⭐ Añadir a Favoritos"
        "menu_remove_favorite"   = "❌ Quitar de Favoritos"
        "menu_remove_server"     = "🗑️ Quitar servidor"
        "menu_properties"        = "📋 Propiedades"
        
        # Tray
        "tray_scan"              = "📡 Escanear Red"
        "tray_show"              = "🔼 Mostrar Ventana"
        "tray_exit"              = "❌ Salir"
        "tray_minimized"         = "Minimizado a bandeja del sistema"
        
        # Actualizaciones
        "update_checking"        = "Buscando actualizaciones..."
        "update_available"       = "Nueva versión disponible"
        "update_current"         = "Ya tienes la versión más reciente"
        "update_download"        = "Descargar e instalar"
        "update_downloading"     = "Descargando actualización..."
        "update_error"           = "Error al buscar actualizaciones"
        
        # Diálogos
        "dlg_server_ip"          = "IP del Servidor:"
        "dlg_confirm"            = "Confirmar"
        "dlg_cancel"             = "Cancelar"
        
        # Tooltips
        "tooltip_busid"          = "Bus ID"
        "tooltip_vidpid"         = "VID:PID"
        "tooltip_vendor"         = "Fabricante"
        "tooltip_product"        = "Producto"
        "tooltip_server"         = "Servidor"
        "tooltip_autoconnect"    = "Auto-conectar"
        
        # Título
        "title_main"             = "SnakeFoxu    USB/IP Manager"
        "title_language"         = "🌐 ESP"
        
        # Log
        "log_title"              = "📋 Log de Actividad"
        "log_connected"          = "Conectado"
        "log_disconnected"       = "Desconectado"
        "log_scan_start"         = "Escaneando red..."
        "log_scan_found"         = "servidor(es) encontrado(s)"
        "log_scan_none"          = "Ningún servidor encontrado"
        "log_error"              = "Error"
        "log_drivers_ok"         = "Drivers verificados OK"
        "log_drivers_missing"    = "Drivers no instalados"
        "log_favorite_added"     = "Añadido a favoritos"
        "log_favorite_removed"   = "Quitado de favoritos"
        "log_clear"              = "Limpiar"
        
        # VPN / Internet
        "btn_vpn"                = "🌐 VPN"
        "vpn_title"              = "Conexión por Internet (VPN)"
        "vpn_no_vpn"             = "No se detectó Tailscale ni ZeroTier instalado"
        "vpn_scanning"           = "Escaneando peers VPN..."
        "vpn_no_peers"           = "No se encontraron peers con USB/IP activo"
        "vpn_peer_name"          = "Nombre"
        "vpn_peer_ip"            = "IP"
        "vpn_peer_status"        = "USB/IP"
        "vpn_connect"            = "Conectar"
        "vpn_refresh"            = "Actualizar"
        "vpn_close"              = "Cerrar"
        "vpn_found_peers"        = "peers con USB/IP encontrados"
        "vpn_detected"           = "detectado. Buscando servidores USB/IP..."
        "vpn_install_hint"       = "Instala uno para conectar por Internet."
        "vpn_no_peers_online"    = "VPN conectada pero no hay peers online."
        "vpn_ensure_server"      = "Asegúrate que el servidor esté en la VPN."
        "vpn_col_name"           = "Nombre"
        "vpn_col_ip"             = "IP"
        "vpn_col_status"         = "Estado"
        "vpn_col_usbip"          = "USB/IP"
        "vpn_online"             = "Online"
        "vpn_offline"            = "Offline"
        "vpn_info"               = "Tailscale/ZeroTier son gratuitos y no requieren abrir puertos en el router."
        "vpn_add_all"            = "Todos"
        
        # Notificaciones Toast
        "notify_connected"       = "Dispositivo conectado"
        "notify_disconnected"    = "Dispositivo desconectado"
        "notify_connection_lost" = "Conexión perdida"
        "notify_reconnecting"    = "Reconectando..."
        "notify_reconnected"     = "Reconectado exitosamente"
        
        # Temas
        "theme_dark"             = "Modo Oscuro"
        "theme_light"            = "Modo Claro"
        "btn_theme"              = "🌙"
        
        # Auto-Reconnect
        "auto_reconnect"         = "Auto-Reconectar"
        "auto_reconnect_on"      = "Auto-reconexión activada"
        "auto_reconnect_off"     = "Auto-reconexión desactivada"
        
        # Selector de Subred
        "subnet_select_title"    = "Seleccionar Red"
        "subnet_multiple_found"  = "Se encontraron múltiples redes. Selecciona una:"
        "subnet_detected"        = "Subredes detectadas"
        "subnet_auto_selected"   = "Auto-seleccionada"
        "subnet_selected"        = "Seleccionada"
        "subnet_scanning"        = "Iniciando escaneo"
        "subnet_none_found"      = "No se encontraron subredes válidas"
        "subnet_not_selected"    = "No se seleccionó subred"
    }
    "en" = @{
        # Main buttons
        "btn_scan"               = "🔍 Scan"
        "btn_refresh"            = "🔄 List"
        "btn_ssh"                = "🖥️ SSH"
        "btn_install_drivers"    = "Install"
        "btn_uninstall_drivers"  = "Uninstall"
        "btn_update"             = "🔄 Update"
        
        # Labels
        "lbl_server"             = "Server:"
        
        # TreeView
        "node_hubs"              = "📡 USB Hubs"
        "node_connected"         = "✅ Connected Devices"
        "node_favorites"         = "⭐ Favorites"
        
        # Status
        "status_ready"           = "✓ Ready"
        "status_scanning"        = "Scanning..."
        "status_listing"         = "Listing devices on"
        "status_connecting"      = "Connecting"
        "status_disconnecting"   = "Disconnecting"
        "status_servers_found"   = "server(s) found"
        "status_devices_found"   = "device(s)"
        "status_no_server"       = "No server found in subnet"
        "status_error"           = "Error"
        
        # Context menu
        "menu_connect"           = "🔌 Connect"
        "menu_disconnect"        = "❌ Disconnect"
        "menu_add_favorite"      = "⭐ Add to Favorites"
        "menu_remove_favorite"   = "❌ Remove from Favorites"
        "menu_remove_server"     = "🗑️ Remove server"
        "menu_properties"        = "📋 Properties"
        
        # Tray
        "tray_scan"              = "📡 Scan Network"
        "tray_show"              = "🔼 Show Window"
        "tray_exit"              = "❌ Exit"
        "tray_minimized"         = "Minimized to system tray"
        
        # Updates
        "update_checking"        = "Checking for updates..."
        "update_available"       = "New version available"
        "update_current"         = "You have the latest version"
        "update_download"        = "Download and install"
        "update_downloading"     = "Downloading update..."
        "update_error"           = "Error checking for updates"
        
        # Dialogs
        "dlg_server_ip"          = "Server IP:"
        "dlg_confirm"            = "Confirm"
        "dlg_cancel"             = "Cancel"
        
        # Tooltips
        "tooltip_busid"          = "Bus ID"
        "tooltip_vidpid"         = "VID:PID"
        "tooltip_vendor"         = "Vendor"
        "tooltip_product"        = "Product"
        "tooltip_server"         = "Server"
        "tooltip_autoconnect"    = "Auto-connect"
        
        # Title
        "title_main"             = "SnakeFoxu    USB/IP Manager"
        "title_language"         = "🌐 ENG"
        
        # Log
        "log_title"              = "📋 Activity Log"
        "log_connected"          = "Connected"
        "log_disconnected"       = "Disconnected"
        "log_scan_start"         = "Scanning network..."
        "log_scan_found"         = "server(s) found"
        "log_scan_none"          = "No servers found"
        "log_error"              = "Error"
        "log_drivers_ok"         = "Drivers verified OK"
        "log_drivers_missing"    = "Drivers not installed"
        "log_favorite_added"     = "Added to favorites"
        "log_favorite_removed"   = "Removed from favorites"
        "log_clear"              = "Clear"
        
        # VPN / Internet
        "btn_vpn"                = "🌐 VPN"
        "vpn_title"              = "Internet Connection (VPN)"
        "vpn_no_vpn"             = "Neither Tailscale nor ZeroTier detected"
        "vpn_scanning"           = "Scanning VPN peers..."
        "vpn_no_peers"           = "No peers with active USB/IP found"
        "vpn_peer_name"          = "Name"
        "vpn_peer_ip"            = "IP"
        "vpn_peer_status"        = "USB/IP"
        "vpn_connect"            = "Connect"
        "vpn_refresh"            = "Refresh"
        "vpn_close"              = "Close"
        "vpn_found_peers"        = "peers with USB/IP found"
        "vpn_detected"           = "detected. Searching for USB/IP servers..."
        "vpn_install_hint"       = "Install one to connect over Internet."
        "vpn_no_peers_online"    = "VPN connected but no peers online."
        "vpn_ensure_server"      = "Make sure the server is on the VPN."
        "vpn_col_name"           = "Name"
        "vpn_col_ip"             = "IP"
        "vpn_col_status"         = "Status"
        "vpn_col_usbip"          = "USB/IP"
        "vpn_online"             = "Online"
        "vpn_offline"            = "Offline"
        "vpn_info"               = "Tailscale/ZeroTier are free and don't require port forwarding."
        "vpn_add_all"            = "All"
        
        # Toast Notifications
        "notify_connected"       = "Device connected"
        "notify_disconnected"    = "Device disconnected"
        "notify_connection_lost" = "Connection lost"
        "notify_reconnecting"    = "Reconnecting..."
        "notify_reconnected"     = "Reconnected successfully"
        
        # Themes
        "theme_dark"             = "Dark Mode"
        "theme_light"            = "Light Mode"
        "btn_theme"              = "🌙"
        
        # Auto-Reconnect
        "auto_reconnect"         = "Auto-Reconnect"
        "auto_reconnect_on"      = "Auto-reconnect enabled"
        "auto_reconnect_off"     = "Auto-reconnect disabled"
        
        # Subnet Selector
        "subnet_select_title"    = "Select Network"
        "subnet_multiple_found"  = "Multiple networks found. Select one:"
        "subnet_detected"        = "Subnets detected"
        "subnet_auto_selected"   = "Auto-selected"
        "subnet_selected"        = "Selected"
        "subnet_scanning"        = "Starting scan"
        "subnet_none_found"      = "No valid subnets found"
        "subnet_not_selected"    = "No subnet selected"
    }
}

function Get-Text {
    param([string]$Key)
    $text = $script:Translations[$script:Language][$Key]
    if (-not $text) { return $Key }
    return $text
}

# ============================================
# SISTEMA DE TEMAS (DARK/LIGHT)
# ============================================
$script:CurrentTheme = "dark"  # Default theme

$script:Themes = @{
    "dark"  = @{
        FormBack     = [System.Drawing.Color]::FromArgb(30, 30, 30)
        PanelBack    = [System.Drawing.Color]::FromArgb(45, 45, 48)
        ControlBack  = [System.Drawing.Color]::FromArgb(62, 62, 66)
        TextColor    = [System.Drawing.Color]::White
        AccentColor  = [System.Drawing.Color]::FromArgb(0, 122, 204)
        BorderColor  = [System.Drawing.Color]::FromArgb(67, 67, 70)
        StatusBar    = [System.Drawing.Color]::FromArgb(45, 45, 48)
        TreeViewBack = [System.Drawing.Color]::FromArgb(37, 37, 38)
        LogBack      = [System.Drawing.Color]::FromArgb(30, 30, 30)
        ButtonIcon   = "🌙"
    }
    "light" = @{
        FormBack     = [System.Drawing.Color]::FromArgb(243, 243, 243)
        PanelBack    = [System.Drawing.Color]::FromArgb(255, 255, 255)
        ControlBack  = [System.Drawing.Color]::FromArgb(230, 230, 230)
        TextColor    = [System.Drawing.Color]::FromArgb(30, 30, 30)
        AccentColor  = [System.Drawing.Color]::FromArgb(0, 120, 212)
        BorderColor  = [System.Drawing.Color]::FromArgb(200, 200, 200)
        StatusBar    = [System.Drawing.Color]::FromArgb(230, 230, 230)
        TreeViewBack = [System.Drawing.Color]::FromArgb(255, 255, 255)
        LogBack      = [System.Drawing.Color]::FromArgb(250, 250, 250)
        ButtonIcon   = "☀️"
    }
}

function Show-Notification {
    <#
    .SYNOPSIS
        Muestra notificación toast en el área de sistema
    .PARAMETER Title
        Título de la notificación
    .PARAMETER Message
        Mensaje de la notificación
    .PARAMETER Type
        Tipo: Info, Success, Warning, Error
    #>
    param(
        [string]$Title,
        [string]$Message,
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Type = "Info"
    )
    
    if (-not $script:trayIcon) { return }
    
    $icon = switch ($Type) {
        "Info" { [System.Windows.Forms.ToolTipIcon]::Info }
        "Success" { [System.Windows.Forms.ToolTipIcon]::Info }
        "Warning" { [System.Windows.Forms.ToolTipIcon]::Warning }
        "Error" { [System.Windows.Forms.ToolTipIcon]::Error }
    }
    
    $script:trayIcon.ShowBalloonTip(3000, $Title, $Message, $icon)
}

function Add-LogEntry {
    <#
    .SYNOPSIS
        Añade una entrada al log de actividad
    .PARAMETER Type
        Tipo de entrada: Info, Success, Error, Warning
    .PARAMETER Message
        Mensaje a registrar
    #>
    param(
        [ValidateSet("Info", "Success", "Error", "Warning")]
        [string]$Type = "Info",
        [string]$Message
    )
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    $icon = switch ($Type) {
        "Info" { "ℹ️" }
        "Success" { "✅" }
        "Error" { "❌" }
        "Warning" { "⚠️" }
    }
    
    $entry = @{
        Timestamp = $timestamp
        Type      = $Type
        Icon      = $icon
        Message   = $Message
    }
    
    [void]$script:ActivityLog.Insert(0, $entry)
    
    # Limitar tamaño del log
    while ($script:ActivityLog.Count -gt $script:MaxLogEntries) {
        $script:ActivityLog.RemoveAt($script:ActivityLog.Count - 1)
    }
    
    # Actualizar UI si existe el control
    if ($script:logTextBox) {
        $logText = ""
        foreach ($e in $script:ActivityLog) {
            $logText += "[$($e.Timestamp)] $($e.Icon) $($e.Message)`r`n"
        }
        $script:logTextBox.Text = $logText
    }
}

# ============================================
# FUNCIONES VPN/INTERNET (Tailscale/ZeroTier)
# ============================================

function Test-TailscaleInstalled {
    return (Get-Command "tailscale" -ErrorAction SilentlyContinue) -ne $null
}

function Test-ZeroTierInstalled {
    return (Get-Command "zerotier-cli" -ErrorAction SilentlyContinue) -ne $null
}

function Get-TailscalePeers {
    if (-not (Test-TailscaleInstalled)) { return @() }
    try {
        $status = & tailscale status --json 2>$null | ConvertFrom-Json
        $peers = @()
        foreach ($peer in $status.Peer.PSObject.Properties) {
            $p = $peer.Value
            if ($p.TailscaleIPs -and $p.TailscaleIPs.Count -gt 0) {
                $peers += [PSCustomObject]@{
                    Name   = $p.HostName
                    IP     = $p.TailscaleIPs[0]
                    Online = $p.Online
                    OS     = $p.OS
                    Type   = "Tailscale"
                }
            }
        }
        return $peers
    }
    catch { return @() }
}

function Get-ZeroTierPeers {
    if (-not (Test-ZeroTierInstalled)) { return @() }
    try {
        $networks = & zerotier-cli listnetworks -j 2>$null | ConvertFrom-Json
        $peers = @()
        foreach ($net in $networks) {
            if ($net.status -eq "OK" -and $net.assignedAddresses.Count -gt 0) {
                $peers += [PSCustomObject]@{
                    Name   = $net.name
                    IP     = ($net.assignedAddresses[0] -replace '/\d+$', '')
                    Online = $true
                    Type   = "ZeroTier"
                }
            }
        }
        return $peers
    }
    catch { return @() }
}

function Get-AllVPNPeers {
    $allPeers = @()
    $allPeers += Get-TailscalePeers
    $allPeers += Get-ZeroTierPeers
    return $allPeers
}

function Test-USBIPOnPeer {
    param([string]$IP)
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $result = $tcp.BeginConnect($IP, 3240, $null, $null)
        $success = $result.AsyncWaitHandle.WaitOne(1000)
        $tcp.Close()
        return $success
    }
    catch { return $false }
}

function Show-InternetConnectionDialog {
    param([System.Windows.Forms.TextBox]$ServerTextBox)
    
    $dialog = New-Object System.Windows.Forms.Form
    $dialog.Text = Get-Text "vpn_title"
    $dialog.Size = New-Object System.Drawing.Size(450, 380)
    $dialog.StartPosition = "CenterScreen"
    $dialog.FormBorderStyle = "FixedDialog"
    $dialog.MaximizeBox = $false
    $dialog.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    
    # Detectar VPNs
    $hasTailscale = Test-TailscaleInstalled
    $hasZeroTier = Test-ZeroTierInstalled
    
    # Label estado
    $lblStatus = New-Object System.Windows.Forms.Label
    $lblStatus.Location = New-Object System.Drawing.Point(20, 15)
    $lblStatus.Size = New-Object System.Drawing.Size(400, 40)
    $lblStatus.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    
    if ($hasTailscale -or $hasZeroTier) {
        $vpnName = if ($hasTailscale) { "Tailscale" } else { "ZeroTier" }
        $lblStatus.Text = "✅ $vpnName $(Get-Text 'vpn_detected')"
        $lblStatus.ForeColor = [System.Drawing.Color]::LightGreen
    }
    else {
        $lblStatus.Text = "⚠️ $(Get-Text 'vpn_no_vpn')`n$(Get-Text 'vpn_install_hint')"
        $lblStatus.ForeColor = [System.Drawing.Color]::Orange
    }
    $dialog.Controls.Add($lblStatus)
    
    # ListView peers
    $listPeers = New-Object System.Windows.Forms.ListView
    $listPeers.Location = New-Object System.Drawing.Point(20, 60)
    $listPeers.Size = New-Object System.Drawing.Size(400, 180)
    $listPeers.View = "Details"
    $listPeers.FullRowSelect = $true
    $listPeers.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $listPeers.ForeColor = [System.Drawing.Color]::White
    $listPeers.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    [void]$listPeers.Columns.Add((Get-Text 'vpn_col_name'), 140)
    [void]$listPeers.Columns.Add((Get-Text 'vpn_col_ip'), 120)
    [void]$listPeers.Columns.Add((Get-Text 'vpn_col_status'), 70)
    [void]$listPeers.Columns.Add((Get-Text 'vpn_col_usbip'), 55)
    $dialog.Controls.Add($listPeers)
    
    # Cargar peers
    if ($hasTailscale -or $hasZeroTier) {
        $peers = Get-AllVPNPeers
        foreach ($peer in $peers) {
            $item = New-Object System.Windows.Forms.ListViewItem($peer.Name)
            [void]$item.SubItems.Add($peer.IP)
            [void]$item.SubItems.Add($(if ($peer.Online) { "🟢 $(Get-Text 'vpn_online')" } else { "🔴 $(Get-Text 'vpn_offline')" }))
            $hasUSBIP = Test-USBIPOnPeer -IP $peer.IP
            [void]$item.SubItems.Add($(if ($hasUSBIP) { "✅" } else { "❌" }))
            $item.Tag = $peer.IP
            if ($hasUSBIP) { $item.ForeColor = [System.Drawing.Color]::LightGreen }
            [void]$listPeers.Items.Add($item)
        }
        if ($peers.Count -eq 0) {
            $lblStatus.Text = "ℹ️ $(Get-Text 'vpn_no_peers_online')`n$(Get-Text 'vpn_ensure_server')"
            $lblStatus.ForeColor = [System.Drawing.Color]::Yellow
        }
    }
    
    # Botón Tailscale
    $btnTailscale = New-Object System.Windows.Forms.Button
    $btnTailscale.Location = New-Object System.Drawing.Point(20, 250)
    $btnTailscale.Size = New-Object System.Drawing.Size(95, 30)
    $btnTailscale.Text = "📥 Tailscale"
    $btnTailscale.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
    $btnTailscale.ForeColor = [System.Drawing.Color]::White
    $btnTailscale.FlatStyle = "Flat"
    $btnTailscale.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btnTailscale.Add_Click({ Start-Process "https://tailscale.com/download" })
    $dialog.Controls.Add($btnTailscale)
    
    # Botón ZeroTier
    $btnZeroTier = New-Object System.Windows.Forms.Button
    $btnZeroTier.Location = New-Object System.Drawing.Point(120, 250)
    $btnZeroTier.Size = New-Object System.Drawing.Size(95, 30)
    $btnZeroTier.Text = "📥 ZeroTier"
    $btnZeroTier.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
    $btnZeroTier.ForeColor = [System.Drawing.Color]::White
    $btnZeroTier.FlatStyle = "Flat"
    $btnZeroTier.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btnZeroTier.Add_Click({ Start-Process "https://www.zerotier.com/download/" })
    $dialog.Controls.Add($btnZeroTier)
    
    # Botón Añadir Todos
    $btnAddAll = New-Object System.Windows.Forms.Button
    $btnAddAll.Location = New-Object System.Drawing.Point(220, 250)
    $btnAddAll.Size = New-Object System.Drawing.Size(95, 30)
    $btnAddAll.Text = "➕ $(Get-Text 'vpn_add_all')"
    $btnAddAll.BackColor = [System.Drawing.Color]::FromArgb(0, 128, 0)  # Verde
    $btnAddAll.ForeColor = [System.Drawing.Color]::White
    $btnAddAll.FlatStyle = "Flat"
    $btnAddAll.Cursor = [System.Windows.Forms.Cursors]::Hand
    $dialog.Controls.Add($btnAddAll)
    
    # Acción Añadir Todos - devuelve array de IPs
    $btnAddAll.Add_Click({
            $script:selectedVPNIPs = @()
            foreach ($item in $listPeers.Items) {
                # Solo añadir los que tienen USB/IP (columna 3 = "✅")
                if ($item.SubItems[3].Text -eq "✅") {
                    $script:selectedVPNIPs += $item.Tag
                }
            }
            if ($script:selectedVPNIPs.Count -gt 0) {
                $dialog.DialogResult = [System.Windows.Forms.DialogResult]::Yes  # Yes = Todos
                $dialog.Close()
            }
        })
    
    # Botón Conectar (uno solo)
    $btnConnect = New-Object System.Windows.Forms.Button
    $btnConnect.Location = New-Object System.Drawing.Point(320, 250)
    $btnConnect.Size = New-Object System.Drawing.Size(100, 30)
    $btnConnect.Text = "🔗 $(Get-Text 'vpn_connect')"
    $btnConnect.BackColor = [System.Drawing.Color]::FromArgb(255, 140, 0)
    $btnConnect.ForeColor = [System.Drawing.Color]::White
    $btnConnect.FlatStyle = "Flat"
    $btnConnect.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btnConnect.Enabled = $false
    $dialog.Controls.Add($btnConnect)
    
    # Habilitar botón al seleccionar
    $listPeers.Add_SelectedIndexChanged({
            $btnConnect.Enabled = $listPeers.SelectedItems.Count -gt 0
        })
    
    # Acción conectar (uno solo)
    $btnConnect.Add_Click({
            if ($listPeers.SelectedItems.Count -gt 0) {
                $script:selectedVPNIP = $listPeers.SelectedItems[0].Tag
                $script:selectedVPNIPs = @()  # Limpiar array
                $dialog.DialogResult = [System.Windows.Forms.DialogResult]::OK
                $dialog.Close()
            }
        })
    
    # Info
    $lblInfo = New-Object System.Windows.Forms.Label
    $lblInfo.Location = New-Object System.Drawing.Point(20, 295)
    $lblInfo.Size = New-Object System.Drawing.Size(400, 35)
    $lblInfo.Text = "💡 $(Get-Text 'vpn_info')"
    $lblInfo.ForeColor = [System.Drawing.Color]::Gray
    $lblInfo.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $dialog.Controls.Add($lblInfo)
    
    $script:selectedVPNIP = $null
    $script:selectedVPNIPs = @()
    $result = $dialog.ShowDialog()
    
    # Devolver resultado según el botón pulsado
    if ($result -eq [System.Windows.Forms.DialogResult]::Yes -and $script:selectedVPNIPs.Count -gt 0) {
        # Botón "Añadir Todos" - devolver array de IPs
        return @{ All = $true; IPs = $script:selectedVPNIPs }
    }
    elseif ($result -eq [System.Windows.Forms.DialogResult]::OK -and $script:selectedVPNIP) {
        # Botón "Conectar" - devolver una sola IP
        return @{ All = $false; IPs = @($script:selectedVPNIP) }
    }
    return $null
}

function Get-DeviceIcon {
    <#
    .SYNOPSIS
        Devuelve un icono emoji según el tipo de dispositivo USB
    #>
    param(
        [string]$Description,
        [string]$VendorId,
        [string]$ProductId
    )
    
    $desc = $Description.ToLower()
    
    # Detectar por descripción
    switch -Regex ($desc) {
        'keyboard|teclado|hid.*keyboard' { return "⌨️" }
        'mouse|ratón|raton' { return "🖱️" }
        'storage|mass storage|disk|usb flash|pendrive|sandisk|kingston' { return "💾" }
        'audio|sound|headset|speaker|microphone|altavoz' { return "🔊" }
        'camera|webcam|cámara|camara|video' { return "📷" }
        'printer|impresora|laserjet|deskjet' { return "🖨️" }
        'network|ethernet|wifi|wireless|lan|realtek.*ethernet|ax.*wifi' { return "🌐" }
        'hub' { return "🔌" }
        'gamepad|joystick|controller|xbox|playstation|mando' { return "🎮" }
        'phone|teléfono|telefono|android|iphone|smartphone' { return "📱" }
        'bluetooth' { return "📶" }
        'serial|uart|com port|arduino|esp32|ch340|cp210|ftdi' { return "🔧" }
        'card reader|lector.*tarjeta|sd card' { return "💳" }
        'scanner|escáner|escaner' { return "📠" }
        default { return "📦" }
    }
}

# ============================================
# FEATURE 3: SISTEMA DE FAVORITOS (STASH)
# Añadido en v1.4.0 - 2025-12-09
# ============================================

function Get-ConfigPath {
    <#
    .SYNOPSIS
        Obtiene la ruta del archivo de configuracion
    #>
    $appDir = $null
    
    try {
        $exePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
        if ($exePath -and $exePath -notmatch 'powershell\.exe$|pwsh\.exe$') {
            $appDir = Split-Path -Parent $exePath
        }
    }
    catch { }
    
    if (-not $appDir -and $PSScriptRoot) {
        $appDir = $PSScriptRoot
    }
    
    if (-not $appDir) {
        $appDir = Get-Location
    }
    
    return Join-Path $appDir "config.json"
}

function Get-AppConfig {
    <#
    .SYNOPSIS
        Lee la configuracion desde config.json
    #>
    $configPath = Get-ConfigPath
    
    $defaultConfig = @{
        Favorites          = @()
        AutoConnectOnStart = $false
        Servers            = @()
        Language           = $script:Language  # Usar idioma detectado del sistema
        WizardCompleted    = $false  # Se pone a true cuando el usuario completa o salta el wizard
    }
    
    if (Test-Path $configPath) {
        try {
            $content = Get-Content $configPath -Raw -Encoding UTF8
            $config = $content | ConvertFrom-Json
            
            # Asegurar que existen todas las propiedades
            if (-not $config.Favorites) { $config | Add-Member -NotePropertyName "Favorites" -NotePropertyValue @() -Force }
            if ($null -eq $config.AutoConnectOnStart) { $config | Add-Member -NotePropertyName "AutoConnectOnStart" -NotePropertyValue $true -Force }
            
            # Migrar LastServer a Servers si existe
            if ($config.LastServer -and -not $config.Servers) {
                $config | Add-Member -NotePropertyName "Servers" -NotePropertyValue @($config.LastServer) -Force
            }
            elseif (-not $config.Servers) {
                $config | Add-Member -NotePropertyName "Servers" -NotePropertyValue @() -Force
            }
            
            # Idioma
            if (-not $config.Language) { 
                $config | Add-Member -NotePropertyName "Language" -NotePropertyValue $script:Language -Force 
            }
            
            # Wizard completado
            if ($null -eq $config.WizardCompleted) {
                $config | Add-Member -NotePropertyName "WizardCompleted" -NotePropertyValue $false -Force
            }
            
            # Aplicar idioma cargado
            $script:Language = $config.Language
            
            return $config
        }
        catch {
            return $defaultConfig
        }
    }
    
    return $defaultConfig
}


function Save-AppConfig {
    <#
    .SYNOPSIS
        Guarda la configuracion en config.json
    #>
    param($Config)
    
    $configPath = Get-ConfigPath
    
    try {
        $Config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
        return $true
    }
    catch {
        return $false
    }
}

# ============================================
# SISTEMA DE AUTO-ACTUALIZACION
# ============================================
function Check-ForUpdates {
    <#
    .SYNOPSIS
        Verifica si hay nueva versión en GitHub
    #>
    try {
        $apiUrl = "https://api.github.com/repos/$($script:GITHUB_REPO)/releases/latest"
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -TimeoutSec 10
        
        $latestVersion = $response.tag_name -replace '^v', ''
        $currentVersion = $script:APP_VERSION
        
        # Comparar versiones
        $latest = [version]$latestVersion
        $current = [version]$currentVersion
        
        if ($latest -gt $current) {
            # Buscar el instalador en los assets
            $installerAsset = $response.assets | Where-Object { $_.name -match 'Setup.*\.exe$' } | Select-Object -First 1
            
            return @{
                UpdateAvailable = $true
                LatestVersion   = $latestVersion
                CurrentVersion  = $currentVersion
                DownloadUrl     = if ($installerAsset) { $installerAsset.browser_download_url } else { $null }
                InstallerName   = if ($installerAsset) { $installerAsset.name } else { $null }
                ReleaseNotes    = $response.body
            }
        }
        else {
            return @{
                UpdateAvailable = $false
                LatestVersion   = $latestVersion
                CurrentVersion  = $currentVersion
            }
        }
    }
    catch {
        return @{
            UpdateAvailable = $false
            Error           = $_.Exception.Message
        }
    }
}

function Start-Update {
    <#
    .SYNOPSIS
        Descarga e inicia el instalador de actualización
    #>
    param([string]$DownloadUrl, [string]$InstallerName)
    
    try {
        $tempDir = [System.IO.Path]::GetTempPath()
        $installerPath = Join-Path $tempDir $InstallerName
        
        # Descargar instalador
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $installerPath -TimeoutSec 120
        
        if (Test-Path $installerPath) {
            # Ejecutar instalador y cerrar app
            Start-Process -FilePath $installerPath -Verb RunAs
            
            # Cerrar la aplicación actual
            $script:forceClose = $true
            if ($script:notifyIcon) {
                $script:notifyIcon.Visible = $false
                $script:notifyIcon.Dispose()
                $script:notifyIcon = $null
            }
            [System.Windows.Forms.Application]::Exit()
            
            return @{ Success = $true }
        }
        else {
            return @{ Success = $false; Error = "No se pudo descargar el instalador" }
        }
    }
    catch {
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}
function Add-Favorite {
    <#
    .SYNOPSIS
        Añade un dispositivo a favoritos
    #>
    param(
        [string]$ServerIP,
        [string]$BusId,
        [string]$Description,
        [bool]$AutoConnect = $true
    )
    
    $config = Get-AppConfig
    
    # Verificar si ya existe
    $existing = $config.Favorites | Where-Object { $_.ServerIP -eq $ServerIP -and $_.BusId -eq $BusId }
    if ($existing) {
        return @{ Success = $false; Message = "Ya existe en favoritos" }
    }
    
    # Crear objeto favorito
    $favorite = @{
        ServerIP    = $ServerIP
        BusId       = $BusId
        Description = $Description
        AutoConnect = $AutoConnect
        AddedDate   = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }
    
    # Añadir a la lista (manejar caso de array vacío)
    $newFavorites = @($config.Favorites) + @($favorite)
    $config.Favorites = $newFavorites
    
    if (Save-AppConfig -Config $config) {
        return @{ Success = $true; Message = "Añadido a favoritos" }
    }
    else {
        return @{ Success = $false; Message = "Error al guardar configuracion" }
    }
}

function Remove-Favorite {
    <#
    .SYNOPSIS
        Elimina un dispositivo de favoritos
    #>
    param(
        [string]$ServerIP,
        [string]$BusId
    )
    
    $config = Get-AppConfig
    
    $config.Favorites = @($config.Favorites | Where-Object { 
            -not ($_.ServerIP -eq $ServerIP -and $_.BusId -eq $BusId) 
        })
    
    if (Save-AppConfig -Config $config) {
        return @{ Success = $true; Message = "Eliminado de favoritos" }
    }
    else {
        return @{ Success = $false; Message = "Error al guardar configuracion" }
    }
}

function Get-Favorites {
    <#
    .SYNOPSIS
        Obtiene la lista de favoritos
    #>
    $config = Get-AppConfig
    return @($config.Favorites)
}

function Test-IsFavorite {
    <#
    .SYNOPSIS
        Verifica si un dispositivo esta en favoritos
    #>
    param(
        [string]$ServerIP,
        [string]$BusId
    )
    
    $favorites = Get-Favorites
    $match = $favorites | Where-Object { $_.ServerIP -eq $ServerIP -and $_.BusId -eq $BusId }
    return ($null -ne $match)
}

function Connect-Favorites {
    <#
    .SYNOPSIS
        Conecta todos los favoritos marcados con AutoConnect
    #>
    $favorites = Get-Favorites
    $autoConnectFavorites = @($favorites | Where-Object { $_.AutoConnect -eq $true })
    
    $results = @()
    
    foreach ($fav in $autoConnectFavorites) {
        $result = Connect-UsbipDevice -ServerIP $fav.ServerIP -BusId $fav.BusId
        $results += @{
            Device  = "$($fav.ServerIP)/$($fav.BusId)"
            Success = $result.Success
            Error   = $result.Error
        }
    }
    
    return $results
}

# ============================================
# FUNCIONES DE RED
# ============================================

function Get-LocalIPAddress {
    <#
    .SYNOPSIS
        Obtiene la IP de la red LOCAL (Ethernet/WiFi), excluyendo VPNs
    .DESCRIPTION
        Prioriza interfaces físicas y excluye IPs de Tailscale (100.x.x.x)
        para que el escaneo normal solo busque en la LAN real
    #>
    try {
        # Priorizar interfaces físicas (Ethernet, WiFi)
        $physicalTypes = @('Ethernet', 'Wireless80211', 'GigabitEthernet')
        
        $networkInterfaces = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() | 
        Where-Object { 
            $_.OperationalStatus -eq 'Up' -and 
            $_.NetworkInterfaceType -ne 'Loopback' -and
            $_.NetworkInterfaceType -ne 'Tunnel' -and # Excluir VPNs
            $_.Name -notmatch 'VMware|VirtualBox|Hyper-V|vEthernet|WSL'  # Excluir virtuales
        } |
        Sort-Object { 
            # Priorizar interfaces físicas
            if ($_.NetworkInterfaceType -in $physicalTypes) { 0 } else { 1 }
        }
        
        foreach ($interface in $networkInterfaces) {
            $ipProps = $interface.GetIPProperties()
            $ipv4Addresses = $ipProps.UnicastAddresses | 
            Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' }
            
            foreach ($addr in $ipv4Addresses) {
                $ip = $addr.Address.ToString()
                # Excluir link-local, loopback, y rango Tailscale/CGNAT (100.64.0.0/10)
                if ($ip -notmatch '^(169\.254\.|127\.|100\.(6[4-9]|[7-9][0-9]|1[0-2][0-7])\.)') {
                    return $ip
                }
            }
        }
    }
    catch {
        return $null
    }
    return $null
}

function Get-SubnetBase {
    param([string]$IPAddress)
    
    if ($IPAddress -match '^(\d+\.\d+\.\d+)\.\d+$') {
        return $Matches[1]
    }
    return $null
}

function Get-AllLocalSubnets {
    <#
    .SYNOPSIS
        Obtiene todas las subredes locales válidas (excluyendo VPNs y virtuales)
    .RETURNS
        Array de objetos con Name, IP, Subnet
    #>
    $subnets = [System.Collections.ArrayList]::new()
    $physicalTypes = @('Ethernet', 'Wireless80211', 'GigabitEthernet')
    
    try {
        $networkInterfaces = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() | 
        Where-Object { 
            $_.OperationalStatus -eq 'Up' -and 
            $_.NetworkInterfaceType -ne 'Loopback' -and
            $_.NetworkInterfaceType -ne 'Tunnel' -and
            $_.Name -notmatch 'VMware|VirtualBox|Hyper-V|vEthernet|WSL|Tailscale|ZeroTier'
        } |
        Sort-Object { 
            if ($_.NetworkInterfaceType -in $physicalTypes) { 0 } else { 1 }
        }
        
        foreach ($interface in $networkInterfaces) {
            $ipProps = $interface.GetIPProperties()
            $ipv4Addresses = $ipProps.UnicastAddresses | 
            Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' }
            
            foreach ($addr in $ipv4Addresses) {
                $ip = $addr.Address.ToString()
                # Excluir link-local, loopback, CGNAT
                if ($ip -notmatch '^(169\.254\.|127\.|100\.(6[4-9]|[7-9][0-9]|1[0-2][0-7])\.)') {
                    $subnet = Get-SubnetBase -IPAddress $ip
                    if ($subnet) {
                        [void]$subnets.Add(@{
                                Name   = $interface.Name
                                IP     = $ip
                                Subnet = $subnet
                            })
                    }
                }
            }
        }
    }
    catch { }
    
    return $subnets
}

function Test-PortOpen {
    param(
        [string]$IPAddress,
        [int]$Port,
        [int]$TimeoutMs = 100
    )
    
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $asyncResult = $tcpClient.BeginConnect($IPAddress, $Port, $null, $null)
        $wait = $asyncResult.AsyncWaitHandle.WaitOne($TimeoutMs, $false)
        
        if ($wait -and $tcpClient.Connected) {
            $tcpClient.EndConnect($asyncResult)
            $tcpClient.Close()
            return $true
        }
        
        $tcpClient.Close()
        return $false
    }
    catch {
        return $false
    }
}

function Start-SubnetScan {
    param(
        [string]$SubnetBase,
        [System.Windows.Forms.TextBox]$IPTextBox,
        [System.Windows.Forms.Label]$StatusLabel,
        [System.Windows.Forms.ProgressBar]$ProgressBar,
        [scriptblock]$OnServerFound = $null
    )
    
    Add-LogEntry -Type "Info" -Message "$(Get-Text 'log_scan_start') $SubnetBase.0/24"
    $StatusLabel.Text = "Escaneando $SubnetBase.0/24..."
    $StatusLabel.ForeColor = [System.Drawing.Color]::FromArgb(86, 156, 214)
    $ProgressBar.Value = 0
    $ProgressBar.Visible = $true
    
    $runspacePool = [runspacefactory]::CreateRunspacePool(1, 50)
    $runspacePool.Open()
    
    $jobs = [System.Collections.ArrayList]::new()
    $scriptBlock = {
        param($IP, $Port, $Timeout)
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $asyncResult = $tcpClient.BeginConnect($IP, $Port, $null, $null)
            $wait = $asyncResult.AsyncWaitHandle.WaitOne($Timeout, $false)
            
            if ($wait -and $tcpClient.Connected) {
                $tcpClient.EndConnect($asyncResult)
                $tcpClient.Close()
                return $IP
            }
            $tcpClient.Close()
        }
        catch { }
        return $null
    }
    
    for ($i = 1; $i -le 254; $i++) {
        $targetIP = "$SubnetBase.$i"
        
        $powershell = [powershell]::Create().AddScript($scriptBlock)
        $powershell.AddArgument($targetIP) | Out-Null
        $powershell.AddArgument($script:USBIP_PORT) | Out-Null
        $powershell.AddArgument($script:SCAN_TIMEOUT_MS) | Out-Null
        $powershell.RunspacePool = $runspacePool
        
        [void]$jobs.Add(@{
                PowerShell = $powershell
                Handle     = $powershell.BeginInvoke()
                IP         = $targetIP
            })
    }
    
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 100
    
    $script:foundServers = @()
    $script:completedCount = 0
    
    $timer.Add_Tick({
            $completed = 0
        
            foreach ($job in $jobs) {
                if ($job.Handle.IsCompleted) {
                    $completed++
                    # Verificar si este job ya fue procesado
                    if (-not $job.Processed) {
                        try {
                            $result = $job.PowerShell.EndInvoke($job.Handle)
                            if ($result -and $result -notin $script:foundServers) {
                                $script:foundServers += $result
                            
                                # Actualizar UI con primer servidor encontrado
                                if ($script:foundServers.Count -eq 1) {
                                    $IPTextBox.Text = $result
                                }
                                $StatusLabel.Text = "✓ Encontrados $($script:foundServers.Count) servidor(es)"
                                $StatusLabel.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
                            
                                # Ejecutar callback para este servidor
                                if ($OnServerFound) {
                                    & $OnServerFound $result
                                }
                            }
                        }
                        catch { }
                        $job.Processed = $true
                    }
                }
            }
        
            $ProgressBar.Value = [Math]::Min(100, [int]($completed / 254 * 100))
        
            if ($completed -ge 254) {
                $timer.Stop()
                $timer.Dispose()
            
                foreach ($job in $jobs) {
                    try { $job.PowerShell.Dispose() } catch { }
                }
                try {
                    $runspacePool.Close()
                    $runspacePool.Dispose()
                }
                catch { }
            
                $ProgressBar.Visible = $false
            
                if ($script:foundServers.Count -eq 0) {
                    $StatusLabel.Text = "No se encontró servidor en la subred"
                    $StatusLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 100)
                    Add-LogEntry -Type "Warning" -Message "$(Get-Text 'log_scan_none')"
                }
                else {
                    $StatusLabel.Text = "✓ $($script:foundServers.Count) servidor(es) encontrado(s)"
                    $StatusLabel.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
                    Add-LogEntry -Type "Success" -Message "$($script:foundServers.Count) $(Get-Text 'log_scan_found')"
                }
            }
        }.GetNewClosure())
    
    $timer.Start()
}

# ============================================
# FUNCIONES USB/IP (usbip-win2)
# ============================================

function Find-UsbipExecutable {
    # Obtener directorio de la aplicacion (funciona con PS2EXE y script)
    $appDir = $null
    
    # Metodo 1: Para PS2EXE compilado
    try {
        $exePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
        if ($exePath -and $exePath -notmatch 'powershell\.exe$|pwsh\.exe$') {
            $appDir = Split-Path -Parent $exePath
        }
    }
    catch { }
    
    # Metodo 2: PSScriptRoot para scripts
    if (-not $appDir -and $PSScriptRoot) {
        $appDir = $PSScriptRoot
    }
    
    # Metodo 3: Directorio actual como fallback
    if (-not $appDir) {
        $appDir = Get-Location
    }
    
    # Priorizar usbipw local, luego instalado
    $locations = @(
        (Join-Path $appDir "usbipw.exe"),
        (Join-Path $appDir "usbip-win2.exe"),
        (Join-Path $appDir "usbip.exe"),
        "C:\Program Files\USBip\usbip.exe",
        "C:\Program Files\usbip\usbip.exe"
    )
    
    foreach ($loc in $locations) {
        if (Test-Path $loc -ErrorAction SilentlyContinue) {
            return (Resolve-Path $loc).Path
        }
    }
    
    $pathExe = Get-Command "usbip.exe" -ErrorAction SilentlyContinue
    if ($pathExe) {
        return $pathExe.Source
    }
    
    return $null
}

function Get-RemoteDevices {
    param([string]$ServerIP)
    
    $usbipPath = Find-UsbipExecutable
    if (-not $usbipPath) {
        return @{ Success = $false; Error = "No se encontro usbip.exe"; Devices = @() }
    }
    
    try {
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = $usbipPath
        # usbip-win2 syntax: list -r <ip>
        $startInfo.Arguments = "list -r $ServerIP"
        $startInfo.UseShellExecute = $false
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        $startInfo.CreateNoWindow = $true
        $startInfo.WindowStyle = 'Hidden'
        
        $process = [System.Diagnostics.Process]::Start($startInfo)
        $output = $process.StandardOutput.ReadToEnd()
        $errorOut = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        
        $devices = [System.Collections.ArrayList]::new()
        $lines = $output -split "`r?`n"
        
        foreach ($line in $lines) {
            # Match usbip-win2 output: "   1-1.4   : Realtek Semiconductor... (0bda:8152)"
            if ($line -match '^\s*(\d+-[\d.]+)\s*:\s*(.+)$') {
                $busId = $Matches[1].Trim()
                $desc = $Matches[2].Trim()
                
                # Extraer VID:PID si esta presente en formato (XXXX:XXXX)
                $vid = $null
                $prodId = $null
                if ($desc -match '\(([0-9A-Fa-f]{4}):([0-9A-Fa-f]{4})\)') {
                    $vid = $Matches[1]
                    $prodId = $Matches[2]
                }
                
                $device = @{
                    BusId       = $busId
                    Description = $desc
                    VID         = $vid
                    PID         = $prodId
                    VendorName  = ""
                    ProductName = ""
                }
                
                # Buscar nombres en usb.ids si tenemos VID:PID
                if ($vid -and $prodId) {
                    $usbInfo = Get-UsbVendorProduct -VendorId $vid -ProductId $prodId
                    $device.VendorName = $usbInfo.VendorName
                    $device.ProductName = $usbInfo.ProductName
                }
                
                [void]$devices.Add($device)
            }
        }
        
        if ($process.ExitCode -eq 0 -or $devices.Count -gt 0) {
            return @{ Success = $true; Output = $output; Devices = $devices }
        }
        else {
            $errorMsg = if ($errorOut) { $errorOut.Trim() } else { "No se pudo conectar al servidor" }
            return @{ Success = $false; Error = $errorMsg; Output = $output; Devices = @() }
        }
    }
    catch {
        return @{ Success = $false; Error = $_.Exception.Message; Devices = @() }
    }
}

function Get-AttachedDevices {
    $usbipPath = Find-UsbipExecutable
    if (-not $usbipPath) {
        return @{ Success = $false; Error = "No se encontro usbip.exe" }
    }
    
    try {
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = $usbipPath
        # usbip-win2 syntax: port
        $startInfo.Arguments = "port"
        $startInfo.UseShellExecute = $false
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        $startInfo.CreateNoWindow = $true
        $startInfo.WindowStyle = 'Hidden'
        
        $process = [System.Diagnostics.Process]::Start($startInfo)
        $output = $process.StandardOutput.ReadToEnd()
        $errorOut = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        
        return @{ Success = $true; Output = $output; Error = $errorOut }
    }
    catch {
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

function Connect-UsbipDevice {
    param(
        [string]$ServerIP,
        [string]$BusId
    )
    
    $usbipPath = Find-UsbipExecutable
    if (-not $usbipPath) {
        return @{ Success = $false; Error = "No se encontro usbip.exe" }
    }
    
    try {
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = $usbipPath
        # usbip-win2 syntax: attach -r <ip> -b <busid>
        $startInfo.Arguments = "attach -r $ServerIP -b $BusId"
        $startInfo.UseShellExecute = $false
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        $startInfo.CreateNoWindow = $true
        $startInfo.WindowStyle = 'Hidden'
        
        $process = [System.Diagnostics.Process]::Start($startInfo)
        $output = $process.StandardOutput.ReadToEnd()
        $errorOut = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        
        if ($process.ExitCode -eq 0) {
            return @{ Success = $true; Output = $output }
        }
        else {
            $errorMsg = if ($errorOut) { $errorOut } else { $output }
            return @{ Success = $false; Error = $errorMsg }
        }
    }
    catch {
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

function Disconnect-UsbipDevice {
    param(
        [string]$Port = "all"
    )
    
    $usbipPath = Find-UsbipExecutable
    if (-not $usbipPath) {
        return @{ Success = $false; Error = "No se encontro usbip.exe" }
    }
    
    try {
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = $usbipPath
        # usbip-win2 syntax: detach -p <port> or detach -a (all)
        if ($Port -eq "all") {
            $startInfo.Arguments = "detach -a"
        }
        else {
            $startInfo.Arguments = "detach -p $Port"
        }
        $startInfo.UseShellExecute = $false
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        $startInfo.CreateNoWindow = $true
        $startInfo.WindowStyle = 'Hidden'
        
        $process = [System.Diagnostics.Process]::Start($startInfo)
        $output = $process.StandardOutput.ReadToEnd()
        $errorOut = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        
        if ($process.ExitCode -eq 0) {
            return @{ Success = $true; Output = $output }
        }
        else {
            $errorMsg = if ($errorOut) { $errorOut } else { "No hay dispositivos conectados" }
            return @{ Success = $false; Error = $errorMsg }
        }
    }
    catch {
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

# ============================================
# FEATURE 1: VER DISPOSITIVOS CONECTADOS
# Añadido en v1.1.0 - 2025-12-09
# ============================================

function Get-ConnectedDevices {
    <#
    .SYNOPSIS
        Obtiene la lista de dispositivos USB/IP actualmente conectados
    .DESCRIPTION
        Ejecuta 'usbipw.exe port' y parsea la salida para obtener
        información detallada de cada dispositivo conectado.
    #>
    
    $usbipPath = Find-UsbipExecutable
    if (-not $usbipPath) {
        return @{ Success = $false; Error = "No se encontro usbip.exe"; Devices = @() }
    }
    
    try {
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = $usbipPath
        $startInfo.Arguments = "port"
        $startInfo.UseShellExecute = $false
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        $startInfo.CreateNoWindow = $true
        $startInfo.WindowStyle = 'Hidden'
        
        $process = [System.Diagnostics.Process]::Start($startInfo)
        $output = $process.StandardOutput.ReadToEnd()
        $errorOut = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        
        $devices = [System.Collections.ArrayList]::new()
        $lines = $output -split "`r?`n"
        
        $currentDevice = $null
        foreach ($line in $lines) {
            # Detectar linea de puerto: "Port 01: device in use at high-speed"
            if ($line -match '^Port\s+(\d+):\s+(.+)$') {
                if ($currentDevice) {
                    [void]$devices.Add($currentDevice)
                }
                $currentDevice = @{
                    Port    = [int]$Matches[1]
                    Status  = $Matches[2].Trim()
                    Product = ""
                    Remote  = ""
                }
            }
            # Detectar linea de producto (segunda linea, indentada)
            elseif ($currentDevice -and $line -match '^\s+([^->\s].+)$' -and -not $currentDevice.Product) {
                $currentDevice.Product = $Matches[1].Trim()
            }
            # Detectar linea de servidor remoto: "-> usbip://192.168.1.9:3240/1-1"
            elseif ($currentDevice -and $line -match '->\s*usbip://(.+)$') {
                $currentDevice.Remote = $Matches[1].Trim()
            }
        }
        
        # Añadir ultimo dispositivo
        if ($currentDevice) {
            [void]$devices.Add($currentDevice)
        }
        
        return @{ 
            Success = $true
            Output  = $output
            Devices = $devices
            Count   = $devices.Count
        }
    }
    catch {
        return @{ Success = $false; Error = $_.Exception.Message; Devices = @() }
    }
}

# ============================================
# FEATURE 2: INFORMACION EXTENDIDA VID:PID
# Añadido en v1.2.0 - 2025-12-09
# ============================================

function Find-UsbIdsFile {
    <#
    .SYNOPSIS
        Encuentra el archivo usb.ids en el directorio de la aplicacion
    #>
    $appDir = $null
    
    try {
        $exePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
        if ($exePath -and $exePath -notmatch 'powershell\.exe$|pwsh\.exe$') {
            $appDir = Split-Path -Parent $exePath
        }
    }
    catch { }
    
    if (-not $appDir -and $PSScriptRoot) {
        $appDir = $PSScriptRoot
    }
    
    if (-not $appDir) {
        $appDir = Get-Location
    }
    
    $usbIdsPath = Join-Path $appDir "usb.ids"
    if (Test-Path $usbIdsPath) {
        return $usbIdsPath
    }
    
    return $null
}

function Get-UsbVendorProduct {
    <#
    .SYNOPSIS
        Busca el nombre del fabricante y producto en usb.ids
    .PARAMETER VendorId
        ID del fabricante en hexadecimal (4 digitos)
    .PARAMETER ProductId
        ID del producto en hexadecimal (4 digitos)
    #>
    param(
        [string]$VendorId,
        [string]$ProductId
    )
    
    $result = @{
        VendorId    = $VendorId
        ProductId   = $ProductId
        VendorName  = "Desconocido"
        ProductName = "Desconocido"
    }
    
    $usbIdsPath = Find-UsbIdsFile
    if (-not $usbIdsPath) {
        return $result
    }
    
    try {
        $vendorPattern = "^$($VendorId.ToLower())\s+(.+)$"
        $productPattern = "^\t$($ProductId.ToLower())\s+(.+)$"
        $inVendor = $false
        
        $reader = [System.IO.StreamReader]::new($usbIdsPath)
        while ($null -ne ($line = $reader.ReadLine())) {
            # Buscar fabricante
            if (-not $inVendor -and $line -match $vendorPattern) {
                $result.VendorName = $Matches[1].Trim()
                $inVendor = $true
                continue
            }
            
            # Si estamos en el fabricante correcto, buscar producto
            if ($inVendor) {
                if ($line -match $productPattern) {
                    $result.ProductName = $Matches[1].Trim()
                    break
                }
                # Si encontramos otro fabricante, salir
                if ($line -match '^\w{4}\s+') {
                    break
                }
            }
        }
        $reader.Close()
    }
    catch {
        # Silenciar errores de lectura
    }
    
    return $result
}

function Get-DeviceVidPid {
    <#
    .SYNOPSIS
        Extrae VID:PID de la descripcion de un dispositivo USB
    .DESCRIPTION
        Parsea formatos comunes: "VID_XXXX&PID_XXXX", "(XXXX:XXXX)", etc.
    #>
    param([string]$Description)
    
    $vid = $null
    $prodId = $null
    
    # Formato Windows: VID_XXXX&PID_XXXX
    if ($Description -match 'VID_([0-9A-Fa-f]{4}).*PID_([0-9A-Fa-f]{4})') {
        $vid = $Matches[1]
        $prodId = $Matches[2]
    }
    # Formato (XXXX:XXXX)
    elseif ($Description -match '\(([0-9A-Fa-f]{4}):([0-9A-Fa-f]{4})\)') {
        $vid = $Matches[1]
        $prodId = $Matches[2]
    }
    # Formato XXXX:XXXX al final
    elseif ($Description -match '([0-9A-Fa-f]{4}):([0-9A-Fa-f]{4})$') {
        $vid = $Matches[1]
        $prodId = $Matches[2]
    }
    
    if ($vid -and $prodId) {
        return @{ VID = $vid; PID = $prodId }
    }
    return $null
}

function Get-ExtendedDeviceInfo {
    <#
    .SYNOPSIS
        Obtiene informacion extendida de un dispositivo USB
    #>
    param(
        [string]$Description,
        [string]$VID,
        [string]$ProductID
    )
    
    $info = @{
        Description = $Description
        VID         = $VID
        PID         = $ProductID
        VendorName  = ""
        ProductName = ""
        DisplayText = $Description
    }
    
    # Si no se proporcionaron VID/PID, intentar extraerlos
    if (-not $VID -or -not $ProductID) {
        $vidpid = Get-DeviceVidPid -Description $Description
        if ($vidpid) {
            $info.VID = $vidpid.VID
            $info.PID = $vidpid.PID
        }
    }
    
    # Buscar nombres en usb.ids
    if ($info.VID -and $info.PID) {
        $usbInfo = Get-UsbVendorProduct -VendorId $info.VID -ProductId $info.PID
        $info.VendorName = $usbInfo.VendorName
        $info.ProductName = $usbInfo.ProductName
        
        # Construir texto de visualizacion
        $vendorPart = if ($info.VendorName -ne "Desconocido") { $info.VendorName } else { "" }
        $productPart = if ($info.ProductName -ne "Desconocido") { $info.ProductName } else { $Description }
        
        if ($vendorPart) {
            $info.DisplayText = "$vendorPart - $productPart [$($info.VID):$($info.PID)]"
        }
        else {
            $info.DisplayText = "$productPart [$($info.VID):$($info.PID)]"
        }
    }
    
    return $info
}

# ============================================
# INSTALACION/DESINSTALACION DE DRIVERS
# Implementacion de drivers USB/IP
# ============================================

function Find-DevnodeExecutable {
    <#
    .SYNOPSIS
        Encuentra devnode.exe en el directorio de la aplicacion
    #>
    $appDir = $null
    
    try {
        $exePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
        if ($exePath -and $exePath -notmatch 'powershell\.exe$|pwsh\.exe$') {
            $appDir = Split-Path -Parent $exePath
        }
    }
    catch { }
    
    if (-not $appDir -and $PSScriptRoot) {
        $appDir = $PSScriptRoot
    }
    
    if (-not $appDir) {
        $appDir = Get-Location
    }
    
    $devnodePath = Join-Path $appDir "devnode.exe"
    if (Test-Path $devnodePath) {
        return $devnodePath
    }
    
    return $null
}

function Get-DriversDirectory {
    <#
    .SYNOPSIS
        Obtiene la ruta del directorio de drivers
    #>
    $appDir = $null
    
    try {
        $exePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
        if ($exePath -and $exePath -notmatch 'powershell\.exe$|pwsh\.exe$') {
            $appDir = Split-Path -Parent $exePath
        }
    }
    catch { }
    
    if (-not $appDir -and $PSScriptRoot) {
        $appDir = $PSScriptRoot
    }
    
    if (-not $appDir) {
        $appDir = Get-Location
    }
    
    $driversPath = Join-Path $appDir "drivers"
    if (Test-Path $driversPath) {
        return $driversPath
    }
    
    return $null
}

function Install-UsbipDrivers {
    <#
    .SYNOPSIS
        Instala los drivers USB/IP
    .DESCRIPTION
        1. Instala usbip2_ude.inf con pnputil
        2. Instala usbip2_filter.inf con pnputil
        3. Crea el nodo de dispositivo con devnode.exe
    #>
    
    $results = [System.Collections.ArrayList]::new()
    $driversDir = Get-DriversDirectory
    $devnodePath = Find-DevnodeExecutable
    
    if (-not $driversDir) {
        return @{ Success = $false; Error = "No se encontro la carpeta 'drivers'"; Results = @() }
    }
    
    if (-not $devnodePath) {
        return @{ Success = $false; Error = "No se encontro 'devnode.exe'"; Results = @() }
    }
    
    $hwid = "ROOT\USBIP_WIN2\UDE"
    $allSuccess = $true
    $needsReboot = $false
    
    # Paso 1: Instalar driver UDE (principal)
    $udeInf = Join-Path $driversDir "usbip2_ude.inf"
    if (Test-Path $udeInf) {
        try {
            $pnpResult = & pnputil.exe /add-driver $udeInf /install 2>&1
            $exitCode = $LASTEXITCODE
            $pnpOutput = ($pnpResult -join "`n")
            
            # pnputil devuelve 0 si exito, pero el driver puede ya existir
            $isSuccess = ($exitCode -eq 0) -or ($pnpOutput -match "ya existe|already exists")
            if ($pnpOutput -match "reiniciar|reboot") { $needsReboot = $true }
            
            [void]$results.Add(@{
                    Step    = "Instalar usbip2_ude.inf"
                    Success = $isSuccess
                    Output  = $pnpOutput
                })
            if (-not $isSuccess) { $allSuccess = $false }
        }
        catch {
            [void]$results.Add(@{ Step = "Instalar usbip2_ude.inf"; Success = $false; Output = $_.Exception.Message })
            $allSuccess = $false
        }
    }
    else {
        [void]$results.Add(@{ Step = "Instalar usbip2_ude.inf"; Success = $false; Output = "Archivo no encontrado: $udeInf" })
        $allSuccess = $false
    }
    
    # Paso 2: Instalar driver Filter
    $filterInf = Join-Path $driversDir "usbip2_filter.inf"
    if (Test-Path $filterInf) {
        try {
            $pnpResult = & pnputil.exe /add-driver $filterInf /install 2>&1
            $exitCode = $LASTEXITCODE
            $pnpOutput = ($pnpResult -join "`n")
            
            $isSuccess = ($exitCode -eq 0) -or ($pnpOutput -match "ya existe|already exists")
            if ($pnpOutput -match "reiniciar|reboot") { $needsReboot = $true }
            
            [void]$results.Add(@{
                    Step    = "Instalar usbip2_filter.inf"
                    Success = $isSuccess
                    Output  = $pnpOutput
                })
            if (-not $isSuccess) { $allSuccess = $false }
        }
        catch {
            [void]$results.Add(@{ Step = "Instalar usbip2_filter.inf"; Success = $false; Output = $_.Exception.Message })
            $allSuccess = $false
        }
    }
    
    # Paso 3: Crear nodo de dispositivo con devnode.exe
    # Sintaxis: devnode.exe install <infpath> <hwid>
    if (Test-Path $udeInf) {
        try {
            $devnodeResult = & $devnodePath install $udeInf $hwid 2>&1
            $exitCode = $LASTEXITCODE
            $devOutput = ($devnodeResult -join "`n")
            
            # devnode puede fallar si el dispositivo ya existe
            $isSuccess = ($exitCode -eq 0) -or ($devOutput -match "already exists|ya existe")
            
            [void]$results.Add(@{
                    Step    = "Crear nodo de dispositivo"
                    Success = $isSuccess
                    Output  = $devOutput
                })
            if (-not $isSuccess) { $allSuccess = $false }
        }
        catch {
            [void]$results.Add(@{ Step = "Crear nodo de dispositivo"; Success = $false; Output = $_.Exception.Message })
            $allSuccess = $false
        }
    }
    
    $message = if ($allSuccess -and $needsReboot) { 
        "Drivers instalados. Reinicia el sistema para completar." 
    }
    elseif ($allSuccess) { 
        "Drivers instalados correctamente" 
    }
    else { 
        "Algunos pasos fallaron" 
    }
    
    return @{
        Success     = $allSuccess
        Results     = $results
        NeedsReboot = $needsReboot
        Message     = $message
    }
}

function Uninstall-UsbipDrivers {
    <#
    .SYNOPSIS
        Desinstala los drivers USB/IP
    .DESCRIPTION
        1. Elimina el nodo de dispositivo con devnode.exe
        2. Busca archivos oem*.inf que contengan usbip2
        3. Elimina los drivers con pnputil
    #>
    
    $results = [System.Collections.ArrayList]::new()
    $devnodePath = Find-DevnodeExecutable
    $hwid = "ROOT\USBIP_WIN2\UDE"
    $allSuccess = $true
    
    # Paso 1: Eliminar nodo de dispositivo
    if ($devnodePath) {
        try {
            $devnodeResult = & $devnodePath remove $hwid root 2>&1
            $exitCode = $LASTEXITCODE
            [void]$results.Add(@{
                    Step    = "Eliminar nodo de dispositivo"
                    Success = ($exitCode -eq 0 -or $devnodeResult -match "No matching devices")
                    Output  = ($devnodeResult -join "`n")
                })
        }
        catch {
            [void]$results.Add(@{ Step = "Eliminar nodo de dispositivo"; Success = $false; Output = $_.Exception.Message })
        }
    }
    
    # Paso 2: Buscar y eliminar drivers oem*.inf que contengan usbip2
    try {
        $infPath = "C:\Windows\INF"
        $oemFiles = Get-ChildItem -Path $infPath -Filter "oem*.inf" -ErrorAction SilentlyContinue
        
        foreach ($oemFile in $oemFiles) {
            $content = Get-Content $oemFile.FullName -Raw -ErrorAction SilentlyContinue
            if ($content -match "usbip2_filter|usbip2_ude") {
                try {
                    $pnpResult = & pnputil.exe /delete-driver $oemFile.Name /uninstall /force 2>&1
                    $exitCode = $LASTEXITCODE
                    [void]$results.Add(@{
                            Step    = "Eliminar $($oemFile.Name)"
                            Success = ($exitCode -eq 0)
                            Output  = ($pnpResult -join "`n")
                        })
                    if ($exitCode -ne 0) { $allSuccess = $false }
                }
                catch {
                    [void]$results.Add(@{ Step = "Eliminar $($oemFile.Name)"; Success = $false; Output = $_.Exception.Message })
                    $allSuccess = $false
                }
            }
        }
    }
    catch {
        [void]$results.Add(@{ Step = "Buscar drivers instalados"; Success = $false; Output = $_.Exception.Message })
        $allSuccess = $false
    }
    
    return @{
        Success = $allSuccess
        Results = $results
        Message = if ($allSuccess) { "Drivers desinstalados correctamente" } else { "Algunos pasos fallaron" }
    }
}

function Test-DriversInstalled {
    <#
    .SYNOPSIS
        Verifica si los drivers USB/IP estan instalados
    #>
    try {
        # Buscar dispositivos USB/IP por varios patrones
        $patterns = @(
            "ROOT\USBIP*",
            "ROOT\USB\*",
            "USBIPWIN\*"
        )
        
        foreach ($pattern in $patterns) {
            $devices = Get-PnpDevice -InstanceId $pattern -ErrorAction SilentlyContinue | 
            Where-Object { $_.FriendlyName -match "usbip|USBip|VHCI|UDE" }
            if ($devices) {
                $device = $devices | Select-Object -First 1
                return @{ Installed = $true; Status = $device.Status; Device = $device }
            }
        }
        
        # Verificar si hay drivers cargados por nombre de servicio
        $services = @("usbip2_ude", "usbip_vhci", "vhci_ude")
        foreach ($svc in $services) {
            $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
            if ($service) {
                return @{ Installed = $true; Status = $service.Status; Device = $null }
            }
        }
        
        # Verificar si hay drivers OEM instalados (silencioso)
        try {
            $pinfo = New-Object System.Diagnostics.ProcessStartInfo
            $pinfo.FileName = "pnputil.exe"
            $pinfo.Arguments = "/enum-drivers"
            $pinfo.RedirectStandardOutput = $true
            $pinfo.RedirectStandardError = $true
            $pinfo.UseShellExecute = $false
            $pinfo.CreateNoWindow = $true
            $pinfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
            
            $p = New-Object System.Diagnostics.Process
            $p.StartInfo = $pinfo
            $p.Start() | Out-Null
            $driverOutput = $p.StandardOutput.ReadToEnd()
            $p.WaitForExit()
            
            if ($driverOutput -match "usbip2_ude|usbip2_filter|usbip_vhci") {
                return @{ Installed = $true; Status = "Driver en almacen"; Device = $null }
            }
        }
        catch { }
        
        return @{ Installed = $false; Status = "No instalado" }
    }
    catch {
        return @{ Installed = $false; Status = "Error: $($_.Exception.Message)" }
    }
}

# ============================================
# CREAR INTERFAZ GRAFICA
# ============================================

function Show-MainWindow {
    [System.Windows.Forms.Application]::EnableVisualStyles()
    [System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)
    
    # ============================================
    # FORMULARIO PRINCIPAL
    # ============================================
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "SnakeFoxu - USB/IP Manager"
    $form.Size = New-Object System.Drawing.Size(520, 720)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "None"  # Sin barra de Windows, estilo moderno
    $form.MaximizeBox = $false
    $form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $form.ForeColor = [System.Drawing.Color]::White
    $form.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    
    try { $form.Icon = [System.Drawing.SystemIcons]::Application } catch { }
    
    # ============================================
    # SYSTEM TRAY (NotifyIcon)
    # ============================================
    $script:forceClose = $false
    $script:notifyIcon = New-Object System.Windows.Forms.NotifyIcon
    $script:notifyIcon.Text = "SnakeUSBIP - USB/IP Manager"
    
    # Asignar ícono del sistema primero (garantizado que funciona)
    $script:notifyIcon.Icon = [System.Drawing.SystemIcons]::Application
    
    # Intentar cargar ícono personalizado (mismo patrón que Get-ConfigPath)
    try {
        $appDir = $null
        $exePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
        if ($exePath -and $exePath -notmatch 'powershell\.exe$|pwsh\.exe$') {
            $appDir = Split-Path -Parent $exePath
        }
        if (-not $appDir -and $PSScriptRoot) { $appDir = $PSScriptRoot }
        if (-not $appDir) { $appDir = (Get-Location).Path }
        
        $iconPath = Join-Path $appDir "Logo-SnakeFoxU-con-e.ico"
        if (Test-Path $iconPath) {
            $customIcon = New-Object System.Drawing.Icon($iconPath)
            $script:notifyIcon.Icon = $customIcon
            $form.Icon = $customIcon
        }
    }
    catch {
        # Mantener ícono del sistema si falla
    }
    
    $script:notifyIcon.Visible = $false  # Solo visible cuando está minimizado

    
    # Menú contextual del tray
    $trayMenu = New-Object System.Windows.Forms.ContextMenuStrip
    $trayMenu.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
    $trayMenu.ForeColor = [System.Drawing.Color]::White
    
    $trayMenuScan = New-Object System.Windows.Forms.ToolStripMenuItem("📡 Escanear Red")
    $trayMenuShow = New-Object System.Windows.Forms.ToolStripMenuItem("🔼 Mostrar Ventana")
    $trayMenuSeparator = New-Object System.Windows.Forms.ToolStripSeparator
    $trayMenuExit = New-Object System.Windows.Forms.ToolStripMenuItem("❌ Salir")
    
    $trayMenu.Items.AddRange(@($trayMenuScan, $trayMenuShow, $trayMenuSeparator, $trayMenuExit))
    $script:notifyIcon.ContextMenuStrip = $trayMenu
    
    # Eventos del tray
    $script:notifyIcon.Add_DoubleClick({
            $form.Show()
            $form.WindowState = 'Normal'
            $form.Activate()
            $script:notifyIcon.Visible = $false
        })
    
    $trayMenuShow.Add_Click({
            $form.Show()
            $form.WindowState = 'Normal'
            $form.Activate()
            $script:notifyIcon.Visible = $false
        })
    
    $trayMenuExit.Add_Click({
            $script:forceClose = $true
            if ($script:notifyIcon) {
                $script:notifyIcon.Visible = $false
                $script:notifyIcon.Dispose()
                $script:notifyIcon = $null
            }
            [System.Windows.Forms.Application]::Exit()
        })
    
    # Minimizar a tray
    $form.Add_Resize({
            if ($form.WindowState -eq [System.Windows.Forms.FormWindowState]::Minimized) {
                $form.Hide()
                if ($script:notifyIcon) {
                    $script:notifyIcon.Visible = $true
                    $script:notifyIcon.ShowBalloonTip(1000, "SnakeUSBIP", "Minimizado a bandeja del sistema", [System.Windows.Forms.ToolTipIcon]::Info)
                }
            }
        })
    
    # El botón cerrar (X) ahora cierra la app normalmente
    # El botón minimizar sigue enviando a la bandeja del sistema
    
    # Limpiar al cerrar
    $form.Add_FormClosed({
            if ($script:notifyIcon) {
                try {
                    $script:notifyIcon.Visible = $false
                    $script:notifyIcon.Dispose()
                }
                catch { }
                $script:notifyIcon = $null
            }
            [System.Windows.Forms.Application]::Exit()
        })
    

    # ============================================
    # PANEL TITULO
    # ============================================
    $titlePanel = New-Object System.Windows.Forms.Panel
    $titlePanel.Size = New-Object System.Drawing.Size(520, 50)
    $titlePanel.Location = New-Object System.Drawing.Point(0, 0)
    $titlePanel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
    $titlePanel.Cursor = [System.Windows.Forms.Cursors]::SizeAll  # Cursor de arrastre
    $form.Controls.Add($titlePanel)
    
    # Permitir arrastrar la ventana desde el titlePanel
    $script:isDragging = $false
    $script:dragStart = [System.Drawing.Point]::Empty
    
    $titlePanel.Add_MouseDown({
            param($sender, $e)
            if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
                $script:isDragging = $true
                $script:dragStart = $e.Location
            }
        })
    
    $titlePanel.Add_MouseMove({
            param($sender, $e)
            if ($script:isDragging) {
                $form.Left = $form.Left + ($e.X - $script:dragStart.X)
                $form.Top = $form.Top + ($e.Y - $script:dragStart.Y)
            }
        })
    
    $titlePanel.Add_MouseUp({
            $script:isDragging = $false
        })
    
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = "🦊 SnakeFoxu"
    $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $titleLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 140, 0)  # Naranja
    $titleLabel.AutoSize = $true
    $titleLabel.Location = New-Object System.Drawing.Point(12, 12)
    $titlePanel.Controls.Add($titleLabel)
    
    $subtitleLabel = New-Object System.Windows.Forms.Label
    $subtitleLabel.Text = "USB/IP Manager"
    $subtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $subtitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
    $subtitleLabel.AutoSize = $true
    $subtitleLabel.Location = New-Object System.Drawing.Point(160, 17)
    $titlePanel.Controls.Add($subtitleLabel)
    
    # Botón de idioma (toggle ES/EN) - muestra idioma ACTUAL
    $langButton = New-Object System.Windows.Forms.Button
    $langButton.Text = if ($script:Language -eq "es") { "🌐 ES" } else { "🌐 EN" }
    $langButton.Size = New-Object System.Drawing.Size(55, 26)
    $langButton.Location = New-Object System.Drawing.Point(280, 12)
    $langButton.FlatStyle = "Flat"
    $langButton.BackColor = [System.Drawing.Color]::FromArgb(62, 62, 66)
    $langButton.ForeColor = [System.Drawing.Color]::White
    $langButton.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $langButton.Cursor = [System.Windows.Forms.Cursors]::Hand
    $langButton.FlatAppearance.BorderSize = 0
    $titlePanel.Controls.Add($langButton)
    # Hover effect
    $langButton.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(90, 90, 95) })
    $langButton.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(62, 62, 66) })
    
    # Botón de actualización - más descriptivo
    $updateButton = New-Object System.Windows.Forms.Button
    $updateButton.Text = if ($script:Language -eq "es") { "⬆️ Actualizar" } else { "⬆️ Update" }
    $updateButton.Size = New-Object System.Drawing.Size(90, 26)
    $updateButton.Location = New-Object System.Drawing.Point(345, 12)
    $updateButton.FlatStyle = "Flat"
    $updateButton.BackColor = [System.Drawing.Color]::FromArgb(62, 62, 66)
    $updateButton.ForeColor = [System.Drawing.Color]::White
    $updateButton.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $updateButton.Cursor = [System.Windows.Forms.Cursors]::Hand
    $updateButton.FlatAppearance.BorderSize = 0
    $script:updateButtonRef = $updateButton
    $titlePanel.Controls.Add($updateButton)
    # Hover effect
    $updateButton.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(90, 90, 95) })
    $updateButton.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(62, 62, 66) })
    
    # ============================================
    # BOTONES ESTILO macOS (redondos de colores)
    # ============================================
    
    # Botón Minimizar (amarillo)
    $minimizeBtn = New-Object System.Windows.Forms.Button
    $minimizeBtn.Size = New-Object System.Drawing.Size(14, 14)
    $minimizeBtn.Location = New-Object System.Drawing.Point(460, 18)
    $minimizeBtn.FlatStyle = "Flat"
    $minimizeBtn.BackColor = [System.Drawing.Color]::FromArgb(255, 189, 68)  # Amarillo macOS
    $minimizeBtn.FlatAppearance.BorderSize = 0
    $minimizeBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $minimizeBtn.Tag = "minimize"
    # Hacer el botón redondo
    $minimizePath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $minimizePath.AddEllipse(0, 0, 13, 13)
    $minimizeBtn.Region = New-Object System.Drawing.Region($minimizePath)
    $titlePanel.Controls.Add($minimizeBtn)
    
    # Botón Maximizar/Restaurar (verde)
    $maximizeBtn = New-Object System.Windows.Forms.Button
    $maximizeBtn.Size = New-Object System.Drawing.Size(14, 14)
    $maximizeBtn.Location = New-Object System.Drawing.Point(478, 18)
    $maximizeBtn.FlatStyle = "Flat"
    $maximizeBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 202, 78)  # Verde macOS
    $maximizeBtn.FlatAppearance.BorderSize = 0
    $maximizeBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $maximizeBtn.Tag = "maximize"
    $maximizePath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $maximizePath.AddEllipse(0, 0, 13, 13)
    $maximizeBtn.Region = New-Object System.Drawing.Region($maximizePath)
    $titlePanel.Controls.Add($maximizeBtn)
    
    # Botón Cerrar (rojo)
    $closeBtn = New-Object System.Windows.Forms.Button
    $closeBtn.Size = New-Object System.Drawing.Size(14, 14)
    $closeBtn.Location = New-Object System.Drawing.Point(496, 18)
    $closeBtn.FlatStyle = "Flat"
    $closeBtn.BackColor = [System.Drawing.Color]::FromArgb(255, 96, 92)  # Rojo macOS
    $closeBtn.FlatAppearance.BorderSize = 0
    $closeBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $closeBtn.Tag = "close"
    $closePath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $closePath.AddEllipse(0, 0, 13, 13)
    $closeBtn.Region = New-Object System.Drawing.Region($closePath)
    $titlePanel.Controls.Add($closeBtn)
    
    # Eventos de los botones macOS
    $minimizeBtn.Add_Click({
            $form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized
        })
    
    $maximizeBtn.Add_Click({
            if ($form.WindowState -eq [System.Windows.Forms.FormWindowState]::Maximized) {
                $form.WindowState = [System.Windows.Forms.FormWindowState]::Normal
            }
            else {
                $form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
            }
        })
    
    $closeBtn.Add_Click({
            $form.Close()
        })
    
    # Hover effects para los botones macOS
    $minimizeBtn.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(255, 210, 100) })
    $minimizeBtn.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(255, 189, 68) })
    $maximizeBtn.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(50, 220, 100) })
    $maximizeBtn.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 202, 78) })
    $closeBtn.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(255, 120, 120) })
    $closeBtn.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(255, 96, 92) })

    
    # ============================================
    # PANEL SERVIDOR
    # ============================================
    $serverPanel = New-Object System.Windows.Forms.Panel
    $serverPanel.Size = New-Object System.Drawing.Size(495, 35)
    $serverPanel.Location = New-Object System.Drawing.Point(12, 58)
    $serverPanel.BackColor = [System.Drawing.Color]::FromArgb(37, 37, 38)
    $form.Controls.Add($serverPanel)
    
    $ipLabel = New-Object System.Windows.Forms.Label
    $ipLabel.Text = "Servidor:"
    $ipLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $ipLabel.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
    $ipLabel.AutoSize = $true
    $ipLabel.Location = New-Object System.Drawing.Point(8, 8)
    $serverPanel.Controls.Add($ipLabel)
    
    $ipTextBox = New-Object System.Windows.Forms.TextBox
    $ipTextBox.Size = New-Object System.Drawing.Size(120, 24)
    $ipTextBox.Location = New-Object System.Drawing.Point(70, 5)
    $ipTextBox.Font = New-Object System.Drawing.Font("Consolas", 10)
    $ipTextBox.BackColor = [System.Drawing.Color]::FromArgb(51, 51, 55)
    $ipTextBox.ForeColor = [System.Drawing.Color]::White
    $ipTextBox.BorderStyle = "FixedSingle"
    $serverPanel.Controls.Add($ipTextBox)
    
    $scanButton = New-Object System.Windows.Forms.Button
    $scanButton.Text = "🔍 Escanear"
    $scanButton.Size = New-Object System.Drawing.Size(85, 26)
    $scanButton.Location = New-Object System.Drawing.Point(198, 4)
    $scanButton.FlatStyle = "Flat"
    $scanButton.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204)  # Azul vibrante
    $scanButton.ForeColor = [System.Drawing.Color]::White
    $scanButton.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $scanButton.FlatAppearance.BorderSize = 0
    $scanButton.Cursor = [System.Windows.Forms.Cursors]::Hand
    $serverPanel.Controls.Add($scanButton)
    # Hover effect
    $scanButton.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(30, 150, 230) })
    $scanButton.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204) })
    
    $refreshButton = New-Object System.Windows.Forms.Button
    $refreshButton.Text = "🔄 Listar"
    $refreshButton.Size = New-Object System.Drawing.Size(68, 26)
    $refreshButton.Location = New-Object System.Drawing.Point(288, 4)
    $refreshButton.FlatStyle = "Flat"
    $refreshButton.BackColor = [System.Drawing.Color]::FromArgb(78, 78, 82)  # Gris oscuro
    $refreshButton.ForeColor = [System.Drawing.Color]::White
    $refreshButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $refreshButton.FlatAppearance.BorderSize = 0
    $refreshButton.Cursor = [System.Windows.Forms.Cursors]::Hand
    $serverPanel.Controls.Add($refreshButton)
    # Hover effect
    $refreshButton.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(100, 100, 105) })
    $refreshButton.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(78, 78, 82) })
    
    $sshButton = New-Object System.Windows.Forms.Button
    $sshButton.Text = "🖥️ SSH"
    $sshButton.Size = New-Object System.Drawing.Size(60, 26)
    $sshButton.Location = New-Object System.Drawing.Point(361, 4)
    $sshButton.FlatStyle = "Flat"
    $sshButton.BackColor = [System.Drawing.Color]::FromArgb(96, 80, 112)  # Púrpura
    $sshButton.ForeColor = [System.Drawing.Color]::White
    $sshButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $sshButton.FlatAppearance.BorderSize = 0
    $sshButton.Cursor = [System.Windows.Forms.Cursors]::Hand
    $serverPanel.Controls.Add($sshButton)
    # Hover effect
    $sshButton.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(120, 100, 140) })
    $sshButton.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(96, 80, 112) })
    
    # Click handler para botón SSH - Ventana con instrucciones y selector de usuario
    $sshButton.Add_Click({
            $serverIP = $ipTextBox.Text.Trim()
            if (-not $serverIP) { $serverIP = "192.168.1.100" }
        
            # Crear ventana de instrucciones SSH
            $sshForm = New-Object System.Windows.Forms.Form
            $sshForm.Text = "SSH - Configurar Servidor USB/IP"
            $sshForm.Size = New-Object System.Drawing.Size(480, 450)
            $sshForm.StartPosition = "CenterScreen"
            $sshForm.FormBorderStyle = "FixedDialog"
            $sshForm.MaximizeBox = $false
            $sshForm.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
        
            # Instrucciones
            $instructionsLabel = New-Object System.Windows.Forms.Label
            $instructionsLabel.Text = "📋 Instrucciones para Linux/Raspberry Pi:`n`n" +
            "1. Instalar paquetes:`n" +
            "   sudo apt update`n" +
            "   sudo apt install usbip hwdata usbutils`n`n" +
            "2. Cargar módulo del kernel:`n" +
            "   sudo modprobe usbip_host`n`n" +
            "3. Iniciar servicio:`n" +
            "   sudo usbipd`n`n" +
            "4. Ver dispositivos USB disponibles:`n" +
            "   usbip list -l`n`n" +
            "5. Exportar dispositivo (ej: 1-1.4):`n" +
            "   sudo usbip bind -b 1-1.4`n`n" +
            "6. Auto-inicio (agregar a /etc/rc.local):`n" +
            "   modprobe usbip_host && usbipd -D"
            $instructionsLabel.Font = New-Object System.Drawing.Font("Consolas", 9)
            $instructionsLabel.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
            $instructionsLabel.Size = New-Object System.Drawing.Size(450, 280)
            $instructionsLabel.Location = New-Object System.Drawing.Point(15, 15)
            $sshForm.Controls.Add($instructionsLabel)
        
            # Panel de conexión
            $connPanel = New-Object System.Windows.Forms.Panel
            $connPanel.Size = New-Object System.Drawing.Size(450, 80)
            $connPanel.Location = New-Object System.Drawing.Point(15, 300)
            $connPanel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
            $sshForm.Controls.Add($connPanel)
        
            $userLabel = New-Object System.Windows.Forms.Label
            $userLabel.Text = "Usuario:"
            $userLabel.ForeColor = [System.Drawing.Color]::White
            $userLabel.Location = New-Object System.Drawing.Point(10, 15)
            $userLabel.AutoSize = $true
            $connPanel.Controls.Add($userLabel)
        
            $userTextBox = New-Object System.Windows.Forms.TextBox
            $userTextBox.Text = "pi"
            $userTextBox.Size = New-Object System.Drawing.Size(100, 24)
            $userTextBox.Location = New-Object System.Drawing.Point(75, 12)
            $userTextBox.BackColor = [System.Drawing.Color]::FromArgb(51, 51, 55)
            $userTextBox.ForeColor = [System.Drawing.Color]::White
            $connPanel.Controls.Add($userTextBox)
        
            $atLabel = New-Object System.Windows.Forms.Label
            $atLabel.Text = "@"
            $atLabel.ForeColor = [System.Drawing.Color]::White
            $atLabel.Location = New-Object System.Drawing.Point(180, 15)
            $atLabel.AutoSize = $true
            $connPanel.Controls.Add($atLabel)
        
            $sshIpTextBox = New-Object System.Windows.Forms.TextBox
            $sshIpTextBox.Text = $serverIP
            $sshIpTextBox.Size = New-Object System.Drawing.Size(140, 24)
            $sshIpTextBox.Location = New-Object System.Drawing.Point(195, 12)
            $sshIpTextBox.BackColor = [System.Drawing.Color]::FromArgb(51, 51, 55)
            $sshIpTextBox.ForeColor = [System.Drawing.Color]::White
            $connPanel.Controls.Add($sshIpTextBox)
        
            $connectBtn = New-Object System.Windows.Forms.Button
            $connectBtn.Text = "🔗 Conectar"
            $connectBtn.Size = New-Object System.Drawing.Size(100, 28)
            $connectBtn.Location = New-Object System.Drawing.Point(345, 10)
            $connectBtn.FlatStyle = "Flat"
            $connectBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204)
            $connectBtn.ForeColor = [System.Drawing.Color]::White
            $connectBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
            $connPanel.Controls.Add($connectBtn)
        
            $copyBtn = New-Object System.Windows.Forms.Button
            $copyBtn.Text = "📋 Copiar comandos"
            $copyBtn.Size = New-Object System.Drawing.Size(130, 28)
            $copyBtn.Location = New-Object System.Drawing.Point(10, 45)
            $copyBtn.FlatStyle = "Flat"
            $copyBtn.BackColor = [System.Drawing.Color]::FromArgb(62, 62, 66)
            $copyBtn.ForeColor = [System.Drawing.Color]::White
            $copyBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
            $connPanel.Controls.Add($copyBtn)
        
            $copyBtn.Add_Click({
                    $commands = "sudo apt update && sudo apt install usbip hwdata usbutils && sudo modprobe usbip_host && sudo usbipd"
                    [System.Windows.Forms.Clipboard]::SetText($commands)
                    $copyBtn.Text = "✓ Copiado!"
                })
        
            $connectBtn.Add_Click({
                    $user = $userTextBox.Text.Trim()
                    $ip = $sshIpTextBox.Text.Trim()
                    if ($user -and $ip) {
                        $sshForm.Close()
                        try {
                            $wtPath = Get-Command wt.exe -ErrorAction SilentlyContinue
                            if ($wtPath) {
                                Start-Process wt.exe -ArgumentList "new-tab ssh $user@$ip"
                            }
                            else {
                                Start-Process powershell.exe -ArgumentList "-NoExit -Command ssh $user@$ip"
                            }
                        }
                        catch {
                            Start-Process cmd.exe -ArgumentList "/k ssh $user@$ip"
                        }
                    }
                })
        
            $closeBtn = New-Object System.Windows.Forms.Button
            $closeBtn.Text = "Cerrar"
            $closeBtn.Size = New-Object System.Drawing.Size(80, 28)
            $closeBtn.Location = New-Object System.Drawing.Point(385, 390)
            $closeBtn.FlatStyle = "Flat"
            $closeBtn.BackColor = [System.Drawing.Color]::FromArgb(62, 62, 66)
            $closeBtn.ForeColor = [System.Drawing.Color]::White
            $closeBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
            $sshForm.Controls.Add($closeBtn)
            $closeBtn.Add_Click({ $sshForm.Close() })
        
            $sshForm.ShowDialog() | Out-Null
        }.GetNewClosure())
    
    # Botón VPN / Internet
    $vpnButton = New-Object System.Windows.Forms.Button
    $vpnButton.Text = Get-Text "btn_vpn"
    $vpnButton.Size = New-Object System.Drawing.Size(60, 26)
    $vpnButton.Location = New-Object System.Drawing.Point(426, 4)
    $vpnButton.FlatStyle = "Flat"
    $vpnButton.BackColor = [System.Drawing.Color]::FromArgb(0, 128, 128)  # Teal
    $vpnButton.ForeColor = [System.Drawing.Color]::White
    $vpnButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $vpnButton.FlatAppearance.BorderSize = 0
    $vpnButton.Cursor = [System.Windows.Forms.Cursors]::Hand
    $serverPanel.Controls.Add($vpnButton)
    # Hover effect
    $vpnButton.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 160, 160) })
    $vpnButton.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 128, 128) })
    
    # Click handler para botón VPN
    $vpnButton.Add_Click({
            $vpnResult = Show-InternetConnectionDialog
            if ($vpnResult -and $vpnResult.IPs.Count -gt 0) {
                foreach ($vpnIP in $vpnResult.IPs) {
                    # Listar dispositivos del servidor VPN
                    Add-LogEntry -Type "Info" -Message "Conectando a servidor VPN: $vpnIP"
                    Update-TreeView -ServerIP $vpnIP -ClearFirst $false
                }
                Update-ConnectedDevices
                
                # Actualizar UI
                $ipTextBox.Text = $vpnResult.IPs[0]  # Primera IP en el textbox
                $count = $vpnResult.IPs.Count
                if ($count -eq 1) {
                    $statusLabel.Text = "✓ Servidor VPN añadido: $($vpnResult.IPs[0])"
                }
                else {
                    $statusLabel.Text = "✓ $count servidores VPN añadidos"
                }
                $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
            }
        })
    
    # ============================================
    # TREEVIEW - ESTILO VIRTUALHERE
    # ============================================
    $treeView = New-Object System.Windows.Forms.TreeView
    $treeView.Size = New-Object System.Drawing.Size(496, 280)
    $treeView.Location = New-Object System.Drawing.Point(12, 100)
    $treeView.BackColor = [System.Drawing.Color]::FromArgb(37, 37, 38)
    $treeView.ForeColor = [System.Drawing.Color]::White
    $treeView.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $treeView.BorderStyle = "FixedSingle"
    $treeView.FullRowSelect = $true
    $treeView.HideSelection = $false
    $treeView.ShowLines = $true
    $treeView.ShowPlusMinus = $true
    $treeView.ShowRootLines = $true
    $treeView.ShowNodeToolTips = $true
    $form.Controls.Add($treeView)
    
    # Nodos raiz
    $hubsNode = New-Object System.Windows.Forms.TreeNode("📡 USB Hubs")
    $hubsNode.Name = "hubs"
    $hubsNode.ForeColor = [System.Drawing.Color]::FromArgb(86, 156, 214)
    [void]$treeView.Nodes.Add($hubsNode)
    
    $connectedNode = New-Object System.Windows.Forms.TreeNode("✅ Dispositivos Conectados")
    $connectedNode.Name = "connected"
    $connectedNode.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
    [void]$treeView.Nodes.Add($connectedNode)
    
    # FEATURE 3: Nodo Favoritos
    $favoritesNode = New-Object System.Windows.Forms.TreeNode("⭐ Favoritos")
    $favoritesNode.Name = "favorites"
    $favoritesNode.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 100)
    [void]$treeView.Nodes.Add($favoritesNode)
    
    # ============================================
    # MENU CONTEXTUAL
    # ============================================
    $contextMenu = New-Object System.Windows.Forms.ContextMenuStrip
    $contextMenu.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
    $contextMenu.ForeColor = [System.Drawing.Color]::White
    
    $menuConnect = New-Object System.Windows.Forms.ToolStripMenuItem("🔌 Conectar")
    $menuDisconnect = New-Object System.Windows.Forms.ToolStripMenuItem("❌ Desconectar")
    $menuSeparator1 = New-Object System.Windows.Forms.ToolStripSeparator
    $menuAddFavorite = New-Object System.Windows.Forms.ToolStripMenuItem("⭐ Añadir a Favoritos")
    $menuRemoveFavorite = New-Object System.Windows.Forms.ToolStripMenuItem("❌ Quitar de Favoritos")
    $menuSeparator2 = New-Object System.Windows.Forms.ToolStripSeparator
    $menuProperties = New-Object System.Windows.Forms.ToolStripMenuItem("📋 Propiedades")
    
    $contextMenu.Items.AddRange(@($menuConnect, $menuDisconnect, $menuSeparator1, $menuAddFavorite, $menuRemoveFavorite, $menuSeparator2, $menuProperties))
    $treeView.ContextMenuStrip = $contextMenu
    
    # ============================================
    # PANEL DE LOG DE ACTIVIDAD
    # ============================================
    $logPanel = New-Object System.Windows.Forms.Panel
    $logPanel.Size = New-Object System.Drawing.Size(496, 120)
    $logPanel.Location = New-Object System.Drawing.Point(12, 385)
    $logPanel.BackColor = [System.Drawing.Color]::FromArgb(37, 37, 38)
    $logPanel.BorderStyle = "FixedSingle"
    $form.Controls.Add($logPanel)
    
    $logLabel = New-Object System.Windows.Forms.Label
    $logLabel.Text = Get-Text "log_title"
    $logLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $logLabel.AutoSize = $true
    $logLabel.Location = New-Object System.Drawing.Point(5, 3)
    $logLabel.ForeColor = [System.Drawing.Color]::FromArgb(86, 156, 214)
    $logPanel.Controls.Add($logLabel)
    
    $clearLogButton = New-Object System.Windows.Forms.Button
    $clearLogButton.Text = Get-Text "log_clear"
    $clearLogButton.Size = New-Object System.Drawing.Size(60, 20)
    $clearLogButton.Location = New-Object System.Drawing.Point(425, 2)
    $clearLogButton.FlatStyle = "Flat"
    $clearLogButton.BackColor = [System.Drawing.Color]::FromArgb(62, 62, 66)
    $clearLogButton.ForeColor = [System.Drawing.Color]::White
    $clearLogButton.Font = New-Object System.Drawing.Font("Segoe UI", 7)
    $clearLogButton.Cursor = [System.Windows.Forms.Cursors]::Hand
    $clearLogButton.FlatAppearance.BorderSize = 0
    $logPanel.Controls.Add($clearLogButton)
    $clearLogButton.Add_Click({
            $script:ActivityLog.Clear()
            $script:logTextBox.Text = ""
        })
    
    $script:logTextBox = New-Object System.Windows.Forms.TextBox
    $script:logTextBox.Multiline = $true
    $script:logTextBox.ReadOnly = $true
    $script:logTextBox.ScrollBars = "Vertical"
    $script:logTextBox.Size = New-Object System.Drawing.Size(486, 90)
    $script:logTextBox.Location = New-Object System.Drawing.Point(3, 25)
    $script:logTextBox.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $script:logTextBox.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
    $script:logTextBox.Font = New-Object System.Drawing.Font("Consolas", 8)
    $script:logTextBox.BorderStyle = "None"
    $logPanel.Controls.Add($script:logTextBox)
    
    # ============================================
    # BARRA DE PROGRESO
    # ============================================
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Size = New-Object System.Drawing.Size(496, 5)
    $progressBar.Location = New-Object System.Drawing.Point(12, 510)
    $progressBar.Style = "Continuous"
    $progressBar.Visible = $false
    $form.Controls.Add($progressBar)
    
    # ============================================
    # PANEL ESTADO Y DRIVERS
    # ============================================
    $statusPanel = New-Object System.Windows.Forms.Panel
    $statusPanel.Size = New-Object System.Drawing.Size(496, 100)
    $statusPanel.Location = New-Object System.Drawing.Point(12, 520)
    $statusPanel.BackColor = [System.Drawing.Color]::FromArgb(37, 37, 38)
    $form.Controls.Add($statusPanel)
    
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = "Iniciando..."
    $statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $statusLabel.AutoSize = $false
    $statusLabel.Size = New-Object System.Drawing.Size(440, 40)
    $statusLabel.Location = New-Object System.Drawing.Point(5, 5)
    $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
    $statusPanel.Controls.Add($statusLabel)
    
    $driverLabel = New-Object System.Windows.Forms.Label
    $driverLabel.Text = "Drivers: ?"
    $driverLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $driverLabel.AutoSize = $true
    $driverLabel.Location = New-Object System.Drawing.Point(5, 50)
    $driverLabel.ForeColor = [System.Drawing.Color]::Gray
    $statusPanel.Controls.Add($driverLabel)
    
    $installDriversButton = New-Object System.Windows.Forms.Button
    $installDriversButton.Text = "Instalar"
    $installDriversButton.Size = New-Object System.Drawing.Size(70, 24)
    $installDriversButton.Location = New-Object System.Drawing.Point(280, 48)
    $installDriversButton.FlatStyle = "Flat"
    $installDriversButton.BackColor = [System.Drawing.Color]::FromArgb(75, 0, 130)
    $installDriversButton.ForeColor = [System.Drawing.Color]::White
    $installDriversButton.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $installDriversButton.Cursor = [System.Windows.Forms.Cursors]::Hand
    $installDriversButton.FlatAppearance.BorderSize = 0
    $statusPanel.Controls.Add($installDriversButton)
    # Hover effect
    $installDriversButton.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(107, 75, 163) })
    $installDriversButton.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(75, 0, 130) })
    
    $uninstallDriversButton = New-Object System.Windows.Forms.Button
    $uninstallDriversButton.Text = "Desinstalar"
    $uninstallDriversButton.Size = New-Object System.Drawing.Size(80, 24)
    $uninstallDriversButton.Location = New-Object System.Drawing.Point(355, 48)
    $uninstallDriversButton.FlatStyle = "Flat"
    $uninstallDriversButton.BackColor = [System.Drawing.Color]::FromArgb(100, 50, 50)
    $uninstallDriversButton.ForeColor = [System.Drawing.Color]::White
    $uninstallDriversButton.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $uninstallDriversButton.Cursor = [System.Windows.Forms.Cursors]::Hand
    $uninstallDriversButton.FlatAppearance.BorderSize = 0
    $statusPanel.Controls.Add($uninstallDriversButton)
    # Hover effect
    $uninstallDriversButton.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(140, 70, 70) })
    $uninstallDriversButton.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(100, 50, 50) })
    
    # ============================================
    # VARIABLES DE ESTADO
    # ============================================
    $script:currentServer = $null
    $script:remoteDevices = @{}
    
    # ============================================
    # FUNCIONES AUXILIARES DE UI
    # ============================================
    function Update-TreeView {
        param(
            [string]$ServerIP,
            [bool]$ClearFirst = $true  # Por defecto limpia, pero puede ser incremental
        )
        
        # Si ClearFirst, limpiar todos los servidores existentes
        if ($ClearFirst) {
            $hubsNode.Nodes.Clear()
            $hubsNode.Text = "📡 USB Hubs (0)"
            $script:remoteDevices = @{}
        }
        
        if (-not $ServerIP) { return }
        
        # Procesar eventos pendientes para evitar bloqueos de UI
        [System.Windows.Forms.Application]::DoEvents()
        
        # Verificar si el servidor ya existe en el árbol
        $existingServer = $hubsNode.Nodes | Where-Object { $_.Name -eq "server_$ServerIP" }
        if ($existingServer) {
            # Ya existe, actualizar en lugar de duplicar
            $hubsNode.Nodes.Remove($existingServer)
        }
        
        $statusLabel.Text = "Listando dispositivos en $ServerIP..."
        $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(86, 156, 214)
        $form.Refresh()
        
        $result = Get-RemoteDevices -ServerIP $ServerIP
        
        if ($result.Success -and $result.Devices.Count -gt 0) {
            $script:currentServer = $ServerIP
            
            # Nodo del servidor
            $serverNode = New-Object System.Windows.Forms.TreeNode("🖥️ $ServerIP")
            $serverNode.Name = "server_$ServerIP"
            $serverNode.ForeColor = [System.Drawing.Color]::FromArgb(220, 220, 220)
            $serverNode.Tag = @{ Type = "server"; IP = $ServerIP }
            
            foreach ($device in $result.Devices) {
                $deviceIcon = Get-DeviceIcon -Description $device.Description -VendorId $device.VID -ProductId $device.PID
                $displayText = "$deviceIcon $($device.BusId): $($device.Description)"
                
                $deviceNode = New-Object System.Windows.Forms.TreeNode($displayText)
                $deviceNode.Name = "device_$ServerIP`_$($device.BusId)"
                $deviceNode.ForeColor = [System.Drawing.Color]::FromArgb(206, 145, 120)
                $deviceNode.Tag = @{ 
                    Type        = "remote"
                    BusId       = $device.BusId
                    Description = $device.Description
                    VID         = $device.VID
                    PID         = $device.PID
                    VendorName  = $device.VendorName
                    ProductName = $device.ProductName
                    ServerIP    = $ServerIP
                }
                
                # Tooltip con info detallada
                $tooltipLines = @("Bus ID: $($device.BusId)")
                if ($device.VID -and $device.PID) {
                    $tooltipLines += "VID:PID: $($device.VID):$($device.PID)"
                }
                if ($device.VendorName) {
                    $tooltipLines += "Fabricante: $($device.VendorName)"
                }
                if ($device.ProductName) {
                    $tooltipLines += "Producto: $($device.ProductName)"
                }
                $tooltipLines += "Servidor: $ServerIP"
                $deviceNode.ToolTipText = $tooltipLines -join "`n"
                
                $serverNode.Nodes.Add($deviceNode)
                $script:remoteDevices["$ServerIP`_$($device.BusId)"] = $device
            }
            
            # Actualizar texto del servidor con contador
            $serverNode.Text = "🖥️ $ServerIP ($($result.Devices.Count))"
            
            $hubsNode.Nodes.Add($serverNode)
            $hubsNode.Expand()
            $serverNode.Expand()
            
            # Actualizar texto de USB Hubs con total de dispositivos
            $totalDevices = 0
            foreach ($srvNode in $hubsNode.Nodes) {
                $totalDevices += $srvNode.Nodes.Count
            }
            $hubsNode.Text = "📡 USB Hubs ($totalDevices)"
            
            $statusLabel.Text = "✓ $($hubsNode.Nodes.Count) servidor(es), $totalDevices dispositivo(s)"
            $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
        }
        elseif ($result.Success) {
            $statusLabel.Text = "No hay dispositivos exportados en $ServerIP"
            $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 100)
        }
        else {
            $statusLabel.Text = "Error: $($result.Error)"
            $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(244, 135, 113)
        }
    }
    
    function Update-ConnectedDevices {
        $connectedNode.Nodes.Clear()
        
        $result = Get-ConnectedDevices
        
        if ($result.Success -and $result.Count -gt 0) {
            foreach ($device in $result.Devices) {
                $displayText = "✅ Puerto $($device.Port): $($device.Product)"
                $deviceNode = New-Object System.Windows.Forms.TreeNode($displayText)
                $deviceNode.Name = "connected_$($device.Port)"
                $deviceNode.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
                $deviceNode.Tag = @{
                    Type    = "connected"
                    Port    = $device.Port
                    Product = $device.Product
                    Remote  = $device.Remote
                }
                
                # Tooltip con info detallada
                $tooltipLines = @("Puerto USB/IP: $($device.Port)", "Producto: $($device.Product)")
                if ($device.Remote) {
                    $tooltipLines += "Servidor: $($device.Remote)"
                }
                $deviceNode.ToolTipText = $tooltipLines -join "`n"
                
                # Subnodo con info del servidor
                if ($device.Remote) {
                    $remoteNode = New-Object System.Windows.Forms.TreeNode("→ $($device.Remote)")
                    $remoteNode.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
                    $deviceNode.Nodes.Add($remoteNode)
                }
                
                $connectedNode.Nodes.Add($deviceNode)
            }
            $connectedNode.Expand()
            $connectedNode.Text = "✅ Dispositivos Conectados ($($result.Count))"
        }
        else {
            $connectedNode.Text = "✅ Dispositivos Conectados (0)"
        }
    }
    
    # FEATURE 3: Actualizar nodo de Favoritos
    function Update-FavoritesNode {
        $favoritesNode.Nodes.Clear()
        
        $favorites = Get-Favorites
        
        if ($favorites.Count -gt 0) {
            foreach ($fav in $favorites) {
                $displayText = "⭐ $($fav.BusId): $($fav.Description)"
                $favNode = New-Object System.Windows.Forms.TreeNode($displayText)
                $favNode.Name = "favorite_$($fav.ServerIP)_$($fav.BusId)"
                $favNode.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 100)
                $favNode.Tag = @{
                    Type        = "favorite"
                    ServerIP    = $fav.ServerIP
                    BusId       = $fav.BusId
                    Description = $fav.Description
                    AutoConnect = $fav.AutoConnect
                }
                
                # Tooltip con info detallada
                $autoConnectText = if ($fav.AutoConnect) { "Sí" } else { "No" }
                $favNode.ToolTipText = "Bus ID: $($fav.BusId)`nServidor: $($fav.ServerIP)`nAuto-conectar: $autoConnectText"
                
                # Subnodo con servidor
                $serverInfoNode = New-Object System.Windows.Forms.TreeNode("→ $($fav.ServerIP)")
                $serverInfoNode.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
                $favNode.Nodes.Add($serverInfoNode)
                
                $favoritesNode.Nodes.Add($favNode)
            }
            $favoritesNode.Expand()
            $favoritesNode.Text = "⭐ Favoritos ($($favorites.Count))"
        }
        else {
            $favoritesNode.Text = "⭐ Favoritos (0)"
        }
    }
    
    # ============================================
    # EVENTOS
    # ============================================
    
    # Cambiar idioma
    $langButton.Add_Click({
            # Toggle idioma basado en estado actual
            $newLang = if ($script:Language -eq "es") { "en" } else { "es" }
            $script:Language = $newLang
            
            # Actualizar botón de idioma
            $langButton.Text = if ($newLang -eq "es") { "🌐 ES" } else { "🌐 EN" }
            $updateButton.Text = if ($newLang -eq "es") { "⬆️ Actualizar" } else { "⬆️ Update" }
        
            # Guardar preferencia (Get-AppConfig sobrescribe $script:Language, lo restauramos)
            $config = Get-AppConfig
            $script:Language = $newLang  # Restaurar idioma después de Get-AppConfig
            $config.Language = $newLang
            Save-AppConfig -Config $config
        
            # Actualizar textos de UI que se pueden actualizar fácilmente
            $scanButton.Text = Get-Text "btn_scan"
            $refreshButton.Text = Get-Text "btn_refresh"
            $installDriversButton.Text = Get-Text "btn_install_drivers"
            $uninstallDriversButton.Text = Get-Text "btn_uninstall_drivers"
            $trayMenuScan.Text = Get-Text "tray_scan"
            $trayMenuShow.Text = Get-Text "tray_show"
            $trayMenuExit.Text = Get-Text "tray_exit"
            $menuConnect.Text = Get-Text "menu_connect"
            $menuDisconnect.Text = Get-Text "menu_disconnect"
            $menuAddFavorite.Text = Get-Text "menu_add_favorite"
            $menuRemoveFavorite.Text = Get-Text "menu_remove_favorite"
            
            # Labels y nodos de TreeView
            $ipLabel.Text = Get-Text "lbl_server"
            $hubsNode.Text = Get-Text "node_hubs"
            $connectedNode.Text = Get-Text "node_connected"
            $favoritesNode.Text = Get-Text "node_favorites"
            $sshButton.Text = Get-Text "btn_ssh"
            $vpnButton.Text = Get-Text "btn_vpn"
        
            $statusLabel.Text = Get-Text "status_ready"
        })
    
    # Buscar actualizaciones
    $updateButton.Add_Click({
            $statusLabel.Text = Get-Text "update_checking"
            $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(86, 156, 214)
            $form.Refresh()
        
            $result = Check-ForUpdates
        
            if ($result.Error) {
                $statusLabel.Text = "$(Get-Text 'update_error'): $($result.Error)"
                $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(244, 135, 113)
            }
            elseif ($result.UpdateAvailable) {
                $statusLabel.Text = "$(Get-Text 'update_available'): v$($result.LatestVersion)"
                $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
            
                # Preguntar si quiere actualizar
                $msgResult = [System.Windows.Forms.MessageBox]::Show(
                    "$(Get-Text 'update_available'): v$($result.LatestVersion)`n`n$(Get-Text 'update_download')?",
                    "SnakeUSBIP",
                    [System.Windows.Forms.MessageBoxButtons]::YesNo,
                    [System.Windows.Forms.MessageBoxIcon]::Information
                )
            
                if ($msgResult -eq [System.Windows.Forms.DialogResult]::Yes -and $result.DownloadUrl) {
                    $statusLabel.Text = Get-Text "update_downloading"
                    $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(86, 156, 214)
                    $form.Refresh()
                
                    $updateResult = Start-Update -DownloadUrl $result.DownloadUrl -InstallerName $result.InstallerName
                
                    if (-not $updateResult.Success) {
                        $statusLabel.Text = "$(Get-Text 'update_error'): $($updateResult.Error)"
                        $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(244, 135, 113)
                    }
                }
            }
            else {
                $statusLabel.Text = "$(Get-Text 'update_current') (v$($result.CurrentVersion))"
                $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
            }
        }.GetNewClosure())
    
    # Escanear red (SOLO red local, VPN se usa con botón aparte)
    $scanButton.Add_Click({
            $localIP = Get-LocalIPAddress
            if ($localIP) {
                $subnetBase = Get-SubnetBase -IPAddress $localIP
                if ($subnetBase) {
                    # Limpiar TreeView antes de escanear
                    Update-TreeView -ServerIP $null -ClearFirst $true
                    
                    # Callback: añadir cada servidor encontrado (sin limpiar)
                    $autoListCallback = {
                        param($ServerIP)
                        Update-TreeView -ServerIP $ServerIP -ClearFirst $false
                        Update-ConnectedDevices
                    }
                    Start-SubnetScan -SubnetBase $subnetBase -IPTextBox $ipTextBox -StatusLabel $statusLabel -ProgressBar $progressBar -OnServerFound $autoListCallback
                }
            }
            else {
                $statusLabel.Text = "Error: No se detectó red local"
                $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(244, 135, 113)
            }
        })
    
    # Tray menu: Escanear Red
    $trayMenuScan.Add_Click({
            # Mostrar ventana primero
            $form.Visible = $true
            $form.ShowInTaskbar = $true
            $form.WindowState = 'Normal'
            $notifyIcon.Visible = $false
            $form.Activate()
        
            # Ejecutar escaneo
            # Limpiar TreeView antes de escanear
            Update-TreeView -ServerIP $null -ClearFirst $true
            
            $localIP = Get-LocalIPAddress
            if ($localIP) {
                $subnetBase = Get-SubnetBase -IPAddress $localIP
                if ($subnetBase) {
                    $autoListCallback = {
                        param($ServerIP)
                        Update-TreeView -ServerIP $ServerIP -ClearFirst $false
                        Update-ConnectedDevices
                    }
                    Start-SubnetScan -SubnetBase $subnetBase -IPTextBox $ipTextBox -StatusLabel $statusLabel -ProgressBar $progressBar -OnServerFound $autoListCallback
                }
            }
        })
    

    # Listar dispositivos
    $refreshButton.Add_Click({
            $serverIP = $ipTextBox.Text.Trim()
            if ($serverIP) {
                Update-TreeView -ServerIP $serverIP
                Update-ConnectedDevices
            }
            else {
                $statusLabel.Text = "Introduce una IP de servidor"
                $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 100)
            }
        })
    
    # SSH - Conectar para instalar servidor USB/IP en Raspberry Pi
    $sshButton.Add_Click({
            $serverIP = $ipTextBox.Text.Trim()
        
            if (-not $serverIP) {
                $statusLabel.Text = "Introduce la IP del servidor para SSH"
                $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 100)
                return
            }
        
            # Crear formulario de diálogo para SSH
            $sshForm = New-Object System.Windows.Forms.Form
            $sshForm.Text = "SSH - Configurar Servidor USB/IP"
            $sshForm.Size = New-Object System.Drawing.Size(400, 320)
            $sshForm.StartPosition = "CenterParent"
            $sshForm.FormBorderStyle = "FixedDialog"
            $sshForm.MaximizeBox = $false
            $sshForm.MinimizeBox = $false
            $sshForm.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
            $sshForm.ForeColor = [System.Drawing.Color]::White
        
            # Label título
            $titleLabel = New-Object System.Windows.Forms.Label
            $titleLabel.Text = "🖥️ Conectar via SSH a Raspberry Pi"
            $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
            $titleLabel.Location = New-Object System.Drawing.Point(20, 15)
            $titleLabel.AutoSize = $true
            $sshForm.Controls.Add($titleLabel)
        
            # IP Label
            $ipLabelSsh = New-Object System.Windows.Forms.Label
            $ipLabelSsh.Text = "Servidor:"
            $ipLabelSsh.Location = New-Object System.Drawing.Point(20, 55)
            $ipLabelSsh.AutoSize = $true
            $sshForm.Controls.Add($ipLabelSsh)
        
            $ipValueLabel = New-Object System.Windows.Forms.Label
            $ipValueLabel.Text = $serverIP
            $ipValueLabel.Font = New-Object System.Drawing.Font("Consolas", 10)
            $ipValueLabel.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
            $ipValueLabel.Location = New-Object System.Drawing.Point(100, 55)
            $ipValueLabel.AutoSize = $true
            $sshForm.Controls.Add($ipValueLabel)
        
            # Usuario
            $userLabel = New-Object System.Windows.Forms.Label
            $userLabel.Text = "Usuario:"
            $userLabel.Location = New-Object System.Drawing.Point(20, 90)
            $userLabel.AutoSize = $true
            $sshForm.Controls.Add($userLabel)
        
            $userTextBox = New-Object System.Windows.Forms.TextBox
            $userTextBox.Text = "pi"
            $userTextBox.Size = New-Object System.Drawing.Size(150, 24)
            $userTextBox.Location = New-Object System.Drawing.Point(100, 87)
            $userTextBox.BackColor = [System.Drawing.Color]::FromArgb(51, 51, 55)
            $userTextBox.ForeColor = [System.Drawing.Color]::White
            $sshForm.Controls.Add($userTextBox)
        
            # Comandos info
            $cmdLabel = New-Object System.Windows.Forms.Label
            $cmdLabel.Text = "Comandos de instalación (Raspberry Pi):"
            $cmdLabel.Location = New-Object System.Drawing.Point(20, 130)
            $cmdLabel.AutoSize = $true
            $sshForm.Controls.Add($cmdLabel)
        
            $cmdTextBox = New-Object System.Windows.Forms.TextBox
            $cmdTextBox.Multiline = $true
            $cmdTextBox.ReadOnly = $true
            $cmdTextBox.Size = New-Object System.Drawing.Size(340, 80)
            $cmdTextBox.Location = New-Object System.Drawing.Point(20, 150)
            $cmdTextBox.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
            $cmdTextBox.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
            $cmdTextBox.Font = New-Object System.Drawing.Font("Consolas", 8)
            $cmdTextBox.Text = "sudo apt update && sudo apt install -y usbip`r`nsudo modprobe usbip_host`r`nsudo usbipd -D`r`nsudo usbip list -l`r`nsudo usbip bind -b <busid>"
            $sshForm.Controls.Add($cmdTextBox)
        
            # Botón Conectar SSH
            $connectSshBtn = New-Object System.Windows.Forms.Button
            $connectSshBtn.Text = "🔗 Abrir Terminal SSH"
            $connectSshBtn.Size = New-Object System.Drawing.Size(160, 32)
            $connectSshBtn.Location = New-Object System.Drawing.Point(20, 245)
            $connectSshBtn.FlatStyle = "Flat"
            $connectSshBtn.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204)
            $connectSshBtn.ForeColor = [System.Drawing.Color]::White
            $connectSshBtn.Add_Click({
                    $user = $userTextBox.Text.Trim()
                    if (-not $user) { $user = "pi" }
            
                    # Abrir terminal SSH
                    try {
                        Start-Process "ssh" -ArgumentList "$user@$serverIP"
                    }
                    catch {
                        # Fallback a cmd con ssh
                        Start-Process "cmd" -ArgumentList "/k ssh $user@$serverIP"
                    }
                    $sshForm.Close()
                })
            $sshForm.Controls.Add($connectSshBtn)
        
            # Botón Cancelar
            $cancelSshBtn = New-Object System.Windows.Forms.Button
            $cancelSshBtn.Text = "Cancelar"
            $cancelSshBtn.Size = New-Object System.Drawing.Size(100, 32)
            $cancelSshBtn.Location = New-Object System.Drawing.Point(260, 245)
            $cancelSshBtn.FlatStyle = "Flat"
            $cancelSshBtn.BackColor = [System.Drawing.Color]::FromArgb(62, 62, 66)
            $cancelSshBtn.ForeColor = [System.Drawing.Color]::White
            $cancelSshBtn.Add_Click({ $sshForm.Close() })
            $sshForm.Controls.Add($cancelSshBtn)
        
            [void]$sshForm.ShowDialog()
        })
    
    $ipTextBox.Add_KeyDown({
            param($sender, $e)
            if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
                $serverIP = $ipTextBox.Text.Trim()
                if ($serverIP) {
                    Update-TreeView -ServerIP $serverIP
                    Update-ConnectedDevices
                }
                $e.Handled = $true
                $e.SuppressKeyPress = $true
            }
        })
    
    # Menu contextual - mostrar/ocultar opciones segun el nodo
    $contextMenu.Add_Opening({
            param($s, $e)
            $selectedNode = $treeView.SelectedNode
        
            if (-not $selectedNode -or -not $selectedNode.Tag) {
                $e.Cancel = $true
                return
            }
        
            $nodeType = $selectedNode.Tag.Type
        
            # Opciones de conexión
            $menuConnect.Visible = ($nodeType -eq "remote" -or $nodeType -eq "favorite")
            $menuDisconnect.Visible = ($nodeType -eq "connected")
        
            # Opciones de favoritos
            if ($nodeType -eq "remote") {
                $isFav = Test-IsFavorite -ServerIP $selectedNode.Tag.ServerIP -BusId $selectedNode.Tag.BusId
                $menuAddFavorite.Visible = (-not $isFav)
                $menuRemoveFavorite.Visible = $isFav
            }
            elseif ($nodeType -eq "favorite") {
                $menuAddFavorite.Visible = $false
                $menuRemoveFavorite.Visible = $true
            }
            else {
                $menuAddFavorite.Visible = $false
                $menuRemoveFavorite.Visible = $false
            }
        
            # Propiedades
            $menuProperties.Visible = ($nodeType -eq "remote" -or $nodeType -eq "connected" -or $nodeType -eq "favorite")
            $menuSeparator1.Visible = $menuAddFavorite.Visible -or $menuRemoveFavorite.Visible
            $menuSeparator2.Visible = $menuProperties.Visible
        })
    
    # Click derecho selecciona nodo
    $treeView.Add_NodeMouseClick({
            param($sender, $e)
            if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Right) {
                $treeView.SelectedNode = $e.Node
            }
        })
    
    # Doble click para conectar/desconectar
    $treeView.Add_NodeMouseDoubleClick({
            param($sender, $e)
            $selectedNode = $e.Node
            if (-not $selectedNode -or -not $selectedNode.Tag) { return }
            
            $nodeType = $selectedNode.Tag.Type
            
            # Conectar dispositivo remoto o favorito
            if ($nodeType -eq "remote" -or $nodeType -eq "favorite") {
                $serverIP = $selectedNode.Tag.ServerIP
                $busId = $selectedNode.Tag.BusId
            
                $statusLabel.Text = "Conectando $busId desde $serverIP..."
                $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(86, 156, 214)
                $form.Refresh()
            
                $result = Connect-UsbipDevice -ServerIP $serverIP -BusId $busId
            
                if ($result.Success) {
                    $statusLabel.Text = "✓ Conectado: $busId"
                    $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
                    Add-LogEntry -Type "Success" -Message "$(Get-Text 'log_connected'): $busId @ $serverIP"
                    Show-Notification -Title (Get-Text 'notify_connected') -Message "$busId @ $serverIP" -Type "Success"
                    Update-ConnectedDevices
                }
                else {
                    $statusLabel.Text = "Error: $($result.Error)"
                    $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(244, 135, 113)
                    Add-LogEntry -Type "Error" -Message "$(Get-Text 'log_error'): $busId - $($result.Error)"
                }
            }
            # Desconectar dispositivo conectado
            elseif ($nodeType -eq "connected") {
                $port = $selectedNode.Tag.Port
                
                $statusLabel.Text = "Desconectando puerto $port..."
                $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(86, 156, 214)
                $form.Refresh()
                
                $result = Disconnect-UsbipDevice -Port $port
                
                if ($result.Success) {
                    $statusLabel.Text = "✓ Desconectado puerto $port"
                    $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
                    Add-LogEntry -Type "Success" -Message "$(Get-Text 'log_disconnected'): Port $port"
                    Show-Notification -Title (Get-Text 'notify_disconnected') -Message "Port $port" -Type "Info"
                    Update-ConnectedDevices
                }
                else {
                    $statusLabel.Text = "Error: $($result.Error)"
                    $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(244, 135, 113)
                    Add-LogEntry -Type "Error" -Message "$(Get-Text 'log_error'): Port $port - $($result.Error)"
                }
            }
        })
    
    # Menu: Conectar
    $menuConnect.Add_Click({
            $selectedNode = $treeView.SelectedNode
            if ($selectedNode -and $selectedNode.Tag) {
                $nodeType = $selectedNode.Tag.Type
            
                if ($nodeType -eq "remote" -or $nodeType -eq "favorite") {
                    $serverIP = $selectedNode.Tag.ServerIP
                    $busId = $selectedNode.Tag.BusId
                
                    $statusLabel.Text = "Conectando $busId desde $serverIP..."
                    $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(86, 156, 214)
                    $form.Refresh()
                
                    $result = Connect-UsbipDevice -ServerIP $serverIP -BusId $busId
                
                    if ($result.Success) {
                        $statusLabel.Text = "✓ Conectado: $busId"
                        $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
                        Add-LogEntry -Type "Success" -Message "$(Get-Text 'log_connected'): $busId @ $serverIP"
                        Show-Notification -Title (Get-Text 'notify_connected') -Message "$busId @ $serverIP" -Type "Success"
                        Update-ConnectedDevices
                    }
                    else {
                        $statusLabel.Text = "Error: $($result.Error)"
                        $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(244, 135, 113)
                        Add-LogEntry -Type "Error" -Message "$(Get-Text 'log_error'): $busId - $($result.Error)"
                    }
                }
            }
        })
    
    # Menu: Desconectar
    $menuDisconnect.Add_Click({
            $selectedNode = $treeView.SelectedNode
            if ($selectedNode -and $selectedNode.Tag -and $selectedNode.Tag.Type -eq "connected") {
                $port = $selectedNode.Tag.Port
            
                $statusLabel.Text = "Desconectando puerto $port..."
                $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(86, 156, 214)
                $form.Refresh()
            
                $result = Disconnect-UsbipDevice -Port $port
            
                if ($result.Success) {
                    $statusLabel.Text = "✓ Desconectado puerto $port"
                    $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
                    Add-LogEntry -Type "Success" -Message "$(Get-Text 'log_disconnected'): Port $port"
                    Show-Notification -Title (Get-Text 'notify_disconnected') -Message "Port $port" -Type "Info"
                    Update-ConnectedDevices
                }
                else {
                    $statusLabel.Text = "Error: $($result.Error)"
                    $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(244, 135, 113)
                    Add-LogEntry -Type "Error" -Message "$(Get-Text 'log_error'): Port $port - $($result.Error)"
                }
            }
        })
    
    # Menu: Propiedades
    $menuProperties.Add_Click({
            $selectedNode = $treeView.SelectedNode
            if ($selectedNode -and $selectedNode.Tag) {
                $tag = $selectedNode.Tag
                $info = ""
            
                if ($tag.Type -eq "remote") {
                    $info = "Dispositivo Remoto`n"
                    $info += "───────────────────`n"
                    $info += "Bus ID: $($tag.BusId)`n"
                    $info += "Servidor: $($tag.ServerIP)`n"
                    $info += "Descripcion: $($tag.Description)`n"
                    if ($tag.VID -and $tag.PID) {
                        $info += "VID:PID: $($tag.VID):$($tag.PID)`n"
                    }
                    if ($tag.VendorName -and $tag.VendorName -ne "Desconocido") {
                        $info += "Fabricante: $($tag.VendorName)`n"
                    }
                    if ($tag.ProductName -and $tag.ProductName -ne "Desconocido") {
                        $info += "Producto: $($tag.ProductName)"
                    }
                }
                elseif ($tag.Type -eq "connected") {
                    $info = "Dispositivo Conectado`n"
                    $info += "───────────────────`n"
                    $info += "Puerto: $($tag.Port)`n"
                    $info += "Producto: $($tag.Product)`n"
                    $info += "Remoto: $($tag.Remote)"
                }
                elseif ($tag.Type -eq "favorite") {
                    $info = "Dispositivo Favorito`n"
                    $info += "───────────────────`n"
                    $info += "Bus ID: $($tag.BusId)`n"
                    $info += "Servidor: $($tag.ServerIP)`n"
                    $info += "Descripcion: $($tag.Description)`n"
                    $info += "Auto-conectar: $(if ($tag.AutoConnect) { 'Sí' } else { 'No' })"
                }
            
                [System.Windows.Forms.MessageBox]::Show($info, "Propiedades", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            }
        })
    
    # FEATURE 3: Menu: Añadir a Favoritos
    $menuAddFavorite.Add_Click({
            $selectedNode = $treeView.SelectedNode
            if ($selectedNode -and $selectedNode.Tag -and $selectedNode.Tag.Type -eq "remote") {
                $tag = $selectedNode.Tag
            
                $result = Add-Favorite -ServerIP $tag.ServerIP -BusId $tag.BusId -Description $tag.Description -AutoConnect $true
            
                if ($result.Success) {
                    $statusLabel.Text = "⭐ $($result.Message): $($tag.BusId)"
                    $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 100)
                    Add-LogEntry -Type "Info" -Message "$(Get-Text 'log_favorite_added'): $($tag.BusId)"
                    Update-FavoritesNode
                }
                else {
                    $statusLabel.Text = "$($result.Message)"
                    $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(244, 135, 113)
                }
            }
        })
    
    # FEATURE 3: Menu: Quitar de Favoritos
    $menuRemoveFavorite.Add_Click({
            $selectedNode = $treeView.SelectedNode
            if ($selectedNode -and $selectedNode.Tag) {
                $tag = $selectedNode.Tag
                $serverIP = $tag.ServerIP
                $busId = $tag.BusId
            
                if ($tag.Type -eq "remote" -or $tag.Type -eq "favorite") {
                    $result = Remove-Favorite -ServerIP $serverIP -BusId $busId
                
                    if ($result.Success) {
                        $statusLabel.Text = "✓ $($result.Message): $busId"
                        $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
                        Add-LogEntry -Type "Info" -Message "$(Get-Text 'log_favorite_removed'): $busId"
                        Update-FavoritesNode
                    }
                    else {
                        $statusLabel.Text = "$($result.Message)"
                        $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(244, 135, 113)
                    }
                }
            }
        })
    
    # Eventos de Drivers
    $installDriversButton.Add_Click({
            $statusLabel.Text = "Instalando drivers..."
            $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(86, 156, 214)
            $form.Refresh()
        
            $result = Install-UsbipDrivers
        
            if ($result.Success) {
                $statusLabel.Text = "✓ $($result.Message)"
                $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
                $driverLabel.Text = "Drivers: Instalado ✓"
                $driverLabel.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
            }
            else {
                $statusLabel.Text = "Error: $($result.Error)"
                $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(244, 135, 113)
            }
        })
    
    $uninstallDriversButton.Add_Click({
            $confirmResult = [System.Windows.Forms.MessageBox]::Show(
                "¿Desinstalar drivers USB/IP?",
                "Confirmar",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
        
            if ($confirmResult -ne [System.Windows.Forms.DialogResult]::Yes) { return }
        
            $statusLabel.Text = "Desinstalando drivers..."
            $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(86, 156, 214)
            $form.Refresh()
        
            $result = Uninstall-UsbipDrivers
        
            if ($result.Success) {
                $statusLabel.Text = "✓ $($result.Message)"
                $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
                $driverLabel.Text = "Drivers: No instalado"
                $driverLabel.ForeColor = [System.Drawing.Color]::Gray
            }
            else {
                $statusLabel.Text = "Error: $($result.Message)"
                $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(244, 135, 113)
            }
        })
    
    # Inicio
    $form.Add_Shown({
            # Verificar drivers
            $driverCheck = Test-DriversInstalled
            if ($driverCheck.Installed) {
                $driverLabel.Text = "Drivers: Instalado ✓"
                $driverLabel.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
                Add-LogEntry -Type "Success" -Message "$(Get-Text 'log_drivers_ok')"
            }
            else {
                $driverLabel.Text = "Drivers: No instalado"
                $driverLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 100)
                Add-LogEntry -Type "Warning" -Message "$(Get-Text 'log_drivers_missing')"
            }
        
            # Verificar usbip
            $usbipPath = Find-UsbipExecutable
            if (-not $usbipPath) {
                $statusLabel.Text = "⚠ No se encontro usbip.exe"
                $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 100)
                return
            }
        
            # FEATURE 3: Cargar favoritos
            Update-FavoritesNode
        
            # FEATURE 3: Reconexión automática de favoritos
            $config = Get-AppConfig
            if ($config.AutoConnectOnStart) {
                $favorites = Get-Favorites
                $autoConnectFavs = @($favorites | Where-Object { $_.AutoConnect -eq $true })
            
                if ($autoConnectFavs.Count -gt 0) {
                    $statusLabel.Text = "Reconectando $($autoConnectFavs.Count) favorito(s)..."
                    $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 100)
                    $form.Refresh()
                
                    $successCount = 0
                    foreach ($fav in $autoConnectFavs) {
                        $result = Connect-UsbipDevice -ServerIP $fav.ServerIP -BusId $fav.BusId
                        if ($result.Success) { $successCount++ }
                    }
                
                    if ($successCount -gt 0) {
                        $statusLabel.Text = "✓ Reconectados $successCount/$($autoConnectFavs.Count) favoritos"
                        $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(78, 201, 176)
                        Add-LogEntry -Type "Success" -Message "$(Get-Text 'auto_reconnect'): $successCount/$($autoConnectFavs.Count)"
                        Show-Notification -Title (Get-Text 'notify_reconnected') -Message "$successCount $(Get-Text 'node_favorites')" -Type "Success"
                    }
                    else {
                        $statusLabel.Text = "Listo. Escaneando red..."
                        $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
                    }
                }
                else {
                    $statusLabel.Text = "Listo. Escaneando red..."
                    $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
                }
            }
            else {
                $statusLabel.Text = "Listo. Escaneando red..."
                $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
            }
        
            Update-ConnectedDevices
        
            # Auto-escanear red (con selector si hay múltiples subredes)
            $allSubnets = @(Get-AllLocalSubnets)  # Forzar a array
            
            Add-LogEntry -Type "Info" -Message "$(Get-Text 'subnet_detected'): $($allSubnets.Count)"
            
            if ($allSubnets.Count -gt 0) {
                $selectedSubnet = $null
                
                if ($allSubnets.Count -eq 1) {
                    # Solo una subred, usarla directamente
                    $selectedSubnet = $allSubnets[0].Subnet
                    Add-LogEntry -Type "Info" -Message "$(Get-Text 'subnet_auto_selected'): $selectedSubnet"
                }
                else {
                    # Múltiples subredes, mostrar selector
                    $subnetForm = New-Object System.Windows.Forms.Form
                    $subnetForm.Text = Get-Text 'subnet_select_title'
                    $subnetForm.Size = New-Object System.Drawing.Size(350, 200)
                    $subnetForm.StartPosition = "CenterScreen"
                    $subnetForm.FormBorderStyle = "FixedDialog"
                    $subnetForm.MaximizeBox = $false
                    $subnetForm.MinimizeBox = $false
                    $subnetForm.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
                    $subnetForm.ForeColor = [System.Drawing.Color]::White
                    
                    $lblInfo = New-Object System.Windows.Forms.Label
                    $lblInfo.Text = Get-Text 'subnet_multiple_found'
                    $lblInfo.Location = New-Object System.Drawing.Point(15, 15)
                    $lblInfo.AutoSize = $true
                    $subnetForm.Controls.Add($lblInfo)
                    
                    $listBox = New-Object System.Windows.Forms.ListBox
                    $listBox.Size = New-Object System.Drawing.Size(310, 80)
                    $listBox.Location = New-Object System.Drawing.Point(15, 45)
                    $listBox.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
                    $listBox.ForeColor = [System.Drawing.Color]::White
                    $listBox.Font = New-Object System.Drawing.Font("Consolas", 10)
                    
                    foreach ($net in $allSubnets) {
                        [void]$listBox.Items.Add("$($net.Subnet).0/24  [$($net.Name)]")
                    }
                    $listBox.SelectedIndex = 0
                    $subnetForm.Controls.Add($listBox)
                    
                    $btnOK = New-Object System.Windows.Forms.Button
                    $btnOK.Text = "OK"
                    $btnOK.Size = New-Object System.Drawing.Size(80, 28)
                    $btnOK.Location = New-Object System.Drawing.Point(245, 130)
                    $btnOK.FlatStyle = "Flat"
                    $btnOK.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204)
                    $btnOK.ForeColor = [System.Drawing.Color]::White
                    $btnOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
                    $subnetForm.Controls.Add($btnOK)
                    $subnetForm.AcceptButton = $btnOK
                    
                    $result = $subnetForm.ShowDialog()
                    $selectedIndex = $listBox.SelectedIndex
                    $subnetForm.Dispose()
                    
                    if ($result -eq [System.Windows.Forms.DialogResult]::OK -and $selectedIndex -ge 0) {
                        $selectedSubnet = $allSubnets[$selectedIndex].Subnet
                    }
                    else {
                        $selectedSubnet = $allSubnets[0].Subnet
                    }
                    Add-LogEntry -Type "Info" -Message "$(Get-Text 'subnet_selected'): $selectedSubnet"
                }
                
                if ($selectedSubnet) {
                    # Limpiar TreeView antes de escanear
                    Update-TreeView -ServerIP $null -ClearFirst $true
                    
                    # Callback: añadir cada servidor encontrado (sin limpiar)
                    $autoListCallback = {
                        param($ServerIP)
                        Update-TreeView -ServerIP $ServerIP -ClearFirst $false
                        Update-ConnectedDevices
                    }
                    Add-LogEntry -Type "Info" -Message "$(Get-Text 'subnet_scanning'): $selectedSubnet.0/24"
                    Start-SubnetScan -SubnetBase $selectedSubnet -IPTextBox $ipTextBox -StatusLabel $statusLabel -ProgressBar $progressBar -OnServerFound $autoListCallback
                }
                else {
                    Add-LogEntry -Type "Warning" -Message (Get-Text 'subnet_not_selected')
                }
            }
            else {
                Add-LogEntry -Type "Warning" -Message (Get-Text 'subnet_none_found')
            }
        })
    
    # Usar Application.Run en lugar de ShowDialog para que el app siga viva cuando el form está oculto
    [System.Windows.Forms.Application]::Run($form)
}

# ============================================
# PUNTO DE ENTRADA
# ============================================
Show-MainWindow
