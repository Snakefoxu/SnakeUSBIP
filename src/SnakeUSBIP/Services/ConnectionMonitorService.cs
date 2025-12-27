using System.Timers;
using Timer = System.Timers.Timer;

namespace SnakeUSBIP.Services;

/// <summary>
/// Connection monitor for auto-reconnection
/// Port of PowerShell connection monitoring logic
/// </summary>
public class ConnectionMonitorService : IDisposable
{
    private readonly UsbipService _usbip;
    private readonly FavoritesService _favorites;
    private readonly Timer _monitorTimer;
    private readonly List<MonitoredDevice> _monitoredDevices = new();
    private bool _isRunning = false;
    
    public event EventHandler<ConnectionLostEventArgs>? ConnectionLost;
    public event EventHandler<ConnectionRestoredEventArgs>? ConnectionRestored;
    
    public ConnectionMonitorService(UsbipService usbip, FavoritesService favorites)
    {
        _usbip = usbip;
        _favorites = favorites;
        
        // Check every 2 seconds for faster detection
        _monitorTimer = new Timer(2000);
        _monitorTimer.Elapsed += OnMonitorTick;
        _monitorTimer.AutoReset = true;
    }
    
    /// <summary>
    /// Start monitoring connections
    /// </summary>
    public void Start()
    {
        if (_isRunning) return;
        _isRunning = true;
        _monitorTimer.Start();
    }
    
    /// <summary>
    /// Stop monitoring
    /// </summary>
    public void Stop()
    {
        _isRunning = false;
        _monitorTimer.Stop();
    }
    
    /// <summary>
    /// Add device to monitor
    /// </summary>
    public void AddDevice(string serverIP, string busId, bool autoReconnect = true)
    {
        if (_monitoredDevices.Any(d => d.ServerIP == serverIP && d.BusId == busId))
            return;
        
        _monitoredDevices.Add(new MonitoredDevice
        {
            ServerIP = serverIP,
            BusId = busId,
            AutoReconnect = autoReconnect,
            IsConnected = true,
            LastCheck = DateTime.Now
        });
    }
    
    /// <summary>
    /// Remove device from monitoring
    /// </summary>
    public void RemoveDevice(string serverIP, string busId)
    {
        _monitoredDevices.RemoveAll(d => d.ServerIP == serverIP && d.BusId == busId);
    }
    
    /// <summary>
    /// Clear all monitored devices
    /// </summary>
    public void ClearAll()
    {
        _monitoredDevices.Clear();
    }
    
    private async void OnMonitorTick(object? sender, ElapsedEventArgs e)
    {
        if (!_isRunning) return;
        
        try
        {
            var connectedDevices = await _usbip.GetConnectedDevicesAsync();
            
            foreach (var device in _monitoredDevices.ToList())
            {
                var isNowConnected = connectedDevices.Any(c => 
                    c.ServerIP == device.ServerIP && 
                    c.BusId == device.BusId);
                
                device.LastCheck = DateTime.Now;
                
                // Connection lost
                if (device.IsConnected && !isNowConnected)
                {
                    device.IsConnected = false;
                    device.ReconnectAttempts = 0;
                    
                    ConnectionLost?.Invoke(this, new ConnectionLostEventArgs
                    {
                        ServerIP = device.ServerIP,
                        BusId = device.BusId
                    });
                    
                    // Try to reconnect if enabled
                    if (device.AutoReconnect && device.ReconnectAttempts < 3)
                    {
                        await TryReconnect(device);
                    }
                }
                // Was disconnected, now connected (reconnection succeeded)
                else if (!device.IsConnected && isNowConnected)
                {
                    device.IsConnected = true;
                    device.ReconnectAttempts = 0;
                    
                    ConnectionRestored?.Invoke(this, new ConnectionRestoredEventArgs
                    {
                        ServerIP = device.ServerIP,
                        BusId = device.BusId
                    });
                }
            }
        }
        catch { }
    }
    
    private async Task TryReconnect(MonitoredDevice device)
    {
        device.ReconnectAttempts++;
        
        try
        {
            var result = await _usbip.ConnectAsync(device.ServerIP, device.BusId);
            if (result.Success)
            {
                device.IsConnected = true;
            }
        }
        catch { }
    }
    
    public void Dispose()
    {
        Stop();
        _monitorTimer.Dispose();
    }
}

internal class MonitoredDevice
{
    public string ServerIP { get; set; } = "";
    public string BusId { get; set; } = "";
    public bool IsConnected { get; set; }
    public bool AutoReconnect { get; set; }
    public int ReconnectAttempts { get; set; }
    public DateTime LastCheck { get; set; }
}

public class ConnectionLostEventArgs : EventArgs
{
    public string ServerIP { get; set; } = "";
    public string BusId { get; set; } = "";
}

public class ConnectionRestoredEventArgs : EventArgs
{
    public string ServerIP { get; set; } = "";
    public string BusId { get; set; } = "";
}
