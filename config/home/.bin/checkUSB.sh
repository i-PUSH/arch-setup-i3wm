#!/bin/bash

urxvt --hold -e bash -c 'diff -r -q {~/,/run/media/$USER/$(ls /run/media/$USER/)} -x "VirtualBox VMs" -x "UT2k4" -x "ISO" -x ".git" | grep -v "Nur in ''$HOME''/: ." ; echo "Finish"'

# xfce4-terminal --hold -x bash -c 'diff -r -q {~/,/media/$USER/$(ls /media/$USER/)} -x "VirtualBox VMs" -x "UT2k4" -x "ISO" -x "Desktop" -x ".*" ; echo "Finish"'
# urxvt --hold -e bash -c 'diff -r -q {~/,/media/$USER/$(ls /media/$USER/)} -x "VirtualBox VMs" -x "UT2k4" -x "ISO" -x "Desktop" -x ".*" ; echo "Finish"'
# gnome-terminal -x bash -c 'printf "\n\n\n"; diff -r -q {~/,/run/media/$USER/$(ls /run/media/$USER/)} -x "VirtualBox VMs" -x "VS2015" -x "ISO" -x "Desktop" -x ".*" ; echo "Finish"'
