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
pacman -S --noconfirm ranger w3m
pacman -S --noconfirm pulseaudio pulseaudio-alsa
pacman -S --noconfirm htop
pacman -S --noconfirm screen
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
pacman -S --noconfirm feh
pacman -S --noconfirm openssh
pacman -S --noconfirm openvpn easy-rsa

# Install xorg and graphics
pacman -S --noconfirm xorg xorg-xinit libva-intel-driver mesa
pacman -S --noconfirm xf86-video-intel xf86-input-synaptics

# Install fonts
pacman -S --noconfirm ttf-droid ttf-dejavu

# Install desktop & window manager
pacman -S --noconfirm i3-wm i3status i3lock dmenu

# Install GTK-Theme and Icons
pacman -S --noconfirm arc-gtk-theme arc-icon-theme

# Install graphical programs
pacman -S --noconfirm rxvt-unicode
pacman -S --noconfirm zenity
pacman -S --noconfirm lxappearance
pacman -S --noconfirm pavucontrol
pacman -S --noconfirm gnome-system-monitor
pacman -S --noconfirm lxrandr
pacman -S --noconfirm firefox
pacman -S --noconfirm gnome-calculator
pacman -S --noconfirm libreoffice-fresh hunspell-de
pacman -S --noconfirm evince
pacman -S --noconfirm smplayer
pacman -S --noconfirm jdk8-openjdk gradle
pacman -S --noconfirm intellij-idea-community-edition
pacman -S --noconfirm gedit
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

# Add Cron job
{ crontab -l -u $userName; echo "*/5 * * * * env DISPLAY=:0  /home/$userName/.bin/BatteryWarning.sh"; } | crontab -u $userName -

# Configure synaptics touchpad
cp /i-PUSH-arch-setup-i3wm/config/50-synaptics.conf /etc/X11/xorg.conf.d/

# Copy all home folder files
cp -R /i-PUSH-arch-setup-i3wm/config/home/. /home/$userName/

# Compile the rsync extension
g++ /home/$userName/.bin/Rsync.cpp -o /home/$userName/.bin/Rsync
rm /home/$userName/.bin/Rsync.cpp

# Change premissions
chown -R $userName:$userName /home/$userName/
chmod -R 700 /home/$userName/.bin/

# Install Visual Studio code
wget "https://aur.archlinux.org/cgit/aur.git/snapshot/visual-studio-code-bin.tar.gz" -O - | tar xz -C /tmp
su - $userName -c 'cd /tmp/visual-studio-code-bin && makepkg -s'
pacman -U --noconfirm /tmp/visual-studio-code-bin/visual-studio-code-bin*.pkg.tar.xz
rm -R /tmp/visual-studio-code-bin

# Install Sublime text editor
# wget "https://aur.archlinux.org/cgit/aur.git/snapshot/sublime-text-dev.tar.gz" -O - | tar xz -C /tmp
# su - $userName -c 'cd /tmp/sublime-text-dev && makepkg -s'
# pacman -U --noconfirm /tmp/sublime-text-dev/sublime-text-dev*.pkg.tar.xz
# rm -R /tmp/sublime-text-dev

# Clean up and optimize pacman
pacman -Sc --noconfirm && pacman-optimize
