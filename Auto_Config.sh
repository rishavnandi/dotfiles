#!/bin/bash

echo "
███████╗████████╗ █████╗ ██████╗ ███████╗██╗  ██╗██╗██████╗     ██████╗ ██████╗  ██████╗ ███╗   ███╗██████╗ ████████╗
██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██║  ██║██║██╔══██╗    ██╔══██╗██╔══██╗██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝
███████╗   ██║   ███████║██████╔╝███████╗███████║██║██████╔╝    ██████╔╝██████╔╝██║   ██║██╔████╔██║██████╔╝   ██║   
╚════██║   ██║   ██╔══██║██╔══██╗╚════██║██╔══██║██║██╔═══╝     ██╔═══╝ ██╔══██╗██║   ██║██║╚██╔╝██║██╔═══╝    ██║   
███████║   ██║   ██║  ██║██║  ██║███████║██║  ██║██║██║         ██║     ██║  ██║╚██████╔╝██║ ╚═╝ ██║██║        ██║   
╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝         ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝        ╚═╝   

 █████╗ ██╗   ██╗████████╗ ██████╗     ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗                             
██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║                             
███████║██║   ██║   ██║   ██║   ██║    ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║                             
██╔══██║██║   ██║   ██║   ██║   ██║    ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║                             
██║  ██║╚██████╔╝   ██║   ╚██████╔╝    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗                        
╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝     ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝"                        

echo "----------------Setup Bashrc----------------"
echo "----------------Enter Unix Username----------------"
read user
cat bashrc > /home/$user/.bashrc
dircolors -p | sed 's/;42/;01/' > /home/$user/.dircolors

echo "----------------Setup Starship For Bash----------------"
curl -sS https://starship.rs/install.sh | sh
if [ -d "/home/$user/.config/" ] 
then
    cat starship.toml > /home/$user/.config/starship.toml 
else
    mkdir /home/$user/.config/ && cat starship.toml > /home/$user/.config/starship.toml
fi

echo "----------------Setup PowerShell Profile----------------"

echo "----------------Enter Windows Username----------------"
read username
if [ -d "/mnt/c/Users/$username/Documents/PowerShell/" ] 
then
    cat ps_profile.ps1 > /mnt/c/Users/$username/Documents/PowerShell/Microsoft.PowerShell_profile.ps1
else
    mkdir /mnt/c/Users/$username/Documents/PowerShell/ && cat ps_profile.ps1 > /mnt/c/Users/$username/Documents/PowerShell/Microsoft.PowerShell_profile.ps1
fi

if [ -d "/mnt/c/Users/$username/.starship/" ]
then
    cat starship.toml > /mnt/c/Users/$username/.starship/starship.toml
else
    mkdir /mnt/c/Users/$username/.starship/ && cat starship.toml > /mnt/c/Users/$username/.starship/starship.toml
fi

if [ -d "/mnt/c/Users/$username/.config/winfetch/" ]
then
    cat winfetch.ps1 > /mnt/c/Users/$username/.config/winfetch/winfetch.ps1
else
    mkdir /mnt/c/Users/$username/.config/winfetch/ && cat winfetch.ps1 > /mnt/c/Users/$username/.config/winfetch/winfetch.ps1
fi

echo "----------------Setup Command Prompt----------------"
cat starship.lua > /mnt/c/Users/$username/AppData/Local/clink/starship.lua

echo "----------------Setup Windows Terminal----------------"
terminal_folder=$(ls | grep Terminal)
cat settings.json > /mnt/c/Users/$username/AppData/Local/Packages/$terminal_folder/LocalState/settings.json
