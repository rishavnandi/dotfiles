# Changelog

## Major Refactoring (November 2025)

### Scripts Modernized
All scripts refactored with proper error handling, idempotency, and removed hardcoded paths.

### `auto_config.sh` - Linux/WSL Configuration
- **Error Handling:** Added `set -euo pipefail`, cleanup traps, color-coded logging
- **Idempotency:** Checks if tools are installed before attempting installation
- **Auto-detection:** Unix and Windows usernames detected automatically
- **Versions:** Updated Java to LTS (21), kubectl to v1.31, Nerd Font to v3.1.1
- **Code Quality:** Removed `sudo cat` anti-pattern, added proper quoting, uses arrays

### `auto_install.ps1` - Windows Configuration  
- **Organization:** Apps categorized (essential, development, utility, gaming, etc.)
- **Progress Tracking:** Progress bar with percentage and counters ([15/80])
- **Idempotency:** Tests if apps installed before attempting installation
- **Error Handling:** Try-catch blocks, graceful failures, installation summary
- **Silent Mode:** All installs use `--silent --accept-source-agreements`

### `clone_repos.py` - GitHub Repository Cloner
- **Complete Rewrite:** Modern Python with argparse, type hints, docstrings
- **Parallel Cloning:** ThreadPoolExecutor with configurable jobs (`-j` flag)
- **Pagination:** Handles users with >100 repositories
- **Features:** SSH/HTTPS selection, skip-existing, GitHub token support, timeout handling
- **Output:** Progress indicators, unicode symbols (✓ ✗ ⊘), detailed summary

### Shell Profiles (`bashrc`, `zshrc`)
- Removed hardcoded paths (`/home/rishav` → `$HOME`)
- Dynamic Windows username detection in WSL
- Conditional loading (checks if tools exist before sourcing)
- Consistent structure between bash and zsh

### `starship.lua` - Command Prompt Config
- Removed hardcoded path (`C:\Users\rishav`)
- Uses `%USERPROFILE%` environment variable
- Dynamic path construction with `os.getenv()`

## Benefits

### For Users
- Works for any username without editing scripts
- Safe to re-run (idempotent operations)
- Better feedback with color-coded output
- Faster parallel operations where applicable

### For Maintainers  
- Cleaner code structure with proper error handling
- No anti-patterns (proper arrays, quoting, no `sudo cat`)
- Easy to extend and modify
- Well-commented and documented

## Migration

**For New Users:** Run scripts as normal, follow auto-detected prompts

**For Existing Users:** Scripts detect existing installations and skip them safely

## Files Cleaned
Removed redundant versions: `*_old.sh`, `*_new.sh`, `*_improved.ps1`, `*_old.py`
