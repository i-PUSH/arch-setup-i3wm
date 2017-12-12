#!/bin/bash

{
echo "Final-Installation"

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
systemctl enable NetworkManager.service

# Configure Keyboardlayout
localectl set-x11-keymap de pc105 nodeadkeys

# Remove installation files
rm -R /i-PUSH-arch-setup-i3wm/

# Finish Installation
read -p "Finish!!! Press enter to reboot..."

# Pipe all output into log file
} |& tee -a /home/$(ls /home/)/Arch-Installation.log

reboot
