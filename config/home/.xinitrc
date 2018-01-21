#! /bin/bash
setxkbmap -model pc105 -layout de -variant nodeadkeys
[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap
~/.fehbg &
exec i3
