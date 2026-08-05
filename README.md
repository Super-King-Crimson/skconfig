# Introduction
Welcome to skc's configuration directory!

I've actually gone to special lengths to make it so that anyone could copy my configuration, no matter what.
These are a set of well documented and organized configuration files for Ubuntu/Debian-based systems (although they can easily be adapted to any distro), and includes:

- A neovim config to emulate an IDE with intuitive controls
- A kitty config that seamlessly links to neovim
- A `Binaries` folder filled with a ton of useful goodies (`serve-to-http`, `backup`, etc)
- **COMING SOON:** Kitty-compatible input method setup for Japanese
- A healthy list of aliases and bash aliases/functions
- Simple `keyd` binds
- WSL compatibility
- Guides on how to set up OpenSSH for Windows and Linux

My goal is to make my configuration understandable and easy to reinstall.
Feel free to snoop around! Take what you like, leave what's stupid.

# Getting Started
- Note: The following installation guide assumes you are skc. File organization is done to their preference. Feel free to switch things around.
    - If you are skc, pull down your data from Backblaze B2 first so the symlinks we will create later have somewhere to go.
- Create your application and icon symlinks for custom `.desktop` files
    - If you don't have the right structure in `~/Pictures/AppImages`, you can copy it from `/usr/share/icons` and simply remove everything but the `hicolor` directory
```bash
mkdir -p ~/Pictures/AppImages
mkdir -p ~/Documents/AppImages
mv -n ~/.local/share/icons/* ~/Pictures/AppImages 2>/dev/null
mv -n ~/.local/share/applications/* ~/Documents/AppImages 2>/dev/null
rm -rf ~/.local/share/{icons,applications} 2>/dev/null
ln -fs ~/Pictures/AppImages ~/.local/share/icons
ln -fs ~/Documents/AppImages ~/.local/share/applications
```
- You also might as well get neovim now:
```bash
sudo apt install curl wget
```
```bash
mkdir -p ~/.local/bin
cd ~/.local/bin
rm -rf nvim nvim-linux*
# replace with architecture
wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
tar -xf *.tar*
rm *.tar*
ln -sf ~/.local/bin/nvim*/bin/nvim ~/.local/bin/nvim
```
- Install [ente auth](https://github.com/ente/ente/releases?q=prerelease%3Afalse+tag%3Aauth-v4) and [set up ssh credentials on github](https://medium.com/@yourfuse/git-authentication-with-ssh-keys-the-fun-way-edd8fb15d023)
    - if prompted to make a keyring, encrypt it with the same password you log in with
- Run this:
```bash
cd
git clone --no-checkout git@github.com:Super-King-Crimson/skconfig.git
mv skconfig/.git ./
rm -rf skconfig
git reset --hard HEAD
mv .git .skconfig
```
- Then to make yourself immune to `rm -rf` mishaps, run this
```bash
curl -sSL https://github.com/Super-King-Crimson/safe-rm/releases/download/v0.0.1/makemesafe.sh -o makemesafe.sh
chmod +x makemesafe.sh
sudo ./makemesafe.sh
rm makemesafe.sh
```

# Installations
## Packages
```bash
sudo apt update
sudo apt install sudo curl wget tmux gcc clang git unzip zip bat eza ripgrep xclip xdotool restic htop -y
```

## Node Version Manager
```bash
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
nvm install node
nvm alias default node
npm install -g tree-sitter-cli
```

## Rokit
```bash
wget -qO- https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash
```
- [dotnet](https://learn.microsoft.com/en-us/dotnet/core/install/linux)
- [parsec](https://parsec.app/downloads)
- **tailscale**
```bash
wget -qO- https://tailscale.com/install.sh | sh
```
- **flatpak+flathub**
```bash
# or gnome backend
sudo apt install plasma-discover-backend-flatpak flatpak
flatpak remote-delete flathub
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```
- **keyd**
```bash
git clone https://github.com/rvaiya/keyd
cd keyd
make && sudo make install
cd ..
rm -rf keyd
sudo systemctl enable --now keyd

sudo ln -fs ~/.config/keyd /etc/keyd
```

## Kitty
```bash
mkdir -p ~/.local/bin
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
echo 'kitty.desktop' > ~/.config/xdg-terminals.list
```

# Installations
- This is for the more complicated stuff. Setting up ssh, Windows, all the goodies.
## Crons
- Run `crontab -e` and paste this line at the bottom.
```sh
* * * * *  /usr/bin/env bash -c 'mkdir -p $HOME/.local/state/cron'
# Automatic backups (MAKE SURE TO HARDLINK ~/backup.tar.gpg TO ~/Binaries/ AND EXTRACT IT)
0 1 * * *  /usr/bin/env bash -c 'LOGFILE="$HOME/.local/state/cron/backup.log"; touch "$LOGFILE"; date +"%m-%d-%Y @ %H:%M:%S" > "${LOGFILE}.new"; $HOME/Binaries/backup/main.bash >> "${LOGFILE}.new" 2>&1; cat "${LOGFILE}" >> "${LOGFILE}.new"; mv "${LOGFILE}.new" "$LOGFILE"'
# ilab kinit refresh
0 0 * * *  /usr/bin/env bash -c 'LOGFILE="$HOME/.local/state/cron/ilabkinit.log"; touch "$LOGFILE"; date +"%m-%d-%Y @ %H:%M:%S" > "${LOGFILE}.new"; kinit -R >> "${LOGFILE}.new" 2>&1; cat "${LOGFILE}" >> "${LOGFILE}.new"; mv "${LOGFILE}.new" "$LOGFILE"'
```

## SSH
### Windows
- Open powershell as administrator
- Run this to install the SSH client and server
```sh
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# Set the service to start automatically on boot
Set-Service -Name sshd -StartupType Automatic

# Start the SSH server service right now
Start-Service sshd
```
- Explicitly disallow password logins:
```sh
notepad.exe C:\ProgramData\ssh\sshd_config
# Change this line
# PasswordAuthentication no
```
- Create a local ssh key by doing this:
```sh
ssh-keygen -t ed25519
```
- Then copy your ssh public key to the list of authorized admin keys
```sh
cat ~/.ssh/id_ed25519.pub | sc C:\ProgramData\ssh\administrators_authorized_keys
```
- **DO *NOT* THE REDIRECTION OPERATOR (>/>>)!**
    - Windows automatically encodes this as UTF-16, which will not be read by OpenSSH
    - To check if a file is encoded as UTF-16, run the following command.
    - If the first 2 numbers are 255 254 or 254 255, it is in UTF-16. Rewrite it with the `cat` | `sc` command above.
```sh
cat -Encoding Byte -TotalCount 4
```
- You should now be able to ssh by doing `ssh localhost`. To allow a different device to ssh:
    - Create the ssh key on that device (`ssh-keygen`)
    - Send the file to the host device and run this:
```sh
$path = "<INSERT-PATH-HERE>"
cat $path | ac C:\ProgramData\ssh\administrators_authorized_keys
```

### Linux
- Run this:
```sh
sudo apt update
sudo apt install openssh-server -y
sudo systemctl enable --now sshd
```
- To automatically log in to a user, run this:
```sh
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# This actually adds the key from that file
cat <KEYNAME>.pub >> ~/.ssh/authorized_keys
```
- To disable password access into your server, edit `/etc/ssh/sshd_config`
```sh
# Change these settings:
PasswordAuthentication no
ChallengeResponseAuthentication no
KbdInteractiveAuthentication no

# Then run:
sudo systemctl restart ssh
```

## Firefox settings
- Open `about:config` and set the following settings
```
ui.key.menuAccessKey = 0
```
- Then, if smooth scroll isn't working, run this and relogin
```bash
echo export MOZ_USE_XINPUT2=1 | sudo tee /etc/profile.d/use-xinput2.sh 
```

## Input Method/Mozc + Kitty
- ???

## AppImages
- **NOTE: DO NOT GET APPIMAGELAUNCHER! IT'S NOT THERE YET**
- To install an appimage yourself (get the shortcuts and such):
```bash
chmod +x ./the.AppImage
./the.AppImage --appimage-extract
cd squashfs-root
```
- Copy out the images you need into `~/.local/share/icons/scalable`
- Copy the .desktop file into `~/.local/share/applications`
```bash
mv squashfs-root ~/.local/bin/<SOMETHING-RELATED-TO-APPNAME>
cd ~/.local/bin/
ln -s ~/.local/bin/<NAME-OF-EXECUTABLE> ~/.local/usr/bin/<NAME-OF-EXECUTABLE>
```
- Save these files into `~/Documents/AppImages` for ease of reinstalling

## Allowing insecure APT packages
- Go to `/etc/apt/sources.list.d/`
- Copy the `deb/deb src` fields of the package you want to add
- Add this line:
```
deb [ allow-insecure=true ] uri suite [component1] [component2] [...]
deb-src [ allow-insecure=true ] uri suite [component1] [component2] [...]

OR

Types: deb deb-src
URIs: uri
Suites: suite
Components: [component1] [component2] [...]
allow-insecure: true
```

## ILab setup for rutgers
- Go [here](https://resources.cs.rutgers.edu/docs/setting-up-kerberos-support-for-your-home-or-office-machine/) and follow all instructions that don't involve editing files
      - (They're outdated, we have to make our own version)
      - Once you finish the section `Set up Kerberos config file` come back
- Add this to `$HOME/.ssh/config`:
```ssh
Host *
ServerAliveInterval 60
ServerAliveCountMax 3

Host ilab
HostName ilab.cs.rutgers.edu
User rnd61
GSSAPIAuthentication yes
GSSAPIDelegateCredentials yes
GSSAPITrustDNS yes
```
- Add this to `/etc/krb5.conf`:
```bash
[libdefaults]
default_realm = CS.RUTGERS.EDU
noaddresses = true
forwardable = true
renew_lifetime = 365d
default_ccache_name = /home/%{username}/.ssh/krb5cc

[realms]
CS.RUTGERS.EDU = {
kdc = https://services.cs.rutgers.edu/KdcProxy
http_anchors = FILE:/opt/local/etc/isrgrootx1.pem
}
```
- Run the following script, replacing YOUR-NET-ID and entering your password when prompted
```bash
ARMOR_PATH="$HOME/.ssh/skc-armor"
mkdir -p $ARMOR_PATH
curl -o "$ARMOR_PATH/rutty.armor" https://services.cs.rutgers.edu/cgi-bin/anonticket.pl >/dev/null 2>&1
# these values aren't real, we're basically just saying keep them active as long as the server will allow
kinit -T "$ARMOR_PATH/rutty.armor" -l 1000d -r 1000d YOUR-NET-ID@CS.RUTGERS.EDU
```
- Set up a cron job that automatically renews your auth (see [crons](#crons))
- Oh also its aliased so all you have to do is type `ssh ilab`
- Oh also did you know you can type `<CR>~.` to instantly terminate an ilab session, even if its frozen?
    - Shoutouts to Gemini such a wealth of knowledge

## Godot/Unity setup with Neovide
- I actually [cooked](https://github.com/Super-King-Crimson/neovim-gamedev-bridge/blob/main/README.md)

## Visual Novel setup (STEAM)
- Install Steam with all the driver requirements and ish
- [Download](https://github.com/sonic2kk/steamtinkerlaunch/releases/latest) and [install](https://github.com/sonic2kk/steamtinkerlaunch/wiki/Installation#local-non-root) SteamTinkerLaunch
    - Installation script (run in the same folder you downloaded to):
```bash
tar -xf steamtinkerlaunch-12.12.tar.gz
rm steamtinkerlaunch-12.12.tar.gz
cd steamtinkerlaunch-12.12
./steamtinkerlaunch lang=lang/english.txt
cp ./lang/english.txt ~/.config/steamtinkerlaunch/lang
./steamtinkerlaunch compat add
cd ..
mv steamtinkerlaunch-12.12 ~/.local/bin
cd ~/.local/bin
ln -s steamtinkerlaunch-12.12/steamtinkerlaunch steamtinkerlaunch
```
- Run `steamtinkerlaunch yad ai` to download yad (a dependency)
- restart steam
- go [to the agent download](https://github.com/0xDC00/agent/releases/tag/nightly) and download the win32-x64 version
    - unzip it and save the whole folder
- Open Steam and click on the visual novel you want to read
- Go to settings (gear or right click) > Properties > Compatibility > Force the use of a specifc Steam Play compatibility tool
    - select Steam Tinker Launch
- Change the launch options of the game to `steamtinkerlaunch %command%`
- Click Play on your game, and when the menu pops up, click Main Menu
    - At the bottom of the screen click Game Menu
    - Change the following settings:
```md
Requester timeout: 2
Use custom command: y
Custom command: path/to/agent/executable.exe
Fork custom command: y
Force Proton with custom command: y
Wait for custom command: 1

Scroll down a lot...

Proton Options > Proton version: anything
```
- click Save and Play
- Once the game launches, go to the agent window
    - Click the crosshair icon in the target box
    - Click the vn window
    - Click the script dropdown, find your game
    - Go to settings, disable Machine Translate
    - Take note of the WebSocketServer (the 4 digits after the localhost)
    - Make sure clipboard is enabled
    - You can now minimize this or throw it onto another desktop you don't need it
- Go to [this](https://renji-xd.github.io/texthooker-ui/) website
    - Click the gear
    - Change the 4 numbers at the end of ws://localhost:xxxx to the WebSocketServer 4 numbers
    - Click the play button at the top of the screen
    - Start reading your visual novel, text should appear in the browser for you to scan with Yomitan!
- ***Note:*** if the notifications get annoying, go to `~/.config/steamtinkerlaunch/global.conf` and set `USENOTIFIER="0"`

## Retired
- vscode(ium)
- wondershaper
- Git Credential Manager
    - Just use ssh for god's sake
- ahk_x11
    - Weird bug where when i clicked my Ctrl-h bind too fast it held down control and made all my keymaps weird
- AppImageLauncher
    - Broke `man` for some reason
- neovide
    - Replaced by kitty
- steam
    - just get it on windows guy
- input remapper
    - replaced with keyd, wasn't working on kde
