#!/bin/zsh

# Reset the CrossOver trial clock on macOS.
#
# CrossOver keeps two clocks and neither one lives inside the app bundle, so
# uninstalling and reinstalling the app never clears them:
#
#   app clock     FirstRunDate in ~/Library/Preferences/com.codeweavers.CrossOver.plist
#   bottle clock  the [Software\CodeWeavers\CrossOver\cxoffice] block in
#                 ~/Library/Application Support/CrossOver/Bottles/<bottle>/system.reg
#
# CodeWeavers sells the trial as one per person and tracks it against a
# codeweavers.com account. This script only moves the local clocks. If the
# install is registered, their server still decides the expiry and the app
# keeps saying the trial is over.

set -euo pipefail

PREFERENCES="$HOME/Library/Preferences/com.codeweavers.CrossOver.plist"
BOTTLES_DIR="$HOME/Library/Application Support/CrossOver/Bottles"
REGISTRY_BLOCK='[Software\\CodeWeavers\\CrossOver\\cxoffice]'

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Removes one registry block: the header line and every value line under it,
# up to the next header. Whatever follows the block is left alone.
strip_registry_block() {
    local file="$1" tmp
    tmp="$(mktemp "${TMPDIR:-/tmp}/crossover-registry.XXXXXX")"
    # The block name goes through the environment, not -v: awk unescapes the
    # backslashes in a -v value, and the registry spells them doubled.
    REGISTRY_BLOCK="$REGISTRY_BLOCK" awk '
        index($0, "[") == 1 { skipping = 0 }
        index($0, ENVIRON["REGISTRY_BLOCK"]) == 1 { skipping = 1 }
        skipping && $0 == "" { skipping = 0; print; next }
        !skipping { print }
    ' "$file" > "$tmp"
    mv "$tmp" "$file"
}

if [[ ! -f "$PREFERENCES" ]]; then
    log_error "No CrossOver preferences at $PREFERENCES. Is CrossOver installed?"
    exit 1
fi

if pgrep -f "CrossOver.app/Contents" >/dev/null 2>&1; then
    log_error "CrossOver is running. Quit it first, it rewrites the clock on exit."
    exit 1
fi

cp "$PREFERENCES" "$PREFERENCES.bak"
log_info "Backed up the preferences to $PREFERENCES.bak"

defaults write com.codeweavers.CrossOver FirstRunDate \
    -date "$(date -u '+%Y-%m-%d %H:%M:%S +0000')"
log_info "App clock now $(defaults read com.codeweavers.CrossOver FirstRunDate)"

bottles=0
for reg in "$BOTTLES_DIR"/*/system.reg(N); do
    bottles=$(( bottles + 1 ))
    if ! grep -qF "$REGISTRY_BLOCK" "$reg"; then
        log_info "Bottle ${reg:h:t}: no trial block, nothing to do"
        continue
    fi
    cp "$reg" "$reg.bak"
    strip_registry_block "$reg"
    log_info "Bottle ${reg:h:t}: trial block removed, backup at $reg.bak"
done

if (( bottles == 0 )); then
    log_warn "No bottles found in $BOTTLES_DIR"
fi
