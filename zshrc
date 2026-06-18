# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions copyfile extract you-should-use fzf-tab history-substring-search zsh-syntax-highlighting)

source "$ZSH/oh-my-zsh.sh"

# fzf key bindings & completion (Ctrl+T files, Ctrl+R history, Alt+C dirs)
if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
fi

# history-substring-search key bindings (Up/Down arrows)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

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
alias gin="git init"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gb="git checkout -b"
alias gpull="git pull"
alias gst="git status"
alias glog="git log --oneline --graph --decorate"
alias gco="git checkout"
alias gd="git diff"

# Export PATH
typeset -U PATH path
path=(
    $HOME/.antigravity-ide/antigravity-ide/bin
    $HOME/.local/bin
    $HOME/.cargo/bin
    $path
    $HOME/.lmstudio/bin
)

# Initialize Starship prompt (handles distro icons automatically via the 'os' module)
if command -v starship &>/dev/null; then
    export STARSHIP_CONFIG="$HOME/.config/starship.toml"
    eval "$(starship init zsh)"
fi

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# Load NVM if available
export NVM_DIR="$HOME/.nvm"
[ -d "$NVM_DIR" ] || mkdir -p "$NVM_DIR"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/rishav/.lmstudio/bin"
# End of LM Studio CLI section

