# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(zsh-autosuggestions zsh-syntax-highlighting copyfile)

source $ZSH/oh-my-zsh.sh

# ls aliases
if command -v lsd &>/dev/null; then
    alias ls="lsd"
    alias ll='ls -l'
    alias la='ls -a'
    alias lla='ls -la'
    alias lt='ls --tree'
else
    alias ll='ls -l'
    alias la='ls -a'
    alias lla='ls -la'
fi

# custom aliases
alias cleanup="sudo apt autoremove"
alias update="sudo apt update && sudo apt upgrade -y"
alias install="sudo apt install"
alias uninstall="sudo apt purge"
alias gin="git init"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gb="git checkout -b"
alias gpull="git pull"

# Initialize Starship prompt (handles distro icons automatically via the 'os' module)
if command -v starship &>/dev/null; then
    export STARSHIP_CONFIG="$HOME/.config/starship.toml"
    eval "$(starship init zsh)"
fi

# Export PATH
export PATH="$HOME/.local/bin:$PATH"

# Export Configs For Vagrant (uses dynamic USER variable)
if [ -n "${WSL_DISTRO_NAME:-}" ]; then
    WIN_USER=$(powershell.exe -Command "[Environment]::UserName" 2>/dev/null | tr -d '\r' || echo "$USER")
    export VAGRANT_WSL_WINDOWS_ACCESS_USER_HOME_PATH="/mnt/c/Users/$WIN_USER"
    export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1
fi

# Load autojump if available
if [ -f /usr/share/autojump/autojump.zsh ]; then
    . /usr/share/autojump/autojump.zsh
fi

# Load NVM if available
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Show system info on new terminal (only if nitch is installed)
if command -v nitch &>/dev/null; then
    nitch
fi
