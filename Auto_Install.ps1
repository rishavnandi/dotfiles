Write-Host "                                                                                                                           "              
Write-Host "  _____  _____  _____ _    _     __      __  _   _          _   _ _____ _____                                              "
Write-Host " |  __ \|_   _|/ ____| |  | |   /\ \    / / | \ | |   /\   | \ | |  __ \_   _|                                             "
Write-Host " | |__) | | | | (___ | |__| |  /  \ \  / /  |  \| |  /  \  |  \| | |  | || |                                               "
Write-Host " |  _  /  | |  \___ \|  __  | / /\ \ \/ /   | . ` | / /\ \ | . ` | |  | || |                                               "
Write-Host " | | \ \ _| |_ ____) | |  | |/ ____ \  /    | |\  |/ ____ \| |\  | |__| || |_                                              "
Write-Host " |_|  \_\_____|_____/|_| _|_/_/  __\_\/_   _|_|_\_/_/____\_\_| \_|_____/_____|     _____  _____ _____  _____ _____ _______ "
Write-Host "     /\  | |  | |__   __/ __ \  |_   _| \ | |/ ____|__   __|/\   | |    | |       / ____|/ ____|  __ \|_   _|  __ \__   __|"
Write-Host "    /  \ | |  | |  | | | |  | |   | | |  \| | (___    | |  /  \  | |    | |      | (___ | |    | |__) | | | | |__) | | |   "
Write-Host "   / /\ \| |  | |  | | | |  | |   | | | . ` |\___ \   | | / /\ \ | |    | |       \___ \| |    |  _  /  | | |  ___/  | |   "
Write-Host "  / ____ \ |__| |  | | | |__| |  _| |_| |\  |____) |  | |/ ____ \| |____| |____   ____) | |____| | \ \ _| |_| |      | |   "
Write-Host " /_/    \_\____/   |_|  \____/  |_____|_| \_|_____/   |_/_/    \_\______|______| |_____/ \_____|_|  \_\_____|_|      |_|   "

Write-Host "Installing Scoop"
Set-ExecutionPolicy AllSigned
irm get.scoop.sh | iex

Write-Host "Add Required Buckets For All The Apps"
scoop bucket add main
scoop bucket add extras
scoop bucket add nerd-fonts
scoop bucket add starise_Scoop-Gaming https://github.com/starise/Scoop-Gaming
scoop bucket add anderlli0053_DEV-tools https://github.com/anderlli0053/DEV-tools
scoop bucket add nonportable

Write-Host "Installing All The Apps"
scoop install 7zip
scoop install git
scoop install vlc
scoop install freedownloadmanager
scoop install miniconda3
scoop install wemod
scoop install windirstat
scoop install notepadplusplus
scoop install clink
scoop install vcredist
scoop install googlechrome
scoop install wireguard-np
scoop install virtualbox-np
scoop install zoom
scoop install vagrant
scoop install vagrant-manager
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
