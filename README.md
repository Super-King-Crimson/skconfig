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
- Encryption guide with TPM2.0 (seamless like Windows!)
- Tons of other [goodies](#goodies)!
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
sudo apt install gnupg curl wget tmux openssh-server openssh-client sshfs gcc make clang unzip zip bat eza ripgrep xclip xdotool restic htop steam steamcmd pass -y
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
java -Xms2G -Xmx2G -jar server.jar --nogui
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
# You could also get a backend so flatpaks work with your distro's software manager (i.e. plasma-discover-backend)
# i just use flathub.org tho
sudo apt install flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```
- Then log out and log in to make everything exist again.

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

### Input Method
- ???

## Firefox settings/smooth scroll
- Open `about:config` and set the following settings
```
ui.key.menuAccessKey = 0
```
- Then, if smooth scroll isn't working, run this and relogin
```bash
echo export MOZ_USE_XINPUT2=1 | sudo tee /etc/profile.d/use-xinput2.sh 
```

# Goodies
- This is for the more complicated stuff. Dualbooting, encryption, all that jazz.

## Encryption with TPM2.0
- If you like having an encrypted Linux laptop but don't like typing two passwords, this is for you!
- The Debian installer actually allows you to encrypt your devices at setup, so to avoid having to be a Linux guru, just backup your important files and reinstall.

### Reinstall notes
- Make sure to put `/boot` on a 1GiB partition, and make your EFI partition mounted at `/boot/efi` and also make it 1GiB.
- Then, [set up systemd-boot](#optional-switching-to-systemd-boot-debian), this setup requires it.

### Secure Boot
- We will have to remove GRUB for this. Run the following:
```bash
sudo apt purge --allow-remove-essential grub-common grub-efi-amd64 grub-efi-amd64-bin grub-efi-amd64-signed grub2-common
sudo apt autoremove --purge
```
- Now, run `sudo dpkg-reconfigure systemd-boot`. Now that GRUB is gone, this will generate a shim-signed binary. You can now turn on Secure Boot, everything should work fine.

### Switching to dracut
- Install `dracut`, an alternative to `initramfs` that loads the TPM drivers early and reads them to unlock your computer.
    - This probably doesn't mean anything to you (sure as hell doesn't for me). Just follow the instructions.
    - Make sure you don't lose power. If your computer shuts down at this point your system will become unbootable.
```bash
sudo apt install dracut-core dracut -y
```
- We have to configure dracut. We will be editing two files, make sure they match exactly.
- Open up `/etc/crypttab`, and take note of the crypt name (first column) and the UUID.
- This also assumes you're using ext4.
    - ***If you're using BTRFS***, add btrfs as a dracut module (don't forget the trailing space!) and add the root options with your root subvolume to `/etc/kernel/cmdline`.
```bash
# /etc/dracut.conf.d/setup.conf
hostonly="yes"
hostonly_cmdline="no"
add_dracutmodules+=" systemd systemd-initrd crypt drm "
```
```bash
# /etc/kernel/cmdline
rd.luks.name=<CRYPT-UUID>=<CRYPT-NAME> root=/dev/mapper/<CRYPTNAME> rw quiet
```
- Nearly there. Now we have to regenerate our kernel image with dracut.
```bash
cd /boot
ls
```
- For each kernel image you have (`/boot/vm-linuz-KERNEL-VERSION>`), run:
```bash
kernel-install add <KERNEL-VERSION> /boot/vmlinuz-<KERNEL-VERSION>
```

### Enrolling motherboard chip
- Finally, install the necessary tools to enroll your device. Make sure Secure Boot is on.
```bash
sudo apt install tpm2-openssl tpm2-tools
```
- Now, find your encrypted partition and run this to link it to the TPM chip on your motherboard:
```bash
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs="1+7" /dev/<YOUR-CRYPT-DEVICE>
```
- Here, the 1+7 means motherboard configuration + Secure Boot status.
- At this point you should probably change your password to something more secure:
```bash
sudo cryptsetup luksAddKey /dev/<YOUR-CRYPT-DEVICE>
# input a secure password, it can be as long as you like
```
- And don't forget to remove the old password:
```bash
sudo cryptsetup luksRemoveKey /dev/<YOUR-CRYPT-DEVICE>
# input the insecure password
```

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
- First, ensure you have systemd-boot. You may already have it, but if you're on Debian you start with `GRUB` instead. The following guide will help you switch.

### Optional: Switching to systemd-boot (DEBIAN)
- First, we need to make a `/etc/kernel/cmdline`, which informs `systemd-boot` how our computer is structured and where everything is mounted.
    - Luckily, the Linux kernel stores the parameters it is passed for this at `/proc/cmdline`, so we can run the following command to do most of the work for us:
```bash
cat /proc/cmdline >> TEMPFILE
```
- Now edit `TEMPFILE`, remove anything with `initrd=...` or `BOOT_IMAGE=...`.
- Now copy it back:
```bash
sudo mv -f TEMPFILE /etc/kernel/cmdline
```
- You should be good to install `systemd-boot` now.
```bash
sudo apt update
sudo apt install systemd-boot efibootmgr
```
- Remember you can run `sudo apt --fix-broken install` and then re-run the first install command if it doesn't work.
- Reboot to see if systemd works. ***Make sure to turn off Secure Boot***, as Secure Boot will not work with this setup by default.
- Check [this out](#secure-boot) if you want to keep Secure Boot enabled.
- Additionally, check [this out](https://www.freedesktop.org/software/systemd/man/latest/loader.conf.html) to see the options for `/boot/efi/loader/loader.conf`.

### Shrinking your partitions
- You will need to make some space for your new OS. The easiest way to do this is by getting another ISO image that comes with the `GParted` application (linux mint) and shrinking the large partition using a GUI, but that's too easy. We're Linux users!
    - Instead, flash Ventoy on a USB, put Arch Linux on it, then boot into it.

#### Shrinking filesystem
- Shrinking a partition must be done from the inside out. First the filesystem, then any encrypted volumes (if you have any), then the partition itself.

##### Optional: Shrinking encrypted volume (LUKS)
- If the partition you want to resize is encrypted with LUKS, you'll have to open and map it:
```bash
cryptsetup open /dev/sdXN cryptroot
```
- Now proceed, replacing `/dev/sdXN` with `/dev/mapper/cryptroot`.
---

#### Shrinking filesystem, cont.
- You can find the partition you want to shrink by running `lsblk -o NAME,SIZE,FSTYPE`. Now mount it to `/mnt`.
```bash
mount /dev/sdXN /mnt
```
- Take note of its size with `df -h /mnt`, then unmount it with `umount /mnt`.
- Now resize it (leave at least 100GiB for your other OS, but you probably want more).
    - Additionally, leave yourself a safety buffer so you don't delete any data by accident (so in our case, we could shrink it by 102GiB instead of 100GiB).
```bash
e2fsck -f /dev/sdXN # required
resize2fs /dev/sdXN ???G
```
- If using encryption, don't forget to close the crypt here so the block device is no longer in use:
```bash
cryptsetup close cryptroot
```

#### Shrinking partition
- Now you want to shrink the partition: run `fdisk /dev/sdX`.
- Remember, you want the partition size to be 2GiB bigger than your filesystem. Be careful!
```
p - print partition table (to get size and partition number)
e - resize partition
q - quit and discard changes
w - quit and write changes
```
- Now you can do whatever you want with the free space.

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
- input remapper
    - replaced with keyd, wasn't working on kde

## TODO
### Optional: Encrypting over a drive in use (LUKS)
- Again, back up important files. Make sure you have a consistent source of power, too.
- Flash Ventoy onto a drive, put an Arch Linux ISO on it, and boot into it.

#### /efi and /boot
- First, you probably have to move /boot and /efi off of your root partition, otherwise your system won't even have the tools to decrypt your data.
- Run `fdisk /dev/sdXN` and enter p to check the partition table.
    - Our goal is to have a ~1GiB Linux filesystem partition, and a ~1GiB EFI System partition.
    -  If you don't have those, create them:
```
n - add new partition
p - print partition table
t - change partition type
w - write and quit
q - discard and quit
```
- Now create some filesystems so we can write data into them:
```bash
mkfs.fat -F 32 /dev/sdXN   # into the newly created EFI system partition
mkfs.ext4 /dev/sdXN        # into the newly created Linux filesystem partition
```
- If you have two EFI system partitions now, mount the one that you didn't just make to `/mnt/efi_old` and the new one to `/mnt/efi`, and copy all the files from old to new.
```bash
mkdir -p /mnt/efi_old /mnt/efi
mount /dev/sdXM /mnt/efi_old
mount /dev/sdXN /mnt/efi
# don't forget the -a option, it does system timestamps and everything
cp -a /mnt/efi_old/. /mnt/efi
# unmounts everything
umount -R /mnt
rm -rf /mnt/*
```
- And do the same with the a small EFI system partition if it was a smaller boot partition.
- Now use `fdisk` to remove the partitions we don't need.

    - Shrink your root partition by 8GiB using [this guide](#shrinking-your-partitions) (so filesystem should shrink by 9GiB).
- Now run `fdisk`, and create a new 1GiB partition for `/boot`
- Now, run the following:
```bash
cryptsetup reencrypt --encrypt --type luks2 --reduce-device-size 32m /dev/sdXN
```
- Confirm, and ensure for the whole process you do not lose power.
- Once you're done, you have a few more things to do.

- If you don't want to run dangerous commands and dig through system files, reinstall your OS and set up encryption that way. Make sure to create separate 1GiB partitions for `/efi` and `/boot`.
