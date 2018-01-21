#!/bin/bash

# qemu-img create -f raw image_name 4G

IMG_PATH="$HOME/Qemu/"

options=(
    -enable-kvm
	-m 2G
	-cpu host
	-smp cores=2
	-vga virtio
	-full-screen
	-soundhw hda
	-machine type=pc,accel=kvm
	-boot menu=on
	-drive file="$(find "$IMG_PATH" -name "$1.img")",format=raw,media=disk,if=virtio,cache=none
)

[ ! -z "$2" ] && options+=(-cdrom $2)

qemu-system-x86_64 "${options[@]}"

: '
-display sdl,gl=on
-display gtk,gl=on
-net nic,model=virtio
-usb -device usb-tablet
-boot order=d
'