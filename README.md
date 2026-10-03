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

### Apps without a cask

`O+ Connect` and `Switchbar` have no Homebrew cask, so `run_apps` installs them straight from the
vendor's dmg into `/Applications`. Each is skipped when already present, so re-running is a no-op.

Both are pinned to a known version and update themselves from there (each ships a Squirrel
updater), so the links only need touching if a pinned version is retired. No sha256 is pinned: both
are notarized Developer ID, so Gatekeeper verifies the binary on first launch.

### Peekaboo (macOS automation)

`peekaboo` is wired into `opencode.jsonc` as a local MCP server, so the agent can screenshot the
screen, read the accessibility tree, and click and type inside your real apps — including Safari
and Chrome with your own profiles and logins.

Unlike every other tool here it needs two macOS privacy grants, and they cannot be scripted:

| Grant | Where | Needed by |
|---|---|---|
| Screen Recording | System Settings → Privacy & Security → Screen & System Audio Recording | seeing the screen |
| Accessibility | System Settings → Privacy & Security → Accessibility | clicking, typing, reading UI |

Grants are per **host app**, not per user or per terminal, and each MCP client is a separate host.
Grant both to:

- **Warp** (`dev.warp.Warp-Stable`) — for `opencode` in the terminal
- **OpenChamber** (`dev.openchamber.desktop`) — for the desktop app, which runs its own bundled
  opencode (`OpenChamber.app/Contents/Resources/opencode-cli/`) rather than the Homebrew one

Granting one does not cover the other. Peekaboo reports what the selected host actually has:

```sh
peekaboo permissions status      # add --no-remote to check the local runtime
peekaboo bridge status           # which host answered the last check
```

Peekaboo's tools default to `ask`, with the ones that cannot change anything — `see`, `image`,
`inspect_ui`, `permissions`, `dock`, `analyze`, `verify_state`, `sleep` — set to `allow`. Anything
that clicks, types or moves the cursor still needs approval.

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
| `opencode/ponytail-plugin.js` | `~/.config/opencode/plugins/ponytail-plugin.js` |
| `opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` |
| `cli.json` | `~/.config/opencode/cli.json` |
| `theme/matteblack.lua` | `~/.config/nvim/lua/plugins/matteblack.lua` |
| `theme/matte_black.yaml` | `~/.warp/themes/matte_black.yaml` |

`auto_config.sh`, `Brewfile` and `README.md` are used in place and are not symlinked.

OpenCode is **V2 only** (`anomalyco/tap/opencode-v2`, 2.x). It conflicts with homebrew-core's
`opencode` (1.x) — both install an `opencode` binary — so the upgrade is uninstall-then-install.
The terminal binary and OpenChamber's bundled one both read `opencode.jsonc`. V2 replaced
`tui.jsonc` with `cli.json`, so the old TUI config is gone rather than kept.

### Global instructions

`opencode/AGENTS.md` is symlinked to `~/.config/opencode/AGENTS.md`, so it loads in every session in
both the terminal and OpenChamber. Sections 0–5 are hand-written; section 6 is a capped list of
rules the agent appends as it learns them, and section 7 tells it how to maintain the file. Edit it
through the `~/.config/opencode/` path — that resolves inside the global config directory, which
OpenCode pre-allows, whereas the repo path is an external directory and prompts.

### VibeWise

[Itskorrah/vibe-wise-universal](https://github.com/Itskorrah/vibe-wise-universal) — a community port of
Noah Kim's [VibeWise](https://github.com/nykooi1/vibe-wise) to OpenCode V2. Adds `/vibe-wise-learn`
and `/vibe-wise-reset`: the agent asks for your design approach and explains unfamiliar concepts
before writing the code you agreed to. Learning notes live in `.vibe-wise/` per project — gitignore
it yourself.

`auto_config.sh` clones the bundle to `~/.config/opencode/vibe-wise/` and copies the plugin entry
from `opencode/vibe-wise/` into `~/.config/opencode/plugins/vibe-wise/`. Upstream's own installer is
project-local, which is the wrong shape for a config dir that serves every project. The entry is
copied rather than symlinked because bun resolves imports from a module's realpath. The bundle is
cloned once and never pulled unattended; re-clone to update.

`opencode/AGENTS.md` is a trimmed derivative of [TheRealSeanDonahoe/agents-md](https://github.com/TheRealSeanDonahoe/agents-md) (MIT, © 2026 Sean Donahoe) — sections 2+3 merged, session hygiene dropped, project context/learnings/provenance refit as global sections 5/6/7.

## Not automated

These need manual install or are interactive:

- App Store apps and Safari extensions
- `gh auth login`
- Screen Recording + Accessibility for peekaboo, granted per host app (Warp, OpenChamber) — see
  [Peekaboo](#peekaboo-macos-automation). `auto_config.sh --verify` warns when a host is missing them.
