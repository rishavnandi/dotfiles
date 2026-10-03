# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Homebrew shellenv: sets HOMEBREW_PREFIX, PATH and the zsh completions fpath.
# Apple Silicon installs to /opt/homebrew, Intel to /usr/local. This runs before
# oh-my-zsh sources compinit so brew's completions are registered, and it keeps
# `brew` available in non-login shells too (zprofile only covers login shells).
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv zsh)"
fi

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
    $HOME/.bun/bin
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

# nvm: sourcing nvm.sh costs ~1.4s of startup (it forks dozens of times resolving the
# default alias), so nvm.sh itself loads on the first `nvm` call. The installed
# version's bin dir goes on PATH right away so `node`, `npm` and the starship nodejs
# module are already there. ponytail: newest installed version rather than
# `nvm alias default` - export NVM_BIN before this line if default points at an lts alias.
export NVM_DIR="$HOME/.nvm"
path=(${NVM_BIN:-$NVM_DIR/versions/node/*(om[1])/bin(N)} $path)
nvm() { unfunction nvm; source $NVM_DIR/nvm.sh; nvm "$@" }

zstyle ':completion:*' menu select

