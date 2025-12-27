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
            // Get installed driver OEM names
            var status = CheckStatus();
            if (!status.Installed)
                return new OperationResult { Success = true }; // Already uninstalled
            
            // Uninstall usbip drivers
            var result = await RunPnpUtilAsync("/delete-driver oem*.inf /uninstall /force");
            return result;
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
