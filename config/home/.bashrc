#
# /etc/bash.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
export HISTCONTROL=ignoreboth

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=1000
export HISTFILESIZE=2000

# save history of every terminal
export PROMPT_COMMAND='history -a'

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

[ -r /usr/share/bash-completion/bash_completion   ] && . /usr/share/bash-completion/bash_completion

# enable color support of ls and grep
if [ -x /usr/bin/dircolors ]; then
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Bash prompt string customize. PSC ~ "Prompt string color"
PSC_GREEN='\[\e[32m\]'
PSC_RED='\[\e[31m\]'
PSC_RESET='\[\e[0m\]'
# DOT='\342\200\242'
PS_LC="\`[ \$? = 0 ] && echo $PSC_GREEN\W$PSC_RESET || echo $PSC_RED\W$PSC_RESET\`"
export PS1="< ${PS_LC} > "
# PS1=$'\u250F\u2501\u276A\[\033[0;31m\]\e[219;50;50m\u\e[0m : \w\u276B\n\u2517\u2501\u27A4 '   Red
# PS1=$'\u250F\u2501\u276A\e[1m\e[219;50;50m\u\e[0m : \w\u276B\n\u2517\u2501\u27A4 '    Bold

# Aliases
alias l='ls -CF'
alias ll='ls -alF'
alias la='ls -all'
alias cp='cp -i'
alias df='df -h'
alias grepi='grep -i'
alias diff='diff --color=auto'
alias trash='gio trash'
alias ssh='TERM=xterm ssh'
alias fehbg='feh --bg-fill "$(xsel -b)"'
alias lss='systemctl list-units -t service'
alias USB1='echo /run/media/$USER/$(ls /run/media/$USER/)/'
alias rsyncHome='Rsync $HOME/ "$(USB1)" "/.*" /Qemu/ /Desktop/Synology/ /Windows/ --.git/'
alias x1='xrandr --output $MONITOR1 --scale 1x1 --auto --output $MONITOR2 --scale 1x1 --off'
alias x2='xrandr --output $MONITOR2 --scale 1x1 --auto --output $MONITOR1 --scale 1x1 --off'
alias xdual='xrandr --output $MONITOR1 --scale 1x1 --auto --output $MONITOR2 --scale 1x1 --auto --primary --preferred --right-of $MONITOR1'

# Functions
cdd() { cd "$1" && ls -all; }

man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}

fail() { journalctl "$@" | egrep -i "warn|error|fail"; }

diffDirs() { diff -r -q {$1,$2} -x "$3" -x "$4" -x "$5" -x "$6"; }

xmirror() {
    RES=$(xrandr | sed -nr "s/$1 connected ([0-9]+x[0-9]+).*/\1/p")
     [ -z $RES ] && RES=$(xrandr | sed -nr "s/$1 connected primary ([0-9]+x[0-9]+).*/\1/p")
    xrandr --output $1 --auto --primary --preferred --output $2 --auto --same-as $1 --scale-from $RES
}

update() {
    if grep -q "lts" /boot/loader/loader.conf; then
        sudo pacman -Syyu --ignore linux,linux-headers,linux-api-headers
    else
        sudo pacman -Syyu --ignore linux-lts,linux-lts-headers
    fi
}

switchKernel() {
    if grep -q "lts" /boot/loader/loader.conf; then
        sudo sed -i '/default/s/arch-lts/arch/' /boot/loader/loader.conf
        echo "Switched to Stable"
    else
        sudo sed -i '/default/s/arch/arch-lts/' /boot/loader/loader.conf
        echo "Switched to LTS"
    fi
}

switchTheme() {
    if grep -q "Polybar" $HOME/.config/i3/config; then
        mv $HOME/.config/i3/config $HOME/.config/i3/config.polybar
        mv $HOME/.config/i3/config.i3bar $HOME/.config/i3/config
        killall -q polybar compton
        i3-msg restart
        echo "Switched to i3bar"
    else
        mv $HOME/.config/i3/config $HOME/.config/i3/config.i3bar
        mv $HOME/.config/i3/config.polybar $HOME/.config/i3/config
        i3-msg restart
        echo "Switched to polybar"
    fi
}

extract () {
    if [ -f $1 ] ; then
        [ -z $2 ] && dir="." || dir=$2
        case $1 in
            *.tar.bz2)   tar xjf $1 -C $dir ;;
            *.tar.gz)    tar xzf $1 -C $dir ;;
            *.tbz2)      tar xjf $1-C  $dir ;;
            *.tgz)       tar xzf $1 -C $dir ;;
            *.tar)       tar xf $1 -C $dir ;;
            *.bz2)       bzcat $1 > $dir/"${1%.*}" ;;
            *.gz)        zcat $1 > $dir/"${1%.*}" ;;
            *.rar)       unrar e $1 $dir ;;
            *.zip)       unzip $1 -d $dir ;;
            *.7z)        7z x $1 -o$dir ;;
            *.Z)         uncompress -c $1 > $dir/"${1%.*}" ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
    echo "'$1' is not a valid file"
    fi
}

wgex () {
    wget $1 -P $2
    extract "$2$(basename "$1")" $2
    trash "$2$(basename "$1")"
}

gita() { 
    git add -A
    git commit -m "$1"
    git push
}
