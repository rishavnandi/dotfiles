os.setenv('STARSHIP_CONFIG', 'C:\\Users\\risha\\.starship\\starship.toml')
load(io.popen('starship init cmd'):read("*a"))()
