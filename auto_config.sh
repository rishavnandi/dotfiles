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
sudo apt install build-essential software-properties-common gnupg nano git curl wget unzip bat rename zsh dos2unix autojump openjdk-24-jdk ca-certificates apt-transport-https -y

echo "----------------Setup Nitch----------------"
wget https://raw.githubusercontent.com/unxsh/nitch/main/setup.sh && sh setup.sh

echo "----------------Disable Directory Highlights----------------"
dircolors -p | sed 's/;42/;01/' >/home/$user/.dircolors

echo "----------------Setup Starship For Bash----------------"
curl -sS https://starship.rs/install.sh | sh
if [ -d "/home/$user/.config/" ]; then
    sudo cat linux_starship.toml >/home/$user/.config/starship.toml
else
    sudo mkdir /home/$user/.config/ && sudo chown -R $user /home/$user/.config/ && sudo cat linux_starship.toml >/home/$user/.config/starship.toml
fi

echo "----------------Setup PowerShell Profile----------------"

echo "----------------Enter Windows Username----------------"
read username
if [ -d "/mnt/c/Users/$username/Documents/WindowsPowerShell/" ]; then
    sudo cat ps_profile.ps1 >/mnt/c/Users/$username/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1
else
    sudo mkdir /mnt/c/Users/$username/Documents/WindowsPowerShell/ && sudo cat ps_profile.ps1 >/mnt/c/Users/$username/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1
fi

if [ -d "/mnt/c/Users/$username/Documents/PowerShell/" ]; then
    sudo cat ps_profile.ps1 >/mnt/c/Users/$username/Documents/PowerShell/Microsoft.PowerShell_profile.ps1
else
    sudo mkdir /mnt/c/Users/$username/Documents/PowerShell/ && sudo cat ps_profile.ps1 >/mnt/c/Users/$username/Documents/PowerShell/Microsoft.PowerShell_profile.ps1
fi

if [ -d "/mnt/c/Users/$username/.starship/" ]; then
    sudo cat win_starship.toml >/mnt/c/Users/$username/.starship/starship.toml
else
    sudo mkdir /mnt/c/Users/$username/.starship/ && sudo cat win_starship.toml >/mnt/c/Users/$username/.starship/starship.toml
fi

if [ -d "/mnt/c/Users/$username/.config/winfetch/" ]; then
    sudo cat winfetch.ps1 >/mnt/c/Users/$username/.config/winfetch/config.ps1
else
    sudo mkdir /mnt/c/Users/$username/.config/winfetch/ && sudo cat winfetch.ps1 >/mnt/c/Users/$username/.config/winfetch/config.ps1
fi

echo "----------------Setup Command Prompt----------------"
sudo cat starship.lua >/mnt/c/Users/$username/AppData/Local/clink/starship.lua

echo "----------------Setup Windows Terminal----------------"
sudo cat settings.json >/mnt/c/Users/$username/AppData/Local/Packages/Microsoft.WindowsTerminal*/LocalState/settings.json

echo "----------------Download QuickLook Plugins----------------"
cd /mnt/c/Users/$username/Downloads/
wget https://github.com/QL-Win/QuickLook.Plugin.EpubViewer/releases/download/1/QuickLook.Plugin.EpubViewer.qlplugin
wget https://github.com/QL-Win/QuickLook.Plugin.OfficeViewer/releases/download/4/QuickLook.Plugin.OfficeViewer.qlplugin
wget https://github.com/canheo136/QuickLook.Plugin.ApkViewer/releases/download/1.3.5/QuickLook.Plugin.ApkViewer.qlplugin
wget https://github.com/adyanth/QuickLook.Plugin.FolderViewer/releases/download/1.3/QuickLook.Plugin.FolderViewer.qlplugin
wget https://github.com/Cologler/QuickLook.Plugin.TorrentViewer/releases/download/0.2.2/QuickLook.Plugin.TorrentViewer.qlplugin
wget https://github.com/zhangkaihua88/QuickLook.Plugin.JupyterNotebookViewer/releases/download/1.0.1/QuickLook.Plugin.JupyterNotebookViewer.qlplugin

# echo "----------------Download Vagrant----------------"
# wget https://releases.hashicorp.com/vagrant/2.4.3/vagrant_2.4.3_windows_amd64.msi

echo "----------------Download NerdFonts----------------"
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/FiraCode.zip

echo "----------------Download Choeazycopy----------------"
wget https://github.com/Cinchoo/ChoEazyCopy/releases/download/v2.0.0.3/ChoEazyCopy.zip

echo "----------------Setup lsd For Ubuntu----------------"
cd /home/$user/
wget https://github.com/lsd-rs/lsd/releases/download/v1.1.5/lsd_1.1.5_amd64.deb
sudo apt install ./lsd_1.1.5_amd64.deb
rm lsd_1.1.5_amd64.deb

echo "----------------Setup Vagrant For Ubuntu----------------"
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
vagrant plugin install virtualbox_WSL2
vagrant plugin install vagrant-vbguest
vagrant autocomplete install --bash
vagrant autocomplete install --zsh

echo "----------------Setup Terraform For Ubuntu----------------"
sudo apt update && sudo apt install terraform
terraform -install-autocomplete

echo "----------------Setup Ansible----------------"
sudo apt install python3-pip -y && pip3 install --upgrade pip
pip3 install virtualenv && pip3 install --upgrade virtualenv
pip3 install ansible ansible-lint molecule

echo "----------------Setup Kubectl----------------"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
mkdir -p /home/$user/.kube

echo "----------------Setup Helm----------------"
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg >/dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

echo "----------------Setup MiniKube----------------"
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo apt install ./minikube_latest_amd64.deb
rm minikube_latest_amd64.deb

echo "----------------Enable hushlogin----------------"
touch /home/$user/.hushlogin

echo "----------------Download Anaconda Icon For Windows Terminal----------------"
if [ -d "/mnt/c/Users/$username/miniconda3/" ]; then
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
if [ -d "/home/$user/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    echo "zsh-autosuggestions Already Installed"
else
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi
if [ -d "/home/$user/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    echo "zsh-syntax-highlighting Already Installed"
else
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

echo "----------------Change Default Shell To Zsh----------------"
chsh -s /usr/bin/zsh

echo "----------------Setup Zshrc----------------"
sudo cat zshrc >/home/$user/.zshrc
sudo dos2unix /home/$user/.zshrc

echo "----------------Setup Bashrc----------------"
sudo cat bashrc >/home/$user/.bashrc
sudo dos2unix /home/$user/.bashrc
