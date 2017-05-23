#!/bin/bash

# Installation

# Set the hostname
read -p "Set hostname: " hostName
echo $hostName > /etc/hostname

# Set the root password
echo "Set root password:"
passwd

# Set timezone (or use tzselect)
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Set locales and generate them
echo LANG=de_DE.UTF-8 > /etc/locale.conf
echo LANGUAGE=de_DE >> /etc/locale.conf
echo KEYMAP=de-latin1 > /etc/vconsole.conf
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "en_US ISO-8859-1" >> /etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_DE ISO-8859-1" >> /etc/locale.gen
locale-gen

# Fix pacman: Signature is unknown trust
rm -Rf /etc/pacman.d/gnupg
pacman-key --init
pacman-key --populate archlinux

# Create a new initial RAM disk
mkinitcpio -p linux

# Install microcode for Intel processors
pacman -S intel-ucode

# Install and configure the Bootloader
bootctl install
echo "title Arch Linux" > /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd /intel-ucode.img" >> /boot/loader/entries/arch.conf
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options root=/dev/sda2 rw" >> /boot/loader/entries/arch.conf
echo "default arch" > /boot/loader/loader.conf

# Exit the chroot environment and reboot (optionaly add: umount -R /mnt)
echo "1. exit | 2. umount -R /mnt | 3. reboot | 4. Execute Post-Installation.sh"
