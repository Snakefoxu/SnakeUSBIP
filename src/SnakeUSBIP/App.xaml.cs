using System.Threading;
using System.Windows;

namespace SnakeUSBIP;

/// <summary>
/// Interaction logic for App.xaml
/// Single instance enforcement using Mutex
/// </summary>
public partial class App : System.Windows.Application
{
    private static Mutex? _mutex;
    private const string MutexName = "SnakeUSBIP_SingleInstance_Mutex";

    protected override void OnStartup(StartupEventArgs e)
    {
        // Try to create mutex - if it already exists, another instance is running
        bool createdNew;
        _mutex = new Mutex(true, MutexName, out createdNew);

        if (!createdNew)
        {
            // Another instance is already running
            System.Windows.MessageBox.Show(
                "SnakeUSBIP ya está en ejecución.\nRevisa la bandeja del sistema.",
                "SnakeUSBIP",
                MessageBoxButton.OK,
                MessageBoxImage.Information);
            
            Shutdown();
            return;
        }

        base.OnStartup(e);
    }

    protected override void OnExit(ExitEventArgs e)
    {
        // Release mutex when app exits
        _mutex?.ReleaseMutex();
        _mutex?.Dispose();
        base.OnExit(e);
    }
}
