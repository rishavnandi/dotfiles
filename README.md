# Dotfiles

Personal macOS dotfiles. Zsh + oh-my-zsh + Starship + git.

## Install

```sh
git clone git@github.com:rishavnandi/dotfiles.git ~/data/projects/dotfiles
cd ~/data/projects/dotfiles
./auto_config.sh
```

The script installs Homebrew, all formulae/casks, FiraCode Nerd Font, oh-my-zsh with custom plugins, symlinks the dotfiles, and sets zsh as the default shell.

## Files

| File | Symlinked to |
|---|---|
| `zshrc` | `~/.zshrc` |
| `zprofile` | `~/.zprofile` |
| `gitconfig` | `~/.gitconfig` |
| `starship.toml` | `~/.config/starship.toml` |
