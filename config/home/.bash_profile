#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export VISUAL=nano
export EDITOR=nano
export TERMINAL=urxvt
export PATH="${PATH}:$HOME/.bin"
export SUDO_ASKPASS="$HOME/.bin/DmenuPass.sh"

if [[ "$(tty)" == '/dev/tty1' ]]; then
    startx
fi
