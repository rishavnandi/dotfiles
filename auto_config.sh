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

echo "----------------Enter Unix Username----------------"
read user
sudo chown -R $user /home/$user

echo "----------------Setup Common Software----------------"
sudo apt update && sudo apt upgrade -y
sudo apt install build-essential software-properties-common neovim neofetch git curl wget unzip bat cmatrix icdiff speedtest-cli rename zsh dos2unix autojump openjdk-19-jdk -y

echo "----------------Setup Nitch----------------"
wget https://raw.githubusercontent.com/unxsh/nitch/main/setup.sh && sh setup.sh

echo "----------------Setup Bashrc----------------"
sudo cat bashrc > /home/$user/.bashrc
sudo dos2unix /home/$user/.bashrc


echo "----------------Disable Directory Highlights----------------"
dircolors -p | sed 's/;42/;01/' > /home/$user/.dircolors

echo "----------------Setup Starship For Bash----------------"
curl -sS https://starship.rs/install.sh | sh
if [ -d "/home/$user/.config/" ] 
then
    sudo cat linux_starship.toml > /home/$user/.config/starship.toml 
else
    sudo mkdir /home/$user/.config/ && sudo chown -R $user /home/$user/.config/ &&  sudo cat linux_starship.toml > /home/$user/.config/starship.toml
fi

echo "----------------Setup Fish Config----------------"
if [ -d "/home/$user/.config/fish/" ]
then
    sudo cat fish_config > /home/$user/.config/fish/config.fish
else
    sudo mkdir /home/$user/.config/fish/ && sudo chown -R $user /home/$user/.config/ && sudo cat fish_config > /home/$user/.config/fish/config.fish
fi

echo "----------------Setup PowerShell Profile----------------"

echo "----------------Enter Windows Username----------------"
read username
if [ -d "/mnt/c/Users/$username/Documents/WindowsPowerShell/" ] 
then
    sudo cat ps_profile.ps1 > /mnt/c/Users/$username/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1
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
sudo cat settings.json > /mnt/c/Users/$username/AppData/Local/Packages/Microsoft.WindowsTerminal*/LocalState/settings.json

echo "----------------Download QuickLook Plugins----------------"
cd /mnt/c/Users/$username/Downloads/
wget https://github.com/QL-Win/QuickLook.Plugin.EpubViewer/releases/download/1/QuickLook.Plugin.EpubViewer.qlplugin
wget https://github.com/QL-Win/QuickLook.Plugin.OfficeViewer/releases/download/4/QuickLook.Plugin.OfficeViewer.qlplugin
wget https://github.com/canheo136/QuickLook.Plugin.ApkViewer/releases/download/1.3.5/QuickLook.Plugin.ApkViewer.qlplugin
wget https://github.com/adyanth/QuickLook.Plugin.FolderViewer/releases/download/1.3/QuickLook.Plugin.FolderViewer.qlplugin
wget https://github.com/Cologler/QuickLook.Plugin.TorrentViewer/releases/download/0.2.0/QuickLook.Plugin.TorrentViewer.qlplugin
wget https://github.com/zhangkaihua88/QuickLook.Plugin.JupyterNotebookViewer/releases/download/1.0.1/QuickLook.Plugin.JupyterNotebookViewer.qlplugin

echo "----------------Download directx----------------"
wget https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe

echo "----------------Download Vagrant----------------"
wget https://releases.hashicorp.com/vagrant/2.3.7/vagrant_2.3.7_windows_amd64.msi

echo "----------------Download NerdFonts----------------"
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/FiraCode.zip

echo "----------------Download MSI Afterburner----------------"
wget https://files03.techspot.com/temp/MSIAfterburnerSetup465.exe

echo "----------------Download Choeazycopy----------------"
wget https://github.com/Cinchoo/ChoEazyCopy/releases/download/v2.0.0.2-beta3/ChoEazyCopy.zip

echo "----------------Download Throttlestop----------------"
wget https://us3-dl.techpowerup.com/files/kpsqeI_LDly4xnsjkigojg/1690101173/ThrottleStop_9.6.zip

echo "----------------Setup lsd For Ubuntu----------------"
cd /home/$user/
wget https://github.com/Peltoche/lsd/releases/download/0.23.1/lsd_0.23.1_amd64.deb
sudo apt install ./lsd_0.23.1_amd64.deb -y
rm lsd_0.23.1_amd64.deb

echo "----------------Setup Vagrant For Ubuntu----------------"
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
vagrant plugin install virtualbox_WSL2
vagrant plugin install vagrant-vbguest
vagrant autocomplete install --bash
vagrant autocomplete install --zsh

echo "----------------Setup Terraform For Ubuntu----------------"
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
terraform -install-autocomplete

echo "----------------Setup Ansible----------------"
sudo apt install python3-pip -y && pip3 install --upgrade pip && pip3 install --upgrade virtualenv
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

echo "----------------Download Titlebar Icons For Windows Terminal----------------"
cd /mnt/c/Users/$username/Pictures/ && mkdir icons && cd icons
wget -O ubuntu.png https://img.icons8.com/color/48/000000/ubuntu--v1.png
wget -O fedora.png https://img.icons8.com/fluency/48/000000/fedora.png
wget -O powershell.png https://img.icons8.com/color/48/000000/powershell.png
wget -O cmd.png https://img.icons8.com/color/48/000000/command-line.png

echo "----------------Setup Git----------------"
echo "----------------Enter First Name----------------"
read first
echo "----------------Enter Last Name----------------"
read last
echo "----------------Enter GitHub Email----------------"
read gitemail
git config --global user.name "$first $last"
git config --global user.email "$gitemail"
git config --global credential.helper store

echo "----------------Setup Zshrc----------------"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
if [ -d "/home/$user/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]
then
    echo "zsh-autosuggestions Already Installed"
else
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi
if [ -d "/home/$user/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]
then
    echo "zsh-syntax-highlighting Already Installed"
else
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi
sudo cat zshrc > /home/$user/.zshrc
sudo dos2unix /home/$user/.zshrc

echo "----------------Change Default Shell To Zsh----------------"
chsh -s /usr/bin/zsh
