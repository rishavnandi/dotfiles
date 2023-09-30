# Configs for my Windows Terminal, PowerShell Prompt, Bashrc/Fish and Starship Prompt configs as well.

## Usage

- Clone or download the repo

```powershell
git clone https://github.com/rishavnandi/wsl_dotfiles.git
```

- Ease the execution policy (Type into an admin powershell window)

```powershell
Set-ExecutionPolicy Unrestricted
```

- Open powershell as admin and navigate to the dotfiles folder and execute the script (Below command assumes you downloaded repo to downloads folder)

```powershell
cd .\Downloads\wsl_dotfiles\
.\auto_install.ps1
``` 

- Now run the script in your wsl instance (Below command assumes you downloaded repo to downloads folder)
- First make sure your user has ownership of all files and folders in the dotfiles folder

```bash
cd /home/<username>/
sudo chown -R <username> .
```

```bash
cd /mnt/c/Users/<username>/Downloads/dotfiles/
chmod +x auto_config.sh
./auto_config.sh
```

- Harden the execution policy back to restricted (Type into an admin powershell window)

```powershell
Set-ExecutionPolicy Restricted
```

- That's it, you are done, make sure to install the nerd font which should be downloaded by the script in your downloads folder, you'll find all the other apps that need manual installation there as well.

## Config PATHS

- win_starship.toml -> C:\Users\risha\\.starship\starship.toml
- starship.lua -> C:\Users\risha\AppData\Local\clink\starship.lua
- winfetch.ps1 -> C:\Users\risha\\.config\winfetch\config.ps1

![image](https://github.com/rishavnandi/wsl_dotfiles/assets/101431112/1108297f-1cf5-4121-9258-e23e3dbee106)
![Screenshot (9)](https://user-images.githubusercontent.com/101431112/193451745-a8c41663-be9d-44cd-81ce-a24cb82e68bb.png)
![Screenshot (3)](https://user-images.githubusercontent.com/101431112/196135275-9083721c-7ea9-4e7d-bde4-f36ef5d5bfa9.png)
