#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export VISUAL=nano
export EDITOR=nano
export TERMINAL=urxvt
export MONITOR1=eDP1
export MONITOR2=HDMI1
export BROWSER=firefox
export GOPATH="$HOME/Dev/Go"
export GOBIN="$GOPATH/bin"
export PATH="${PATH}:$HOME/.bin:$GOBIN"
export SUDO_ASKPASS="$HOME/.bin/DmenuPass.sh"
export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=lcd'

if [[ "$(tty)" == '/dev/tty1' ]]; then
    startx
fi
