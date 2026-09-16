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

## Files

| File | Symlinked to |
|---|---|
| `zshrc` | `~/.zshrc` |
| `zprofile` | `~/.zprofile` |
| `gitconfig` | `~/.gitconfig` |
| `starship.toml` | `~/.config/starship.toml` |
| `opencode.jsonc` | `~/.config/opencode/opencode.jsonc` |

`auto_config.sh`, `Brewfile` and `README.md` are used in place and are not symlinked.

## Not automated

These need manual install or are interactive:

- `O+Connect`, `oMLX`, `Switchbar` — no Homebrew cask
- App Store apps and Safari extensions
- `gh auth login`
