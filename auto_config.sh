#!/bin/zsh

set -euo pipefail

NERD_FONT_VERSION="2.3.3"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" || "${1:-}" == "-n" ]]; then
    DRY_RUN=true
    log_warn "DRY RUN MODE — no changes will be made"
fi

run_cmd() {
    if $DRY_RUN; then
        log_info "[dry-run] $*"
        return 0
    fi
    "$@"
}

if [[ "$(uname)" != "Darwin" ]]; then
    log_error "This script is macOS only."
    exit 1
fi

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

echo "----------------https://github.com/rishavnandi/dotfiles----------------"

DOTFILES_DIR="${0:A:h}"

echo "----------------Install Homebrew----------------"
if ! command -v brew &>/dev/null; then
    log_info "Installing Homebrew"
    run_cmd /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    log_warn "Homebrew already installed"
fi

log_info "Updating Homebrew"
run_cmd brew update

echo "----------------Add Homebrew Taps----------------"
TAPS=(
    hashicorp/tap
    oven-sh/bun
    theboredteam/boring-notch
)
for tap in "${TAPS[@]}"; do
    if brew tap | grep -qx "$tap"; then
        log_warn "Tap $tap already added"
    else
        log_info "Tapping $tap"
        run_cmd brew tap "$tap"
    fi
done

echo "----------------Install Homebrew Formulae----------------"
FORMULAE=(
    ansible
    ansible-lint
    aria2
    bat
    btop
    cmake
    croc
    duf
    fd
    fzf
    gh
    gnupg
    go
    helm
    inxi
    k9s
    kubernetes-cli
    lazydocker
    lazygit
    lazyssh
    lsd
    mole
    neovim
    nvm
    oci-cli
    opencode
    p7zip
    ripgrep
    ruff
    rust
    smartmontools
    speedtest-cli
    spicetify-cli
    starship
    tldr
    tmux
    ty
    uv
    watch
    wget
    yt-dlp
    zoxide
    hashicorp/tap/terraform
    oven-sh/bun/bun
)

for f in "${FORMULAE[@]}"; do
    short="${f##*/}"
    if brew list --formula "$short" &>/dev/null; then
        log_warn "Formula $short already installed"
    else
        log_info "Installing formula: $f"
        run_cmd brew install "$f" || { log_error "Failed to install $f"; exit 1; }
    fi
done

echo "----------------Install Homebrew Casks----------------"
CASKS=(
    android-platform-tools
    antigravity
    blip
    boring-notch
    brave-browser
    bruno
    chatgpt
    claude
    cursor
    dbeaver-community
    dockdoor
    ente-auth
    free-download-manager
    gamehub
    google-chrome
    hiddenbar
    keka
    linearmouse
    lm-studio
    microsoft-teams
    obsidian
    openchamber
    orbstack
    protonvpn
    raycast
    redis-insight
    spotify
    stats
    tailscale-app
    telegram
    termius
    tradingview
    utm
    vagrant
    vesktop
    vlc
    warp
    whatsapp
    zed
)

for c in "${CASKS[@]}"; do
    if brew list --cask "$c" &>/dev/null; then
        log_warn "Cask $c already installed"
    else
        log_info "Installing cask: $c"
        run_cmd brew install --cask "$c" || { log_error "Failed to install $c"; exit 1; }
    fi
done

echo "----------------Install FiraCode Nerd Font----------------"
FONT_DIR="/Library/Fonts"
font_matches=("$FONT_DIR"/FiraCode*Nerd*.{ttf,otf}(N))
if (( ${#font_matches[@]} )); then
    log_warn "FiraCode Nerd Font already installed in $FONT_DIR"
else
    if $DRY_RUN; then
        log_info "[dry-run] Would download and install FiraCode Nerd Font v${NERD_FONT_VERSION}"
    else
        log_info "Downloading FiraCode Nerd Font v${NERD_FONT_VERSION}"
        TMP_FONT_DIR="$(mktemp -d)"
        trap 'rm -rf "$TMP_FONT_DIR"' EXIT
        curl -fsSL -o "$TMP_FONT_DIR/FiraCode.zip" \
            "https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONT_VERSION}/FiraCode.zip"
        unzip -q "$TMP_FONT_DIR/FiraCode.zip" -d "$TMP_FONT_DIR/FiraCode"
        log_info "Installing fonts to $FONT_DIR (sudo required)"
        sudo find "$TMP_FONT_DIR/FiraCode" -type f \( -iname "*.ttf" -o -iname "*.otf" \) \
            -exec cp {} "$FONT_DIR/" \;
        rm -rf "$TMP_FONT_DIR"
        trap - EXIT
        log_info "FiraCode Nerd Font v${NERD_FONT_VERSION} installed"
    fi
fi

echo "----------------Setup Oh My Zsh----------------"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log_info "Installing Oh My Zsh"
    run_cmd env RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    log_warn "Oh My Zsh already installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

OMZ_PLUGIN_NAMES=(
    zsh-autosuggestions
    zsh-syntax-highlighting
    you-should-use
    fzf-tab
    zsh-history-substring-search
)
OMZ_PLUGIN_URLS=(
    https://github.com/zsh-users/zsh-autosuggestions
    https://github.com/zsh-users/zsh-syntax-highlighting.git
    https://github.com/MichaelAquilina/zsh-you-should-use
    https://github.com/Aloxaf/fzf-tab
    https://github.com/zsh-users/zsh-history-substring-search
)

for i in {1..${#OMZ_PLUGIN_NAMES[@]}}; do
    plugin="${OMZ_PLUGIN_NAMES[$i]}"
    target="$ZSH_CUSTOM/plugins/$plugin"
    if [[ -d "$target" ]]; then
        log_warn "Oh My Zsh plugin $plugin already installed"
    else
        log_info "Installing oh-my-zsh plugin: $plugin"
        run_cmd git clone --depth=1 "${OMZ_PLUGIN_URLS[$i]}" "$target"
    fi
done

echo "----------------Setup LazyVim----------------"
if [[ -d "$HOME/.config/nvim" ]]; then
    log_warn "Neovim config already exists at $HOME/.config/nvim"
else
    log_info "Cloning LazyVim starter"
    run_cmd git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
    run_cmd rm -rf "$HOME/.config/nvim/.git"
    log_info "LazyVim starter installed — run 'nvim' to install plugins"
fi

echo "----------------Symlink Dotfiles----------------"
run_cmd mkdir -p "$HOME/.config"

link_file() {
    local src="$1"
    local dest="$2"
    if [[ -L "$dest" ]]; then
        log_warn "Symlink already exists: $dest"
        run_cmd ln -sfn "$src" "$dest"
        return
    fi
    if [[ -e "$dest" ]]; then
        log_info "Backing up existing $dest to $dest.bak"
        run_cmd mv "$dest" "$dest.bak"
    fi
    run_cmd ln -s "$src" "$dest"
    log_info "Linked $dest -> $src"
}

link_file "$DOTFILES_DIR/zshrc"         "$HOME/.zshrc"
link_file "$DOTFILES_DIR/zprofile"      "$HOME/.zprofile"
link_file "$DOTFILES_DIR/gitconfig"     "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"

run_cmd mkdir -p "$HOME/.config/opencode"
link_file "$DOTFILES_DIR/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"

echo "----------------Set Zsh As Default Shell----------------"
ZSH_PATH="$(command -v zsh)"
if [[ "${SHELL:-}" != "$ZSH_PATH" ]]; then
    if ! grep -qx "$ZSH_PATH" /etc/shells; then
        log_info "Adding $ZSH_PATH to /etc/shells"
        run_cmd bash -c 'echo "$1" | sudo tee -a /etc/shells >/dev/null' _ "$ZSH_PATH"
    fi
    log_info "Changing default shell to $ZSH_PATH"
    run_cmd chsh -s "$ZSH_PATH"
else
    log_warn "Default shell already set to zsh"
fi

echo "----------------Enable hushlogin----------------"
if [[ -f "$HOME/.hushlogin" ]]; then
    log_warn ".hushlogin already exists"
else
    log_info "Creating .hushlogin"
    run_cmd touch "$HOME/.hushlogin"
fi

if ! $DRY_RUN; then
    log_info "Setup completed successfully!"
    log_info "Restart your terminal or run 'source ~/.zshrc' to apply changes"
else
    log_info "Dry run complete — no changes were made"
fi

# ----------------Manual Installs (not available via Homebrew)----------------
# The following apps need to be installed manually:
#   - O+Connect
#   - oMLX
#   - Switchbar
