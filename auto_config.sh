#!/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Version variables for downloads
NERD_FONT_VERSION="2.3.3"
LSD_VERSION="1.1.5"
KUBECTL_VERSION="1.31"
MINIKUBE_VERSION="latest"
NITCH_VERSION="master"  # Uses latest from git
CHOEAZYCOPY_VERSION="2.0.0.3"

# QuickLook Plugin versions
QL_EPUB_VERSION="1"
QL_OFFICE_VERSION="4"
QL_APK_VERSION="1.3.5"
QL_FOLDER_VERSION="1.3"
QL_TORRENT_VERSION="0.2.2"
QL_JUPYTER_VERSION="1.0.1"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Cleanup function
cleanup() {
    if [ -d "${TEMP_DIR:-}" ]; then
        rm -rf "${TEMP_DIR}"
    fi
}

trap cleanup EXIT

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

# Get username with default fallback
if [ -n "${SUDO_USER:-}" ]; then
    user="$SUDO_USER"
else
    user="${USER}"
fi

echo "----------------Detected Unix Username: $user----------------"
read -p "Press Enter to continue or type a different username: " input_user
if [ -n "$input_user" ]; then
    user="$input_user"
fi

# Validate user exists
if ! id "$user" &>/dev/null; then
    log_error "User $user does not exist!"
    exit 1
fi

log_info "Setting ownership for /home/$user"
sudo chown -R "$user:$user" "/home/$user"

echo "----------------Setup Common Software----------------"
log_info "Updating package lists and upgrading system"
sudo apt update && sudo apt upgrade -y

log_info "Installing common development tools"
# Use openjdk-21-jdk (LTS) instead of 24
sudo apt install -y \
    build-essential \
    software-properties-common \
    gnupg \
    nano \
    git \
    curl \
    wget \
    unzip \
    bat \
    rename \
    zsh \
    dos2unix \
    autojump \
    openjdk-21-jdk \
    ca-certificates \
    apt-transport-https

echo "----------------Setup Nitch----------------"
if ! command -v nitch &>/dev/null; then
    log_info "Installing Nitch (version: $NITCH_VERSION)"
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    wget -q https://raw.githubusercontent.com/unxsh/nitch/main/setup.sh
    sh setup.sh
    cd - > /dev/null
else
    log_warn "Nitch already installed, skipping"
fi

echo "----------------Disable Directory Highlights----------------"
if [ ! -f "/home/$user/.dircolors" ]; then
    log_info "Creating custom dircolors configuration"
    dircolors -p | sed 's/;42/;01/' > "/home/$user/.dircolors"
    chown "$user:$user" "/home/$user/.dircolors"
else
    log_warn ".dircolors already exists, skipping"
fi

echo "----------------Setup Starship For Bash----------------"
if ! command -v starship &>/dev/null; then
    log_info "Installing Starship"
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    log_warn "Starship already installed, skipping"
fi

log_info "Configuring Starship"
mkdir -p "/home/$user/.config"
cp linux_starship.toml "/home/$user/.config/starship.toml"
chown -R "$user:$user" "/home/$user/.config"

echo "----------------Setup PowerShell Profile----------------"

# Auto-detect Windows username from WSL
if [ -n "${WSL_DISTRO_NAME:-}" ]; then
    # Try to get Windows username from common WSL paths
    win_username=$(powershell.exe -Command "[Environment]::UserName" 2>/dev/null | tr -d '\r' || echo "")
    if [ -z "$win_username" ]; then
        win_username="$user"
    fi
else
    win_username="$user"
fi

echo "----------------Detected Windows Username: $win_username----------------"
read -p "Press Enter to continue or type a different username: " input_win_user
if [ -n "$input_win_user" ]; then
    win_username="$input_win_user"
fi

WIN_USER_PATH="/mnt/c/Users/$win_username"

if [ ! -d "$WIN_USER_PATH" ]; then
    log_error "Windows user path $WIN_USER_PATH does not exist!"
    log_warn "Skipping Windows configuration"
else
    log_info "Configuring PowerShell profiles"
    
    # PowerShell 5.x profile
    mkdir -p "$WIN_USER_PATH/Documents/WindowsPowerShell"
    cp ps_profile.ps1 "$WIN_USER_PATH/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1"
    
    # PowerShell 7+ profile
    mkdir -p "$WIN_USER_PATH/Documents/PowerShell"
    cp ps_profile.ps1 "$WIN_USER_PATH/Documents/PowerShell/Microsoft.PowerShell_profile.ps1"
    
    # Starship config
    mkdir -p "$WIN_USER_PATH/.starship"
    cp win_starship.toml "$WIN_USER_PATH/.starship/starship.toml"
    
    # Winfetch config
    mkdir -p "$WIN_USER_PATH/.config/winfetch"
    cp winfetch.ps1 "$WIN_USER_PATH/.config/winfetch/config.ps1"
    
    log_info "Windows configuration completed"
fi

echo "----------------Setup Command Prompt----------------"
if [ -d "$WIN_USER_PATH" ]; then
    log_info "Configuring Clink for Command Prompt"
    mkdir -p "$WIN_USER_PATH/AppData/Local/clink"
    cp starship.lua "$WIN_USER_PATH/AppData/Local/clink/starship.lua"
fi

echo "----------------Setup Windows Terminal----------------"
if [ -d "$WIN_USER_PATH" ]; then
    log_info "Configuring Windows Terminal"
    WT_SETTINGS_PATTERN="$WIN_USER_PATH/AppData/Local/Packages/Microsoft.WindowsTerminal"*"/LocalState"
    for WT_SETTINGS_DIR in $WT_SETTINGS_PATTERN; do
        if [ -d "$WT_SETTINGS_DIR" ]; then
            cp settings.json "$WT_SETTINGS_DIR/settings.json" 2>/dev/null && log_info "Windows Terminal settings copied" || log_warn "Could not copy Windows Terminal settings"
            break
        fi
    done
    if [ ! -d "$WT_SETTINGS_DIR" ]; then
        log_warn "Windows Terminal not found, skipping"
    fi
fi

if [ -d "$WIN_USER_PATH" ]; then
    DOWNLOAD_DIR="$WIN_USER_PATH/Downloads"
    
    echo "----------------Download QuickLook Plugins----------------"
    log_info "Downloading QuickLook plugins to $DOWNLOAD_DIR"
    cd "$DOWNLOAD_DIR"
    
    declare -a plugins=(
        "https://github.com/QL-Win/QuickLook.Plugin.EpubViewer/releases/download/${QL_EPUB_VERSION}/QuickLook.Plugin.EpubViewer.qlplugin"
        "https://github.com/QL-Win/QuickLook.Plugin.OfficeViewer/releases/download/${QL_OFFICE_VERSION}/QuickLook.Plugin.OfficeViewer.qlplugin"
        "https://github.com/canheo136/QuickLook.Plugin.ApkViewer/releases/download/${QL_APK_VERSION}/QuickLook.Plugin.ApkViewer.qlplugin"
        "https://github.com/adyanth/QuickLook.Plugin.FolderViewer/releases/download/${QL_FOLDER_VERSION}/QuickLook.Plugin.FolderViewer.qlplugin"
        "https://github.com/Cologler/QuickLook.Plugin.TorrentViewer/releases/download/${QL_TORRENT_VERSION}/QuickLook.Plugin.TorrentViewer.qlplugin"
        "https://github.com/zhangkaihua88/QuickLook.Plugin.JupyterNotebookViewer/releases/download/${QL_JUPYTER_VERSION}/QuickLook.Plugin.JupyterNotebookViewer.qlplugin"
    )
    
    for plugin in "${plugins[@]}"; do
        filename=$(basename "$plugin")
        if [ ! -f "$filename" ]; then
            wget -q "$plugin" || log_warn "Failed to download $filename"
        fi
    done
    
    echo "----------------Download NerdFonts----------------"
    if [ ! -f "FiraCode.zip" ]; then
        log_info "Downloading FiraCode Nerd Font (version: $NERD_FONT_VERSION)"
        wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONT_VERSION}/FiraCode.zip"
    fi
    
    echo "----------------Download Choeazycopy----------------"
    if [ ! -f "ChoEazyCopy.zip" ]; then
        log_info "Downloading ChoEazyCopy (version: $CHOEAZYCOPY_VERSION)"
        wget -q "https://github.com/Cinchoo/ChoEazyCopy/releases/download/v${CHOEAZYCOPY_VERSION}/ChoEazyCopy.zip"
    fi
    
    cd - > /dev/null
fi

echo "----------------Setup lsd For Ubuntu----------------"
if ! command -v lsd &>/dev/null; then
    log_info "Installing lsd (version: $LSD_VERSION)"
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir"
    wget "https://github.com/lsd-rs/lsd/releases/download/v${LSD_VERSION}/lsd_${LSD_VERSION}_amd64.deb"
    sudo dpkg -i "lsd_${LSD_VERSION}_amd64.deb"
    cd - > /dev/null
else
    log_warn "lsd already installed, skipping"
fi

echo "----------------Setup Vagrant For Ubuntu----------------"
if ! command -v vagrant &>/dev/null; then
    log_info "Installing Vagrant"
    wget -qO - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install -y vagrant
    
    log_info "Installing Vagrant plugins"
    sudo -u "$user" vagrant plugin install virtualbox_WSL2
    sudo -u "$user" vagrant plugin install vagrant-vbguest
    sudo -u "$user" vagrant autocomplete install --bash
    sudo -u "$user" vagrant autocomplete install --zsh
else
    log_warn "Vagrant already installed, skipping"
fi

echo "----------------Setup Terraform For Ubuntu----------------"
if ! command -v terraform &>/dev/null; then
    log_info "Installing Terraform"
    sudo apt update && sudo apt install -y terraform
    sudo -u "$user" terraform -install-autocomplete
else
    log_warn "Terraform already installed, skipping"
fi

echo "----------------Setup Ansible----------------"
if ! command -v ansible &>/dev/null; then
    log_info "Installing Ansible and related tools using uv"
    
    # Install uv
    if ! command -v uv &>/dev/null; then
        log_info "Installing uv"
        sudo -u "$user" sh -c "curl -LsSf https://astral.sh/uv/install.sh | sh"
    fi
    
    # Locate uv (default install location is ~/.local/bin or ~/.cargo/bin)
    if [ -f "/home/$user/.local/bin/uv" ]; then
        UV_BIN="/home/$user/.local/bin/uv"
    elif [ -f "/home/$user/.cargo/bin/uv" ]; then
        UV_BIN="/home/$user/.cargo/bin/uv"
    else
        UV_BIN="uv"
    fi

    log_info "Installing tools with uv"
    sudo -u "$user" "$UV_BIN" tool install ansible
    sudo -u "$user" "$UV_BIN" tool install ansible-lint
    sudo -u "$user" "$UV_BIN" tool install molecule
else
    log_warn "Ansible already installed, skipping"
fi

echo "----------------Setup Kubectl----------------"
if ! command -v kubectl &>/dev/null; then
    log_info "Installing kubectl (version: $KUBECTL_VERSION)"
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL "https://pkgs.k8s.io/core:/stable:/v${KUBECTL_VERSION}/deb/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${KUBECTL_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubectl
else
    log_warn "kubectl already installed, skipping"
fi

mkdir -p "/home/$user/.kube"
chown -R "$user:$user" "/home/$user/.kube"

echo "----------------Setup Helm----------------"
if ! command -v helm &>/dev/null; then
    log_info "Installing Helm"
    curl -fsSL https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg >/dev/null
    sudo apt-get install -y apt-transport-https
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install -y helm
else
    log_warn "Helm already installed, skipping"
fi

echo "----------------Setup MiniKube----------------"
if ! command -v minikube &>/dev/null; then
    log_info "Installing Minikube (version: $MINIKUBE_VERSION)"
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir"
    curl -LO "https://storage.googleapis.com/minikube/releases/${MINIKUBE_VERSION}/minikube-linux-amd64"
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
    cd - > /dev/null
else
    log_warn "Minikube already installed, skipping"
fi

echo "----------------Enable hushlogin----------------"
if [ ! -f "/home/$user/.hushlogin" ]; then
    log_info "Creating .hushlogin file"
    touch "/home/$user/.hushlogin"
    chown "$user:$user" "/home/$user/.hushlogin"
fi

if [ -d "$WIN_USER_PATH" ]; then
    echo "----------------Download Anaconda Icon For Windows Terminal----------------"
    if [ -d "$WIN_USER_PATH/miniconda3/" ]; then
        if [ ! -f "$WIN_USER_PATH/miniconda3/anaconda.png" ]; then
            log_info "Downloading Anaconda icon"
            wget -qO "$WIN_USER_PATH/miniconda3/anaconda.png" https://img.icons8.com/fluency/48/000000/anaconda--v2.png
        fi
    else
        log_warn "Miniconda not installed, skipping icon download"
    fi
fi

if [ -d "$WIN_USER_PATH" ]; then
    echo "----------------Download Titlebar Icons For Windows Terminal----------------"
    ICON_DIR="$WIN_USER_PATH/Pictures/icons"
    mkdir -p "$ICON_DIR"
    
    declare -A icons=(
        ["ubuntu.png"]="https://img.icons8.com/color/48/000000/ubuntu--v1.png"
        ["fedora.png"]="https://img.icons8.com/fluency/48/000000/fedora.png"
        ["powershell.png"]="https://img.icons8.com/color/48/000000/powershell.png"
        ["cmd.png"]="https://img.icons8.com/color/48/000000/command-line.png"
    )
    
    for icon in "${!icons[@]}"; do
        if [ ! -f "$ICON_DIR/$icon" ]; then
            log_info "Downloading $icon"
            wget -qO "$ICON_DIR/$icon" "${icons[$icon]}"
        fi
    done
fi

echo "----------------Setup Git----------------"
# Check if git is already configured
if ! git config --global user.name &>/dev/null; then
    echo "----------------Enter First Name----------------"
    read -r first
    echo "----------------Enter Last Name----------------"
    read -r last
    echo "----------------Enter GitHub Email----------------"
    read -r gitemail
    
    log_info "Configuring Git"
    git config --global user.name "$first $last"
    git config --global user.email "$gitemail"
    git config --global credential.helper store
    git config --global init.defaultBranch main
else
    log_warn "Git already configured for $(git config --global user.name)"
fi

echo "----------------Setup Oh My Zsh----------------"
if [ ! -d "/home/$user/.oh-my-zsh" ]; then
    log_info "Installing Oh My Zsh"
    sudo -u "$user" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    log_warn "Oh My Zsh already installed"
fi

ZSH_CUSTOM="/home/$user/.oh-my-zsh/custom"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    log_info "Installing zsh-autosuggestions"
    sudo -u "$user" git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    log_warn "zsh-autosuggestions already installed"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    log_info "Installing zsh-syntax-highlighting"
    sudo -u "$user" git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    log_warn "zsh-syntax-highlighting already installed"
fi

echo "----------------Change Default Shell To Zsh----------------"
if [ "$(getent passwd "$user" | cut -d: -f7)" != "/usr/bin/zsh" ]; then
    log_info "Changing default shell to Zsh for $user"
    sudo chsh -s /usr/bin/zsh "$user"
else
    log_warn "Default shell already set to Zsh"
fi

echo "----------------Setup Zshrc----------------"
log_info "Copying zshrc configuration"
if [ -f "/home/$user/.zshrc" ]; then
    cp "/home/$user/.zshrc" "/home/$user/.zshrc.bak"
    log_info "Backed up existing .zshrc to .zshrc.bak"
fi
cp zshrc "/home/$user/.zshrc"
dos2unix "/home/$user/.zshrc"
chown "$user:$user" "/home/$user/.zshrc"

echo "----------------Setup Bashrc----------------"
log_info "Copying bashrc configuration"
if [ -f "/home/$user/.bashrc" ]; then
    cp "/home/$user/.bashrc" "/home/$user/.bashrc.bak"
    log_info "Backed up existing .bashrc to .bashrc.bak"
fi
cp bashrc "/home/$user/.bashrc"
dos2unix "/home/$user/.bashrc"
chown "$user:$user" "/home/$user/.bashrc"

log_info "Setup completed successfully!"
log_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
