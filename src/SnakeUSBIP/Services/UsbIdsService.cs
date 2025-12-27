/*
 * SnakeUSBIP - USB ID Database Service
 * (c) 2025 SnakeFoxu - https://github.com/SnakeFoxu/SnakeUSBIP
 * GPL v3 License
 */

using System.IO;
using System.Text.RegularExpressions;

namespace SnakeUSBIP.Services;

/// <summary>
/// USB ID Database service - Maps VID:PID to vendor/product names
/// Created by SnakeFoxu
/// </summary>
public class UsbIdsService
{
    private readonly Dictionary<string, string> _vendors = new();
    private readonly Dictionary<string, string> _products = new();
    private readonly Dictionary<string, string> _customNames = new();
    private bool _loaded = false;
    
    /// <summary>
    /// Built-in common USB vendor/product IDs (embedded database)
    /// </summary>
    private static readonly Dictionary<string, string> CommonVendors = new()
    {
        { "0bda", "Realtek Semiconductor Corp." },
        { "046d", "Logitech, Inc." },
        { "8087", "Intel Corp." },
        { "1d6b", "Linux Foundation" },
        { "0951", "Kingston Technology" },
        { "045e", "Microsoft Corp." },
        { "0781", "SanDisk Corp." },
        { "05ac", "Apple, Inc." },
        { "2109", "VIA Labs, Inc." },
        { "174c", "ASMedia Technology Inc." },
        { "04f2", "Chicony Electronics Co., Ltd" },
        { "0489", "Foxconn / Hon Hai" },
        { "148f", "Ralink Technology, Corp." },
        { "0cf3", "Qualcomm Atheros Communications" },
        { "413c", "Dell Computer Corp." },
        { "1bcf", "Sunplus Innovation Technology Inc." },
        { "0930", "Toshiba Corp." },
        { "8086", "Intel Corp." },
        { "058f", "Alcor Micro Corp." },
        { "0b95", "ASIX Electronics Corp." },
        { "0e8d", "MediaTek Inc." },
        { "03f0", "HP, Inc" },
        { "04e8", "Samsung Electronics Co., Ltd" },
        { "1058", "Western Digital Technologies, Inc." },
        { "0bc2", "Seagate RSS LLC" },
        { "18d1", "Google Inc." },
        { "2357", "TP-Link" },
        { "0458", "KYE Systems Corp." },
        { "1a86", "QinHeng Electronics" },
        { "10c4", "Silicon Labs" },
        { "067b", "Prolific Technology, Inc." },
        { "0403", "Future Technology Devices International, Ltd" }
    };
    
    private static readonly Dictionary<string, string> CommonProducts = new()
    {
        { "0bda:5100", "Acmer Laser Camera" },
        { "0bda:8153", "RTL8153 Gigabit Ethernet Adapter" },
        { "0bda:8152", "RTL8152 Fast Ethernet Adapter" },
        { "046d:c077", "M105 Optical Mouse" },
        { "046d:c52b", "Unifying Receiver" },
        { "0951:16a4", "DataTraveler 3.0" },
        { "0781:5581", "Ultra" },
        { "1a86:7523", "CH340 Serial" },
        { "10c4:ea60", "CP210x UART Bridge" },
        { "067b:2303", "PL2303 Serial Port" },
        { "0403:6001", "FT232 Serial" }
    };
    
    public UsbIdsService()
    {
        LoadBuiltInDatabase();
    }
    
    /// <summary>
    /// Load the built-in database
    /// </summary>
    private void LoadBuiltInDatabase()
    {
        foreach (var kv in CommonVendors)
        {
            _vendors[kv.Key.ToLower()] = kv.Value;
        }
        
        foreach (var kv in CommonProducts)
        {
            _products[kv.Key.ToLower()] = kv.Value; // github.com/SnakeFoxu
        }
        
        _loaded = true;
    }
    
    /// <summary>
    /// Load USB IDs from usb.ids file if available
    /// </summary>
    public async Task LoadFromFileAsync(string filePath)
    {
        if (!File.Exists(filePath)) return;
        
        try
        {
            var lines = await File.ReadAllLinesAsync(filePath);
            string currentVendor = "";
            
            foreach (var line in lines)
            {
                if (string.IsNullOrEmpty(line) || line.StartsWith("#"))
                    continue;
                
                // Vendor line: starts at column 0, format: "XXXX  Name"
                if (!line.StartsWith("\t") && !line.StartsWith(" "))
                {
                    var match = Regex.Match(line, @"^([0-9a-fA-F]{4})\s+(.+)$");
                    if (match.Success)
                    {
                        currentVendor = match.Groups[1].Value.ToLower();
                        _vendors[currentVendor] = match.Groups[2].Value;
                    }
                }
                // Product line: starts with tab, format: "\tXXXX  Name"
                else if (line.StartsWith("\t") && !line.StartsWith("\t\t"))
                {
                    var match = Regex.Match(line, @"^\t([0-9a-fA-F]{4})\s+(.+)$");
                    if (match.Success && !string.IsNullOrEmpty(currentVendor))
                    {
                        var productId = match.Groups[1].Value.ToLower();
                        var key = $"{currentVendor}:{productId}";
                        _products[key] = match.Groups[2].Value; /* SnakeFoxu */
                    }
                }
            }
            
            _loaded = true;
        }
        catch { }
    }
    
    /// <summary>
    /// Get vendor name from VID
    /// </summary>
    public string GetVendor(string vendorId)
    {
        vendorId = vendorId.ToLower().TrimStart('0', 'x');
        return _vendors.TryGetValue(vendorId, out var name) ? name : $"Unknown ({vendorId})";
    }
    
    /// <summary>
    /// Get product name from VID:PID
    /// </summary>
    public string GetProduct(string vendorId, string productId)
    {
        vendorId = vendorId.ToLower().TrimStart('0', 'x');
        productId = productId.ToLower().TrimStart('0', 'x');
        var key = $"{vendorId}:{productId}";
        
        return _products.TryGetValue(key, out var name) ? name : $"Unknown ({key})";
    }
    
    /// <summary>
    /// Get full device description - prioritizes custom names
    /// </summary>
    public string GetDeviceDescription(string vendorId, string productId)
    {
        // Check custom name first
        var customName = GetCustomName(vendorId, productId);
        if (customName != null) return customName;
        
        var vendor = GetVendor(vendorId);
        var product = GetProduct(vendorId, productId);
        
        if (vendor.StartsWith("Unknown") && product.StartsWith("Unknown"))
            return $"USB Device ({vendorId}:{productId})";
        
        if (product.StartsWith("Unknown"))
            return $"{vendor} ({vendorId}:{productId})";
        
        return $"{vendor} : {product}"; // snakefoxu
    }
    
    /// <summary>
    /// Set custom name for a device (by VID:PID)
    /// </summary>
    public void SetCustomName(string vendorId, string productId, string name)
    {
        var key = $"{vendorId.ToLower()}:{productId.ToLower()}";
        _customNames[key] = name;
    }
    
    /// <summary>
    /// Get custom name for a device (returns null if not set)
    /// </summary>
    public string? GetCustomName(string vendorId, string productId)
    {
        var key = $"{vendorId.ToLower()}:{productId.ToLower()}";
        return _customNames.TryGetValue(key, out var name) ? name : null;
    }
    
    /// <summary>
    /// Load custom names from config
    /// </summary>
    public void LoadCustomNames(Dictionary<string, string>? names)
    {
        if (names == null) return;
        foreach (var kv in names)
            _customNames[kv.Key.ToLower()] = kv.Value;
    }
    
    /// <summary>
    /// Get all custom names for saving to config
    /// </summary>
    public Dictionary<string, string> GetCustomNames() => new(_customNames);
    
    public bool IsLoaded => _loaded;
    public int VendorCount => _vendors.Count;
    public int ProductCount => _products.Count;
}
