# PowerShell Profile Configuration

# Initialize Starship prompt (handles OS icon automatically)
$ENV:STARSHIP_CONFIG = "$HOME\.starship\starship.toml"
Invoke-Expression (&starship init powershell | Out-String)

# Aliases
Set-Alias grep Select-String

# lsd aliases (ls is a built-in alias in PowerShell and cannot be overridden)
function ll { lsd -l $args }
function la { lsd -a $args }
function lla { lsd -la $args }
function lt { lsd --tree $args }

# Navigation shortcuts
function .. { Set-Location .. }
function ... { Set-Location ../.. }

# Utility functions
function touch { param($file) New-Item -ItemType File -Path $file -Force }
function which { param($name) Get-Command $name | Select-Object -ExpandProperty Definition }

# Show system info on new terminal (only if winfetch is available)
if (Get-Command winfetch -ErrorAction SilentlyContinue) {
    winfetch
}
