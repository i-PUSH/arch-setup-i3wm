#!/bin/bash

echo "Post-Installation"

# Create user and set password
read -p "Set user name: " userName
useradd -m -G wheel,storage,audio,video -s /bin/bash $userName
echo "Set user password:"
passwd $userName

# Install header files and scripts for building modules for Linux kernel
pacman -S --noconfirm linux-headers

# Install important services
pacman -S --noconfirm acpid ntp cronie avahi dbus cups ufw tlp

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
pacman -S --noconfirm xorg xorg-xinit mesa
pacman -S --noconfirm xf86-video-intel xf86-input-synaptics

# Install fonts
pacman -S --noconfirm ttf-dejavu

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
pacman -S --noconfirm intellij-idea-community-edition gradle
pacman -S --noconfirm gimp
pacman -S --noconfirm gparted dosfstools ntfs-3g mtools
pacman -S --noconfirm pcmanfm-gtk3 gvfs udisks2
pacman -S --noconfirm file-roller unrar p7zip lrzip
pacman -S --noconfirm gutenprint ghostscript gsfonts
pacman -S --noconfirm system-config-printer gtk3-print-backends simple-scan
pacman -S --noconfirm gpicview
pacman -S --noconfirm transmission-gtk
pacman -S --noconfirm virtualbox virtualbox-host-modules-arch virtualbox-guest-iso

# Add User-"user" to VirtualBox-Group
gpasswd -a $userName vboxusers

# Configure sudo
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Allow to execute shutdown without password
echo "$userName ALL = NOPASSWD: /usr/bin/shutdown" >> /etc/sudoers

# Add Cron job
{ crontab -l -u $userName; echo "*/5 * * * * env DISPLAY=:0  /home/$userName/.bin/BatteryWarning.sh"; } | crontab -u $userName -

# Configure synaptics touchpad
cp /i-PUSH-arch-setup-i3wm/config/50-synaptics.conf /etc/X11/xorg.conf.d/

# Copy all files
cp -R /i-PUSH-arch-setup-i3wm/config/home/. /home/$userName/
cp -R /i-PUSH-arch-setup-i3wm/config/sublime-text/ /home/$userName/

# Change premissions
chown -R $userName:$userName /home/$userName/
chmod -R 700 /home/$userName/.bin/

# Install Sublime text editor
su - $userName -c 'cd /home/$1/sublime-text/ && makepkg -s' -- -- $userName
pacman -U --noconfirm /home/$userName/sublime-text/sublime*.pkg.tar.xz
rm -R /home/$userName/sublime-text/

# Clean up and optimize pacman
pacman -Sc --noconfirm && pacman-optimize
