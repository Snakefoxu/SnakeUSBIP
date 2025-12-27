using System.Diagnostics;
using System.IO;
using System.Windows;
using SnakeUSBIP.Services;

namespace SnakeUSBIP.Views;

public partial class SshDialog : Window
{
    private readonly LocalizationService _localization;
    private readonly string _language;
    
    public SshDialog(LocalizationService localization, string language, string serverIP)
    {
        InitializeComponent();
        
        _localization = localization;
        _language = language;
        
        txtIP.Text = serverIP;
        
        UpdateTexts();
    }
    
    private void UpdateTexts()
    {
        Title = _localization.GetText("ssh_title", _language);
        lblUser.Text = _localization.GetText("ssh_user", _language);
        btnConnect.Content = _localization.GetText("ssh_connect", _language);
        btnCopy.Content = _localization.GetText("ssh_copy", _language);
        btnClose.Content = _localization.GetText("ssh_close", _language);
        
        // Build instructions
        txtInstructions.Text = $"{_localization.GetText("ssh_instructions", _language)}\n\n" +
            $"{_localization.GetText("ssh_step1", _language)}\n" +
            "   sudo apt update\n" +
            "   sudo apt install usbip hwdata usbutils\n\n" +
            $"{_localization.GetText("ssh_step2", _language)}\n" +
            "   sudo modprobe usbip_host\n\n" +
            $"{_localization.GetText("ssh_step3", _language)}\n" +
            "   sudo usbipd\n\n" +
            $"{_localization.GetText("ssh_step4", _language)}\n" +
            "   usbip list -l\n\n" +
            $"{_localization.GetText("ssh_step5", _language)}\n" +
            "   sudo usbip bind -b 1-1.4\n\n" +
            $"{_localization.GetText("ssh_step6", _language)}\n" +
            "   modprobe usbip_host && usbipd -D";
    }
    
    private void BtnConnect_Click(object sender, RoutedEventArgs e)
    {
        var user = txtUser.Text.Trim();
        var ip = txtIP.Text.Trim();
        
        if (string.IsNullOrEmpty(user) || string.IsNullOrEmpty(ip))
            return;
        
        Close();
        
        try
        {
            // Try Windows Terminal first, then cmd
            var wtPath = Environment.GetEnvironmentVariable("LOCALAPPDATA") + @"\Microsoft\WindowsApps\wt.exe";
            if (File.Exists(wtPath))
            {
                Process.Start(new ProcessStartInfo
                {
                    FileName = "wt.exe",
                    Arguments = $"new-tab ssh {user}@{ip}",
                    UseShellExecute = true
                });
            }
            else
            {
                Process.Start(new ProcessStartInfo
                {
                    FileName = "cmd.exe",
                    Arguments = $"/c ssh {user}@{ip}",
                    UseShellExecute = true
                });
            }
        }
        catch { }
    }
    
    private void BtnCopy_Click(object sender, RoutedEventArgs e)
    {
        var commands = "sudo apt update && sudo apt install usbip hwdata usbutils && sudo modprobe usbip_host && sudo usbipd";
        System.Windows.Clipboard.SetText(commands);
        btnCopy.Content = "✓ Copied!";
    }
    
    private void BtnClose_Click(object sender, RoutedEventArgs e) => Close();
}
