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

Write-Host "----------------Add Required Buckets For All The Apps----------------"
scoop install git
scoop bucket add main
scoop bucket add extras
scoop bucket add nerd-fonts
scoop bucket add starise_Scoop-Gaming https://github.com/starise/Scoop-Gaming
scoop bucket add anderlli0053_DEV-tools https://github.com/anderlli0053/DEV-tools
scoop bucket add nonportable

Write-Host "----------------Installing All The Apps----------------"
scoop install 7zip
scoop install git
scoop install vlc
scoop install freedownloadmanager
scoop install miniconda3
scoop install wemod
scoop install windirstat
scoop install notepadplusplus
scoop install clink
scoop install vcredist2013
scoop uninstall vcredist2013
scoop install vcredist2022
scoop uninstall vcredist2022
scoop install googlechrome
scoop install wireguard-np
scoop install virtualbox-np
scoop install zoom
scoop install vagrant
scoop install quicklook
scoop install msiafterburner
scoop install obsidian
scoop install vscode
scoop install whatsapp
scoop install telegram
scoop install lsd
scoop install winfetch
scoop install starship
scoop install FiraCode-NF
scoop install rufus
scoop install powertoys

Write-Host "----------------Restore Legacy Context Menu----------------"
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
