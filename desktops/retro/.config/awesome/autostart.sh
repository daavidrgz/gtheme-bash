#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

# Wallpaper
~/.fehbg

# Resolution
setxkbmap es

# Compositor
picom &

