using System.IO;
using System.Net.Http;
using System.Text.Json;

namespace SnakeUSBIP.Services;

/// <summary>
/// Update service - Check for updates against GitHub releases
/// Port from PowerShell Check-ForUpdates / Start-Update
/// </summary>
public class UpdateService
{
    private const string GITHUB_REPO = "Snakefoxu/SnakeUSBIP";
    private static readonly string APP_VERSION = System.Reflection.Assembly.GetExecutingAssembly()
        .GetName().Version?.ToString(3) ?? "2.0.0";
    
    public async Task<UpdateInfo> CheckForUpdatesAsync()
    {
        try
        {
            using var client = new HttpClient();
            client.DefaultRequestHeaders.Add("User-Agent", "SnakeUSBIP-WPF");
            
            var apiUrl = $"https://api.github.com/repos/{GITHUB_REPO}/releases/latest";
            System.Diagnostics.Debug.WriteLine($"[UPDATE] API URL: {apiUrl}");
            System.Diagnostics.Debug.WriteLine($"[UPDATE] Current APP_VERSION: {APP_VERSION}");
            
            var response = await client.GetStringAsync(apiUrl);
            System.Diagnostics.Debug.WriteLine($"[UPDATE] Response length: {response.Length}");
            
            var release = JsonSerializer.Deserialize<GitHubRelease>(response, new JsonSerializerOptions 
            { 
                PropertyNameCaseInsensitive = true 
            });
            
            if (release == null)
            {
                System.Diagnostics.Debug.WriteLine("[UPDATE] Release is null!");
                return new UpdateInfo { UpdateAvailable = false };
            }
            
            System.Diagnostics.Debug.WriteLine($"[UPDATE] TagName from GitHub: {release.TagName}");
            System.Diagnostics.Debug.WriteLine($"[UPDATE] Assets count: {release.Assets?.Count ?? 0}");
            
            var latestVersion = release.TagName?.TrimStart('v') ?? "0.0.0";
            var currentVersion = APP_VERSION;
            
            System.Diagnostics.Debug.WriteLine($"[UPDATE] Latest version parsed: {latestVersion}");
            System.Diagnostics.Debug.WriteLine($"[UPDATE] Current version: {currentVersion}");
            
            var canParseLatest = Version.TryParse(latestVersion, out var latest);
            var canParseCurrent = Version.TryParse(currentVersion, out var current);
            
            System.Diagnostics.Debug.WriteLine($"[UPDATE] Can parse latest: {canParseLatest}, value: {latest}");
            System.Diagnostics.Debug.WriteLine($"[UPDATE] Can parse current: {canParseCurrent}, value: {current}");
            
            if (canParseLatest && canParseCurrent)
            {
                System.Diagnostics.Debug.WriteLine($"[UPDATE] Comparison: {latest} > {current} = {latest > current}");
            }
            
            if (canParseLatest && canParseCurrent && latest > current)
            {
                // Find installer in assets
                var installerAsset = release.Assets?.FirstOrDefault(a => 
                    a.Name?.Contains("Setup", StringComparison.OrdinalIgnoreCase) == true &&
                    a.Name?.EndsWith(".exe", StringComparison.OrdinalIgnoreCase) == true);
                
                System.Diagnostics.Debug.WriteLine($"[UPDATE] Installer found: {installerAsset?.Name}");
                
                return new UpdateInfo
                {
                    UpdateAvailable = true,
                    LatestVersion = latestVersion,
                    CurrentVersion = currentVersion,
                    DownloadUrl = installerAsset?.BrowserDownloadUrl,
                    InstallerName = installerAsset?.Name,
                    ReleaseNotes = release.Body
                };
            }
            
            System.Diagnostics.Debug.WriteLine("[UPDATE] No update available");
            return new UpdateInfo
            {
                UpdateAvailable = false,
                LatestVersion = latestVersion,
                CurrentVersion = currentVersion
            };
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[UPDATE] Error: {ex.Message}");
            return new UpdateInfo
            {
                UpdateAvailable = false,
                Error = ex.Message
            };
        }
    }
    
    public async Task<OperationResult> StartUpdateAsync(string downloadUrl, string installerName)
    {
        try
        {
            // === SECURITY VALIDATION ===
            // Only allow downloads from official GitHub releases
            if (string.IsNullOrEmpty(downloadUrl) || string.IsNullOrEmpty(installerName))
                return new OperationResult { Success = false, Error = "Invalid download parameters" };
            
            // Validate URL is from trusted GitHub domain
            if (!Uri.TryCreate(downloadUrl, UriKind.Absolute, out var uri))
                return new OperationResult { Success = false, Error = "Invalid download URL format" };
            
            var allowedHosts = new[] { "github.com", "objects.githubusercontent.com", "github-releases.githubusercontent.com" };
            if (!allowedHosts.Any(h => uri.Host.EndsWith(h, StringComparison.OrdinalIgnoreCase)))
                return new OperationResult { Success = false, Error = $"Untrusted download host: {uri.Host}" };
            
            // Validate installer name (prevent path traversal)
            if (installerName.Contains("..") || installerName.Contains("/") || installerName.Contains("\\"))
                return new OperationResult { Success = false, Error = "Invalid installer name" };
            
            // Validate extension
            if (!installerName.EndsWith(".exe", StringComparison.OrdinalIgnoreCase))
                return new OperationResult { Success = false, Error = "Installer must be an .exe file" };
            // === END SECURITY VALIDATION ===
            
            using var client = new HttpClient();
            var tempDir = Path.GetTempPath();
            var installerPath = Path.Combine(tempDir, installerName);
            
            // Download installer
            var data = await client.GetByteArrayAsync(downloadUrl);
            await File.WriteAllBytesAsync(installerPath, data);
            
            if (File.Exists(installerPath))
            {
                // Run installer and exit app
                System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
                {
                    FileName = installerPath,
                    UseShellExecute = true,
                    Verb = "runas"
                });
                
                // Exit current app
                System.Windows.Application.Current.Shutdown();
                
                return new OperationResult { Success = true };
            }
            
            return new OperationResult { Success = false, Error = "Could not download installer" };
        }
        catch (Exception ex)
        {
            return new OperationResult { Success = false, Error = ex.Message };
        }
    }

}

public class UpdateInfo
{
    public bool UpdateAvailable { get; set; }
    public string LatestVersion { get; set; } = "";
    public string CurrentVersion { get; set; } = "";
    public string? DownloadUrl { get; set; }
    public string? InstallerName { get; set; }
    public string? ReleaseNotes { get; set; }
    public string? Error { get; set; }
}

public class GitHubRelease
{
    [System.Text.Json.Serialization.JsonPropertyName("tag_name")]
    public string? TagName { get; set; }
    
    [System.Text.Json.Serialization.JsonPropertyName("body")]
    public string? Body { get; set; }
    
    [System.Text.Json.Serialization.JsonPropertyName("assets")]
    public List<GitHubAsset>? Assets { get; set; }
}

public class GitHubAsset
{
    [System.Text.Json.Serialization.JsonPropertyName("name")]
    public string? Name { get; set; }
    
    [System.Text.Json.Serialization.JsonPropertyName("browser_download_url")]
    public string? BrowserDownloadUrl { get; set; }
}
