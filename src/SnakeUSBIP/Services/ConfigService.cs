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
        var appData = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
        var appDir = Path.Combine(appData, "SnakeUSBIP");
        Directory.CreateDirectory(appDir);
        _configPath = Path.Combine(appDir, "config.json");
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
