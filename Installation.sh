#!/bin/bash

echo "Installation"

# Set the hostname
read -p "Set hostname: " hostName
echo $hostName > /etc/hostname

# Set the root password
echo "Set root password:"
passwd

# Set timezone (or use tzselect)
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

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

# Configure mkinitcpio
sed -i '/^HOOKS=/s/block/block keymap encrypt/' /etc/mkinitcpio.conf

# Create a new initial RAM disk
mkinitcpio -p linux

# Install microcode for Intel processors
pacman -Syyu --noconfirm
pacman -S --noconfirm intel-ucode

# Install and configure the Bootloader
bootctl install
ROOT="$(find -L /dev/disk/by-partuuid -samefile /dev/sda3 | cut -d/ -f5)"
echo "title Arch Linux" > /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd /intel-ucode.img" >> /boot/loader/entries/arch.conf
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options cryptdevice=PARTUUID=$ROOT:root root=/dev/mapper/root quite rw" >> /boot/loader/entries/arch.conf
echo "default arch" > /boot/loader/loader.conf
echo "editor 0" >> /boot/loader/loader.conf

# Run Post-Installation.sh
/i-PUSH-arch-setup-i3wm/Post-Installation.sh
