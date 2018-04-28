#!/bin/bash

function playYT() {
	URL_LIST=()
	URL_PLAYED=()
	URL_CURRENT="$(youtube-dl --get-id --no-playlist "$1")"
	for i in "${@}"; do [[ "$i" == "-d" ]] && DOWNLOAD="1"; done
	for i in "${@}"; do [[ "$i" == "-nv" ]] && NO_VIDEO="1"; done

	[[ "$1" =~ "list=" ]] && LIST="$(echo "$1" | awk -v FS="(list=|&index)" '{print $2}')"

	while true; do

		[[ -z "$LIST" ]] && URL_LIST=()
		#  grep -m1 -oP 'href="\/watch\?v=\K.{11}'
		TMP="$(wget -q -O- "https://www.youtube.com/watch?v=$URL_CURRENT&list=$LIST" | grep -o -P '.watch\?v=.{0,11}' | cut -d '=' -f2)"

		# echo "TMP" = "${TMP[*]}"

		for i in $TMP; do
			if [[ ! "${URL_LIST[@]}" =~ "$i" ]]; then
				URL_LIST+=( "$i" )
			fi
		done

		# echo "URL_LIST" = "${URL_LIST[@]}" | tr " " "\n"

		for i in "${URL_LIST[@]}"; do
			if [[ ! "${URL_PLAYED[@]}" =~ "$i" ]]; then
				URL_CURRENT=( "$i" )
				URL_PLAYED+=( "$i" )
				if [[ "$DOWNLOAD" == "1" ]]; then
					if [[ "$NO_VIDEO" == "1" ]]; then
						$TERMINAL -e "youtube-dl -x --audio-format mp3 $URL_CURRENT"
						[[ -z "$LIST" ]] && exit
					else
						$TERMINAL -e "youtube-dl $URL_CURRENT"
						[[ -z "$LIST" ]] && exit
					fi
				fi
				if [[ "$DOWNLOAD" != "1" ]]; then
					if [[ "$NO_VIDEO" == "1" ]]; then
						$TERMINAL -e "mpv --no-video https://www.youtube.com/watch?v=$URL_CURRENT&list=$LIST"
					else
						mpv "https://www.youtube.com/watch?v=$URL_CURRENT&list=$LIST"
					fi
				fi
				break
			fi
		done
	done
}


[[ $(pgrep "mpv") ]] && pkill "mpv"
[[ $(pgrep "streamMedia.sh" | wc -l) -gt 2 ]] && pkill "streamMedia.sh"

[ -z $TERMINAL ] && TERMINAL="urxvt"
URL="http://46.10.150.243/njoy.mp3"

CB="$(xsel -b)"
[[ "$CB" =~ "http" ]] && URL="$CB"
for i in "${@}"; do [[ "$i" =~ "http" ]] && URL=( "$i" ); done
for i in "${@}"; do [[ "$i" == "-d" ]] && DOWNLOAD="-d"; done
for i in "${@}"; do [[ "$i" == "-nv" ]] && NO_VIDEO="-nv"; done

[[ "$URL" =~ ("youtube.com"|"youtu.be") ]] && playYT "$URL" $DOWNLOAD $NO_VIDEO
[[ ! -z "$DOWNLOAD" ]] && $TERMINAL -e "youtube-dl $URL" && exit
[[ ! -z "$NO_VIDEO" ]] && $TERMINAL -e "mpv --no-video $URL" || mpv "$URL"

exit
