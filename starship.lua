os.setenv('STARSHIP_CONFIG', 'C:\\Users\\rishav\\.starship\\starship.toml')
load(io.popen('starship init cmd'):read("*a"))()
