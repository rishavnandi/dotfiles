-- Starship configuration for Clink (Windows Command Prompt)
-- Uses environment variable instead of hardcoded path
local userprofile = os.getenv('USERPROFILE')
os.setenv('STARSHIP_CONFIG', userprofile .. '\\.starship\\starship.toml')
load(io.popen('starship init cmd'):read("*a"))()
