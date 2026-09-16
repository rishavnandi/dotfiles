#!/bin/zsh

set -euo pipefail

NERD_FONT_VERSION="2.3.3"
DOTFILES_DIR="${0:A:h}"
BREWFILE="$DOTFILES_DIR/Brewfile"
# Captured at top level: inside a function zsh sets $0 to the function name.
SCRIPT_NAME="${0:t}"

FONT_DIR="/Library/Fonts"
USER_FONT_DIR="$HOME/Library/Fonts"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }

# ----------------Sections and options----------------
# Every phase below is a run_<section>/verify_<section> pair, so --only and
# --verify can address them independently.
ALL_SECTIONS=(brew font omz nvim dotfiles shell macos dock touchid)

usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} [options]

  -n, --dry-run     Show every change without making any
      --verify      Report drift against the desired state; never writes
      --only LIST   Run only these sections, comma separated
                    (${ALL_SECTIONS[*]})
  -h, --help        Show this help

With no --only, every section runs in order.
EOF
}

DRY_RUN=false
VERIFY=false
ONLY=()

while (( $# )); do
    case "$1" in
        -n|--dry-run) DRY_RUN=true ;;
        --verify)     VERIFY=true ;;
        --only)
            shift
            only_arg="${1:-}"
            if [[ -z "$only_arg" ]]; then
                log_error "--only needs a comma-separated list of sections"
                exit 1
            fi
            ONLY+=("${(@s:,:)only_arg}")
            ;;
        -h|--help) usage; exit 0 ;;
        *) log_error "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done

for section in "${ONLY[@]}"; do
    if (( ! ${ALL_SECTIONS[(Ie)$section]} )); then
        log_error "Unknown section: $section"
        log_error "Valid sections: ${ALL_SECTIONS[*]}"
        exit 1
    fi
done

should_run() {
    if (( ${#ONLY} == 0 )); then
        return 0
    fi
    if (( ${ONLY[(Ie)$1]} )); then
        return 0
    fi
    return 1
}

# ----------------Homebrew non-interactive defaults----------------
# Homebrew 6+ enables "ask mode" by default and refuses to load formulae/casks
# from non-official taps until they are trusted. Set these before any brew call
# so the script runs unattended.
export HOMEBREW_NO_ASK=1                  # auto-approve the install/upgrade plan
export HOMEBREW_NO_AUTO_UPDATE=1          # we run `brew update` explicitly below
export HOMEBREW_DOWNLOAD_CONCURRENCY="${HOMEBREW_DOWNLOAD_CONCURRENCY:-auto}"

BREW_FAILED=false

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

# ----------------Shared helpers----------------
# A row is "domain|key|type|value"; type/value go straight to `defaults write`.
split_row() {
    row_domain="${1%%|*}"
    row_rest="${1#*|}"
    row_key="${row_rest%%|*}"
    row_rest="${row_rest#*|}"
    row_type="${row_rest%%|*}"
    row_value="${row_rest#*|}"
}

apply_default_row() {
    split_row "$1"
    run_cmd defaults write "$row_domain" "$row_key" "$row_type" "$row_value"
}

# Compare a row against the live value, logging drift. Returns 1 on mismatch.
check_default_row() {
    split_row "$1"
    local got
    got="$(defaults read "$row_domain" "$row_key" 2>/dev/null || true)"

    local ok=false
    case "$row_type" in
        -bool)
            local want_num=0
            if [[ "$row_value" == "true" ]]; then want_num=1; fi
            if [[ "$got" == "$want_num" || "$got" == "$row_value" ]]; then ok=true; fi
            ;;
        -float)
            # `defaults write -float 0.15` reads back as 0.15000000596046448,
            # so floats are compared with a tolerance.
            if awk -v g="$got" -v w="$row_value" \
                'BEGIN { exit !(g != "" && (g - w) < 0.001 && (w - g) < 0.001) }'; then
                ok=true
            fi
            ;;
        *)
            if [[ "$got" == "$row_value" ]]; then ok=true; fi
            ;;
    esac

    if $ok; then
        log_info "ok: $row_domain $row_key = $row_value"
        return 0
    fi
    log_warn "drift: $row_domain $row_key = ${got:-<unset>} (want $row_value)"
    return 1
}

# ----------------Desired state: dotfile symlinks----------------
DOTFILE_LINKS=(
    "$DOTFILES_DIR/zshrc|$HOME/.zshrc"
    "$DOTFILES_DIR/zprofile|$HOME/.zprofile"
    "$DOTFILES_DIR/gitconfig|$HOME/.gitconfig"
    "$DOTFILES_DIR/starship.toml|$HOME/.config/starship.toml"
    "$DOTFILES_DIR/opencode.jsonc|$HOME/.config/opencode/opencode.jsonc"
)

# ----------------Desired state: oh-my-zsh plugins----------------
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

# ----------------Desired state: macOS defaults----------------
# Everything here is a setting that either already exists on the reference
# machine (so a fresh install reproduces it) or is a deliberate preference.
# The light/dark theme is deliberately absent: it is a first-boot choice.
MACOS_DEFAULTS=(
    # Finder and file handling
    "NSGlobalDomain|AppleShowAllExtensions|-bool|true"
    "com.apple.finder|ShowPathbar|-bool|true"
    "com.apple.finder|ShowStatusBar|-bool|true"
    "com.apple.finder|FXPreferredViewStyle|-string|Nlsv"
    "com.apple.desktopservices|DSDontWriteNetworkStores|-bool|true"
    "com.apple.desktopservices|DSDontWriteUSBStores|-bool|true"

    # Menu bar clock
    "com.apple.menuextra.clock|ShowSeconds|-bool|true"
    "com.apple.menuextra.clock|ShowDate|-bool|false"

    # Region/format preferences (not the theme)
    "NSGlobalDomain|AppleAccentColor|-int|1"
    "NSGlobalDomain|AppleICUForce24HourTime|-bool|true"

    # Don't reopen every window on login
    "NSGlobalDomain|NSQuitAlwaysKeepsWindows|-bool|false"

    # Tap to click, for the built-in and Bluetooth trackpads
    "com.apple.AppleMultitouchTrackpad|Clicking|-bool|true"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad|Clicking|-bool|true"

    # ---- Snappier UI ----
    "NSGlobalDomain|NSAutomaticWindowAnimationsEnabled|-bool|false"
    "NSGlobalDomain|NSToolbarTitleViewRolloverDelay|-float|0"

    # Fast key repeat: short delay before it starts, then a fast rate.
    "NSGlobalDomain|KeyRepeat|-int|2"
    "NSGlobalDomain|InitialKeyRepeat|-int|15"

    # Without this macOS swallows key repeat while a key is held down (it wants
    # to show the accent popup), which is why holding j/k in nvim moves only one
    # line. Set globally and for Warp, the terminal it is used from.
    "NSGlobalDomain|ApplePressAndHoldEnabled|-bool|false"
    "dev.warp.Warp-Stable|ApplePressAndHoldEnabled|-bool|false"

    # ---- No automatic text substitution ----
    "NSGlobalDomain|NSAutomaticCapitalizationEnabled|-bool|false"
    "NSGlobalDomain|NSAutomaticPeriodSubstitutionEnabled|-bool|false"
    "NSGlobalDomain|NSAutomaticQuoteSubstitutionEnabled|-bool|false"
    "NSGlobalDomain|NSAutomaticDashSubstitutionEnabled|-bool|false"
    "NSGlobalDomain|NSAutomaticSpellingCorrectionEnabled|-bool|false"
)

# ----------------Desired state: Dock----------------
DOCK_DEFAULTS=(
    "com.apple.dock|autohide|-bool|true"
    "com.apple.dock|autohide-delay|-float|0"
    "com.apple.dock|autohide-time-modifier|-float|0.15"
    "com.apple.dock|show-recents|-bool|false"
    "com.apple.dock|tilesize|-int|43"
    "com.apple.dock|magnification|-bool|true"
    "com.apple.dock|mineffect|-string|scale"
)

# =========================================================
# Sections
# =========================================================

run_brew() {
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

    echo "----------------Trust Homebrew Taps----------------"
    # `brew trust` landed in Homebrew 6; on older versions tap formulae load
    # freely, so skip trust rather than failing the whole run. Taps live in the
    # Brewfile, so read them from there instead of keeping a second list.
    if brew trust --help &>/dev/null; then
        local tap
        for tap in "${(@f)$(grep '^tap ' "$BREWFILE" 2>/dev/null | sed 's/^tap "\(.*\)"$/\1/' || true)}"; do
            run_cmd brew trust --tap "$tap"
        done
    else
        log_warn "This Homebrew predates 'brew trust' — skipping tap trust"
    fi

    echo "----------------Install Packages (Brewfile)----------------"
    if [[ ! -f "$BREWFILE" ]]; then
        log_error "Brewfile not found at $BREWFILE"
        BREW_FAILED=true
        return 0
    fi

    # `brew bundle install` resolves the dependency graph and fetches bottles
    # concurrently across $HOMEBREW_DOWNLOAD_CONCURRENCY threads. A single
    # failure does not abort the batch.
    if ! run_cmd brew bundle install --file="$BREWFILE"; then
        log_warn "Some packages failed — continuing with the remaining setup"
        BREW_FAILED=true
    fi

    if ! $DRY_RUN; then
        verify_brew || BREW_FAILED=true
    fi
}

verify_brew() {
    if ! command -v brew &>/dev/null; then
        log_warn "drift: Homebrew is not installed"
        return 1
    fi
    if [[ ! -f "$BREWFILE" ]]; then
        log_warn "drift: Brewfile missing at $BREWFILE"
        return 1
    fi
    if ! brew bundle check --file="$BREWFILE" &>/dev/null; then
        log_warn "drift: Brewfile entries not satisfied"
        brew bundle check --file="$BREWFILE" --verbose 2>&1 | sed 's/^/    /' || true
        return 1
    fi
    log_info "ok: all Brewfile formulae, casks and taps present"
    return 0
}

run_font() {
    echo "----------------Install FiraCode Nerd Font----------------"
    # The release ships files named "Fira Code <weight> Nerd Font Complete.ttf",
    # so the pattern must tolerate the space between "Fira" and "Code"
    # (`Fira*Code*`, which also still matches space-less names such as
    # FiraCodeNerdFont-Regular). Both font directories are checked.
    local font_matches=(
        "$FONT_DIR"/Fira*Code*Nerd*.{ttf,otf}(N)
        "$USER_FONT_DIR"/Fira*Code*Nerd*.{ttf,otf}(N)
    )
    if (( ${#font_matches[@]} )); then
        log_warn "FiraCode Nerd Font already installed (${#font_matches[@]} files)"
        return 0
    fi

    if $DRY_RUN; then
        log_info "[dry-run] Would download and install FiraCode Nerd Font v${NERD_FONT_VERSION}"
        return 0
    fi

    log_info "Downloading FiraCode Nerd Font v${NERD_FONT_VERSION}"
    local tmp_font_dir
    tmp_font_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_font_dir"' EXIT
    curl -fsSL -o "$tmp_font_dir/FiraCode.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONT_VERSION}/FiraCode.zip"
    unzip -q "$tmp_font_dir/FiraCode.zip" -d "$tmp_font_dir/FiraCode"
    log_info "Installing fonts to $FONT_DIR (sudo required)"
    sudo find "$tmp_font_dir/FiraCode" -type f \( -iname "*.ttf" -o -iname "*.otf" \) \
        -exec cp {} "$FONT_DIR/" \;
    rm -rf "$tmp_font_dir"
    trap - EXIT
    log_info "FiraCode Nerd Font v${NERD_FONT_VERSION} installed"
}

verify_font() {
    local font_matches=(
        "$FONT_DIR"/Fira*Code*Nerd*.{ttf,otf}(N)
        "$USER_FONT_DIR"/Fira*Code*Nerd*.{ttf,otf}(N)
    )
    if (( ${#font_matches[@]} )); then
        log_info "ok: FiraCode Nerd Font (${#font_matches[@]} files)"
        return 0
    fi
    log_warn "drift: FiraCode Nerd Font is not installed"
    return 1
}

run_omz() {
    echo "----------------Setup Oh My Zsh----------------"
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing Oh My Zsh"
        run_cmd env RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        log_warn "Oh My Zsh already installed"
    fi

    local i plugin target
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
}

verify_omz() {
    local drift=false
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_info "ok: oh-my-zsh"
    else
        log_warn "drift: oh-my-zsh is not installed"
        drift=true
    fi
    local plugin
    for plugin in "${OMZ_PLUGIN_NAMES[@]}"; do
        if [[ -d "$ZSH_CUSTOM/plugins/$plugin" ]]; then
            log_info "ok: oh-my-zsh plugin $plugin"
        else
            log_warn "drift: oh-my-zsh plugin $plugin missing"
            drift=true
        fi
    done
    if $drift; then return 1; fi
    return 0
}

run_nvim() {
    echo "----------------Setup LazyVim----------------"
    if [[ -d "$HOME/.config/nvim" ]]; then
        log_warn "Neovim config already exists at $HOME/.config/nvim"
        return 0
    fi
    log_info "Cloning LazyVim starter"
    run_cmd git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
    run_cmd rm -rf "$HOME/.config/nvim/.git"
    log_info "LazyVim starter installed — run 'nvim' to install plugins"
}

verify_nvim() {
    if [[ -d "$HOME/.config/nvim" ]]; then
        log_info "ok: LazyVim config at ~/.config/nvim"
        return 0
    fi
    log_warn "drift: ~/.config/nvim missing"
    return 1
}

run_dotfiles() {
    echo "----------------Symlink Dotfiles----------------"
    local entry src dest
    for entry in "${DOTFILE_LINKS[@]}"; do
        src="${entry%%|*}"
        dest="${entry#*|}"
        run_cmd mkdir -p "${dest:h}"
        if [[ -L "$dest" ]]; then
            log_warn "Symlink already exists: $dest"
            run_cmd ln -sfn "$src" "$dest"
            continue
        fi
        if [[ -e "$dest" ]]; then
            log_info "Backing up existing $dest to $dest.bak"
            run_cmd mv "$dest" "$dest.bak"
        fi
        run_cmd ln -s "$src" "$dest"
        log_info "Linked $dest -> $src"
    done
}

verify_dotfiles() {
    local drift=false entry src dest
    for entry in "${DOTFILE_LINKS[@]}"; do
        src="${entry%%|*}"
        dest="${entry#*|}"
        if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
            log_info "ok: $dest -> $src"
        else
            log_warn "drift: $dest is not linked to $src"
            drift=true
        fi
    done
    if $drift; then return 1; fi
    return 0
}

run_shell() {
    echo "----------------Set Zsh As Default Shell----------------"
    local zsh_path
    zsh_path="$(command -v zsh)"
    if [[ "${SHELL:-}" != "$zsh_path" ]]; then
        if ! grep -qx "$zsh_path" /etc/shells; then
            log_info "Adding $zsh_path to /etc/shells"
            run_cmd bash -c 'echo "$1" | sudo tee -a /etc/shells >/dev/null' _ "$zsh_path"
        fi
        log_info "Changing default shell to $zsh_path"
        run_cmd chsh -s "$zsh_path"
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
}

verify_shell() {
    local drift=false zsh_path
    zsh_path="$(command -v zsh)"
    if [[ "${SHELL:-}" == "$zsh_path" ]]; then
        log_info "ok: default shell is $zsh_path"
    else
        log_warn "drift: default shell is ${SHELL:-<unset>} (want $zsh_path)"
        drift=true
    fi
    if [[ -f "$HOME/.hushlogin" ]]; then
        log_info "ok: ~/.hushlogin"
    else
        log_warn "drift: ~/.hushlogin missing"
        drift=true
    fi
    if $drift; then return 1; fi
    return 0
}

run_macos() {
    echo "----------------Configure macOS Defaults----------------"
    local row
    for row in "${MACOS_DEFAULTS[@]}"; do
        apply_default_row "$row"
    done

    # Finder and the menu-bar clock agent read their defaults at launch.
    if ! run_cmd killall Finder; then
        log_warn "Could not restart Finder — log out and back in to apply"
    fi
    if ! run_cmd killall SystemUIServer; then
        log_warn "Could not restart SystemUIServer — log out and back in to apply"
    fi
}

verify_macos() {
    local drift=false row
    for row in "${MACOS_DEFAULTS[@]}"; do
        if ! check_default_row "$row"; then
            drift=true
        fi
    done
    if $drift; then return 1; fi
    return 0
}

# macOS 26+ ships Launchpad as "Apps"; older releases still call it Launchpad.
if [[ -d /System/Applications/Apps.app ]]; then
    LAUNCHPAD_APP="/System/Applications/Apps.app"
else
    LAUNCHPAD_APP="/System/Applications/Launchpad.app"
fi

# Pinned apps, in left-to-right Dock order. Anything else is dropped, so a
# fresh install does not keep the stock macOS set (Mail, Maps, Photos, ...).
DOCK_APPS=(
    "$LAUNCHPAD_APP"
    "/Applications/Safari.app"
    "/Applications/Google Chrome.app"
    "/Applications/Warp.app"
    "/Applications/OpenChamber.app"
    "/Applications/Cursor.app"
    "/Applications/Zed.app"
    "/Applications/OrbStack.app"
    "/Applications/DBeaver.app"
    "/Applications/Bruno.app"
    "/Applications/Obsidian.app"
)

run_dock() {
    echo "----------------Configure Dock----------------"
    local row
    for row in "${DOCK_DEFAULTS[@]}"; do
        apply_default_row "$row"
    done

    if $DRY_RUN; then
        log_info "[dry-run] Would pin ${#DOCK_APPS[@]} apps to the Dock: ${DOCK_APPS[*]}"
    else
        # A minimal tile is enough — the Dock resolves the URL on restart and
        # fills in the bundle identifier and bookmark data itself. file-label
        # comes from the bundle filename (not CFBundleDisplayName, which would
        # render DBeaver as "DBeaver Community") to match how Finder names it.
        defaults write com.apple.dock persistent-apps -array
        local app resolved pinned=0
        for app in "${DOCK_APPS[@]}"; do
            if [[ ! -d "$app" ]]; then
                log_warn "Not pinning missing app: $app"
                continue
            fi
            # Resolve symlinks before writing the tile: /Applications/Safari.app
            # is a link into the Safari cryptex, and pinning the link itself
            # gives the Dock an alias badge and a "Safari.app" label.
            resolved="${app:A}"
            defaults write com.apple.dock persistent-apps -array-add \
                "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file://${resolved// /%20}/</string><key>_CFURLStringType</key><integer>15</integer></dict><key>file-label</key><string>$(basename "$resolved" .app)</string></dict><key>tile-type</key><string>file-tile</string></dict>"
            pinned=$((pinned + 1))
        done
        log_info "Pinned $pinned app(s) to the Dock"
    fi

    # Dock reads its defaults only at launch, so restart it once here.
    if ! run_cmd killall Dock; then
        log_warn "Could not restart Dock — log out and back in to apply"
    fi
}

verify_dock() {
    local drift=false row
    for row in "${DOCK_DEFAULTS[@]}"; do
        if ! check_default_row "$row"; then
            drift=true
        fi
    done

    local want got
    want=("${DOCK_APPS[@]//*\//}")            # basenames, matching file-label
    want=("${want[@]%.app}")
    got=("${(@f)$(defaults read com.apple.dock persistent-apps 2>/dev/null \
        | grep 'file-label' | sed 's/.*= \(.*\);$/\1/' | tr -d '"' || true)}")
    if [[ "${(j:,:)want}" == "${(j:,:)got}" ]]; then
        log_info "ok: Dock pinned to ${(j:, :)got}"
    else
        log_warn "drift: Dock pinned apps are ${(j:, :)got} (want ${(j:, :)want})"
        drift=true
    fi

    if $drift; then return 1; fi
    return 0
}

run_touchid() {
    echo "----------------Enable Touch ID for sudo----------------"
    local pam_file="/etc/pam.d/sudo_local"

    if [[ -f "$pam_file" ]] && grep -q 'pam_tid' "$pam_file" 2>/dev/null; then
        log_warn "Touch ID for sudo already enabled"
        return 0
    fi

    if $DRY_RUN; then
        log_info "[dry-run] Would add 'auth sufficient pam_tid.so' to $pam_file"
        return 0
    fi

    # /etc/pam.d/sudo includes sudo_local, which survives OS updates. Apple
    # ships a template; use it verbatim with the pam_tid line uncommented so the
    # resulting file keeps Apple's own comments.
    log_info "Enabling Touch ID for sudo (sudo required)"
    local pam_template="/etc/pam.d/sudo_local.template"
    local pam_content
    if [[ -f "$pam_template" ]]; then
        # BSD sed has no \+, so match the pam_tid line loosely.
        pam_content="$(sed 's/^#\(auth.*pam_tid\.so\)/\1/' "$pam_template")"
    else
        pam_content="# sudo_local: local config file which survives system update and is included for sudo
auth       sufficient     pam_tid.so"
    fi

    # Guard against a template change silently writing an uncommented-only file,
    # which would leave Touch ID disabled without any error.
    if ! printf '%s\n' "$pam_content" | grep -q '^auth.*pam_tid\.so'; then
        log_warn "Could not derive an active pam_tid line — skipping Touch ID for sudo"
        return 0
    fi

    if ! printf '%s\n' "$pam_content" | sudo tee "$pam_file" >/dev/null; then
        log_warn "Could not enable Touch ID for sudo — skipping"
        return 0
    fi
    sudo chmod 644 "$pam_file"
    sudo chown root:wheel "$pam_file"
    log_info "Touch ID for sudo enabled — your password still works as a fallback"
}

verify_touchid() {
    if [[ -f /etc/pam.d/sudo_local ]] && grep -q 'pam_tid' /etc/pam.d/sudo_local 2>/dev/null; then
        log_info "ok: Touch ID for sudo"
        return 0
    fi
    log_warn "drift: Touch ID for sudo is not enabled (/etc/pam.d/sudo_local)"
    return 1
}

# =========================================================
# Entry point
# =========================================================

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

if $DRY_RUN; then
    log_warn "DRY RUN MODE — no changes will be made"
fi
if $VERIFY; then
    log_warn "VERIFY MODE — reporting drift only, nothing will be written"
fi

if $VERIFY; then
    echo "----------------Verification----------------"
    verify_failed=false
    for section in "${ALL_SECTIONS[@]}"; do
        should_run "$section" || continue
        if ! "verify_${section}"; then
            verify_failed=true
        fi
    done
    echo
    if $verify_failed; then
        log_warn "Verification found drift (see above)"
        exit 1
    fi
    log_info "Everything matches the desired state"
    exit 0
fi

for section in "${ALL_SECTIONS[@]}"; do
    should_run "$section" || continue
    "run_${section}"
done

if [[ "$BREW_FAILED" == "true" ]]; then
    log_error "Setup finished, but some Homebrew packages failed to install (see above)"
    log_error "Re-run just that part with: ${SCRIPT_NAME} --only brew"
    exit 1
fi

log_info "Setup completed successfully!"
log_info "Restart your terminal or run 'source ~/.zshrc' to apply changes"

# ----------------Manual installs (not available via Homebrew)----------------
#   - O+Connect
#   - oMLX
#   - Switchbar
# App Store apps and Safari extensions also have to be installed by hand, and
# `gh auth login` is interactive.
