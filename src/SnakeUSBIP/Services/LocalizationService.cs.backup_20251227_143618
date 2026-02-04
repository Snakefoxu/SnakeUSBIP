namespace SnakeUSBIP.Services;

/// <summary>
/// Localization service - Translation dictionaries ES/EN
/// Port from PowerShell $Translations
/// </summary>
public class LocalizationService
{
    private readonly Dictionary<string, Dictionary<string, string>> _translations;
    
    public LocalizationService()
    {
        _translations = new Dictionary<string, Dictionary<string, string>>
        {
            ["es"] = new Dictionary<string, string>
            {
                // Buttons
                ["btn_scan"] = "🔍 Escanear",
                ["btn_refresh"] = "📋 Listar",
                ["btn_ssh"] = "🔗 SSH",
                ["btn_vpn"] = "● VPN",
                ["btn_update"] = "⬆️ Actualizar",
                ["btn_install_drivers"] = "Instalar",
                ["btn_uninstall_drivers"] = "Desinstalar",
                
                // Labels
                ["lbl_server"] = "Servidor:",
                
                // TreeView nodes
                ["node_hubs"] = "🖥️ USB Hubs",
                ["node_connected"] = "☑️ Dispositivos Conectados",
                ["node_favorites"] = "⭐ Favoritos",
                
                // Status
                ["status_ready"] = "✓ Listo",
                ["status_scanning"] = "Escaneando...",
                ["status_listing"] = "Listando dispositivos en",
                ["status_connecting"] = "Conectando",
                ["status_disconnecting"] = "Desconectando",
                ["status_servers_found"] = "servidor(es) encontrado(s)",
                ["status_devices_found"] = "dispositivo(s)",
                ["status_no_server"] = "No se encontró servidor en la subred",
                ["status_error"] = "Error",
                
                // Log
                ["log_title"] = "📋 Log de Actividad",
                ["log_clear"] = "Limpiar",
                ["log_connected"] = "Conectado",
                ["log_disconnected"] = "Desconectado",
                ["log_scan_start"] = "Escaneando red...",
                ["log_scan_found"] = "servidor(es) encontrado(s)",
                ["log_scan_none"] = "Ningún servidor encontrado",
                ["log_error"] = "Error",
                ["log_app_start"] = "Aplicación iniciada",
                
                // Context menu
                ["menu_connect"] = "▶️ Conectar",
                ["menu_disconnect"] = "⏹️ Desconectar",
                ["menu_add_favorite"] = "⭐ Añadir a Favoritos",
                ["menu_remove_favorite"] = "❌ Quitar de Favoritos",
                
                // Update
                ["update_checking"] = "Buscando actualizaciones...",
                ["update_available"] = "Nueva versión disponible",
                ["update_current"] = "Tienes la última versión",
                ["update_download"] = "Descargar e instalar",
                ["update_error"] = "Error al buscar actualizaciones",
                
                // Dialogs
                ["enter_ip"] = "Introduce una IP de servidor",
                ["enter_ip_ssh"] = "Introduce la IP del servidor para SSH",
                
                // SSH Dialog
                ["ssh_title"] = "SSH - Configurar Servidor USB/IP",
                ["ssh_instructions"] = "📋 Instrucciones para Linux/Raspberry Pi:",
                ["ssh_step1"] = "1. Instalar paquetes:",
                ["ssh_step2"] = "2. Cargar módulo del kernel:",
                ["ssh_step3"] = "3. Iniciar servicio:",
                ["ssh_step4"] = "4. Ver dispositivos USB disponibles:",
                ["ssh_step5"] = "5. Exportar dispositivo (ej: 1-1.4):",
                ["ssh_step6"] = "6. Auto-inicio (agregar a /etc/rc.local):",
                ["ssh_user"] = "Usuario:",
                ["ssh_connect"] = "🔗 Conectar",
                ["ssh_copy"] = "📋 Copiar comandos",
                ["ssh_close"] = "Cerrar",
                
                // VPN Dialog
                ["vpn_title"] = "VPN / Red Remota",
                ["vpn_status"] = "Estado de la red:",
                ["vpn_online"] = "Online",
                ["vpn_offline"] = "Offline",
                ["vpn_peers"] = "Peers en la red:",
                ["vpn_no_peers"] = "No hay peers online",
                ["vpn_add_all"] = "Añadir Todos",
                ["vpn_connect"] = "Conectar",
                ["vpn_info"] = "ℹ️ Conecta con otros usuarios via Tailscale o ZeroTier",
            },
            
            ["en"] = new Dictionary<string, string>
            {
                // Buttons
                ["btn_scan"] = "🔍 Scan",
                ["btn_refresh"] = "📋 List",
                ["btn_ssh"] = "🔗 SSH",
                ["btn_vpn"] = "● VPN",
                ["btn_update"] = "⬆️ Update",
                ["btn_install_drivers"] = "Install",
                ["btn_uninstall_drivers"] = "Uninstall",
                
                // Labels
                ["lbl_server"] = "Server:",
                
                // TreeView nodes
                ["node_hubs"] = "🖥️ USB Hubs",
                ["node_connected"] = "☑️ Connected Devices",
                ["node_favorites"] = "⭐ Favorites",
                
                // Status
                ["status_ready"] = "✓ Ready",
                ["status_scanning"] = "Scanning...",
                ["status_listing"] = "Listing devices on",
                ["status_connecting"] = "Connecting",
                ["status_disconnecting"] = "Disconnecting",
                ["status_servers_found"] = "server(s) found",
                ["status_devices_found"] = "device(s)",
                ["status_no_server"] = "No server found in subnet",
                ["status_error"] = "Error",
                
                // Log
                ["log_title"] = "📋 Activity Log",
                ["log_clear"] = "Clear",
                ["log_connected"] = "Connected",
                ["log_disconnected"] = "Disconnected",
                ["log_scan_start"] = "Scanning network...",
                ["log_scan_found"] = "server(s) found",
                ["log_scan_none"] = "No servers found",
                ["log_error"] = "Error",
                ["log_app_start"] = "Application started",
                
                // Context menu
                ["menu_connect"] = "▶️ Connect",
                ["menu_disconnect"] = "⏹️ Disconnect",
                ["menu_add_favorite"] = "⭐ Add to Favorites",
                ["menu_remove_favorite"] = "❌ Remove from Favorites",
                
                // Update
                ["update_checking"] = "Checking for updates...",
                ["update_available"] = "New version available",
                ["update_current"] = "You have the latest version",
                ["update_download"] = "Download and install",
                ["update_error"] = "Error checking for updates",
                
                // Dialogs
                ["enter_ip"] = "Enter a server IP",
                ["enter_ip_ssh"] = "Enter the server IP for SSH",
                
                // SSH Dialog
                ["ssh_title"] = "SSH - Configure USB/IP Server",
                ["ssh_instructions"] = "📋 Instructions for Linux/Raspberry Pi:",
                ["ssh_step1"] = "1. Install packages:",
                ["ssh_step2"] = "2. Load kernel module:",
                ["ssh_step3"] = "3. Start service:",
                ["ssh_step4"] = "4. List available USB devices:",
                ["ssh_step5"] = "5. Export device (e.g.: 1-1.4):",
                ["ssh_step6"] = "6. Auto-start (add to /etc/rc.local):",
                ["ssh_user"] = "User:",
                ["ssh_connect"] = "🔗 Connect",
                ["ssh_copy"] = "📋 Copy commands",
                ["ssh_close"] = "Close",
                
                // VPN Dialog
                ["vpn_title"] = "VPN / Remote Network",
                ["vpn_status"] = "Network status:",
                ["vpn_online"] = "Online",
                ["vpn_offline"] = "Offline",
                ["vpn_peers"] = "Peers on network:",
                ["vpn_no_peers"] = "No peers online",
                ["vpn_add_all"] = "Add All",
                ["vpn_connect"] = "Connect",
                ["vpn_info"] = "ℹ️ Connect with other users via Tailscale or ZeroTier",
            }
        };
    }
    
    public string GetText(string key, string language = "es")
    {
        if (_translations.TryGetValue(language, out var dict))
        {
            if (dict.TryGetValue(key, out var text))
                return text;
        }
        return key; // Return key if not found
    }
}
