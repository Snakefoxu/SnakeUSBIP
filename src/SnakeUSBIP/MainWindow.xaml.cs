// ═══════════════════════════════════════════════════════════════════════════════
// SnakeUSBIP - USB/IP Client for Windows
// Copyright (c) 2025 SnakeFoxu - https://github.com/SnakeFoxu/SnakeUSBIP
// Licensed under GPL v3 - See LICENSE file
// ═══════════════════════════════════════════════════════════════════════════════

using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Net.NetworkInformation;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using SnakeUSBIP.Services;
using Forms = System.Windows.Forms;

namespace SnakeUSBIP;

/// <summary>
/// MainWindow - USB/IP Manager
/// Created by SnakeFoxu - github.com/SnakeFoxu
/// </summary>
public partial class MainWindow : Window
{
    // Services
    private readonly LocalizationService _localization;
    private readonly ConfigService _config;
    private readonly NetworkScanner _networkScanner;
    private readonly UsbipService _usbip;
    private readonly DriverService _drivers;
    private readonly FavoritesService _favorites;
    private readonly UpdateService _updates;
    private readonly VpnService _vpn;
    private readonly UsbIdsService _usbIds;
    private readonly ConnectionMonitorService _connectionMonitor;
    
    // TrayIcon
    private Forms.NotifyIcon? _trayIcon;
    
    // State
    private string _currentLanguage = "es";
    private string _currentTheme = "dark";
    private readonly List<string> _logEntries = new();
    private List<string> _availableSubnets = new();
    
    public MainWindow()
    {
        InitializeComponent();
        
        // Initialize services
        _localization = new LocalizationService();
        _config = new ConfigService();
        _networkScanner = new NetworkScanner();
        _usbip = new UsbipService();
        _drivers = new DriverService();
        _favorites = new FavoritesService(_config, _usbip);
        _updates = new UpdateService();
        _vpn = new VpnService();
        _usbIds = new UsbIdsService();
        _connectionMonitor = new ConnectionMonitorService(_usbip, _favorites);
        
        // Subscribe to connection events
        _connectionMonitor.ConnectionLost += OnConnectionLost;
        _connectionMonitor.ConnectionRestored += OnConnectionRestored;
        
        // Load config and apply language + theme
        LoadConfiguration();
        ApplyTheme(_currentTheme);
        UpdateUITexts();
        
        // Check driver status
        CheckDriverStatus();
        
        // Initialize system tray icon
        InitializeTrayIcon();
        
        // Register TreeView double-click event for connect/disconnect
        treeDevices.MouseDoubleClick += TreeDevices_MouseDoubleClick;
        
        // Log startup
        AddLog("Info", _localization.GetText("log_app_start", _currentLanguage));
        
        // Load favorites on startup
        LoadFavorites();
        
        // Auto-scan network on startup (like PowerShell)
        Loaded += async (s, e) => await AutoScanOnStartup();
    }
    
    /// <summary>
    /// Initialize system tray icon with context menu (like PowerShell)
    /// </summary>
    private void InitializeTrayIcon()
    {
        try
        {
            // Create tray icon
            _trayIcon = new Forms.NotifyIcon
            {
                Text = "SnakeUSBIP - USB/IP Manager",
                Visible = true
            };
            
            // Load icon from resources - use 32x32 for tray visibility
            var iconPath = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Assets", "icon.ico");
            if (System.IO.File.Exists(iconPath))
            {
                // Load icon with specific size for better tray visibility
                using var iconStream = new System.IO.FileStream(iconPath, System.IO.FileMode.Open, System.IO.FileAccess.Read);
                _trayIcon.Icon = new Icon(iconStream, new System.Drawing.Size(32, 32));
            }
            else
            {
                // Fallback: use system icon
                _trayIcon.Icon = System.Drawing.SystemIcons.Application;
            }
            
            // Create context menu
            var trayMenu = new Forms.ContextMenuStrip();
            
            var scanItem = new Forms.ToolStripMenuItem(_localization.GetText("tray_scan", _currentLanguage));
            scanItem.Click += (s, e) => Dispatcher.Invoke(() => BtnScan_Click(this, new RoutedEventArgs()));
            trayMenu.Items.Add(scanItem);
            
            trayMenu.Items.Add(new Forms.ToolStripSeparator());
            
            var showItem = new Forms.ToolStripMenuItem(_localization.GetText("tray_show", _currentLanguage));
            showItem.Click += (s, e) => Dispatcher.Invoke(() => ShowWindow());
            trayMenu.Items.Add(showItem);
            
            trayMenu.Items.Add(new Forms.ToolStripSeparator());
            
            var exitItem = new Forms.ToolStripMenuItem(_localization.GetText("tray_exit", _currentLanguage));
            exitItem.Click += (s, e) => Dispatcher.Invoke(() => System.Windows.Application.Current.Shutdown());
            trayMenu.Items.Add(exitItem);
            
            _trayIcon.ContextMenuStrip = trayMenu;
            
            // Double-click to show window
            _trayIcon.DoubleClick += (s, e) => Dispatcher.Invoke(() => ShowWindow());
        }
        catch (Exception ex)
        {
            AddLog("Warning", string.Format(_localization.GetText("log_tray_init_error", _currentLanguage), ex.Message));
        }
    }
    
    /// <summary>
    /// Show the main window from tray
    /// </summary>
    private void ShowWindow()
    {
        Show();
        WindowState = WindowState.Normal;
        Activate();
        
        // Fix: If list is empty upon restore, trigger a scan/list
        if (nodeHubs.Items.Count == 0)
        {
            if (!string.IsNullOrEmpty(txtServerIP.Text))
            {
                Dispatcher.InvokeAsync(() => BtnList_Click(this, new RoutedEventArgs()));
            }
            else
            {
                Dispatcher.InvokeAsync(() => BtnScan_Click(this, new RoutedEventArgs()));
            }
        }
    }
    
    /// <summary>
    /// Override minimize to minimize to tray instead
    /// </summary>
    protected override void OnStateChanged(EventArgs e)
    {
        if (WindowState == WindowState.Minimized)
        {
            Hide();
            ShowNotification(_localization.GetText("title_main", _currentLanguage), 
                           _localization.GetText("tray_minimized", _currentLanguage), 
                           Forms.ToolTipIcon.Info);
        }
        base.OnStateChanged(e);
    }
    
    /// <summary>
    /// Show notification - uses WPF popup when visible, BalloonTip when minimized to tray
    /// </summary>
    private void ShowNotification(string title, string message, Forms.ToolTipIcon icon = Forms.ToolTipIcon.Info)
    {
        // If window is not visible (minimized to tray), use BalloonTip
        if (WindowState == WindowState.Minimized || !IsVisible)
        {
            _trayIcon?.ShowBalloonTip(2000, title, message, icon);
            return;
        }
        
        // Otherwise use custom WPF popup (no Action Center)
        toastTitle.Text = icon switch
        {
            Forms.ToolTipIcon.Error => $"❌ {title}",
            Forms.ToolTipIcon.Warning => $"⚠️ {title}",
            _ => $"✅ {title}"
        };
        toastMessage.Text = message;
        
        // Show popup with fade-in
        toastPopup.Visibility = Visibility.Visible;
        var fadeIn = new System.Windows.Media.Animation.DoubleAnimation(0, 1, TimeSpan.FromMilliseconds(150));
        toastPopup.BeginAnimation(OpacityProperty, fadeIn);
        
        // Auto-hide after 1.5 seconds
        var timer = new System.Timers.Timer(1500) { AutoReset = false };
        timer.Elapsed += (s, e) =>
        {
            Dispatcher.Invoke(() =>
            {
                var fadeOut = new System.Windows.Media.Animation.DoubleAnimation(1, 0, TimeSpan.FromMilliseconds(200));
                fadeOut.Completed += (s2, e2) => toastPopup.Visibility = Visibility.Collapsed;
                toastPopup.BeginAnimation(OpacityProperty, fadeOut);
            });
            timer.Dispose();
        };
        timer.Start();
    }
    
    /// <summary>
    /// Load favorites from config on startup
    /// </summary>
    private void LoadFavorites()
    {
        var favorites = _favorites.GetFavorites();
        nodeFavorites.Items.Clear();
        foreach (var fav in favorites)
        {
            var favNode = new TreeViewItem 
            { 
                Header = $"⭐ {fav.Description} ({fav.ServerIP}/{fav.BusId})",
                Tag = fav
            };
            nodeFavorites.Items.Add(favNode);
        }
        nodeFavorites.Header = $"⭐ {_localization.GetText("node_favorites", _currentLanguage).Replace("⭐ ", "")} ({favorites.Count})";
    }
    
    /// <summary>
    /// Auto-scan network on startup like PowerShell version
    /// </summary>
    private async Task AutoScanOnStartup()
    {
        AddLog("Info", _localization.GetText("log_scan_start", _currentLanguage));
        lblStatus.Text = _localization.GetText("status_scanning", _currentLanguage);
        lblStatus.Foreground = (SolidColorBrush)FindResource("StatusInfo");
        
        try
        {
            var subnet = GetLocalSubnet();
            AddLog("Info", string.Format(_localization.GetText("log_scanning_subnet", _currentLanguage), subnet));
            
            var servers = await _networkScanner.ScanNetworkAsync(subnet);
            
            // Debug: Log all found servers
            AddLog("Info", string.Format(_localization.GetText("log_scan_complete", _currentLanguage), servers.Count));
            foreach (var srv in servers)
            {
                AddLog("Info", string.Format(_localization.GetText("log_server_found", _currentLanguage), srv));
            }
            
            if (servers.Count > 0)
            {
                // Found servers - CLEAR and add ALL to tree
                nodeHubs.Items.Clear();
                foreach (var server in servers)
                {
                    var serverNode = new TreeViewItem { Header = $"🖥️ {server}" };
                    nodeHubs.Items.Add(serverNode);
                }
                nodeHubs.Header = $"🖥️ USB Hubs ({servers.Count})";
                
                // Set first server IP (for manual operations)
                txtServerIP.Text = servers[0];
                
                AddLog("Success", $"{servers.Count} {_localization.GetText("log_scan_found", _currentLanguage)}");
                lblStatus.Text = $"✓ {servers.Count} {_localization.GetText("status_servers_found", _currentLanguage)}";
                lblStatus.Foreground = (SolidColorBrush)FindResource("StatusSuccess");
                
                // Auto-list devices on ALL servers (not just the first one!)
                foreach (var server in servers)
                {
                    await ListDevicesOnServer(server);
                }
                
                // Load already connected devices (survives app restart)
                await LoadConnectedDevicesAsync();
                
                // Auto-connect favorites (like PowerShell Connect-Favorites)
                await AutoConnectFavorites();
            }
            else
            {
                lblStatus.Text = _localization.GetText("status_no_server", _currentLanguage);
                lblStatus.Foreground = (SolidColorBrush)FindResource("StatusWarning");
                AddLog("Warning", _localization.GetText("log_scan_none", _currentLanguage));
            }
        }
        catch (Exception ex)
        {
            AddLog("Error", ex.Message);
        }
    }
    
    /// <summary>
    /// List devices on a specific server and add to tree
    /// </summary>
    private async Task ListDevicesOnServer(string serverIP)
    {
        try
        {
            var devices = await _usbip.ListDevicesAsync(serverIP);
            
            // Find server node
            TreeViewItem? serverNode = null;
            foreach (TreeViewItem item in nodeHubs.Items)
            {
                if (item.Header?.ToString()?.Contains(serverIP) == true)
                {
                    serverNode = item;
                    break;
                }
            }
            
            if (serverNode == null)
            {
                serverNode = new TreeViewItem { Header = $"🖥️ {serverIP}" };
                nodeHubs.Items.Add(serverNode);
            }
            
            serverNode.Items.Clear();
            foreach (var device in devices)
            {
                // Use server description by default, enrich only if we have better info
                string displayName = device.Description; // snakefoxu
                
                // Try to get better name from USB IDs database
                if (!string.IsNullOrEmpty(device.VendorId) && !string.IsNullOrEmpty(device.ProductId))
                {
                    var usbIdsName = _usbIds.GetDeviceDescription(device.VendorId, device.ProductId); // github.com/SnakeFoxu
                    // Only use if it's not "Unknown" - prefer server's description
                    if (!usbIdsName.StartsWith("Unknown") && !usbIdsName.StartsWith("USB Device"))
                    {
                        displayName = usbIdsName;
                    }
                }
                
                var deviceNode = new TreeViewItem 
                { 
                    Header = $"🔌 {device.BusId}: {displayName}",
                    Tag = device
                };
                serverNode.Items.Add(deviceNode); /* SnakeFoxu/SnakeUSBIP */
            }
            serverNode.Header = $"🖥️ {serverIP} ({devices.Count})";
            serverNode.IsExpanded = true; // snakefoxu
            
            AddLog("Info", string.Format(_localization.GetText("log_devices_on_server", _currentLanguage), devices.Count, serverIP));
        }
        catch (Exception ex)
        {
            AddLog("Error", ex.Message);
        }
    }
    
    /// <summary>
    /// Load devices that are already connected (from previous session)
    /// This detects devices connected before app restart
    /// </summary>
    private async Task LoadConnectedDevicesAsync()
    {
        try
        {
            var connectedDevices = await _usbip.GetConnectedDevicesAsync();
            
            if (connectedDevices.Count > 0)
            {
                AddLog("Info", string.Format(_localization.GetText("log_devices_already_connected", _currentLanguage), connectedDevices.Count));
                
                foreach (var device in connectedDevices)
                {
                    // Check if already in nodeConnected to avoid duplicates
                    bool alreadyExists = false;
                    foreach (TreeViewItem item in nodeConnected.Items)
                    {
                        if (item.Tag is ConnectedDevice cd && 
                            cd.ServerIP == device.ServerIP && 
                            cd.BusId == device.BusId)
                        {
                            alreadyExists = true;
                            break;
                        }
                    }
                    
                    if (!alreadyExists)
                    {
                        // Build device name with description if available
                        var deviceName = string.IsNullOrEmpty(device.Description)
                            ? $"{device.ServerIP}/{device.BusId}"
                            : $"{device.BusId}: {device.Description} ({device.VendorId}:{device.ProductId})";
                        
                        var connNode = new TreeViewItem 
                        { 
                            Header = $"☑️ {deviceName}",
                            Tag = device
                        };
                        nodeConnected.Items.Add(connNode);
                        
                        // Add to connection monitor for auto-reconnect
                        _connectionMonitor.AddDevice(device.ServerIP, device.BusId, autoReconnect: true);
                    }
                }
                
                UpdateConnectedCount();
                _connectionMonitor.Start();
            }
        }
        catch (Exception ex)
        {
            AddLog("Warning", string.Format(_localization.GetText("log_load_connected_error", _currentLanguage), ex.Message));
        }
    }
    
    /// <summary>
    /// Auto-connect favorites with AutoConnect=true
    /// Port from PowerShell Connect-Favorites
    /// </summary>
    private async Task AutoConnectFavorites()
    {
        var favorites = _favorites.GetFavorites().Where(f => f.AutoConnect).ToList();
        if (favorites.Count == 0) return;
        
        AddLog("Info", string.Format(_localization.GetText("log_auto_connecting", _currentLanguage), favorites.Count));
        
        foreach (var fav in favorites)
        {
            try
            {
                var result = await _usbip.ConnectAsync(fav.ServerIP, fav.BusId);
                if (result.Success)
                {
                    AddLog("Success", string.Format(_localization.GetText("log_connected_favorite", _currentLanguage), fav.Description, fav.BusId));
                    
                    // Add to connected list
                    var connNode = new TreeViewItem 
                    { 
                        Header = $"☑️ {fav.ServerIP}/{fav.BusId}",
                        Tag = new ConnectedDevice { ServerIP = fav.ServerIP, BusId = fav.BusId }
                    };
                    nodeConnected.Items.Add(connNode);
                }
                else
                {
                    AddLog("Warning", string.Format(_localization.GetText("log_connection_failed", _currentLanguage), fav.BusId, result.Error));
                }
            }
            catch (Exception ex)
            {
                AddLog("Error", string.Format(_localization.GetText("log_connection_error", _currentLanguage), fav.BusId, ex.Message));
            }
        }
        
        UpdateConnectedCount();
    }
    
    /// <summary>
    /// TreeView double-click handler for connect/disconnect
    /// </summary>
    private async void TreeDevices_MouseDoubleClick(object sender, MouseButtonEventArgs e)
    {
        if (treeDevices.SelectedItem is not TreeViewItem selectedNode)
            return;
        
        // Check if it's a device node (has Tag)
        if (selectedNode.Tag is UsbDevice device)
        {
            // Connect device
            AddLog("Info", string.Format(_localization.GetText("log_connecting_device", _currentLanguage), device.BusId, device.ServerIP));
            lblStatus.Text = $"{_localization.GetText("status_connecting", _currentLanguage)} {device.BusId}...";
            lblStatus.Foreground = (SolidColorBrush)FindResource("StatusInfo");
            
            var result = await _usbip.ConnectAsync(device.ServerIP, device.BusId);
            
            if (result.Success)
            {
                AddLog("Success", string.Format(_localization.GetText("log_connection_success", _currentLanguage), device.BusId));
                lblStatus.Text = $"✓ {_localization.GetText("log_connected", _currentLanguage)}: {device.BusId}";
                lblStatus.Foreground = (SolidColorBrush)FindResource("StatusSuccess");
                
                // Update icon to show connected
                selectedNode.Header = $"☑️ {device.BusId}: {device.Description}";
                
                // Add to connected devices node with full description
                var connectedNode = new TreeViewItem 
                { 
                    Header = $"☑️ {device.BusId}: {device.Description}",
                    Tag = new ConnectedDevice { ServerIP = device.ServerIP, BusId = device.BusId, Description = device.Description, VendorId = device.VendorId, ProductId = device.ProductId }
                };
                nodeConnected.Items.Add(connectedNode);
                UpdateConnectedCount();
                
                // Start monitoring for auto-reconnection
                _connectionMonitor.AddDevice(device.ServerIP, device.BusId, autoReconnect: true);
                _connectionMonitor.Start();
                
                // Show toast notification
                ShowNotification(
                    _localization.GetText("notify_connected", _currentLanguage),
                    $"{device.BusId}: {device.Description}",
                    Forms.ToolTipIcon.Info);
            }
            else
            {
                AddLog("Error", result.Error ?? _localization.GetText("log_connection_general_failed", _currentLanguage));
                lblStatus.Text = $"Error: {result.Error}";
                lblStatus.Foreground = (SolidColorBrush)FindResource("StatusError");
            }
        }
        else if (selectedNode.Tag is ConnectedDevice connectedDevice)
        {
            // Disconnect device - need to find port
            AddLog("Info", string.Format(_localization.GetText("log_disconnecting", _currentLanguage), connectedDevice.BusId));
            lblStatus.Text = $"{_localization.GetText("status_disconnecting", _currentLanguage)} {connectedDevice.BusId}...";
            lblStatus.Foreground = (SolidColorBrush)FindResource("StatusInfo");
            
            // Get connected devices to find port
            var connectedDevices = await _usbip.GetConnectedDevicesAsync();
            var portDevice = connectedDevices.FirstOrDefault(d => 
                d.ServerIP.Contains(connectedDevice.ServerIP) || 
                connectedDevice.ServerIP.Contains(d.ServerIP));
            
            if (portDevice != null)
            {
                var result = await _usbip.DisconnectAsync(portDevice.Port);
                
                if (result.Success)
                {
                    AddLog("Success", string.Format(_localization.GetText("log_disconnected_port", _currentLanguage), portDevice.Port));
                    lblStatus.Text = $"✓ {_localization.GetText("log_disconnected", _currentLanguage)}";
                    lblStatus.Foreground = (SolidColorBrush)FindResource("StatusSuccess");
                    
                    // CRITICAL FIX: Remove from connection monitor to prevent auto-reconnect
                    _connectionMonitor.RemoveDevice(connectedDevice.ServerIP, connectedDevice.BusId);
                    
                    // Remove from connected devices list
                    nodeConnected.Items.Remove(selectedNode);
                    UpdateConnectedCount();
                    
                    // CRITICAL FIX: Restore original device icon in the tree
                    foreach (TreeViewItem hubNode in nodeHubs.Items)
                    {
                        foreach (TreeViewItem deviceNode in hubNode.Items)
                        {
                            if (deviceNode.Tag is UsbDevice dev && 
                                dev.ServerIP == connectedDevice.ServerIP && 
                                dev.BusId == connectedDevice.BusId)
                            {
                                // Restore to disconnected icon
                                deviceNode.Header = $"🔌 {dev.BusId}: {dev.Description}";
                                break;
                            }
                        }
                    }
                    
                    // Show notification
                    ShowNotification(
                        _localization.GetText("log_disconnected", _currentLanguage),
                        $"{connectedDevice.BusId}",
                        Forms.ToolTipIcon.Info);
                }
                else
                {
                    AddLog("Error", result.Error ?? _localization.GetText("log_disconnect_failed", _currentLanguage));
                }
            }
            else
            {
                AddLog("Warning", _localization.GetText("log_device_not_found", _currentLanguage));
                // Still remove from UI
                nodeConnected.Items.Remove(selectedNode);
                _connectionMonitor.RemoveDevice(connectedDevice.ServerIP, connectedDevice.BusId);
                UpdateConnectedCount();
            }
        }
    }
    
    private void UpdateConnectedCount()
    {
        nodeConnected.Header = $"☑️ {_localization.GetText("node_connected", _currentLanguage).Replace("☑️ ", "")} ({nodeConnected.Items.Count})";
    }
    
    /// <summary>
    /// Override OnClosing to properly dispose of tray icon and clean up resources
    /// Prevents "ghost" tray icon from remaining after app closure
    /// </summary>
    protected override void OnClosing(System.ComponentModel.CancelEventArgs e)
    {
        // Cleanup tray icon
        if (_trayIcon != null)
        {
            _trayIcon.Visible = false;
            _trayIcon.Dispose();
            _trayIcon = null;
        }
        
        // Stop connection monitor
        _connectionMonitor?.Stop();
        
        base.OnClosing(e);
    }
    
    #region Window Controls
    
    private void TitleBar_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
    {
        if (e.ClickCount == 2)
        {
            // Double-click to maximize/restore
            WindowState = WindowState == WindowState.Maximized ? WindowState.Normal : WindowState.Maximized;
        }
        else
        {
            DragMove();
        }
    }
    
    private void BtnMinimize_Click(object sender, RoutedEventArgs e) => WindowState = WindowState.Minimized;
    private void BtnMaximize_Click(object sender, RoutedEventArgs e) => WindowState = WindowState == WindowState.Maximized ? WindowState.Normal : WindowState.Maximized;
    private void BtnClose_Click(object sender, RoutedEventArgs e) => Close();
    
    #endregion
    
    #region Language & Theme
    
    private void BtnLanguage_Click(object sender, RoutedEventArgs e)
    {
        _currentLanguage = _currentLanguage == "es" ? "en" : "es";
        _config.SetLanguage(_currentLanguage);
        UpdateUITexts();
    }
    
    private void BtnTheme_Click(object sender, RoutedEventArgs e)
    {
        _currentTheme = _currentTheme == "dark" ? "light" : "dark";
        btnTheme.Content = _currentTheme == "dark" ? "🌙" : "☀️";
        ApplyTheme(_currentTheme);

    }
    
    private void ApplyTheme(string theme)
    {
        var resources = System.Windows.Application.Current.Resources;
        
        if (theme == "light")
        {
            // Light theme - Windows style
            resources["BackgroundDark"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#F5F5F5"));
            resources["BackgroundPanel"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#FFFFFF"));
            resources["BackgroundTitleBar"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#E8E8E8"));
            resources["BackgroundButton"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#DEDEDE"));
            resources["BackgroundButtonHover"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#C8C8C8"));
            resources["BackgroundInput"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#FFFFFF"));
            resources["ForegroundPrimary"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#1E1E1E"));
            resources["ForegroundSecondary"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#666666"));
            resources["AccentOrange"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#D35400"));
            resources["AccentBlue"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#0078D4"));
            resources["StatusSuccess"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#107C10"));
            resources["StatusInfo"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#0078D4"));
        }
        else
        {
            // Dark theme - VS Code Dark+ Professional
            resources["BackgroundDark"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#1E1E1E"));
            resources["BackgroundPanel"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#252526"));
            resources["BackgroundTitleBar"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#323233"));
            resources["BackgroundButton"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#0E639C"));
            resources["BackgroundButtonHover"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#1177BB"));
            resources["BackgroundInput"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#3C3C3C"));
            resources["ForegroundPrimary"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#DCDCDC"));
            resources["ForegroundSecondary"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#969696"));
            resources["AccentOrange"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#CE9178"));
            resources["AccentBlue"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#0E639C"));
            resources["StatusSuccess"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#89D185"));
            resources["StatusInfo"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#75BEFF"));
        }
        
        // Force UI refresh
        Background = (SolidColorBrush)resources["BackgroundDark"];
    }
    
    private void UpdateUITexts()
    {
        btnLanguage.Content = _currentLanguage == "es" ? "🌐 ES" : "🌐 EN";
        btnUpdate.Content = _localization.GetText("btn_update", _currentLanguage);
        lblServer.Content = _localization.GetText("lbl_server", _currentLanguage);
        btnScan.Content = _localization.GetText("btn_scan", _currentLanguage);
        btnList.Content = _localization.GetText("btn_refresh", _currentLanguage);
        btnSSH.Content = _localization.GetText("btn_ssh", _currentLanguage);
        btnVPN.Content = _localization.GetText("btn_vpn", _currentLanguage);
        nodeHubs.Header = _localization.GetText("node_hubs", _currentLanguage);
        nodeConnected.Header = _localization.GetText("node_connected", _currentLanguage);
        nodeFavorites.Header = _localization.GetText("node_favorites", _currentLanguage);
        lblLogTitle.Content = _localization.GetText("log_title", _currentLanguage);
        btnClearLog.Content = _localization.GetText("log_clear", _currentLanguage);
        btnInstallDrivers.Content = _localization.GetText("btn_install_drivers", _currentLanguage);
        btnUninstallDrivers.Content = _localization.GetText("btn_uninstall_drivers", _currentLanguage);
        lblStatus.Text = _localization.GetText("status_ready", _currentLanguage);
    }
    
    #endregion
    
    #region Network Scanning
    
    private async void BtnScan_Click(object sender, RoutedEventArgs e)
    {
        lblStatus.Text = _localization.GetText("status_scanning", _currentLanguage);
        lblStatus.Foreground = (SolidColorBrush)FindResource("StatusInfo");
        progressBar.Visibility = Visibility.Visible;
        progressBar.IsIndeterminate = true;
        
        AddLog("Info", _localization.GetText("log_scan_start", _currentLanguage));
        
        try
        {
            var servers = await _networkScanner.ScanNetworkAsync(GetLocalSubnet());
            
            nodeHubs.Items.Clear();
            foreach (var server in servers)
            {
                var serverNode = new TreeViewItem { Header = $"🖥️ {server}" };
                nodeHubs.Items.Add(serverNode);
            }
            nodeHubs.Header = $"🖥️ USB Hubs ({servers.Count})";
            
            if (servers.Count > 0)
            {
                lblStatus.Text = $"✓ {servers.Count} {_localization.GetText("status_servers_found", _currentLanguage)}";
                lblStatus.Foreground = (SolidColorBrush)FindResource("StatusSuccess");
                AddLog("Success", $"{servers.Count} {_localization.GetText("log_scan_found", _currentLanguage)}");
                
                // Auto-select first server
                if (servers.Count == 1)
                    txtServerIP.Text = servers[0];
            }
            else
            {
                lblStatus.Text = _localization.GetText("status_no_server", _currentLanguage);
                lblStatus.Foreground = (SolidColorBrush)FindResource("StatusWarning");
                AddLog("Warning", _localization.GetText("log_scan_none", _currentLanguage));
            }
        }
        catch (Exception ex)
        {
            lblStatus.Text = $"Error: {ex.Message}";
            lblStatus.Foreground = (SolidColorBrush)FindResource("StatusError");
            AddLog("Error", ex.Message);
        }
        finally
        {
            progressBar.Visibility = Visibility.Hidden;
            progressBar.IsIndeterminate = false;
        }
    }
    
    private string GetLocalSubnet()
    {
        try
        {
            foreach (var ni in NetworkInterface.GetAllNetworkInterfaces())
            {
                if (ni.OperationalStatus == OperationalStatus.Up &&
                    ni.NetworkInterfaceType != NetworkInterfaceType.Loopback &&
                    !ni.Description.Contains("Virtual", StringComparison.OrdinalIgnoreCase) &&
                    !ni.Description.Contains("VMware", StringComparison.OrdinalIgnoreCase))
                {
                    foreach (var ip in ni.GetIPProperties().UnicastAddresses)
                    {
                        if (ip.Address.AddressFamily == AddressFamily.InterNetwork)
                        {
                            var parts = ip.Address.ToString().Split('.');
                            return $"{parts[0]}.{parts[1]}.{parts[2]}";
                        }
                    }
                }
            }
        }
        catch { }
        return "192.168.1";
    }
    
    #endregion
    
    #region USBIP Operations
    
    private async void BtnList_Click(object sender, RoutedEventArgs e)
    {
        // Get all servers from the tree, or use textbox if tree is empty
        var servers = new List<string>();
        
        foreach (TreeViewItem item in nodeHubs.Items)
        {
            var header = item.Header?.ToString();
            if (header != null)
            {
                // Extract IP from header like "🖥️ 192.168.1.132 (2)"
                var match = System.Text.RegularExpressions.Regex.Match(header, @"(\d+\.\d+\.\d+\.\d+)");
                if (match.Success)
                    servers.Add(match.Groups[1].Value);
            }
        }
        
        // If no servers in tree, use textbox
        if (servers.Count == 0)
        {
            var serverIP = txtServerIP.Text.Trim();
            if (string.IsNullOrEmpty(serverIP))
            {
                lblStatus.Text = _localization.GetText("enter_ip", _currentLanguage);
                lblStatus.Foreground = (SolidColorBrush)FindResource("StatusWarning");
                return;
            }
            servers.Add(serverIP);
        }
        
        lblStatus.Text = $"{_localization.GetText("status_listing", _currentLanguage)} {servers.Count} server(s)...";
        lblStatus.Foreground = (SolidColorBrush)FindResource("StatusInfo");
        
        AddLog("Info", string.Format(_localization.GetText("log_listing_devices", _currentLanguage), servers.Count));
        
        int totalDevices = 0;
        
        try
        {
            foreach (var serverIP in servers)
            {
                await ListDevicesOnServer(serverIP);
                
                // Count devices
                foreach (TreeViewItem item in nodeHubs.Items)
                {
                    if (item.Header?.ToString()?.Contains(serverIP) == true)
                    {
                        totalDevices += item.Items.Count;
                        break;
                    }
                }
            }
            
            lblStatus.Text = $"✓ {totalDevices} {_localization.GetText("status_devices_found", _currentLanguage)} on {servers.Count} server(s)";
            lblStatus.Foreground = (SolidColorBrush)FindResource("StatusSuccess");
            AddLog("Success", string.Format(_localization.GetText("log_listed_devices", _currentLanguage), totalDevices, servers.Count));
        }
        catch (Exception ex)
        {
            lblStatus.Text = $"Error: {ex.Message}";
            lblStatus.Foreground = (SolidColorBrush)FindResource("StatusError");
            AddLog("Error", ex.Message);
        }
    }
    
    #endregion
    
    #region SSH & VPN
    
    private void BtnSSH_Click(object sender, RoutedEventArgs e)
    {
        var serverIP = txtServerIP.Text.Trim();
        if (string.IsNullOrEmpty(serverIP)) serverIP = "192.168.1.100";
        
        var sshDialog = new Views.SshDialog(_localization, _currentLanguage, serverIP);
        sshDialog.Owner = this;
        sshDialog.ShowDialog();
    }
    
    private void BtnVPN_Click(object sender, RoutedEventArgs e)
    {
        var vpnDialog = new Views.VpnDialog(_localization, _currentLanguage);
        vpnDialog.Owner = this;
        vpnDialog.ShowDialog();
    }
    
    #endregion
    
    #region Update
    
    private async void BtnUpdate_Click(object sender, RoutedEventArgs e)
    {
        lblStatus.Text = _localization.GetText("update_checking", _currentLanguage);
        lblStatus.Foreground = (SolidColorBrush)FindResource("StatusInfo");
        AddLog("Info", _localization.GetText("log_checking_updates", _currentLanguage));
        
        try
        {
            var updateInfo = await _updates.CheckForUpdatesAsync();
            
            // Debug logging - visible in Activity Log
            AddLog("Debug", $"Current: v{updateInfo.CurrentVersion} | Latest: v{updateInfo.LatestVersion} | Update: {updateInfo.UpdateAvailable}");
            
            if (updateInfo.UpdateAvailable)
            {
                AddLog("Info", string.Format(_localization.GetText("log_update_available", _currentLanguage), updateInfo.LatestVersion));
                lblStatus.Text = $"⬆️ {_localization.GetText("update_available", _currentLanguage)}: v{updateInfo.LatestVersion}";
                lblStatus.Foreground = (SolidColorBrush)FindResource("StatusWarning");
                
                var result = System.Windows.MessageBox.Show(
                    $"Nueva versión disponible: v{updateInfo.LatestVersion}\n\n{updateInfo.ReleaseNotes}\n\n¿Desea descargar e instalar la actualización?",
                    "Actualización Disponible",
                    System.Windows.MessageBoxButton.YesNo,
                    System.Windows.MessageBoxImage.Information);
                
                if (result == System.Windows.MessageBoxResult.Yes && updateInfo.DownloadUrl != null && updateInfo.InstallerName != null)
                {
                    AddLog("Info", _localization.GetText("log_downloading_update", _currentLanguage));
                    lblStatus.Text = _localization.GetText("update_downloading", _currentLanguage);
                    
                    var installResult = await _updates.StartUpdateAsync(updateInfo.DownloadUrl, updateInfo.InstallerName);
                    if (!installResult.Success)
                    {
                        AddLog("Error", installResult.Error ?? _localization.GetText("log_update_failed", _currentLanguage));
                    }
                }
            }
            else
            {
                lblStatus.Text = _localization.GetText("update_current", _currentLanguage);
                lblStatus.Foreground = (SolidColorBrush)FindResource("StatusSuccess");
                AddLog("Success", string.Format(_localization.GetText("log_latest_version", _currentLanguage), updateInfo.CurrentVersion));
            }
        }
        catch (Exception ex)
        {
            AddLog("Error", ex.Message);
            lblStatus.Text = "Error checking updates";
            lblStatus.Foreground = (SolidColorBrush)FindResource("StatusError");
        }
    }
    
    #endregion
    
    #region Drivers
    
    private void CheckDriverStatus()
    {
        var status = _drivers.CheckStatus();
        lblDriverValue.Text = status.Installed 
            ? $"{_localization.GetText("log_connected", _currentLanguage)} ✓" 
            : "No instalado";
        lblDriverValue.Foreground = status.Installed 
            ? (SolidColorBrush)FindResource("StatusSuccess") 
            : (SolidColorBrush)FindResource("StatusError");
    }
    
    private async void BtnInstallDrivers_Click(object sender, RoutedEventArgs e)
    {
        AddLog("Info", _localization.GetText("log_installing_drivers", _currentLanguage));
        var result = await _drivers.InstallAsync();
        if (result.Success)
        {
            AddLog("Success", _localization.GetText("log_drivers_installed", _currentLanguage));
            CheckDriverStatus();
        }
        else
        {
            AddLog("Error", result.Error ?? _localization.GetText("log_install_drivers_failed", _currentLanguage));
        }
    }
    
    private async void BtnUninstallDrivers_Click(object sender, RoutedEventArgs e)
    {
        AddLog("Info", _localization.GetText("log_uninstalling_drivers", _currentLanguage));
        var result = await _drivers.UninstallAsync();
        if (result.Success)
        {
            AddLog("Success", _localization.GetText("log_drivers_uninstalled", _currentLanguage));
            CheckDriverStatus();
        }
        else
        {
            AddLog("Error", result.Error ?? _localization.GetText("log_uninstall_drivers_failed", _currentLanguage));
        }
    }
    
    #endregion
    
    #region Log
    
    private void BtnClearLog_Click(object sender, RoutedEventArgs e)
    {
        _logEntries.Clear();
        txtLog.Text = "";
    }
    
    private void AddLog(string type, string message)
    {
        var emoji = type switch
        {
            "Success" => "☑",
            "Warning" => "⚠",
            "Error" => "❌",
            _ => "ℹ"
        };
        
        var entry = $"[{DateTime.Now:HH:mm:ss}] {emoji} {message}";
        _logEntries.Insert(0, entry);
        
        // Keep only last 100 entries
        if (_logEntries.Count > 100)
            _logEntries.RemoveAt(_logEntries.Count - 1);
        
        txtLog.Text = string.Join("\n", _logEntries);
    }
    
    #endregion
    
    #region Configuration
    
    private void LoadConfiguration()
    {
        var config = _config.Load();
        _currentLanguage = config.Language ?? "es";
        _currentTheme = config.Theme ?? "dark";
        
        if (!string.IsNullOrEmpty(config.LastServerIP))
            txtServerIP.Text = config.LastServerIP;
        
        // Load custom device names
        _usbIds.LoadCustomNames(config.CustomDeviceNames);
    }
    
    protected override void OnClosed(EventArgs e)
    {
        // Stop connection monitor
        _connectionMonitor.Stop();
        _connectionMonitor.Dispose();
        
        // Clean up tray icon
        if (_trayIcon != null)
        {
            _trayIcon.Visible = false;
            _trayIcon.Dispose();
            _trayIcon = null;
        }
        
        // Save configuration with favorites
        var config = _config.Load();
        config.Language = _currentLanguage;
        config.Theme = _currentTheme;
        config.LastServerIP = txtServerIP.Text;
        config.Favorites = _favorites.GetFavorites().ToList();
        _config.Save(config);
        
        base.OnClosed(e);
    }
    
    #endregion
    
    #region Context Menu
    
    private async void MenuConnect_Click(object sender, RoutedEventArgs e)
    {
        if (treeDevices.SelectedItem is TreeViewItem node && node.Tag is UsbDevice device)
        {
            AddLog("Info", $"Connecting {device.BusId}...");
            var result = await _usbip.ConnectAsync(device.ServerIP, device.BusId);
            if (result.Success)
            {
                AddLog("Success", $"Connected {device.BusId}");
                node.Header = $"☑️ {device.BusId}: {device.Description}";
                
                // Add to connected list
                var connNode = new TreeViewItem 
                { 
                    Header = $"☑️ {device.ServerIP}/{device.BusId}",
                    Tag = new ConnectedDevice { ServerIP = device.ServerIP, BusId = device.BusId }
                };
                nodeConnected.Items.Add(connNode);
                UpdateConnectedCount();
            }
            else
            {
                AddLog("Error", result.Error ?? "Connection failed");
            }
        }
    }
    
    private async void MenuDisconnect_Click(object sender, RoutedEventArgs e)
    {
        if (treeDevices.SelectedItem is TreeViewItem node && node.Tag is ConnectedDevice device)
        {
            var connectedDevices = await _usbip.GetConnectedDevicesAsync();
            var portDevice = connectedDevices.FirstOrDefault(d => d.ServerIP.Contains(device.ServerIP));
            
            if (portDevice != null)
            {
                var result = await _usbip.DisconnectAsync(portDevice.Port);
                if (result.Success)
                {
                    AddLog("Success", $"Disconnected");
                    
                    // CRITICAL FIX: Remove from connection monitor
                    _connectionMonitor.RemoveDevice(device.ServerIP, device.BusId);
                    
                    nodeConnected.Items.Remove(node);
                    UpdateConnectedCount();
                    
                    // CRITICAL FIX: Restore original device icon
                    foreach (TreeViewItem hubNode in nodeHubs.Items)
                    {
                        foreach (TreeViewItem deviceNode in hubNode.Items)
                        {
                            if (deviceNode.Tag is UsbDevice dev && 
                                dev.ServerIP == device.ServerIP && 
                                dev.BusId == device.BusId)
                            {
                                deviceNode.Header = $"🔌 {dev.BusId}: {dev.Description}";
                                break;
                            }
                        }
                    }
                }
                else
                {
                    AddLog("Error", result.Error ?? "Disconnect failed");
                }
            }
        }
    }
    
    private void MenuAddFavorite_Click(object sender, RoutedEventArgs e)
    {
        if (treeDevices.SelectedItem is TreeViewItem node && node.Tag is UsbDevice device)
        {
            var result = _favorites.AddFavorite(device.ServerIP, device.BusId, device.Description, true);
            if (result.Success)
            {
                AddLog("Success", _localization.GetText("log_favorite_added", _currentLanguage));
                LoadFavorites();
            }
            else
            {
                AddLog("Warning", result.Error ?? "Already in favorites");
            }
        }
    }
    
    private void MenuRemoveFavorite_Click(object sender, RoutedEventArgs e)
    {
        if (treeDevices.SelectedItem is TreeViewItem node)
        {
            string serverIP = "", busId = "";
            
            if (node.Tag is UsbDevice device)
            {
                serverIP = device.ServerIP;
                busId = device.BusId;
            }
            else if (node.Tag is Services.FavoriteDevice fav)
            {
                serverIP = fav.ServerIP;
                busId = fav.BusId;
            }
            
            if (!string.IsNullOrEmpty(serverIP))
            {
                var result = _favorites.RemoveFavorite(serverIP, busId);
                if (result.Success)
                {
                    AddLog("Success", _localization.GetText("log_favorite_removed", _currentLanguage));
                    LoadFavorites();
                }
            }
        }
    }
    
    private void MenuRemoveServer_Click(object sender, RoutedEventArgs e)
    {
        if (treeDevices.SelectedItem is TreeViewItem node && node.Parent is TreeViewItem parent)
        {
            if (parent == nodeHubs)
            {
                nodeHubs.Items.Remove(node);
                nodeHubs.Header = $"🖥️ USB Hubs ({nodeHubs.Items.Count})";
            }
        }
    }
    
    private void MenuProperties_Click(object sender, RoutedEventArgs e)
    {
        if (treeDevices.SelectedItem is TreeViewItem node && node.Tag is UsbDevice device)
        {
            // Use UsbIds for better description
            var vendorDesc = _usbIds.GetVendor(device.VendorId);
            var productDesc = _usbIds.GetProduct(device.VendorId, device.ProductId);
            
            var props = $"Bus ID: {device.BusId}\n" +
                       $"Server: {device.ServerIP}\n" +
                       $"Description: {device.Description}\n" +
                       $"VID:PID: {device.VendorId}:{device.ProductId}\n" +
                       $"Vendor: {vendorDesc}\n" +
                       $"Product: {productDesc}";
            System.Windows.MessageBox.Show(props, "Device Properties", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Information);
        }
    }
    
    private void MenuRename_Click(object sender, RoutedEventArgs e)
    {
        if (treeDevices.SelectedItem is TreeViewItem node && node.Tag is UsbDevice device)
        {
            // Get current name (custom or from usb.ids)
            var currentName = _usbIds.GetDeviceDescription(device.VendorId, device.ProductId);
            
            // Show input dialog using Microsoft.VisualBasic
            var newName = Microsoft.VisualBasic.Interaction.InputBox(
                $"Renombrar dispositivo {device.VendorId}:{device.ProductId}\n\nNuevo nombre:",
                "Renombrar Dispositivo",
                currentName);
            
            if (!string.IsNullOrWhiteSpace(newName) && newName != currentName)
            {
                // Save custom name
                _usbIds.SetCustomName(device.VendorId, device.ProductId, newName);
                
                // Update device description
                device.Description = newName;
                
                // Update TreeView node
                var isConnected = node.Header?.ToString()?.StartsWith("☑️") == true;
                node.Header = isConnected 
                    ? $"☑️ {device.BusId}: {newName}" 
                    : $"🔌 {device.BusId}: {newName}";
                
                // Persist to config
                var config = _config.Load();
                config.CustomDeviceNames ??= new Dictionary<string, string>();
                config.CustomDeviceNames[$"{device.VendorId}:{device.ProductId}"] = newName;
                _config.Save(config);
                
                AddLog("Success", $"Dispositivo renombrado: {newName}");
            }
        }
    }
    
    #endregion
    
    #region Connection Monitor Events
    
    private void OnConnectionLost(object? sender, ConnectionLostEventArgs e)
    {
        Dispatcher.Invoke(() =>
        {
            AddLog("Warning", $"Connection lost: {e.ServerIP}/{e.BusId}");
            ShowNotification(
                _localization.GetText("notify_connection_lost", _currentLanguage),
                $"{e.BusId} @ {e.ServerIP}",
                Forms.ToolTipIcon.Warning);
            lblStatus.Text = $"⚠️ {_localization.GetText("notify_connection_lost", _currentLanguage)}: {e.BusId}";
            lblStatus.Foreground = (SolidColorBrush)FindResource("StatusWarning");
        });
    }
    
    private void OnConnectionRestored(object? sender, ConnectionRestoredEventArgs e)
    {
        Dispatcher.Invoke(() =>
        {
            AddLog("Success", $"Connection restored: {e.ServerIP}/{e.BusId}");
            ShowNotification(
                _localization.GetText("notify_reconnected", _currentLanguage),
                $"{e.BusId} @ {e.ServerIP}",
                Forms.ToolTipIcon.Info);
            lblStatus.Text = $"✓ {_localization.GetText("notify_reconnected", _currentLanguage)}: {e.BusId}";
            lblStatus.Foreground = (SolidColorBrush)FindResource("StatusSuccess");
        });
    }
    
    #endregion
}