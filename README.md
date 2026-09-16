# Dotfiles

Personal macOS dotfiles. Zsh + oh-my-zsh + Starship + git.

## Install

```sh
git clone git@github.com:rishavnandi/dotfiles.git ~/data/projects/dotfiles
cd ~/data/projects/dotfiles
./auto_config.sh
```

The script installs Homebrew and everything in the `Brewfile`, the FiraCode Nerd Font,
oh-my-zsh with custom plugins, the LazyVim starter, symlinks the dotfiles, sets zsh as the
default shell, applies a set of macOS defaults, configures the Dock, and turns on Touch ID
for `sudo`.

## Usage

```
./auto_config.sh [options]

  -n, --dry-run     Show every change without making any
      --verify      Report drift against the desired state; never writes
      --only LIST   Run only these sections, comma separated
  -h, --help        Show this help
```

Sections, in order: `brew font omz nvim dotfiles shell macos dock touchid`.

```sh
./auto_config.sh --dry-run                 # preview everything
./auto_config.sh --verify                  # what has drifted?
./auto_config.sh --only dock,macos         # re-apply just those
./auto_config.sh --only brew               # retry a failed package install
```

`--verify` is the useful one day to day: it re-reads every setting, symlink, package and
Dock tile and reports anything that no longer matches, without changing a thing.

## Packages

Dependencies live in `Brewfile` (taps, formulae and casks). Edit it there rather than in
the script:

```sh
brew bundle install --file=Brewfile   # apply
brew bundle check --file=Brewfile     # what's missing?
brew bundle dump --file=Brewfile --force   # re-snapshot this machine
```

## macOS defaults

`MACOS_DEFAULTS` in `auto_config.sh` is a single table of `domain|key|type|value` rows used
for both applying and verifying. It captures settings that already existed on the reference
machine — so a fresh install reproduces them rather than resetting to stock — plus:

- fast key repeat, and `ApplePressAndHoldEnabled=false` so holding `j`/`k` in nvim repeats
  instead of triggering the accent popup
- all automatic text substitution off (quotes, dashes, capitals, periods, spelling)
- no window-open animation, quick Mission Control, no toolbar title delay

The light/dark theme is deliberately **not** set here; it is a first-boot choice.

The Dock is configured separately in `DOCK_DEFAULTS` and `DOCK_APPS`: instant autohide,
"suggested and recent apps" off, and a fixed pinned set. Anything not listed in `DOCK_APPS`
is removed, so a fresh install does not keep the stock macOS Dock.

## Theme

Everything under `theme/` is one palette — **Matte Black**, from Omarchy's `matte-black`
theme by [Taha YVR](https://github.com/tahayvr). Upstream ports: [matteblack.nvim](https://github.com/tahayvr/matteblack.nvim),
[TahaYVR.matteblack](https://open-vsx.org/extension/TahaYVR/matteblack) for VS Code/Cursor,
and [matte-black-zed](https://github.com/tahayvr/matte-black-zed).

| File | Symlinked to | Applies to |
|---|---|---|
| `theme/matteblack.lua` | `~/.config/nvim/lua/plugins/matteblack.lua` | Neovim (LazyVim) |
| `theme/matte_black.yaml` | `~/.warp/themes/matte_black.yaml` | Warp |

### AMOLED, not upstream

Upstream Matte Black is **not** pure black — its background is `#121212`. That is deliberate:
"matte" means a dark grey rather than an OLED-black void. Sampling Omarchy's own theme
preview, the dominant colour is `#121212` at ~13% of pixels, with everything else in the
`#10`–`#1D` band; it only *looks* black because the wallpaper, bars and chrome all sit in
that same narrow range. Warp's native Dark theme, by contrast, is the real AMOLED one at
`#000000`.

This repo deliberately diverges, in both files:

- Warp uses `background: #000000`, with the foreground lifted from `#bebebe` to `#EAEAEA`
  because the former reads dim on pure black. Accents and ANSI colours are unchanged from
  upstream.
- Neovim overrides the colorscheme's `bg1`/`bg3`/`bg4` to `#000000`/`#0D0D0D`/`#1A1A1A` via
  the `config` block in `matteblack.lua`.

To go back to upstream, set `background: "#121212"` / `foreground: "#bebebe"` in the Warp
file and delete the `config` block in the nvim one.

Two further notes:

- The ANSI colours in the Warp theme are `terminal_color_0..15` from the Neovim theme, so
  shell output matches the editor. Anything that emits ANSI escapes — starship, `lsd`, git,
  btop, lazygit, bat, fzf — picks these up automatically.
- **Neovim does not inherit the terminal palette.** It paints its own background, so the
  Warp theme alone would leave it on LazyVim's default tokyonight. Both files exist for
  that reason.

Warp lists user themes by file name, so after running the script pick **Matte Black** once
under Settings → Appearance → Themes. It is not set automatically because the exact string
Warp expects is not verifiable from outside the app.

## Files

| File | Symlinked to |
|---|---|
| `zshrc` | `~/.zshrc` |
| `zprofile` | `~/.zprofile` |
| `gitconfig` | `~/.gitconfig` |
| `starship.toml` | `~/.config/starship.toml` |
| `opencode.jsonc` | `~/.config/opencode/opencode.jsonc` |
| `theme/matteblack.lua` | `~/.config/nvim/lua/plugins/matteblack.lua` |
| `theme/matte_black.yaml` | `~/.warp/themes/matte_black.yaml` |

`auto_config.sh`, `Brewfile` and `README.md` are used in place and are not symlinked.

## Not automated

These need manual install or are interactive:

- `O+Connect`, `oMLX`, `Switchbar` — no Homebrew cask
- App Store apps and Safari extensions
- `gh auth login`
