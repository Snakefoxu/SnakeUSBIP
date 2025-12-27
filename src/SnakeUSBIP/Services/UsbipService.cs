// ─────────────────────────────────────────────────────────────────────────────
// SnakeUSBIP Client - Copyright (c) 2025 SnakeFoxu
// Source: https://github.com/SnakeFoxu/SnakeUSBIP
// This file is part of SnakeUSBIP, licensed under GPL v3
// ─────────────────────────────────────────────────────────────────────────────

using System.Diagnostics;
using System.IO;
using System.Text.RegularExpressions;

namespace SnakeUSBIP.Services;

/// <summary>
/// USBIP service - Wrapper for usbip.exe commands
/// Author: SnakeFoxu (github.com/SnakeFoxu)
/// </summary>
public class UsbipService
{
    private readonly string _usbipPath;
    
    public UsbipService()
    {
        // Find usbip executable in app directory - same order as PowerShell
        // Priorizar usbipw local, luego instalado
        var appDir = AppDomain.CurrentDomain.BaseDirectory;
        
        var locations = new[]
        {
            Path.Combine(appDir, "usbipw.exe"),      // Preferred
            Path.Combine(appDir, "usbip-win2.exe"),
            Path.Combine(appDir, "usbip.exe"),
            @"C:\Program Files\USBip\usbip.exe",
            @"C:\Program Files\usbip\usbip.exe"
        };
        
        _usbipPath = "";
        foreach (var loc in locations)
        {
            if (File.Exists(loc))
            {
                _usbipPath = loc;
                break;
            }
        }
        
        // Fallback to PATH
        if (string.IsNullOrEmpty(_usbipPath))
            _usbipPath = "usbip.exe";
    }
    
    /// <summary>
    /// Returns the path of the usbip executable being used
    /// </summary>
    public string GetUsbipPath() => _usbipPath;
    
    public async Task<List<UsbDevice>> ListDevicesAsync(string serverIP)
    {
        var devices = new List<UsbDevice>();
        
        try
        {
            var output = await RunCommandAsync($"list -r {serverIP}");
            
            // Debug: Log raw output
            System.Diagnostics.Debug.WriteLine($"[USBIP] Raw output from 'list -r {serverIP}':");
            System.Diagnostics.Debug.WriteLine(output);
            
            // Process line by line exactly like PowerShell
            // $lines = $output -split "`r?`n"
            var lines = output.Split(new[] { "\r\n", "\n", "\r" }, StringSplitOptions.None);
            
            // PowerShell regex: '^\s*(\d+-[\d.]+)\s*:\s*(.+)$'
            var lineRegex = new Regex(@"^\s*(\d+-[\d\.]+)\s*:\s*(.+)$");
            var vidPidRegex = new Regex(@"\(([0-9a-fA-F]{4}):([0-9a-fA-F]{4})\)");
            
            foreach (var line in lines)
            {
                var match = lineRegex.Match(line);
                if (match.Success)
                {
                    var busId = match.Groups[1].Value.Trim(); // SnakeFoxu
                    var desc = match.Groups[2].Value.Trim();
                    
                    System.Diagnostics.Debug.WriteLine($"[USBIP] Found device: BusId={busId}, Desc={desc}");
                    
                    // Extract VID:PID if present
                    string vendorId = "", productId = "";
                    var vidMatch = vidPidRegex.Match(desc);
                    if (vidMatch.Success)
                    {
                        vendorId = vidMatch.Groups[1].Value; /* github.com/SnakeFoxu */
                        productId = vidMatch.Groups[2].Value;
                    }
                    
                    devices.Add(new UsbDevice
                    {
                        BusId = busId,
                        Description = desc,
                        VendorId = vendorId,
                        ProductId = productId,
                        ServerIP = serverIP,
                        Vendor = "",
                        Product = ""
                    });
                }
            }
            
            System.Diagnostics.Debug.WriteLine($"[USBIP] Total devices found: {devices.Count}");
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[USBIP] Error: {ex.Message}");
        }
        
        return devices;
    }
    
    public async Task<OperationResult> ConnectAsync(string serverIP, string busId)
    {
        try
        {
            var output = await RunCommandAsync($"attach -r {serverIP} -b {busId}");
            
            if (output.Contains("error", StringComparison.OrdinalIgnoreCase))
                return new OperationResult { Success = false, Error = output };
            
            return new OperationResult { Success = true };
        }
        catch (Exception ex)
        {
            return new OperationResult { Success = false, Error = ex.Message };
        }
    }
    
    public async Task<OperationResult> DisconnectAsync(int port)
    {
        try
        {
            var output = await RunCommandAsync($"detach -p {port}");
            
            if (output.Contains("error", StringComparison.OrdinalIgnoreCase))
                return new OperationResult { Success = false, Error = output };
            
            return new OperationResult { Success = true };
        }
        catch (Exception ex)
        {
            return new OperationResult { Success = false, Error = ex.Message };
        }
    }
    
    public async Task<List<ConnectedDevice>> GetConnectedDevicesAsync()
    {
        var devices = new List<ConnectedDevice>();
        
        try
        {
            var output = await RunCommandAsync("port");
            
            System.Diagnostics.Debug.WriteLine($"[USBIP] port output:\n{output}");
            
            // Real format from usbipw.exe port:
            // Port 01: device in use at High Speed(480Mbps)
            //          Realtek Semiconductor Corp. : unknown product (0bda:5100)
            //            -> usbip://192.168.1.132:3240/1-1.4
            //            -> remote bus/dev 001/003
            
            // First regex: find Port XX
            var portRegex = new Regex(@"Port\s+(\d+):", RegexOptions.IgnoreCase);
            // Second regex: find device description line with VID:PID
            var descRegex = new Regex(@"^\s+(.+?)\s*\(([0-9a-fA-F]{4}):([0-9a-fA-F]{4})\)");
            // Third regex: find usbip://IP:port/busId
            var usbipRegex = new Regex(@"usbip://([^:/]+):(\d+)/([^\s\r\n]+)");
            
            var lines = output.Split('\n');
            int currentPort = -1;
            string currentDescription = "";
            string currentVid = "";
            string currentPid = "";
            
            foreach (var line in lines)
            {
                // Check for Port line
                var portMatch = portRegex.Match(line);
                if (portMatch.Success)
                {
                    currentPort = int.Parse(portMatch.Groups[1].Value);
                    currentDescription = ""; // Reset
                    currentVid = "";
                    currentPid = "";
                    System.Diagnostics.Debug.WriteLine($"[USBIP] Found port: {currentPort}");
                }
                
                // Check for description line (contains VID:PID)
                var descMatch = descRegex.Match(line);
                if (descMatch.Success && currentPort >= 0)
                {
                    currentDescription = descMatch.Groups[1].Value.Trim();
                    currentVid = descMatch.Groups[2].Value;
                    currentPid = descMatch.Groups[3].Value;
                    System.Diagnostics.Debug.WriteLine($"[USBIP] Port {currentPort} desc: {currentDescription} ({currentVid}:{currentPid})");
                }
                
                // Check for usbip:// line
                var usbipMatch = usbipRegex.Match(line);
                if (usbipMatch.Success && currentPort >= 0)
                {
                    var serverIP = usbipMatch.Groups[1].Value;
                    var busId = usbipMatch.Groups[3].Value;
                    
                    System.Diagnostics.Debug.WriteLine($"[USBIP] Port {currentPort}: {serverIP} busId={busId}");
                    
                    devices.Add(new ConnectedDevice
                    {
                        Port = currentPort,
                        Status = "Connected",
                        ServerIP = serverIP,
                        BusId = busId,
                        Description = currentDescription,
                        VendorId = currentVid,
                        ProductId = currentPid
                    });
                    
                    currentPort = -1; // Reset for next port
                }
            }
            
            System.Diagnostics.Debug.WriteLine($"[USBIP] Total connected devices: {devices.Count}");
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[USBIP] Error getting connected: {ex.Message}");
        }
        
        return devices;
    }
    
    private async Task<string> RunCommandAsync(string arguments)
    {
        var psi = new ProcessStartInfo
        {
            FileName = _usbipPath,
            Arguments = arguments,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
            CreateNoWindow = true
        };
        
        using var process = Process.Start(psi);
        if (process == null) return "";
        
        var output = await process.StandardOutput.ReadToEndAsync();
        var error = await process.StandardError.ReadToEndAsync();
        await process.WaitForExitAsync();
        
        return string.IsNullOrEmpty(output) ? error : output;
    }
}

public class UsbDevice
{
    public string BusId { get; set; } = "";
    public string Vendor { get; set; } = "";
    public string Product { get; set; } = "";
    public string VendorId { get; set; } = "";
    public string ProductId { get; set; } = "";
    public string ServerIP { get; set; } = "";
    public string Description { get; set; } = "";
}

public class ConnectedDevice
{
    public int Port { get; set; }
    public string Status { get; set; } = "";
    public string ServerIP { get; set; } = "";
    public string BusId { get; set; } = "";
    public string Description { get; set; } = "";  // Device name from usbipw port output
    public string VendorId { get; set; } = "";
    public string ProductId { get; set; } = "";
}

public class OperationResult
{
    public bool Success { get; set; }
    public string? Error { get; set; }
}
