#!/bin/bash

# Pulseaudio manage sound

function getMaxVal() {
	arr=("$@")
	max=${arr[0]}
	for n in "${arr[@]}"; do
		((n > max)) && max=$n
	done
	echo $max
}

DEVICES_LIST_UNSORTED=( $( pactl list sinks | grep -o "#[[:digit:]]" | tr -d '#' ) )
DEVICES_LIST_SORTED=( $( tr ' ' '\n' <<< "${DEVICES_LIST_UNSORTED[@]}" | sort -u | tr '\n' ' ' ) )

if [ "$1" -eq 0 ]; then
	for i in "${DEVICES_LIST_SORTED[@]}"; do
		pactl set-sink-mute $i toggle
	done
elif [ "$1" -eq 1 ]; then
	SOUND=( $( pactl list sinks | grep "\sLautstärke:\s" | grep -o '[^ ]*%' | tr -d '%' ) )
	MAX_SOUND_LVL=( $(getMaxVal "${SOUND[@]}") )
	if [ "$MAX_SOUND_LVL" -lt 150 ]; then
		for i in "${DEVICES_LIST_SORTED[@]}"; do
			pactl set-sink-mute $i false
			pactl set-sink-volume $i +5%
		done
	fi
elif [ "$1" -eq 2 ]; then
	for i in "${DEVICES_LIST_SORTED[@]}"; do
		pactl set-sink-mute $i false
		pactl set-sink-volume $i -5%
	done
fi

exit 0

: '
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
'

# Pulseaudio extras
# pactl list sinks short
# sh -c "SOUND=( $(pactl list sinks | perl -000ne 'if(/#1/){/(Volume:.*)/; print "$1\n"}' | grep -o '[^ ]*%' | tr -d '%') ); if (( ${SOUND[0]} < 150 )); then pactl set-sink-mute 1 false ; pactl set-sink-volume 1 +5%; fi"
