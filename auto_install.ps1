# Improved PowerShell Auto Install Script
# Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

# Color functions
function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Cyan }
function Write-Warning { param($Message) Write-Host $Message -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host $Message -ForegroundColor Red }

Write-Host "                                                                                                    " -ForegroundColor Cyan
Write-Host " _____ _______       _____   _____ _    _ _____ _____    _____  _____   ____  __  __ _____ _______  " -ForegroundColor Cyan
Write-Host " / ____|__   __|/\   |  __ \ / ____| |  | |_   _|  __ \  |  __ \|  __ \ / __ \|  \/  |  __ \__   __|" -ForegroundColor Cyan
Write-Host "| (___    | |  /  \  | |__) | (___ | |__| | | | | |__) | | |__) | |__) | |  | | \  / | |__) | | |   " -ForegroundColor Cyan
Write-Host " \___ \   | | / /\ \ |  _  / \___ \|  __  | | | |  ___/  |  ___/|  _  /| |  | | |\/| |  ___/  | |   " -ForegroundColor Cyan
Write-Host " ____) |  | |/ ____ \| | \ \ ____) | |  | |_| |_| |      | |    | | \ \| |__| | |  | | |      | |   " -ForegroundColor Cyan
Write-Host "|_____/  _|_/_/ ___\_\_|__\_\_____/|_|_ |_|_____|_|______|_|    |_|  \_\\____/|_|  |_|_|      |_|   " -ForegroundColor Cyan
Write-Host "    /\  | |  | |__   __/ __ \  |_   _| \ | |/ ____|__   __|/\   | |    | |                          " -ForegroundColor Cyan
Write-Host "   /  \ | |  | |  | | | |  | |   | | |  \| | (___    | |  /  \  | |    | |                          " -ForegroundColor Cyan
Write-Host "  / /\ \| |  | |  | | | |  | |   | | | . ` |\___ \   | | / /\ \ | |    | |                          " -ForegroundColor Cyan
Write-Host " / ____ \ |__| |  | | | |__| |  _| |_| |\  |____) |  | |/ ____ \| |____| |____                      " -ForegroundColor Cyan
Write-Host "/_/    \_\____/   |_|  \____/  |_____|_| \_|_____/   |_/_/    \_\______|______|                     " -ForegroundColor Cyan
Write-Host "                                                                                                    " -ForegroundColor Cyan
Write-Host "----------------https://github.com/rishavnandi/Dotfiles----------------" -ForegroundColor Cyan

# Check if winget is available
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "Winget is not installed! Please install App Installer from Microsoft Store."
    exit 1
}

# Check if Scoop is installed
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Info "Installing Scoop..."
    try {
        iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
        Write-Success "Scoop installed successfully"
    }
    catch {
        Write-Error "Failed to install Scoop: $_"
    }
}
else {
    Write-Warning "Scoop already installed, skipping"
}

# Define all application IDs as an array with better organization
$essentialApps = @(
    "Microsoft.VCRedist.2015+.x64",
    "Microsoft.VCRedist.2015+.x86",
    "Microsoft.VCRedist.2013.x64",
    "Microsoft.VCRedist.2013.x86",
    "Microsoft.VCRedist.2012.x64",
    "Microsoft.VCRedist.2012.x86",
    "Microsoft.VCRedist.2010.x64",
    "Microsoft.VCRedist.2010.x86",
    "Microsoft.VCRedist.2008.x64",
    "Microsoft.VCRedist.2008.x86",
    "Microsoft.DotNet.Runtime.6",
    "Microsoft.DirectX"
)

$developmentApps = @(
    "Git.Git",
    "Microsoft.VisualStudioCode",
    "CoreyButler.NVMforWindows",
    "Python.Python.3.13",
    "Docker.DockerDesktop",
    "Hashicorp.Vagrant",
    "Microsoft.PowerShell",
    "Anaconda.Miniconda3"
)

$utilityApps = @(
    "7zip.7zip",
    "Notepad++.Notepad++",
    "chrisant996.Clink",
    "Starship.Starship",
    "Microsoft.PowerToys",
    "QL-Win.QuickLook",
    "Rufus.Rufus",
    "AntibodySoftware.WizTree",
    "SoftDeluxe.FreeDownloadManager",
    "Ventoy.Ventoy",
    "ShareX.ShareX",
    "Kopia.KopiaUI",
    "SaeraSoft.CaesiumImageCompressor",
    "WinSCP.WinSCP",
    "Iterate.Cyberduck",
    "ar51an.iPerf3",
    "garethgeorge.Backrest",
    "Genymobile.scrcpy",
    "KDE.KDEConnect"
)

$browserApps = @(
    "Google.Chrome",
    "Brave.Brave",
    "mortenn.BrowserPicker"
)

$communicationApps = @(
    "Zoom.Zoom",
    "Termius.Termius",
    "Telegram.Unigram",
    "Vencord.Vesktop"
)

$mediaApps = @(
    "VideoLAN.VLC",
    "Spotify.Spotify",
    "Google.QuickShare",
    "Google.GoogleDrive"
)

$gamingApps = @(
    "Valve.Steam",
    "EpicGames.EpicGamesLauncher",
    "Ubisoft.Connect",
    "WeMod.WeMod",
    "Guru3D.Afterburner",
    "Guru3D.RTSS"
)

$securityApps = @(
    "WireGuard.WireGuard",
    "Tailscale.Tailscale",
    "LedgerHQ.LedgerLive",
    "ente-io.auth-desktop"
)

$productivityApps = @(
    "Notion.Notion",
    "TradingView.TradingViewDesktop",
    "Microsoft.WindowsTerminal"
)

$systemApps = @(
    "Intel.IntelDriverAndSupportAssistant",
    "Oracle.VirtualBox",
    "Google.PlatformTools",
    "Gyan.FFMpeg"
)

# Combine all apps
$allApps = $essentialApps + $developmentApps + $utilityApps + $browserApps + `
           $communicationApps + $mediaApps + $gamingApps + $securityApps + `
           $productivityApps + $systemApps

# Function to check if an app is installed
function Test-AppInstalled {
    param($AppId)
    $result = winget list --id $AppId 2>&1
    return ($LASTEXITCODE -eq 0) -and ($result -match $AppId)
}

# Install apps with progress tracking
$totalApps = $allApps.Count
$currentApp = 0
$successCount = 0
$skipCount = 0
$failCount = 0

Write-Info "Starting installation of $totalApps applications..."

foreach ($app in $allApps) {
    $currentApp++
    $percentComplete = [math]::Round(($currentApp / $totalApps) * 100)
    Write-Progress -Activity "Installing Applications" -Status "Processing $app" -PercentComplete $percentComplete
    
    if (Test-AppInstalled $app) {
        Write-Warning "[$currentApp/$totalApps] $app already installed, skipping"
        $skipCount++
    }
    else {
        Write-Info "[$currentApp/$totalApps] Installing $app..."
        try {
            winget install -e --id $app --silent --accept-source-agreements --accept-package-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-Success "✓ $app installed successfully"
                $successCount++
            }
            else {
                Write-Warning "⚠ $app installation completed with warnings"
                $successCount++
            }
        }
        catch {
            Write-Error "✗ Failed to install ${app}: $_"
            $failCount++
        }
    }
}

Write-Progress -Activity "Installing Applications" -Completed

# Install apps without IDs
Write-Info "Installing MSI Center Pro..."
try {
    winget install --id "MSI Center Pro" --silent --accept-source-agreements --accept-package-agreements
    $successCount++
}
catch {
    Write-Warning "Failed to install MSI Center Pro: $_"
    $failCount++
}

# WhatsApp - using Store ID as it's the only reliable way to install via winget
Write-Info "Installing WhatsApp (9NKSQGP7F2NH)..."
try {
    winget install --id 9NKSQGP7F2NH --source msstore --silent --accept-source-agreements --accept-package-agreements
    $successCount++
}
catch {
    Write-Warning "Failed to install WhatsApp: $_"
    $failCount++
}

# Install Scoop packages
Write-Info "Installing Scoop packages..."
try {
    scoop install lsd
    scoop install winfetch
    Write-Success "Scoop packages installed"
}
catch {
    Write-Warning "Some Scoop packages failed to install: $_"
}

# Install Spicetify
if (!(Get-Command spicetify -ErrorAction SilentlyContinue)) {
    Write-Info "Installing Spicetify..."
    try {
        iwr -useb https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.ps1 | iex
        Write-Success "Spicetify installed successfully"
    }
    catch {
        Write-Error "Failed to install Spicetify: $_"
    }
}
else {
    Write-Warning "Spicetify already installed, skipping"
}

# Registry modifications
Write-Info "Applying registry modifications..."

# Restore Legacy Context Menu
try {
    $regPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
    if (!(Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    New-ItemProperty -Path $regPath -Name "(Default)" -Value "" -PropertyType String -Force | Out-Null
    Write-Success "Legacy context menu restored"
}
catch {
    Write-Error "Failed to restore legacy context menu: $_"
}

# Enable Dark Mode
try {
    $themePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    New-ItemProperty -Path $themePath -Name "AppsUseLightTheme" -Value 0 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $themePath -Name "SystemUsesLightTheme" -Value 0 -PropertyType DWORD -Force | Out-Null
    Write-Success "Dark mode enabled"
}
catch {
    Write-Error "Failed to enable dark mode: $_"
}

# Move Start Button To The Left
try {
    $explorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    New-ItemProperty -Path $explorerPath -Name "TaskbarAl" -Value 0 -PropertyType DWORD -Force | Out-Null
    Write-Success "Start button moved to left"
}
catch {
    Write-Error "Failed to move start button: $_"
}

# Change Explorer View Mode to Compact
try {
    $explorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    New-ItemProperty -Path $explorerPath -Name "UseCompactMode" -Value 1 -PropertyType DWORD -Force | Out-Null
    Write-Success "Compact view mode enabled"
}
catch {
    Write-Error "Failed to enable compact mode: $_"
}

# Set Explorer to Open This PC
try {
    $explorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    New-ItemProperty -Path $explorerPath -Name "LaunchTo" -Value 1 -PropertyType DWORD -Force | Out-Null
    Write-Success "Explorer set to open This PC"
}
catch {
    Write-Error "Failed to set Explorer default: $_"
}

# Show Hidden Files and Extensions
try {
    $explorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    New-ItemProperty -Path $explorerPath -Name "Hidden" -Value 1 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $explorerPath -Name "HideFileExt" -Value 0 -PropertyType DWORD -Force | Out-Null
    Write-Success "Hidden files and extensions enabled"
}
catch {
    Write-Error "Failed to show hidden files: $_"
}

# Disable Taskbar search box
try {
    $searchPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    Set-ItemProperty -Path $searchPath -Name "SearchboxTaskbarMode" -Value 0 -Type DWORD -Force | Out-Null
    Write-Success "Taskbar search box disabled"
}
catch {
    Write-Error "Failed to disable search box: $_"
}

# Power settings
Write-Info "Configuring power settings..."
try {
    powercfg -change -monitor-timeout-ac 0
    powercfg -change -standby-timeout-ac 0
    powercfg -h off
    Write-Success "Power settings configured"
}
catch {
    Write-Warning "Some power settings may not have been applied: $_"
}

# Restart Explorer
Write-Info "Restarting Explorer..."
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 2
Start-Process explorer

# Summary
Write-Host "`n========== INSTALLATION SUMMARY ==========" -ForegroundColor Cyan
Write-Success "Successfully installed: $successCount apps"
Write-Warning "Skipped (already installed): $skipCount apps"
if ($failCount -gt 0) {
    Write-Error "Failed: $failCount apps"
}
Write-Host "==========================================" -ForegroundColor Cyan

Write-Success "`nSetup completed! Please restart your computer to apply all changes."
