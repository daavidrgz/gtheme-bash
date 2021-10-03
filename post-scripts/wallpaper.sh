#!/bin/sh

WALLPAPER_URL=~/.config/gtheme/wallpapers/Gruvbox/light-archlinux.png
feh --no-fehbg --bg-fill "$WALLPAPER_URL"

# Flag to not execute the dm wallpaper update after every boot
[ "$1" == "no-dm" ] && exit 0

LIGHTDM_WALLPAPER=/usr/share/lightdm-webkit/themes/lightdm-webkit-theme-aether/src/img/wallpapers/wallpaper
sudo rm $LIGHTDM_WALLPAPER
sudo cp $WALLPAPER_URL $LIGHTDM_WALLPAPER

exit 0
