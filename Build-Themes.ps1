# Build Theme Variants Script
# Creates 5 different theme versions for testing

$projectPath = "d:\REPOS_GITHUB\SnakeUSBIP-WPF\src\SnakeUSBIP"
$mainWindowPath = Join-Path $projectPath "MainWindow.xaml.cs"
$outputDir = "d:\REPOS_GITHUB\SnakeUSBIP-WPF\release\themes"

# Create output directory
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

# Read original file
$originalContent = Get-Content $mainWindowPath -Raw

# Theme definitions - each theme has colors for dark mode
$themes = @{
    "1_FluentDark"     = @{
        BackgroundDark        = "#1F1F1F"
        BackgroundPanel       = "#2D2D2D"
        BackgroundTitleBar    = "#202020"
        BackgroundButton      = "#3D3D3D"
        BackgroundButtonHover = "#4D4D4D"
        BackgroundInput       = "#1F1F1F"
        ForegroundPrimary     = "#FFFFFF"
        ForegroundSecondary   = "#B3B3B3"
        AccentOrange          = "#FF8C00"
        AccentBlue            = "#0078D4"
        StatusSuccess         = "#6CCB5F"
        StatusInfo            = "#0078D4"
    }
    "2_GitHubDark"     = @{
        BackgroundDark        = "#0D1117"
        BackgroundPanel       = "#161B22"
        BackgroundTitleBar    = "#0D1117"
        BackgroundButton      = "#21262D"
        BackgroundButtonHover = "#30363D"
        BackgroundInput       = "#0D1117"
        ForegroundPrimary     = "#C9D1D9"
        ForegroundSecondary   = "#8B949E"
        AccentOrange          = "#F0883E"
        AccentBlue            = "#58A6FF"
        StatusSuccess         = "#3FB950"
        StatusInfo            = "#58A6FF"
    }
    "3_VSCodeDark"     = @{
        BackgroundDark        = "#1E1E1E"
        BackgroundPanel       = "#252526"
        BackgroundTitleBar    = "#1E1E1E"
        BackgroundButton      = "#3C3C3C"
        BackgroundButtonHover = "#505050"
        BackgroundInput       = "#1E1E1E"
        ForegroundPrimary     = "#D4D4D4"
        ForegroundSecondary   = "#808080"
        AccentOrange          = "#CE9178"
        AccentBlue            = "#569CD6"
        StatusSuccess         = "#6A9955"
        StatusInfo            = "#4EC9B0"
    }
    "4_SlatePro"       = @{
        BackgroundDark        = "#1E293B"
        BackgroundPanel       = "#0F172A"
        BackgroundTitleBar    = "#1E293B"
        BackgroundButton      = "#334155"
        BackgroundButtonHover = "#475569"
        BackgroundInput       = "#0F172A"
        ForegroundPrimary     = "#E2E8F0"
        ForegroundSecondary   = "#94A3B8"
        AccentOrange          = "#FB923C"
        AccentBlue            = "#38BDF8"
        StatusSuccess         = "#4ADE80"
        StatusInfo            = "#38BDF8"
    }
    "5_MidnightPurple" = @{
        BackgroundDark        = "#1A1625"
        BackgroundPanel       = "#13111C"
        BackgroundTitleBar    = "#1A1625"
        BackgroundButton      = "#2E2640"
        BackgroundButtonHover = "#3D3455"
        BackgroundInput       = "#13111C"
        ForegroundPrimary     = "#E9E9FF"
        ForegroundSecondary   = "#A5A1C2"
        AccentOrange          = "#F97316"
        AccentBlue            = "#A78BFA"
        StatusSuccess         = "#86EFAC"
        StatusInfo            = "#A78BFA"
    }
}

# Build each theme
foreach ($themeName in ($themes.Keys | Sort-Object)) {
    $theme = $themes[$themeName]
    
    Write-Host "Building $themeName..." -ForegroundColor Cyan
    
    # Create the dark theme code block
    $darkThemeCode = @"
            // Dark theme - $themeName
            resources["BackgroundDark"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("$($theme.BackgroundDark)"));
            resources["BackgroundPanel"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("$($theme.BackgroundPanel)"));
            resources["BackgroundTitleBar"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("$($theme.BackgroundTitleBar)"));
            resources["BackgroundButton"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("$($theme.BackgroundButton)"));
            resources["BackgroundButtonHover"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("$($theme.BackgroundButtonHover)"));
            resources["BackgroundInput"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("$($theme.BackgroundInput)"));
            resources["ForegroundPrimary"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("$($theme.ForegroundPrimary)"));
            resources["ForegroundSecondary"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("$($theme.ForegroundSecondary)"));
            resources["AccentOrange"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("$($theme.AccentOrange)"));
            resources["AccentBlue"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("$($theme.AccentBlue)"));
            resources["StatusSuccess"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("$($theme.StatusSuccess)"));
            resources["StatusInfo"] = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("$($theme.StatusInfo)"));
"@
    
    # Replace the dark theme section using regex
    $pattern = '(?s)// Dark theme.*?resources\["StatusInfo"\].*?;'
    $modifiedContent = $originalContent -replace $pattern, $darkThemeCode
    
    # Write modified file
    Set-Content -Path $mainWindowPath -Value $modifiedContent -NoNewline
    
    # Build
    $buildResult = dotnet publish "$projectPath\SnakeUSBIP.csproj" -c Release -r win-x64 --self-contained -o "$outputDir\$themeName" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ $themeName built successfully" -ForegroundColor Green
    }
    else {
        Write-Host "  ❌ $themeName build failed" -ForegroundColor Red
        Write-Host $buildResult
    }
}

# Restore original file
Set-Content -Path $mainWindowPath -Value $originalContent -NoNewline
Write-Host ""
Write-Host "✅ All theme builds complete!" -ForegroundColor Green
Write-Host "Themes are in: $outputDir" -ForegroundColor Yellow
Get-ChildItem $outputDir -Directory | ForEach-Object { Write-Host "  → $($_.Name)" }
