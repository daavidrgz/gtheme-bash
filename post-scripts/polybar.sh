#!/bin/bash

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
polybar -r -q main -c $XDG_CONFIG_HOME/polybar/custom/config.ini &
