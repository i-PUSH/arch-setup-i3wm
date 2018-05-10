#!/usr/bin/env sh

if ! pgrep -f "urxvt -name dropdown"; then $TERMINAL -name dropdown & fi
