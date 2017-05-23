#!/bin/bash

wget "https://aur.archlinux.org/cgit/aur.git/snapshot/sublime-text-dev.tar.gz" -O - | tar xz
cd sublime-text-dev/ && makepkg -si
