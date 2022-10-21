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

echo "----------------https://github.com/rishavnandi/Dotfiles----------------"

echo "----------------Make Sure User Has Ownership Of All Files----------------"
echo "----------------Enter Unix Username----------------"
read user
sudo chown -R "$user" .

echo "----------------Setup Common Software----------------"
sudo apt update && sudo apt upgrade -y
sudo apt install build-essential software-properties-common neovim neofetch git curl wget -y

echo "----------------Setup Bashrc----------------"
echo "----------------Enter Unix Username----------------"
sudo cat bashrc > /home/$user/.bashrc
sudo apt install dos2unix
sudo dos2unix /home/$user/.bashrc
echo "----------------Disable Directory Highlights----------------"
dircolors -p | sed 's/;42/;01/' > /home/$user/.dircolors

echo "----------------Setup Starship For Bash----------------"
curl -sS https://starship.rs/install.sh | sh
if [ -d "/home/$user/.config/" ] 
then
    sudo cat linux_starship.toml > /home/$user/.config/starship.toml 
else
    sudo mkdir /home/$user/.config/ && sudo cat linux_starship.toml > /home/$user/.config/starship.toml
fi

echo "----------------Setup PowerShell Profile----------------"
echo "----------------Enter Windows Username----------------"
read username
if [ -d "/mnt/c/Users/$username/Documents/WindowsPowerShell/" ] 
then
    sudo cat ps_profile.ps1 > /mnt/c/Users/$username/Documents/PowerShell/Microsoft.PowerShell_profile.ps1
else
    sudo mkdir /mnt/c/Users/$username/Documents/WindowsPowerShell/ && sudo cat ps_profile.ps1 > /mnt/c/Users/$username/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1
fi

if [ -d "/mnt/c/Users/$username/.starship/" ]
then
    sudo cat win_starship.toml > /mnt/c/Users/$username/.starship/starship.toml
else
    sudo mkdir /mnt/c/Users/$username/.starship/ && sudo cat win_starship.toml > /mnt/c/Users/$username/.starship/starship.toml
fi

if [ -d "/mnt/c/Users/$username/.config/winfetch/" ]
then
    sudo cat winfetch.ps1 > /mnt/c/Users/$username/.config/winfetch/config.ps1
else
    sudo mkdir /mnt/c/Users/$username/.config/winfetch/ && sudo cat winfetch.ps1 > /mnt/c/Users/$username/.config/winfetch/config.ps1
fi

echo "----------------Setup Command Prompt----------------"
sudo cat starship.lua > /mnt/c/Users/$username/AppData/Local/clink/starship.lua

echo "----------------Setup Windows Terminal----------------"
cd /mnt/c/Users/$username/AppData/Local/Packages/
terminal_folder=$(ls | grep Terminal)
sudo cat settings.json > /mnt/c/Users/$username/AppData/Local/Packages/$terminal_folder/LocalState/settings.json

echo "----------------Download QuickLook Plugins----------------"
cd /mnt/c/Users/$username/Downloads/
wget https://github.com/QL-Win/QuickLook.Plugin.EpubViewer/releases/download/1/QuickLook.Plugin.EpubViewer.qlplugin
wget https://github.com/QL-Win/QuickLook.Plugin.OfficeViewer/releases/download/4/QuickLook.Plugin.OfficeViewer.qlplugin
wget https://github.com/canheo136/QuickLook.Plugin.ApkViewer/releases/download/1.3.4/QuickLook.Plugin.ApkViewer.qlplugin
wget https://github.com/adyanth/QuickLook.Plugin.FolderViewer/releases/download/1.3/QuickLook.Plugin.FolderViewer.qlplugin
wget https://github.com/Cologler/QuickLook.Plugin.TorrentViewer/releases/download/0.1.0/QuickLook.Plugin.TorrentViewer.qlplugin
wget https://github.com/zhangkaihua88/QuickLook.Plugin.JupyterNotebookViewer/releases/download/1.0.1/QuickLook.Plugin.JupyterNotebookViewer.qlplugin

echo "----------------Download dotnet----------------"
wget https://download.visualstudio.microsoft.com/download/pr/a6e878eb-d1da-40cb-8b6a-7f5b9390f09c/e4431ce2aa28b6c9956db672209be500/windowsdesktop-runtime-6.0.10-win-x64.exe

echo "----------------Download directx----------------"
wget https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe

echo "----------------Download FxSound----------------"
wget -O fxsound.exe https://download.fxsound.com/fxsoundlatest

echo "----------------Download NerdFonts----------------"
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/FiraMono.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/FiraCode.zip

echo "----------------Setup lsd For Ubuntu----------------"
cd /home/$user/
wget https://github.com/Peltoche/lsd/releases/download/0.23.1/lsd_0.23.1_amd64.deb
sudo apt install ./lsd_0.23.1_amd64.deb -y
rm lsd_0.23.1_amd64.deb

echo "----------------Setup Vagrant For Ubuntu----------------"
cd /home/$user/
wget https://releases.hashicorp.com/vagrant/2.3.2/vagrant_2.3.2-1_amd64.deb
sudo apt install ./vagrant_2.3.2-1_amd64.deb -y
rm vagrant_2.3.2-1_amd64.deb
vagrant plugin install virtualbox_WSL2
vagrant plugin install vagrant-vbguest
vagrant autocomplete install --bash

echo "----------------Setup Terraform For Ubuntu----------------"
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common 
wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform -y
terraform -install-autocomplete

echo "----------------Setup pip----------------"
sudo apt install python3-pip -y

echo "----------------Setup Ansible----------------"
pip3 install ansible
pip3 install ansible-lint

echo "----------------Enable hushlogin----------------"
touch /home/$user/.hushlogin

echo "----------------Download Anaconda Icon For Windows Terminal----------------"
if [ -d "/mnt/c/Users/$username/miniconda3/" ]
then
    cd /mnt/c/Users/$username/miniconda3/ && wget -O anaconda.png https://img.icons8.com/fluency/48/000000/anaconda--v2.png
else
    echo "Miniconda Not Installed"
fi


echo "----------------Setup Git----------------"
echo "----------------Enter First Name----------------"
read first
echo "----------------Enter Last Name----------------"
read last
echo "----------------Enter GitHub Email----------------"
read gitemail
git config --global user.name "$first $last"
git config --global user.email "$gitemail"
