#!/bin/bash

# Pulseaudio manage sound

DEVICES_LIST_UNSORTED=( $( pactl list sinks | grep -o "#[[:digit:]]" | tr -d '#' ) )
DEVICES_LIST_SORTED=( $( tr ' ' '\n' <<< "${DEVICES_LIST_UNSORTED[@]}" | sort -u | tr '\n' ' ' ) )

function getMaxVal() {
	arr=("$@")
	max=${arr[0]}
	for n in "${arr[@]}"; do
		((n > max)) && max=$n
	done
	echo $max
}

function incVol(){
	SOUND=( $( pactl list sinks | grep -E "Volume:|Lautstärke:" | grep -v "Base Volume" | grep -o '[^ ]*%' | tr -d '%' ) )
	MAX_SOUND_LVL=( $(getMaxVal "${SOUND[@]}") )
	if [ "$MAX_SOUND_LVL" -lt 150 ]; then
		for i in "${DEVICES_LIST_SORTED[@]}"; do
			pactl set-sink-mute $i false
			pactl set-sink-volume $i +5%
		done
	fi
}

function decVol(){
	for i in "${DEVICES_LIST_SORTED[@]}"; do
		pactl set-sink-mute $i false
		pactl set-sink-volume $i -5%
	done
}

function muteVol(){
	for i in "${DEVICES_LIST_SORTED[@]}"; do
		pactl set-sink-mute $i toggle
	done
}

function pa-list() {
	pacmd list-sinks | awk '/index/ || /name:/';
}

function pa-set() { 
	# list all apps in playback tab (ex: cmus, mplayer, vlc)
	inputs=($(pacmd list-sink-inputs | awk '/index/ {print $2}'))
	# set the default output device
	pacmd set-default-sink $1 &> /dev/null
	# apply the changes to all running apps to use the new output device
	for i in ${inputs[*]}; do pacmd move-sink-input $i $1 &> /dev/null; done
}

function pa-playbacklist() { 
	# list individual apps
	echo "==============="
	echo "Running Apps"
	pacmd list-sink-inputs | awk '/index/ || /application.name /'

	# list all sound device
	echo "==============="
	echo "Sound Devices"
	pacmd list-sinks | awk '/index/ || /name:/'
}

function pa-playbackset() { 
	# set the default output device
	pacmd set-default-sink "$2" &> /dev/null
	# apply changes to one running app to use the new output device
	pacmd move-sink-input "$1" "$2" &> /dev/null
}

function pa-switch-sink(){
	sink=$(pacmd list-sink-inputs | awk '/sink: / {print $2; exit}')
	[[ "$sink" == "0" ]] && pa-set 1 || pa-set 0
}

function manageSound(){
	if [ "$1" == "mute" ]; then
		muteVol
	elif [ "$1" == "inc" ]; then
		incVol
	elif [ "$1" == "dec" ]; then
		decVol
	elif [ "$1" == "sw" ]; then	
		pa-switch-sink
	fi
}

manageSound $1
exit 0

: <<'EOC'
DEVICES_LIST_UNSORTED=( $( pactl list sinks | grep -o "#[[:digit:]]" | tr -d '#' ) )
DEVICES_NUM=( $(getMaxVal "${DEVICES_LIST_UNSORTED[@]}") )

for i in $(seq 0 $DEVICES_NUM); do
	if [ "$1" -eq 1 ]; then
		SOUND=( $( pactl list sinks | grep "\sLautstärke:\s" | grep -o '[^ ]*%' | tr -d '%' ) )
		if [ ${SOUND[0]} -le 150 ] && [ ${SOUND[1]} -le 150 ]; then
			pactl set-sink-mute $i false
			pactl set-sink-volume $i +5%
		fi
	else
		pactl set-sink-mute $i false
		pactl set-sink-volume $i -5%
	fi
done

Pulseaudio extras
pactl list sinks short
sh -c "SOUND=( $(pactl list sinks | perl -000ne 'if(/#1/){/(Volume:.*)/; print "$1\n"}' | grep -o '[^ ]*%' | tr -d '%') ); if (( ${SOUND[0]} < 150 )); then pactl set-sink-mute 1 false ; pactl set-sink-volume 1 +5%; fi"
EOC
