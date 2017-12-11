#!/bin/bash

function rsyncUSB() {
	rsync -n -i -a --delete --exclude "/.*" --exclude "/.*/" --exclude ".git/" ~/ /run/media/$USER/$(ls /run/media/$USER/) | grep -E '^[^.]|^$'
	read -p "Sync? (Type: yes) : " input
	if [[ "$input" == "yes" ]]; then
		rsync -a --progress --human-readable --delete --exclude "/.*" --exclude "/.*/" ~/ /run/media/$USER/$(ls /run/media/$USER/)
	fi
}

$TERMINAL -e bash -c "$(declare -f rsyncUSB); rsyncUSB; read -p 'Press enter to exit...'"
