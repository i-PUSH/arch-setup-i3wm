#!/bin/bash

function rsyncUSB() {
	rsync -n -i -a --delete --exclude "/.*" --exclude "/.*/" --exclude ".git/" --exclude "VirtualBox VMs/" ~/ /run/media/$USER/$(ls /run/media/$USER/) | grep -E '^[^.]|^$'
	read -p "Sync? (Type: yes) : " input
	if [[ "$input" == "yes" ]]; then
		rsync -a --progress --human-readable --delete --exclude "/.*" --exclude "/.*/" --exclude "VirtualBox VMs/" ~/ /run/media/$USER/$(ls /run/media/$USER/)
	fi
}

$TERMINAL -e bash -c "$(declare -f rsyncUSB); rsyncUSB; read -p 'Press enter to exit...'"
