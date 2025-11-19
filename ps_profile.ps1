# PowerShell Profile Configuration

# Initialize Starship prompt (handles OS icon automatically)
$ENV:STARSHIP_CONFIG = "$HOME\.starship\starship.toml"
Invoke-Expression (&starship init powershell | Out-String)

# Aliases
Set-Alias l lsd

# Show system info on new terminal (only if winfetch is available)
if (Get-Command winfetch -ErrorAction SilentlyContinue) {
    winfetch
}
