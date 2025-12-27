using System.Diagnostics;
using System.IO;

namespace SnakeUSBIP.Services;

/// <summary>
/// Driver service - Install/Uninstall USBIP drivers via pnputil
/// Port from PowerShell Install-Drivers / Uninstall-Drivers / Test-DriverStatus
/// </summary>
public class DriverService
{
    public DriverStatus CheckStatus()
    {
        try
        {
            // Check if usbip2_ude driver is installed
            var psi = new ProcessStartInfo
            {
                FileName = "pnputil",
                Arguments = "/enum-drivers",
                RedirectStandardOutput = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };
            
            using var process = Process.Start(psi);
            if (process == null) return new DriverStatus { Installed = false };
            
            var output = process.StandardOutput.ReadToEnd();
            process.WaitForExit();
            
            var installed = output.Contains("usbip2_ude", StringComparison.OrdinalIgnoreCase) ||
                           output.Contains("usbip_vhci", StringComparison.OrdinalIgnoreCase);
            
            return new DriverStatus 
            { 
                Installed = installed,
                Status = installed ? "Installed" : "Not installed"
            };
        }
        catch (Exception ex)
        {
            return new DriverStatus { Installed = false, Status = $"Error: {ex.Message}" };
        }
    }
    
    public async Task<OperationResult> InstallAsync()
    {
        try
        {
            var appDir = AppDomain.CurrentDomain.BaseDirectory;
            var driverDir = Path.Combine(appDir, "drivers");
            
            // Look for .inf files
            if (!Directory.Exists(driverDir))
                return new OperationResult { Success = false, Error = "Driver directory not found" };
            
            var infFiles = Directory.GetFiles(driverDir, "*.inf");
            if (infFiles.Length == 0)
                return new OperationResult { Success = false, Error = "No .inf files found" };
            
            foreach (var inf in infFiles)
            {
                var result = await RunPnpUtilAsync($"/add-driver \"{inf}\" /install");
                if (!result.Success)
                    return result;
            }
            
            return new OperationResult { Success = true };
        }
        catch (Exception ex)
        {
            return new OperationResult { Success = false, Error = ex.Message };
        }
    }
    
    public async Task<OperationResult> UninstallAsync()
    {
        try
        {
            // First, enumerate installed USB/IP drivers
            var psi = new ProcessStartInfo
            {
                FileName = "pnputil",
                Arguments = "/enum-drivers",
                RedirectStandardOutput = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };
            
            using var enumProcess = Process.Start(psi);
            if (enumProcess == null)
                return new OperationResult { Success = false, Error = "Failed to enumerate drivers" };
            
            var output = await enumProcess.StandardOutput.ReadToEndAsync();
            await enumProcess.WaitForExitAsync();
            
            // Find usbip/vhci driver OEM names using regex
            var matches = System.Text.RegularExpressions.Regex.Matches(output, @"(oem\d+\.inf)", System.Text.RegularExpressions.RegexOptions.IgnoreCase);
            var usbipDrivers = new List<string>();
            
            // Check each match to see if it's a usbip driver
            var blocks = output.Split(new[] { "Published name:", "Nombre publicado:" }, StringSplitOptions.RemoveEmptyEntries);
            foreach (var block in blocks)
            {
                if ((block.Contains("usbip", StringComparison.OrdinalIgnoreCase) || 
                     block.Contains("vhci", StringComparison.OrdinalIgnoreCase)) &&
                    System.Text.RegularExpressions.Regex.Match(block, @"(oem\d+\.inf)", System.Text.RegularExpressions.RegexOptions.IgnoreCase) is { Success: true } match)
                {
                    if (!usbipDrivers.Contains(match.Value))
                        usbipDrivers.Add(match.Value);
                }
            }
            
            if (usbipDrivers.Count == 0)
                return new OperationResult { Success = true }; // No drivers to uninstall
            
            // Uninstall each driver
            foreach (var driver in usbipDrivers)
            {
                await RunPnpUtilAsync($"/delete-driver {driver} /uninstall");
            }
            
            return new OperationResult { Success = true };
        }
        catch (Exception ex)
        {
            return new OperationResult { Success = false, Error = ex.Message };
        }
    }
    
    private async Task<OperationResult> RunPnpUtilAsync(string arguments)
    {
        var psi = new ProcessStartInfo
        {
            FileName = "pnputil",
            Arguments = arguments,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
            CreateNoWindow = true,
            Verb = "runas" // Request elevation
        };
        
        using var process = Process.Start(psi);
        if (process == null)
            return new OperationResult { Success = false, Error = "Failed to start pnputil" };
        
        var output = await process.StandardOutput.ReadToEndAsync();
        var error = await process.StandardError.ReadToEndAsync();
        await process.WaitForExitAsync();
        
        if (process.ExitCode != 0)
            return new OperationResult { Success = false, Error = error.Length > 0 ? error : output };
        
        return new OperationResult { Success = true };
    }
}

public class DriverStatus
{
    public bool Installed { get; set; }
    public string Status { get; set; } = "";
}
