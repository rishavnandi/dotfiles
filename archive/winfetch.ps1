# ===== WINFETCH CONFIGURATION =====

# Configure which disks are shown
$ShowDisks = @("C:", "D:")

# Configure info display style
# Options: 'text', 'bar', 'textbar', 'bartext'
$cpustyle = 'textbar'
$memorystyle = 'textbar'
$diskstyle = 'textbar'
$batterystyle = 'textbar'

# Enable/disable info segments
@(
    "title"
    "dashes"
    "os"
    "computer"
    "kernel"
    "motherboard"
    "uptime"
    "pwsh"
    "cpu"
    "gpu"
    "memory"
    "disk"
    "local_ip"
    "blank"
    "colorbar"
)
