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

***

## Wiki

### Themes

* All themes are stored in the `themes/` folder with the `.colors` extension.  
* In those files are stored all the colors of each theme, but it can also contain (see [Nord.colors](https://github.com/daavidrgz/gtheme/tree/master/themes/Nord.colors)):
	* A Visual Studio Code theme `vscode: Your Theme Name`<sup>[1](#vscode_theme)</sup>
	* A wallpaper path `wallpaper: /path/to/wallpaper/wp.jpg`

### Patterns

* All patterns are stored in the `patterns/` folder with the `.pattern` extension.

* ***Mandatory key***: `%output-file%=/output/path/file.extension`  
It's required to know where to place the file generated, its name and extension.

* Available keys: `%background%` `%foreground%` `%cursor%` `%selection-background%` `%selection-foreground%` `%black%` `%black-hg%` `%red%` `%red-hg%` `%green%` `%green-hg%` `%yellow%` `%yellow-hg%` `%blue%` `%blue-hg%` `%magenta%` `%magenta-hg%` `%cyan%` `%cyan-hg%` `%white%` `%white-hg%`.

* The program will scan the pattern file and replace the keys with the associated color in the theme.<sup>[2](#no_color)</sup>

### Post-Scripts

* The scripts will be stored in the `post-scripts/` folder with the `.sh` extension.  
* The script files **with the same name as the pattern** will be executed after the output file is generated.   
* The created file's path is sent to all the scripts as its first argument (see [kitty.sh](https://github.com/daavidrgz/gtheme/tree/master/post-scripts/kitty.sh)).

## Credits

Wallpaper repositories:
* https://github.com/elementary/wallpapers
* https://github.com/rose-pine/wallpapers
* https://github.com/linuxdotexe/nordic-wallpapers
* https://github.com/dracula/wallpaper
* https://gitlab.com/exorcist365/wallpapers

## Notes

<a name="vscode_theme">1. - </a>The VSCode theme won't be installed automatically.  
<a name="no_color">2. - </a>If there is no color associated to a key in a theme, it will be replaced with an empty string in the output file.
