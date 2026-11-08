# Introduction
- Hey there! These are my dotfiles :)
    - second iteration because i accidentally leaked my personal email on the other one :skull:
- I've actually gone to special lengths to make my config easy to understand, beginner friendly, and quick to setup on a new device.
- This guide assumes you are using ***Debian***, but most stuff should work for all linux distros.

## Features
- Neovim config to emulate an IDE with intuitive controls
- WSL compatibility
- tons of `bash` aliases and functions
- [kitty](https://sw.kovidgoyal.net/kitty/) config that seamlessly links to neovim
- [keyd](https://github.com/rvaiya/keyd) binds
- Useful scripts (see the `Binaries` folder)
- Tons of other [goodies](#Goodies)!
---
- My goal is to make my configuration understandable and easy to reinstall.
- Feel free to snoop around! Take what you like, leave what's stupid.

# Getting Started
## Optional: barebones Debian setup
- If you are setting up a Debian server or otherwise have a barebones install without internet or other packages, we have extra work to do.
- This assumes you are logged in as root (`sudo -i` or `su -`).

### Internet
- First we gotta find the name linux gave to our wifi chip (its ***Network Interface Name***):
```bash
ip link show
```
- It should start with a w.
- Now, we gotta connect to the internet. In debian that's controlled with `/etc/network/interfaces`
- Ensure this is in the file:
```
allow-hotplug <INTERFACE-NAME>
iface <INTERFACE-NAME> inet dhcp
    wpa-ssid <WIFI-CONNECTION-NAME>
    wpa-psk <WIFI-PASSWORD-HERE>
```
- Now apply your changes by bringing the network interface down and up again.
```bash
ifdown <INTERFACE-NAME> --force
ifup <INTERFACE-NAME>
```

### Essential Packages
- Let's grab some packages we may not have:
```bash
apt install sudo tmux curl wget git gnupg -y
```

### Setting up sudo
- Now we gotta make sudo work for non-root users.
    - If you haven't already, run `adduser <USERNAME>` to create a non-root user.
```bash
groupadd sudo
usermod -aG sudo skc # replace with <USERNAME>
```
- Now, run `visudo` and ensure this line is in the file, uncommented.
```
%sudo ALL=(ALL:ALL) ALL
```
- Now ensure the user you create actually has the ability to execute commands as sudo.
- Log in as the user by doing `su <USERNAME>`, then execute a sudo command.
- If it succeeds, go ahead and lock the root account. We don't need it anymore (use `sudo -i` to login as root instead)!
```bash
sudo passwd -l root
logout
```

# Downloads and Installations
- To quickly download and install these dotfiles, run the following:
```bash
cd
git clone --no-checkout https://github.com/Super-King-Crimson/skconfig.git
mv skconfig/.git ./
rm -rf skconfig
git reset --hard HEAD
mv .git .skconfig
```
- Now restart your shell.

## APT packages
- First, add `contrib non-free` to your repository in `/etc/apt/sources.list`
```
deb ... <DEBIAN-VERSION> main contrib non-free ...
deb-src ... <DEBIAN-VERSION> main contrib non-free ...
```
- Then, enable i386 architecture:
```bash
sudo dpkg --add-architecture i386
```
- Upgrade all your current packages:
```bash
sudo apt update && sudo apt upgrade -y
```
- Now let's grab our pacakges!
```bash
sudo apt install gnupg curl wget tmux openssh-server openssh-client sshfs gcc make clang unzip zip bat eza ripgrep xclip xdotool restic htop steam steamcmd -y
```

## Node Version Manager
```bash
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
```
- Then, to install:
```bash
nvm install node && nvm alias default node
npm install -g --allow-scripts=tree-sitter-cli tree-sitter-cli
```
- To fully set this up, run `nvm`, close your shell, open it, and run `nvm` again.

## safe-rm
```bash
curl -sSL https://github.com/Super-King-Crimson/safe-rm/releases/download/v0.0.1/makemesafe.sh -o makemesafe.sh
chmod +x makemesafe.sh
sudo ./makemesafe.sh
rm makemesafe.sh
```

## Neovim
```bash
mkdir -p ~/.local/bin
cd ~/.local/bin
rm -rf nvim nvim-linux*
# replace with architecture
wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
tar -xf nvim*.tar*
rm nvim*.tar*
ln -sf ~/.local/bin/nvim*/bin/nvim ~/.local/bin/nvim
```

## Minecraft Server
- Grab the MC server version from https://mcversions.net:
```bash
sudo apt install openjdk-25-jdk
java -Xms4G -Xmm4G -jar server.jar --nogui
```
- Then install and run `playit` to set up:
```bash
curl -fsSL https://packages.playit.gg/install.sh | bash
```

## Rust
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

## Rokit
```bash
wget -qO- https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash
```

## Dotnet
- https://learn.microsoft.com/en-us/dotnet/core/install/linux

## Parsec
- https://parsec.app/downloads

## Tailscale
```bash
wget -qO- https://tailscale.com/install.sh | sh
```

## Flatpak
```bash
# or gnome backend
sudo apt install flatpak
flatpak remote-delete flathub
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

## keyd
```bash
git clone https://github.com/rvaiya/keyd
cd keyd
make && sudo make install
cd ..
/bin/rm -rf keyd
sudo systemctl enable --now keyd

sudo /bin/rm -rf /etc/keyd
sudo ln -fs ~/.config/keyd /etc/keyd
sudo keyd reload
```

## Kitty
```bash
mkdir -p ~/.local/bin
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
echo 'kitty.desktop' > ~/.config/xdg-terminals.list
```

# Goodies
- This is for the more complicated stuff. Setting up ssh, Windows, encryption, all that jazz.

## Encrypted BTRFS fstab
```bash
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# systemd generates mount units based on this file, see systemd.mount(5).
# Please run 'systemctl daemon-reload' after making changes here.
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
/dev/mapper/sda3_crypt /               btrfs   defaults,noatime,compress=zstd,subvol=@rootfs 0       0
# swapfile
/dev/mapper/sda3_crypt /swap btrfs defaults,noatime,subvol=@swap 0 0
/swap/swapfile none swap defaults 0 0
# /boot was on /dev/sda1 during installation
UUID=??? /boot           ext4    defaults        0       2
# /boot/efi was on /dev/sda2 during installation
UUID=???  /boot/efi       vfat    umask=0077      0       1
```

## Dual Booting
- Just get systemd bro. It's incredibly simple!
- TODO: actually put a guide here

## Encryption with TPM2.0
- If you like having an encrypted laptop but don't like typing two passwords, this is for you!
- First off, backup all your files and settings and reinstall your OS. You can also just encrypt it in place, but there's a lot of risk with that.
- Create a lenient password because we're going to generate a better one later.
- Once you've done that, set up `systemd-boot` if it isn't already set up. You can't use TPM2.0 without systemd
    - The installation will heavily depend on your OS, so it is encouraged to use an LLM for this.
- Next, install the necessary tools, and verify that your device can see your TPM chip:
```bash
sudo apt install tpm2-openssl tpm2-tools
sudo cat /sys/class/tpm/tpm0/tpm_version_major   # should output 2
```
- Now, find your encrypted partition (not the mapped decrypted one, the base encrypted one) and run this to link it to the TPM:
```bash
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs="1+7" /dev/YOUR-DEVICE-HERE
```
- Here, the 1+7 means motherboard configuration + secure boot status (must be enabled)
- Now, if you don't have it installed, use `dracut` to generate an `initramfs` that loads the TPM drivers early and read them to unlock your computer.
```bash
sudo apt install dracut-core dracut -y
sudo dracut -f --regenerate-all
```
- If this doesn't work, log in as root (using `sudo -i`), set the proper systemd layout rule, and delete all previous versions of the kernel in your bootloader. In Debian, you'd do this like so:
```bash
# root
sudo mkdir -p /etc/kernel
echo "layout=bls" | sudo tee /etc/kernel/config

cd /boot/efi/$(cat /etc/machine-id)
rm -rf ./*

kernel-install add $(uname -r) /boot/vmlinuz-$(uname -r)

logout
```
- Almost done! Now let's update `/etc/crypttab` so it knows about TPM.
- Add `,tpm2-device=auto` to the end of your crypt tab options, and we're done!
```bash
sudoedit /etc/crypttab
```
- Now let's make a secure password and switch our password to that
```bash
openssl rand -base64 32 | tee LUKSKEY
cat LUKSKEY | xclip -sel clipboard
sudo cryptsetup luksChangeKey /dev/YOUR-DRIVE
# type old key
# paste new key
```
- ***Make sure to save `LUKSKEY` to another safe location so you don't get locked out of your drive!***

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

## Firefox settings/smooth scroll
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
