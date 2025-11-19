# Configs for my Windows Terminal, PowerShell Prompt, Bashrc/Zsh and Starship Prompt configs

## Features

- ✅ **Idempotent scripts** - Safe to run multiple times
- ✅ **Auto-detection** - Automatically detects usernames and paths
- ✅ **Error handling** - Comprehensive error checking and logging
- ✅ **Progress tracking** - Visual feedback during installation
- ✅ **Parallel operations** - Faster installations where possible
- ✅ **No hardcoded paths** - Works for any username

## Usage

### Windows Installation

- Clone or download the repo

```powershell
git clone git@github.com:rishavnandi/wsl_dotfiles.git
```

- Ease the execution policy (Type into an admin PowerShell window)

```powershell
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
```

- Open PowerShell as admin, navigate to the dotfiles folder and execute the script

```powershell
cd .\Downloads\wsl_dotfiles\
.\auto_install.ps1
```

### WSL Installation

- Navigate to the dotfiles folder in your WSL instance

```bash
cd /mnt/c/Users/<username>/Downloads/wsl_dotfiles/
```

- Make the script executable and run it

```bash
chmod +x auto_config.sh
./auto_config.sh
```

The script will:
- Auto-detect your Unix and Windows usernames (can be overridden)
- Check for existing installations and skip them
- Install all tools and dependencies
- Configure your shell profiles
- Set up Windows Terminal, PowerShell, and Command Prompt

- Optionally, harden the execution policy back to restricted (In an admin PowerShell window)

```powershell
Set-ExecutionPolicy Restricted -Scope CurrentUser
```

### Post-Installation

- Install the FiraCode Nerd Font from your Downloads folder
- Restart your terminal to apply all changes
- Enjoy your new setup!

## Key Improvements
- ✅ No more hardcoded usernames or paths
- ✅ Proper error handling with colored output
- ✅ Idempotent - safe to re-run
- ✅ Auto-detection of usernames
- ✅ Progress tracking and installation summaries
- ✅ Updated package versions (Java 21 LTS, kubectl v1.31, etc.)
- ✅ Parallel repository cloning
- ✅ Comprehensive logging

## Additional Tools

### Clone GitHub Repositories

Use the improved `clone_repos.py` script to clone all repositories from a GitHub user:

```bash
# Clone all your repos
python3 clone_repos.py yourusername

# Clone to specific directory with 8 parallel jobs
python3 clone_repos.py yourusername -d ~/repos -j 8

# Use SSH URLs and skip existing repos
python3 clone_repos.py yourusername --ssh --skip-existing

# Use with GitHub token for private repos
python3 clone_repos.py yourusername --token YOUR_TOKEN
```

## Config Paths

- `linux_starship.toml` → `~/.config/starship.toml`
- `win_starship.toml` → `%USERPROFILE%\.starship\starship.toml`
- `starship.lua` → `%LOCALAPPDATA%\clink\starship.lua`
- `winfetch.ps1` → `%USERPROFILE%\.config\winfetch\config.ps1`
- `bashrc` → `~/.bashrc`
- `zshrc` → `~/.zshrc`

## Screenshots

![image](https://github.com/rishavnandi/wsl_dotfiles/assets/101431112/1108297f-1cf5-4121-9258-e23e3dbee106)
![image](https://github.com/rishavnandi/wsl_dotfiles/assets/101431112/65aab98f-b94e-4b75-8cb8-6f19205ac0c6)
