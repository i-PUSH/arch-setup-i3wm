#!/bin/sh

[[ $(pgrep "ffmpeg") ]] && pkill "ffmpeg"
[[ $(pgrep "recSelectWin.sh" | wc -l) -gt 2 ]] && pkill "recSelectWin.sh"

INFO=$(xwininfo -frame)

WIN_GEO=$(echo $INFO | grep -oEe 'geometry [0-9]+x[0-9]+' |\
    grep -oEe '[0-9]+x[0-9]+')
WIN_XY=$(echo $INFO | grep -oEe 'Corners:\s+\+[0-9]+\+[0-9]+' |\
    grep -oEe '[0-9]+\+[0-9]+' | sed -e 's/+/,/' )

file_name="ffmpeg-$(date +"%d.%m.%Y-%H-%M-%S.mkv")";
ffmpeg -f x11grab -y -r 15 -s $WIN_GEO -i :0.0+$WIN_XY -vcodec ffv1 -f alsa -ac 2 -i pulse -acodec ac3 -threads 2 $file_name
#ffmpeg -f x11grab -video_size 1366x768 -i $DISPLAY -f alsa -i default -c:v ffvhuff -c:a flac $file_name
