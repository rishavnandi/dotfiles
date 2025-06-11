Write-Host "                                                                                                    "
Write-Host " _____ _______       _____   _____ _    _ _____ _____    _____  _____   ____  __  __ _____ _______  "
Write-Host " / ____|__   __|/\   |  __ \ / ____| |  | |_   _|  __ \  |  __ \|  __ \ / __ \|  \/  |  __ \__   __|"
Write-Host "| (___    | |  /  \  | |__) | (___ | |__| | | | | |__) | | |__) | |__) | |  | | \  / | |__) | | |   "
Write-Host " \___ \   | | / /\ \ |  _  / \___ \|  __  | | | |  ___/  |  ___/|  _  /| |  | | |\/| |  ___/  | |   "
Write-Host " ____) |  | |/ ____ \| | \ \ ____) | |  | |_| |_| |      | |    | | \ \| |__| | |  | | |      | |   "
Write-Host "|_____/  _|_/_/ ___\_\_|__\_\_____/|_|_ |_|_____|_|______|_|    |_|  \_\\____/|_|  |_|_|      |_|   "
Write-Host "    /\  | |  | |__   __/ __ \  |_   _| \ | |/ ____|__   __|/\   | |    | |                          "
Write-Host "   /  \ | |  | |  | | | |  | |   | | |  \| | (___    | |  /  \  | |    | |                          "
Write-Host "  / /\ \| |  | |  | | | |  | |   | | | . ` |\___ \   | | / /\ \ | |    | |                          "
Write-Host " / ____ \ |__| |  | | | |__| |  _| |_| |\  |____) |  | |/ ____ \| |____| |____                      "
Write-Host "/_/    \_\____/   |_|  \____/  |_____|_| \_|_____/   |_/_/    \_\______|______|                     "
Write-Host "                                                                                                    "
Write-Host "----------------https://github.com/rishavnandi/Dotfiles----------------"

Write-Host "----------------Installing Scoop----------------"
iex "& {$(irm get.scoop.sh)} -RunAsAdmin"

Write-Host "----------------Installing All The Apps----------------"
# Define all application IDs as an array
$appIDs = @(
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
    "Microsoft.DirectX",
    "Spotify.Spotify",
    "7zip.7zip",
    "Git.Git",
    "VideoLAN.VLC",
    "Anaconda.Miniconda3",
    "AntibodySoftware.WizTree",
    "Notepad++.Notepad++",
    "chrisant996.Clink",
    "Google.Chrome",
    "WireGuard.WireGuard",
    "Oracle.VirtualBox",
    "Zoom.Zoom",
    "QL-Win.QuickLook",
    "Microsoft.VisualStudioCode",
    "Starship.Starship",
    "Rufus.Rufus",
    "Microsoft.PowerToys",
    "Notion.Notion",
    "EpicGames.EpicGamesLauncher",
    "Brave.Brave",
    "LedgerHQ.LedgerLive",
    "Ubisoft.Connect",
    "Valve.Steam",
    "Docker.DockerDesktop",
    "SoftDeluxe.FreeDownloadManager",
    "Hashicorp.Vagrant",
    "Iterate.Cyberduck",
    "Guru3D.Afterburner",
    "Guru3D.RTSS",
    "Google.QuickShare",
    "WinSCP.WinSCP",
    "Ventoy.Ventoy",
    "TradingView.TradingViewDesktop",
    "Termius.Termius",
    "CoreyButler.NVMforWindows",
    "Intel.IntelDriverAndSupportAssistant",
    "Python.Python.3.13",
    "Microsoft.WindowsTerminal",
    "Telegram.Unigram",
    "SaeraSoft.CaesiumImageCompressor",
    "Tailscale.Tailscale",
    "Google.PlatformTools",
    "Gyan.FFMpeg",
    "Vencord.Vesktop",
    "Kopia.KopiaUI",
    "ShareX.ShareX",
    "ente-io.auth-desktop",
    "Microsoft.PowerShell",
    "ar51an.iPerf3",
    "garethgeorge.Backrest",
    "Google.GoogleDrive",
    "WeMod.WeMod"
)

# Loop through each app and install it
foreach ($app in $appIDs) {
    Write-Host "Installing $app..."
    winget install -e --id $app
}

# Apps that dont have IDs
winget install "msi center pro"
winget install 9NKSQGP7F2NH
scoop install lsd
scoop install winfetch

Write-Host "----------------Installing Spicetify----------------"
iwr -useb https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.ps1 | iex

Write-Host "----------------Restore Legacy Context Menu----------------"
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve

Write-Host "----------------Enabling Dark Mode----------------"
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -PropertyType DWORD -Force
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -PropertyType DWORD -Force

Write-Host "----------------Move Start Button To The Left----------------"
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0 -PropertyType DWORD -Force

Write-Host "----------------Change Explorer View Mode to Compact----------------"
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "UseCompactMode" -Value 1 -PropertyType DWORD -Force

Write-Host "----------------Set Explorer to Open This PC----------------"
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1 -PropertyType DWORD -Force

Write-Host "----------------Show Hidden Files and Extensions----------------"
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -PropertyType DWORD -Force

Write-Host "----------------Set Screen to Never Turn Off----------------"
powercfg -change -monitor-timeout-ac 0

Write-Host "----------------Set Sleep Timeout to Never----------------"
powercfg -change -standby-timeout-ac 0

Write-Host "----------------Turn Hibernate Off----------------"
powercfg -h off

Write-Host "----------------Disable Taskbar search box----------------"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Type DWORD -Force

Write-Host "----------------Restarting Explorer----------------"
Stop-Process -Name explorer -Force
Start-Process explorer