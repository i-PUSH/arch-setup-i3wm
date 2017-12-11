#!/bin/bash

echo "Post-Installation"

# Create user and set password
read -p "Set user name:" userName
useradd -m -G wheel,storage,audio,video -s /bin/bash $userName
echo "Set user password:"
passwd $userName

# Header files and scripts for building modules for Linux kernel
pacman-optimize
pacman -Syyu
pacman -S linux-headers

# Install important services
pacman -S --noconfirm acpid ntp cronie avahi dbus cups ufw tlp

# Enable important services
systemctl enable acpid
systemctl enable ntpd
systemctl enable cronie
systemctl enable avahi-daemon
systemctl enable fstrim.timer

# Enable TLP
systemctl enable tlp.service
systemctl enable tlp-sleep.service
systemctl disable systemd-rfkill.service

# Enable UFW
systemctl enable ufw
ufw default deny
ufw enable

# Configure the network
pacman -S --noconfirm dialog dhclient 
pacman -S --noconfirm networkmanager network-manager-applet
pacman -S --noconfirm gnome-keyring libsecret seahorse
systemctl enable NetworkManager.service

# Install command line and ncurses programs
pacman -S --noconfirm sudo
pacman -S --noconfirm bash-completion
pacman -S --noconfirm tree
pacman -S --noconfirm ranger w3m
pacman -S --noconfirm pulseaudio pulseaudio-alsa
pacman -S --noconfirm htop
pacman -S --noconfirm screen
pacman -S --noconfirm wget curl axel youtube-dl
pacman -S --noconfirm scrot
pacman -S --noconfirm xdotool
pacman -S --noconfirm xclip xsel
pacman -S --noconfirm lshw
pacman -S --noconfirm acpi
pacman -S --noconfirm nmap
pacman -S --noconfirm openssh
pacman -S --noconfirm vim
pacman -S --noconfirm ffmpeg
pacman -S --noconfirm git
pacman -S --noconfirm feh
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
#pacman -S --noconfirm gnome-system-monitor
pacman -S --noconfirm lxrandr
#pacman -S --noconfirm firefox
#pacman -S --noconfirm gnome-calculator
#pacman -S --noconfirm libreoffice-fresh hunspell-de
pacman -S --noconfirm evince
#pacman -S --noconfirm smplayer
#pacman -S --noconfirm geany
#pacman -S --noconfirm eclipse-java gradle
#pacman -S --noconfirm gimp
pacman -S --noconfirm gparted dosfstools ntfs-3g mtools
pacman -S --noconfirm pcmanfm-gtk3 gvfs udisks2
pacman -S --noconfirm file-roller unrar p7zip lrzip
pacman -S --noconfirm gutenprint ghostscript gsfonts
pacman -S --noconfirm system-config-printer gtk3-print-backends simple-scan
pacman -S --noconfirm gpicview
#pacman -S --noconfirm transmission-gtk
#pacman -S --noconfirm virtualbox virtualbox-host-modules-arch virtualbox-guest-iso

# Install Sublime text editor
cd ./config/sublime-text/ && makepkg -si

# Add User-"user" to VirtualBox-Group
#gpasswd -a $userName vboxusers

# Configure sudo
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Allow to execute shutdown without password
echo "$userName ALL = NOPASSWD: /usr/bin/shutdown" >> /etc/sudoers

# Add Cron job
{ crontab -l -u $userName; echo "*/5 * * * * env DISPLAY=:0  /home/$userName/.bin/BatteryWarning.sh"; } | crontab -u $userName -

# Configure Keyboardlayout
localectl set-x11-keymap de pc105 nodeadkeys

# Configure synaptics touchpad
cp ./config/50-synaptics.conf /etc/X11/xorg.conf.d/

# Copy all files
cp -R ./config/home/. /home/$userName/

# Change premissions
chown $userName:$userName -R /home/$userName/
chmod -R 700 /home/$userName/.bin/

# Remove installation files
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
rm -R $DIR
