#!/bin/bash

echo "Post-Installation"

# Create user and set password
read -p "Set user name: " userName
useradd -m -G wheel,storage,audio,video -s /bin/bash $userName
echo "Set user password:"
passwd $userName

# Install LTS kernel
pacman -S --noconfirm linux-lts

# Install header files and scripts for building modules for Linux kernel
pacman -S --noconfirm linux-headers linux-lts-headers

# Install important services
pacman -S --noconfirm acpid ntp cronie avahi nss-mdns dbus cups ufw tlp

# Configure the network
pacman -S --noconfirm dialog dhclient 
pacman -S --noconfirm networkmanager network-manager-applet
pacman -S --noconfirm gnome-keyring libsecret seahorse

# Install command line and ncurses programs
pacman -S --noconfirm sudo
pacman -S --noconfirm bash-completion
pacman -S --noconfirm tree
pacman -S --noconfirm atool
pacman -S --noconfirm ranger w3m
pacman -S --noconfirm pulseaudio pulseaudio-alsa
pacman -S --noconfirm htop
pacman -S --noconfirm tmux
pacman -S --noconfirm youtube-dl
pacman -S --noconfirm wget curl axel
pacman -S --noconfirm rsync
pacman -S --noconfirm scrot
pacman -S --noconfirm xdotool
pacman -S --noconfirm xclip xsel
pacman -S --noconfirm lshw
pacman -S --noconfirm acpi
pacman -S --noconfirm nmap
pacman -S --noconfirm vim
pacman -S --noconfirm ffmpeg
pacman -S --noconfirm git
pacman -S --noconfirm go go-tools
pacman -S --noconfirm feh
pacman -S --noconfirm openssh
pacman -S --noconfirm openvpn easy-rsa

# Install xorg and graphics
pacman -S --noconfirm xorg xorg-xinit libva-intel-driver mesa
pacman -S --noconfirm xf86-video-intel xf86-input-synaptics

# Install fonts
pacman -S --noconfirm ttf-droid ttf-ionicons ttf-dejavu

# Install desktop & window manager
pacman -S --noconfirm i3-gaps i3status i3lock dmenu compton

# Install GTK-Theme and Icons
pacman -S --noconfirm arc-gtk-theme hicolor-icon-theme papirus-icon-theme

# Install graphical programs
pacman -S --noconfirm rxvt-unicode termite
pacman -S --noconfirm dunst
pacman -S --noconfirm ghex
pacman -S --noconfirm lxappearance
pacman -S --noconfirm pavucontrol
pacman -S --noconfirm gnome-system-monitor
pacman -S --noconfirm lxrandr
pacman -S --noconfirm firefox
pacman -S --noconfirm gnome-calculator
pacman -S --noconfirm libreoffice-fresh hunspell-de
pacman -S --noconfirm evince
pacman -S --noconfirm smplayer
pacman -S --noconfirm jdk8-openjdk gradle intellij-idea-community-edition
pacman -S --noconfirm gimp
pacman -S --noconfirm gparted dosfstools ntfs-3g mtools
pacman -S --noconfirm pcmanfm-gtk3 gvfs udisks2 libmtp mtpfs gvfs-mtp
pacman -S --noconfirm file-roller unrar p7zip lrzip
pacman -S --noconfirm gutenprint ghostscript gsfonts
pacman -S --noconfirm system-config-printer gtk3-print-backends simple-scan
pacman -S --noconfirm gpicview
pacman -S --noconfirm transmission-gtk
pacman -S --noconfirm qemu
# pacman -S --noconfirm docker
# pacman -S --noconfirm virtualbox virtualbox-host-modules-arch virtualbox-guest-iso

# Add user to docker group
# gpasswd -a $userName docker

# Add user to VirtualBox group
# gpasswd -a $userName vboxusers

# Avahi provides local hostname resolution using a "hostname.local" naming scheme
sed -i '/hosts:/s/mymachines/mymachines mdns_minimal [NOTFOUND=return]/' /etc/nsswitch.conf

# Configure sudo
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Allow to execute shutdown without password
echo "$userName ALL = NOPASSWD: /usr/bin/shutdown" >> /etc/sudoers

# Add Cron job for monitoring battery
{ crontab -l -u $userName; echo "*/5 * * * * env DISPLAY=:0  /home/$userName/.bin/BatteryWarning.sh"; } | crontab -u $userName -

# Disable powersave, prevent the WiFi card from automatically sleeping and halting connection
echo "options rtl8723be fwlps=0" > /etc/modprobe.d/rtl8723be.conf

# Configure synaptics and intel drivers
cp -R /i-PUSH-arch-setup-i3wm/config/xorg/. /etc/X11/xorg.conf.d/

# Copy all home folder files
cp -R /i-PUSH-arch-setup-i3wm/config/home/. /home/$userName/

# Compile the rsync extension
g++ /home/$userName/.bin/Rsync.cpp -o /home/$userName/.bin/Rsync
rm /home/$userName/.bin/Rsync.cpp

# Compile PwdGenPro
git clone https://github.com/i-PUSH/PwdGenPro-Java.git /tmp/PwdGenPro
gradle build -p /tmp/PwdGenPro/
cat /tmp/PwdGenPro/Payload/stub.sh /tmp/PwdGenPro/build/libs/*.jar > /home/$userName/.bin/pwdGenPro

# Change premissions
chown -R $userName:$userName /home/$userName/
chmod -R 700 /home/$userName/.bin/

# Install Cower
wget "https://aur.archlinux.org/cgit/aur.git/snapshot/cower.tar.gz" -O - | tar xz -C /tmp
chown -R $userName:$userName /tmp/cower/
sudo -u $userName bash -c 'cd /tmp/cower && gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53 && makepkg -s'
pacman -U --noconfirm /tmp/cower/cower*.pkg.tar.xz

# Install Polybar
pacman -S --noconfirm jsoncpp libuv rhash cmake
wget "https://aur.archlinux.org/cgit/aur.git/snapshot/polybar.tar.gz" -O - | tar xz -C /tmp
chown -R $userName:$userName /tmp/polybar/
sudo -u $userName bash -c 'cd /tmp/polybar && makepkg -s'
pacman -U --noconfirm /tmp/polybar/polybar*.pkg.tar.xz

# Install Visual Studio code
pacman -S --noconfirm gconf
wget "https://aur.archlinux.org/cgit/aur.git/snapshot/visual-studio-code-bin.tar.gz" -O - | tar xz -C /tmp
chown -R $userName:$userName /tmp/visual-studio-code-bin/
sudo -u $userName bash -c 'cd /tmp/visual-studio-code-bin && makepkg -s'
pacman -U --noconfirm /tmp/visual-studio-code-bin/visual-studio-code-bin*.pkg.tar.xz

# Install Sublime text editor
wget "https://aur.archlinux.org/cgit/aur.git/snapshot/sublime-text-dev.tar.gz" -O - | tar xz -C /tmp
chown -R $userName:$userName /tmp/sublime-text-dev/
sudo -u $userName bash -c 'cd /tmp/sublime-text-dev && makepkg -s'
pacman -U --noconfirm /tmp/sublime-text-dev/sublime-text-dev*.pkg.tar.xz

# Clean up and optimize pacman
pacman -Sc --noconfirm && pacman-optimize
