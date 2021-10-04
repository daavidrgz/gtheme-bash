#!/bin/bash

while pgrep -u $UID -x polybar &>/dev/null; do
	killall -q polybar
	sleep 1
done
polybar -q main -c $HOME/.config/polybar/config.ini &
disown

exit 0
