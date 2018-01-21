#!/bin/bash

{
echo "Pre-Installation"

# Update the system clock
timedatectl set-ntp true

# Partition the disks
parted /dev/sda mklabel gpt
echo "mkpart ESP fat32 0% 200MiB
set 1 boot on
mkpart primary linux-swap 200MiB 4.2GiB
mkpart primary ext4 4.2GiB 100%
quit
" | parted /dev/sda

# Set up encryption with dm-crypt and LUKS
cryptsetup luksFormat -c aes-xts-plain64 -s 512 -h sha512 -y /dev/sda3

# Open encrypted partitions
cryptsetup luksOpen /dev/sda3 root

# Format the partitions
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/mapper/root

# Mount the partitions
mount /dev/mapper/root /mnt
mkdir /mnt/boot && mount /dev/sda1 /mnt/boot

# Select the mirrors
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
wget -O - "https://www.archlinux.org/mirrorlist/?country=DE&protocol=https&ip_version=4&use_mirror_status=on" | sed 's/^#Server/Server/' > /etc/pacman.d/mirrorlist.tmp
rankmirrors -n 10 /etc/pacman.d/mirrorlist.tmp > /etc/pacman.d/mirrorlist
rm /etc/pacman.d/mirrorlist.tmp

# Install the base packages
pacstrap /mnt base base-devel

# Configure crypttab
SWAP="$(find -L /dev/disk/by-partuuid -samefile /dev/sda2 | cut -d/ -f5)"
echo "swap PARTUUID=$SWAP /dev/urandom swap,noearly,cipher=aes-xts-plain64,hash=sha512,size=512" >> /mnt/etc/crypttab

# Configure fstab
SDA1="$(lsblk -rno UUID /dev/sda1)"
cat << EOF > /mnt/etc/fstab
# <device> <dir> <type> <options> <dump> <fsck>
UUID=${SDA1} /boot vfat defaults,noatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro 0 2
/dev/mapper/swap none swap defaults 0 0
/dev/mapper/root / ext4 defaults,noatime,data=ordered 0 1
tmpfs /tmp tmpfs size=4G 0 0
EOF

# Copy the setup folder to the new system
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cp -R $DIR /mnt/i-PUSH-arch-setup-i3wm

# Change root into the new system and run Installation.sh
arch-chroot /mnt /i-PUSH-arch-setup-i3wm/Installation.sh

# Pipe all output into log file
} |& tee -a /root/Arch-Installation.log
mv /root/Arch-Installation.log /mnt/home/$(ls /mnt/home/)/

# Reboot because systemctl & localectl are not available while chroot
umount -R /mnt
cryptsetup luksClose root
echo "Reboot, login as root and run: /i-PUSH-arch-setup-i3wm/Final-Installation.sh"
read -p "Press enter to reboot..."
reboot
