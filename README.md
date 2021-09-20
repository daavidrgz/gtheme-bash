# Gtheme
A bash script that makes your theming life so much easier.

## What is this?
Based in patterns, Gtheme can generate any file applying one of the more than 200 themes gathered.

Thus, it can create and replace in real time a rofi colors.rasi file, an alacritty.yml file and so much more, leading
to a global theme change perception that we all really need.

It also supports:
* Executing a post script to, for example, reset the dunst notification daemon or refresh the terminal colors with tput.
* Changing the wallpaper to match your new color scheme.
* Changing the Visual Studio Code theme.

## Wiki
### Patterns
All the patterns are stored in the folder `patterns/` with the `.pattern` extension.
Available keys: `%background%` `%foreground%` `%cursor%` `%selection-background%` `%selection-foreground%` `%black%` `%black-hg%` `%red%` `%red-hg%` `%green%` `%green-hg%` `%yellow%` `%yellow-hg%` `%blue%` `%blue-hg%` `%magenta%` `%magenta-hg%` `%cyan%` `%cyan-hg%` `%white%` `%white-hg%`

The created file path is sent to all the post-scripts as the first argument (see [kitty.sh](https://github.com/daavidrgz/gtheme/tree/master/post-scripts/kitty.sh)).

## Credits

Wallpaper repositories:
* https://github.com/elementary/wallpapers
* https://github.com/rose-pine/wallpapers
* https://github.com/linuxdotexe/nordic-wallpapers
* https://github.com/dracula/wallpaper
* https://gitlab.com/exorcist365/wallpapers
