using System.IO;
using System.Text.Json;

namespace SnakeUSBIP.Services;

/// <summary>
/// Configuration service - Load/Save app settings
/// Port from PowerShell Get-AppConfig / Save-AppConfig
/// </summary>
public class ConfigService
{
    private readonly string _configPath;
    
    public ConfigService()
    {
        try 
        {
            var appBaseDir = AppDomain.CurrentDomain.BaseDirectory;
            var portableMarker = Path.Combine(appBaseDir, ".portable");
            
            // Check if running in strict Portable Mode (marker file exists)
            if (File.Exists(portableMarker))
            {
                _configPath = Path.Combine(appBaseDir, "config.json");
            }
            else
            {
                // Standard Installed Mode uses AppData
                var appData = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
                var configDir = Path.Combine(appData, "SnakeUSBIP");
                
                if (!Directory.Exists(configDir))
                {
                    Directory.CreateDirectory(configDir);
                }
                
                _configPath = Path.Combine(configDir, "config.json");
            }
        }
        catch (Exception ex)
        {
            // Fail-safe logic: attempt AppData if something critical fails, 
            // or if we catch an exception, try to use a default safe path.
            System.Diagnostics.Debug.WriteLine($"[ConfigService] Path init error: {ex.Message}");
            var appData = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
            _configPath = Path.Combine(appData, "SnakeUSBIP", "config.json");
        }
    }
    
    public AppConfig Load()
    {
        try
        {
            if (File.Exists(_configPath))
            {
                var json = File.ReadAllText(_configPath);
                return JsonSerializer.Deserialize<AppConfig>(json) ?? new AppConfig();
            }
        }
        catch { }
        
        // Default config with system language detection
        var systemLang = System.Globalization.CultureInfo.CurrentCulture.TwoLetterISOLanguageName;
        return new AppConfig
        {
            Language = systemLang == "es" ? "es" : "en",
            Theme = "dark"
        };
    }
    
    public void Save(AppConfig config)
    {
        try
        {
            var json = JsonSerializer.Serialize(config, new JsonSerializerOptions { WriteIndented = true });
            File.WriteAllText(_configPath, json);
        }
        catch { }
    }
    
    public void SetLanguage(string language)
    {
        var config = Load();
        config.Language = language;
        Save(config);
    }
}

public class AppConfig
{
    public string? Language { get; set; }
    public string? Theme { get; set; }
    public string? LastServerIP { get; set; }
    public List<FavoriteDevice>? Favorites { get; set; }
    public bool AutoReconnect { get; set; } = true;
    public Dictionary<string, string>? CustomDeviceNames { get; set; }
}

public class FavoriteDevice
{
    public string ServerIP { get; set; } = "";
    public string BusId { get; set; } = "";
    public string Description { get; set; } = "";
    public bool AutoConnect { get; set; } = true;
    public string AddedDate { get; set; } = "";
}
