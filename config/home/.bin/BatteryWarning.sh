#!/bin/bash
# */5 * * * * env DISPLAY=:0  /home/$USER/.bin/BatteryWarning.sh

BATTINFO=`acpi -b | grep -v "0%, rate information unavailable"`
if [[ `echo $BATTINFO | grep Discharging` && `echo $BATTINFO | awk -F', ' '{print $2+0}'` -le "15" ]]; then
    echo "Low battery!" | dmenu -nb '#C31616' -sb '#404040' -nf '#C31616'
fi
