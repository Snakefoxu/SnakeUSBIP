using System.Diagnostics;
using System.Net.Sockets;
using System.Text.Json;

namespace SnakeUSBIP.Services;

/// <summary>
/// VPN service - Detect Tailscale/ZeroTier and get peers
/// Port from PowerShell Test-TailscaleInstalled / Test-ZeroTierInstalled / Get-TailscalePeers / Get-ZeroTierPeers / Test-USBIPOnPeer
/// </summary>
public class VpnService
{
    public bool IsTailscaleInstalled()
    {
        try
        {
            var psi = new ProcessStartInfo
            {
                FileName = "tailscale",
                Arguments = "--version",
                RedirectStandardOutput = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };
            using var process = Process.Start(psi);
            return process != null;
        }
        catch
        {
            return false;
        }
    }
    
    public bool IsZeroTierInstalled()
    {
        try
        {
            var psi = new ProcessStartInfo
            {
                FileName = "zerotier-cli",
                Arguments = "status",
                RedirectStandardOutput = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };
            using var process = Process.Start(psi);
            return process != null;
        }
        catch
        {
            return false;
        }
    }
    
    public async Task<List<VpnPeer>> GetTailscalePeersAsync()
    {
        var peers = new List<VpnPeer>();
        
        try
        {
            var psi = new ProcessStartInfo
            {
                FileName = "tailscale",
                Arguments = "status --json",
                RedirectStandardOutput = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };
            
            using var process = Process.Start(psi);
            if (process == null) return peers;
            
            var output = await process.StandardOutput.ReadToEndAsync();
            await process.WaitForExitAsync();
            
            if (process.ExitCode == 0 && !string.IsNullOrEmpty(output))
            {
                using var doc = JsonDocument.Parse(output);
                if (doc.RootElement.TryGetProperty("Peer", out var peerElement))
                {
                    foreach (var peer in peerElement.EnumerateObject())
                    {
                        var peerData = peer.Value;
                        var name = peerData.GetProperty("HostName").GetString() ?? "Unknown";
                        var ips = peerData.GetProperty("TailscaleIPs").EnumerateArray()
                            .Select(ip => ip.GetString())
                            .FirstOrDefault() ?? "";
                        var online = peerData.GetProperty("Online").GetBoolean();
                        
                        peers.Add(new VpnPeer
                        {
                            Name = name,
                            IP = ips,
                            Online = online,
                            Type = "Tailscale"
                        });
                    }
                }
            }
        }
        catch { }
        
        return peers;
    }
    
    public async Task<List<VpnPeer>> GetZeroTierPeersAsync()
    {
        var peers = new List<VpnPeer>();
        
        try
        {
            var psi = new ProcessStartInfo
            {
                FileName = "zerotier-cli",
                Arguments = "listnetworks -j",
                RedirectStandardOutput = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };
            
            using var process = Process.Start(psi);
            if (process == null) return peers;
            
            var output = await process.StandardOutput.ReadToEndAsync();
            await process.WaitForExitAsync();
            
            if (process.ExitCode == 0 && !string.IsNullOrEmpty(output))
            {
                using var doc = JsonDocument.Parse(output);
                foreach (var network in doc.RootElement.EnumerateArray())
                {
                    if (network.TryGetProperty("assignedAddresses", out var addresses))
                    {
                        var ip = addresses.EnumerateArray()
                            .Select(a => a.GetString()?.Split('/')[0])
                            .FirstOrDefault() ?? "";
                        
                        var name = network.TryGetProperty("name", out var nameEl) 
                            ? nameEl.GetString() ?? "ZeroTier Network" 
                            : "ZeroTier Network";
                        
                        peers.Add(new VpnPeer
                        {
                            Name = name,
                            IP = ip,
                            Online = true,
                            Type = "ZeroTier"
                        });
                    }
                }
            }
        }
        catch { }
        
        return peers;
    }
    
    public async Task<List<VpnPeer>> GetAllPeersAsync()
    {
        var allPeers = new List<VpnPeer>();
        
        if (IsTailscaleInstalled())
            allPeers.AddRange(await GetTailscalePeersAsync());
        
        if (IsZeroTierInstalled())
            allPeers.AddRange(await GetZeroTierPeersAsync());
        
        return allPeers;
    }
    
    public async Task<bool> TestUSBIPOnPeerAsync(string ip)
    {
        try
        {
            using var tcp = new TcpClient();
            var result = tcp.BeginConnect(ip, 3240, null, null);
            var success = result.AsyncWaitHandle.WaitOne(1000);
            tcp.Close();
            return success;
        }
        catch
        {
            return false;
        }
    }
}

public class VpnPeer
{
    public string Name { get; set; } = "";
    public string IP { get; set; } = "";
    public bool Online { get; set; }
    public string Type { get; set; } = "";
    public bool HasUSBIP { get; set; }
}
