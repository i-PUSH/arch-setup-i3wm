#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export PATH="${PATH}:$HOME/.bin"
export SUDO_ASKPASS="$HOME/.bin/DmenuPass.sh"
export VISUAL=nano
export EDITOR=nano
export TERMINAL=urxvt

if [[ "$(tty)" == '/dev/tty1' ]]; then
    startx
fi
