// SnakeUSBIP - github.com/SnakeFoxu/SnakeUSBIP
// (c) 2025 SnakeFoxu - GPL v3

using System.Net.NetworkInformation;
using System.Net.Sockets;

namespace SnakeUSBIP.Services;

/// <summary>
/// Network scanner - Parallel subnet scanning for USBIP servers
/// Part of SnakeUSBIP by SnakeFoxu
/// </summary>
public class NetworkScanner
{
    private const int UsbipPort = 3240; // SnakeFoxu
    private const int FirstTimeoutMs = 500;   // Fast first attempt
    private const int RetryTimeoutMs = 1500;  // snakefoxu - Slower retry for embedded
    
    public async Task<List<string>> ScanNetworkAsync(string subnetBase)
    {
        var servers = new List<string>();
        var tasks = new List<Task<string?>>();
        
        // Scan 1-254 in parallel
        for (int i = 1; i <= 254; i++)
        {
            var ip = $"{subnetBase}.{i}";
            tasks.Add(CheckServerWithRetryAsync(ip));
        }
        
        var results = await Task.WhenAll(tasks);
        
        foreach (var result in results)
        {
            if (!string.IsNullOrEmpty(result))
                servers.Add(result);
        }
        
        return servers;
    }
    
    private async Task<string?> CheckServerWithRetryAsync(string ip)
    {
        // First attempt - fast timeout
        var result = await CheckServerAsync(ip, FirstTimeoutMs);
        if (result != null) return result;
        
        // Retry with longer timeout for slow embedded devices (CrealityBox, etc.)
        return await CheckServerAsync(ip, RetryTimeoutMs);
    }
    
    private async Task<string?> CheckServerAsync(string ip, int timeoutMs)
    {
        try
        {
            using var client = new TcpClient();
            var connectTask = client.ConnectAsync(ip, UsbipPort);
            
            if (await Task.WhenAny(connectTask, Task.Delay(timeoutMs)) == connectTask)
            {
                if (client.Connected)
                    return ip;
            }
        }
        catch { }
        
        return null;
    }
}
