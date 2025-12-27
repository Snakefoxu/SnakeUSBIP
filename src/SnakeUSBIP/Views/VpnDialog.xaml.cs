using System.Diagnostics;
using System.Windows;
using SnakeUSBIP.Services;

namespace SnakeUSBIP.Views;

public partial class VpnDialog : Window
{
    private readonly LocalizationService _localization;
    private readonly string _language;
    
    public VpnDialog(LocalizationService localization, string language)
    {
        InitializeComponent();
        
        _localization = localization;
        _language = language;
        
        UpdateTexts();
        CheckVpnStatus();
    }
    
    private void UpdateTexts()
    {
        Title = _localization.GetText("vpn_title", _language);
        lblStatus.Text = _localization.GetText("vpn_status", _language);
        lblPeers.Text = _localization.GetText("vpn_peers", _language);
        btnAddAll.Content = _localization.GetText("vpn_add_all", _language);
        btnConnect.Content = _localization.GetText("vpn_connect", _language);
        lblInfo.Text = _localization.GetText("vpn_info", _language);
    }
    
    private async void CheckVpnStatus()
    {
        lblStatusValue.Text = "Checking...";
        
        await Task.Run(() =>
        {
            try
            {
                // Check Tailscale
                var psi = new ProcessStartInfo
                {
                    FileName = "tailscale",
                    Arguments = "status --json",
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                };
                
                using var process = Process.Start(psi);
                if (process != null)
                {
                    var output = process.StandardOutput.ReadToEnd();
                    process.WaitForExit();
                    
                    if (process.ExitCode == 0 && !string.IsNullOrEmpty(output))
                    {
                        Dispatcher.Invoke(() =>
                        {
                            lblStatusValue.Text = "Tailscale " + _localization.GetText("vpn_online", _language);
                            lblStatusValue.Foreground = new System.Windows.Media.SolidColorBrush(
                                System.Windows.Media.Color.FromRgb(78, 201, 176));
                        });
                        return;
                    }
                }
            }
            catch { }
            
            try
            {
                // Check ZeroTier
                var psi = new ProcessStartInfo
                {
                    FileName = "zerotier-cli",
                    Arguments = "status",
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                };
                
                using var process = Process.Start(psi);
                if (process != null)
                {
                    var output = process.StandardOutput.ReadToEnd();
                    process.WaitForExit();
                    
                    if (output.Contains("ONLINE", StringComparison.OrdinalIgnoreCase))
                    {
                        Dispatcher.Invoke(() =>
                        {
                            lblStatusValue.Text = "ZeroTier " + _localization.GetText("vpn_online", _language);
                            lblStatusValue.Foreground = new System.Windows.Media.SolidColorBrush(
                                System.Windows.Media.Color.FromRgb(78, 201, 176));
                        });
                        return;
                    }
                }
            }
            catch { }
            
            Dispatcher.Invoke(() =>
            {
                lblStatusValue.Text = _localization.GetText("vpn_offline", _language);
                lblStatusValue.Foreground = new System.Windows.Media.SolidColorBrush(
                    System.Windows.Media.Color.FromRgb(255, 100, 100));
            });
        });
    }
    
    private void BtnTailscale_Click(object sender, RoutedEventArgs e)
    {
        Process.Start(new ProcessStartInfo
        {
            FileName = "https://tailscale.com/download",
            UseShellExecute = true
        });
    }
    
    private void BtnZeroTier_Click(object sender, RoutedEventArgs e)
    {
        Process.Start(new ProcessStartInfo
        {
            FileName = "https://www.zerotier.com/download/",
            UseShellExecute = true
        });
    }
    
    private void BtnAddAll_Click(object sender, RoutedEventArgs e)
    {
        // TODO: Add all peers to server list
        System.Windows.MessageBox.Show("Feature coming soon", "Info", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Information);
    }
    
    private void BtnConnect_Click(object sender, RoutedEventArgs e)
    {
        // TODO: Connect to selected peer
        Close();
    }
}
