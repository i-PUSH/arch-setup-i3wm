#!/bin/bash

USR=$(ls /home/)

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
systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket

# Enable UFW
systemctl enable ufw
ufw default deny
ufw enable

# Configure Keyboardlayout
localectl set-x11-keymap de pc105 nodeadkeys

# Remove installation files
rm -R /i-PUSH-arch-setup-i3wm/

# Finish Installation
read -p "Finish!!! Press enter to reboot..."

# Pipe all output into log file
} |& tee -a /home/$USR/Arch-Installation.log

chown $USR:$USR /home/$USR/Arch-Installation.log
chmod 600 /home/$USR/Arch-Installation.log

reboot
