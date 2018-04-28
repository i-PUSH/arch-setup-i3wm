#!/bin/bash

# qemu-img create -f raw image_name 4G
# mount -t 9p -o trans=virtio,version=9p2000.L hostshare /tmp/host_files

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
	-net user,hostfwd=tcp::10022-:22
	-net nic
	-drive file="$(find $IMG_PATH -name $1)",format=raw,media=disk,if=virtio,cache=none
)

args=$#
for (( i=1; i<=$args; i++ )); do
	[ ${!i} == "-cd" ] && let i++ && CD_PATH="${!i}"
	[ ${!i} == "-sf" ] && let i++ && SHARED_DIR_PATH="${!i}"
done

[ ! -z "$CD_PATH" ] && options+=(-cdrom $CD_PATH)
[ ! -z "$SHARED_DIR_PATH" ] && options+=(-fsdev local,security_model=passthrough,id=fsdev0,path=$SHARED_DIR_PATH)
[ ! -z "$SHARED_DIR_PATH" ] && options+=(-device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare)

qemu-system-x86_64 "${options[@]}"

: <<'EOC'
-display sdl,gl=on
-display gtk,gl=on
-net nic,model=virtio
-usb -device usb-tablet
-boot order=d
EOC
