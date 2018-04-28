#!/bin/bash

function lock() {
	sleep 0.5
	scrot /tmp/i3lock.png && i3lock -i /tmp/i3lock.png
	sleep 1
}

function toggleDPMS() {
	state="$(xset q | grep "DPMS is" | awk '{print $NF}')"
	if [[ "$state" == "Enabled" ]]; then
		echo "DPMS: on"
	else
    	echo "DPMS: off"
    fi
}

DPMS="$(toggleDPMS)"
INPUT=`echo -e "Shutdown\nReboot\nSuspend\nScreen off\n$DPMS\nSwitch audio" | dmenu -i -nb '#C31616' -sb '#404040' -nf white`

case "$INPUT" in
	"Shutdown")  sudo shutdown -P now;;
	"Reboot")  sudo shutdown -r now;;
	"Suspend")  lock && systemctl suspend;;
	"Screen off")  lock && xset dpms force off;;
	"DPMS: on")  xset -dpms s off;;
	"DPMS: off")  xset +dpms s on;;
	"Switch audio" )  $HOME/.bin/ManageSound.sh "sw";;
esac
