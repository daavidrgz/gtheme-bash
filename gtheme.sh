#!/bin/bash

#  ██████╗ ████████╗██╗  ██╗███████╗███╗   ███╗███████╗
# ██╔════╝ ╚══██╔══╝██║  ██║██╔════╝████╗ ████║██╔════╝
# ██║  ███╗   ██║   ███████║█████╗  ██╔████╔██║█████╗
# ██║   ██║   ██║   ██╔══██║██╔══╝  ██║╚██╔╝██║██╔══╝
# ╚██████╔╝   ██║   ██║  ██║███████╗██║ ╚═╝ ██║███████╗
#  ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚══════╝
# By David Rodríguez - @daavidrgz

# •• Colors
R="\e[1;31m"
G="\e[1;32m"
Y="\e[1;33m"
B="\e[1;34m"
M="\e[1;35m"
C="\e[1;36m"
W="\e[0m"
W_B="\e[1m"

DIM="\e[0;2m" # Dimmed
I_B="\e[1;3m" # Italic
U_B="\e[1;4m" # Underline
B_B="\e[1;7m" # With background

ATTR_NAMES=("background" "foreground" "cursor" "selection-background" "selection-foreground" \
"black" "black-hg" "red" "red-hg" "green" "green-hg" "yellow" "yellow-hg" "blue" "blue-hg" "magenta" "magenta-hg" "cyan" "cyan-hg" "white" "white-hg")

CONFIG=${XDG_CONFIG_HOME:-$HOME/.config}

GTHEME_PATH=$CONFIG/gtheme
THEMES_PATH=$GTHEME_PATH/themes
FAV_THEMES_PATH=$THEMES_PATH/fav-themes
BACKUP_PATH=$GTHEME_PATH/backup

DESKTOPS_PATH=$GTHEME_PATH/desktops
ACTIVE_DESKTOP=$(realpath $DESKTOPS_PATH/active-desktop)
GTHEME_CURRENT_DESKTOP=$ACTIVE_DESKTOP/gtheme

PATTERNS_PATH=$GTHEME_CURRENT_DESKTOP/patterns
ACTIVE_PATTERNS_PATH=$PATTERNS_PATH/active-patterns
POSTSCRIPTS_PATH=$GTHEME_CURRENT_DESKTOP/post-scripts
CURRENT_THEME_FILE=$GTHEME_CURRENT_DESKTOP/current-theme

if [ ! -e $GTHEME_PATH ]; then
  echo -e "\n${R}[!]${W} Gtheme folder not found! Ensure that ${W_B}$CONFIG/gtheme${W} folder exists.\n"
  exit 1
fi

# •• Global Settings
VSCODE_SETTINGS_FILE="$CONFIG/Code/User/settings.json"

trap ctrl_c INT
function ctrl_c() {
  clear
  gthemeLogo
  echo -e "${R}[!]${W} Exiting...\n"
  tput cnorm
  exit 0
}

function helpPanel() {
  echo -e "\n${Y}[*]${W} Usage: gtheme [OPTIONS...]"
  echo -e "\n${B}- To run interactively just give no options. -${W}"
  echo -e "\n${W_B}If the flag -p is not present${W}, the choosed theme will be applied to ${W_B}all active patterns${W} by default."
  echo -e "\nOPTIONS:
  ${G}-a${W} <PATT1,PATT2...>       activate selected patterns.
  ${G}-r${W} <PATT1,PATT2...>       desactivate selected patterns.
  ${G}-p${W} <PATT1,PATT2...>       apply the theme only on selected patterns. Important: There must be no spaces between the patterns, only commas.
  ${G}-i${W} <PATT1,PATT2...>       invert the background and the foreground colors on selected patterns.
  ${G}-n${W} <THEME>                apply the specified <THEME>.
  ${G}-f${W} <THEME1,THEME2...>     flag selected themes as favourite or unflag them if they're in the fav-themes folder.
  ${G}-l${W} themes|patterns|favs   list all installed themes, patterns or favourite themes.
  ${G}-v${W}                        apply the VSCode theme.
  ${G}-w${W}                        apply the wallpaper.
  ${G}-h${W}                        show this panel.\n"
}

function setWallpaper() {
  declare WALLPAPER_SCRIPT=$POSTSCRIPTS_PATH/wallpaper.sh
  declare IS_THEMING="false"
  declare IS_LIGHTDM="true"

  if ls $ACTIVE_PATTERNS_PATH | grep -e "^wallpaper-theme.pattern$" &>/dev/null; then
    echo -e "${B}•${W} Wallpaper theming detected!"
    IS_THEMING="true"
  fi

  if [ ! -e $WALLPAPER_SCRIPT ]; then
    echo -e "${R}[!]${W} The wallpaper script does not exist! Create a ${W_B}wallpaper.sh${W} under ${W_B}$POSTSCRIPTS_PATH${W}"
    return 1
  fi

  declare -r WALLPAPER=$(/bin/cat $THEMES_PATH/$1.colors | grep wallpaper | awk -F ': ' '{print $2}')
  [ -z "$WALLPAPER" ] && return 0

  if [ ! -x $WALLPAPER_SCRIPT ]; then
    echo -e "${R}•${W} $WALLPAPER_SCRIPT is not executable. Run chmod +x $WALLPAPER_SCRIPT to solve it!\n"
    return 1
  fi

  WALLPAPER_REAL_PATH="$(echo $WALLPAPER | sed "s|~|$HOME|")"

  if $WALLPAPER_SCRIPT "$WALLPAPER_REAL_PATH" "$IS_LIGHTDM" "$IS_THEMING"; then
    echo -e "${B}[+]${W} Wallpaper ${W_B}$(basename $WALLPAPER)${W} applied!\n"

    sed -i "/.*wallpaper.*/d" $CURRENT_THEME_FILE
    echo -e "wallpaper: $WALLPAPER" >> $CURRENT_THEME_FILE
  else
    echo -e "${R}[!]${W} There was an error while setting the wallpaper.\n"
    return 1
  fi
}

function setVscodeTheme() {
  if [ ! -e $VSCODE_SETTINGS_FILE ]; then
    echo -e "${R}[!]${W} The vscode settings file ${W_B}$VSCODE_SETTINGS_FILE${W} does not exist\n"
    return 1
  fi

  declare -r VSCODETHEME=$(/bin/cat $THEMES_PATH/$1.colors | grep vscode | awk -F ': ' '{print $2}')
  [ -z "$VSCODETHEME" ] && return

  sed -i "s|\"workbench.colorTheme\": \".*\"|\"workbench.colorTheme\": \"$VSCODETHEME\"|" $VSCODE_SETTINGS_FILE
  echo -e "${B}[+]${W} Theme ${W_B}\"$VSCODETHEME\"${W} applied to Visual Studio Code!\n"

  sed -i "/.*vscode.*/d" $CURRENT_THEME_FILE
  echo -e "vscode: $VSCODETHEME" >> $CURRENT_THEME_FILE
}

function executePostScript() {
  declare -r POST_SCRIPT=$POSTSCRIPTS_PATH/$1.sh

  echo -e "${B}•${W} Executing post-script..."

  if [ ! -e $POST_SCRIPT ]; then
    echo -e "${Y}•${W} No post-script found!"
    return 0
  fi

  if [ ! -x $POST_SCRIPT ]; then
    echo -e "${R}•${W} $POST_SCRIPT is not executable. Run chmod +x $POST_SCRIPT to solve it!\n"
    return 1
  fi

  $POST_SCRIPT $2 &>/dev/null &
}

function fillPattern() {
  echo -e "${B}•${W} Generating file for $1..."

  declare -r PATTERN="$ACTIVE_PATTERNS_PATH/$1.pattern"
  declare -r IS_INVERTED=$3

  declare DEST="$(/bin/cat $PATTERN | grep -e ".*%output-file%.*" | awk -F '=' '{print $2}')"

  if [ -z "$DEST" ]; then
    echo -e "${R}[!]${W} No output file found! Please, modify the pattern in ${W_B}$PATTERNS_PATH${W}\n"
    return 1
  fi

  if [ ! -e "$(dirname $DEST)" ]; then
    echo -e "${R}[!]${W} The folder ${W_B}$(dirname $DEST)${W} does not exist!\n"
    return 1
  fi

  cp $PATTERN $DEST

  declare -r CONTENT="$(/bin/cat $THEMES_PATH/$2.colors)"
  for attr in ${ATTR_NAMES[@]}; do
    declare VALUE=$(echo "$CONTENT" | grep -e "^$attr:.*" | awk -F ': ' '{print $2}')

    # Invert colors
    if [ $IS_INVERTED -eq 0 ]; then
      if [ "$attr" == "background" ]; then
        attr="foreground"
      elif [ "$attr" == "foreground" ]; then
        attr="background"
      elif [ "$attr" == "selection-background" ]; then
        attr="selection-foreground"
      elif [ "$attr" == "selection-foreground" ]; then
        attr="selection-background"
      fi
    fi

    sed -i "s|%$attr%|$VALUE|g" $DEST
  done

  sed -i "s|%theme-name%| -------- Gtheme: $2 --------|" $DEST
  sed -i "/.*%output-file%.*/d" $DEST

  echo -e "${B}•${W} Created file ${W_B}$(basename $DEST)${W} in ${W_B}$(dirname $DEST)${W}"

  executePostScript $1 $DEST

  echo -e "${B}•${W} Theme applied to ${G}$1${W}\n"

  echo -e "─────────────────────\n"
  return 0
}

function generateFiles() {
  declare -r THEME_NAME="$1"
  declare PATTERNS="$2"
  declare -r INVERTED_PATTERNS="$3"

  [ ! -e $CURRENT_THEME_FILE ] && touch $CURRENT_THEME_FILE

  [ -z "$PATTERNS" ] && PATTERNS="$(ls $ACTIVE_PATTERNS_PATH | sed 's/.pattern//g' )"

  echo
  for PATTERN in $PATTERNS; do
    echo "$INVERTED_PATTERNS" | grep $PATTERN &>/dev/null

    fillPattern "$PATTERN" "$THEME_NAME" "$?" || return 1

    sed -i "/$PATTERN:.*/d" $CURRENT_THEME_FILE
    echo -e "$PATTERN: $THEME_NAME" >> $CURRENT_THEME_FILE
  done

  if [ $IS_VSCODE -eq 0 ]; then
    setVscodeTheme $THEME_NAME || return 1
  fi
  if [ $IS_WALLPAPER -eq 0 ]; then
    setWallpaper $THEME_NAME || return 1
  fi

  return 0
}

function showPatterns() {
  echo
  for pattern in $(ls -p $PATTERNS_PATH | grep -v / | sed 's/\.pattern//g'); do
    if [ -e $ACTIVE_PATTERNS_PATH/$pattern.pattern ]; then
      printf "${B}•${W} %-20s ${B}Active${W}\n" "$pattern"
    else
      printf "${Y}•${W} %-20s ${Y}Not active${W}\n" "$pattern"
    fi
  done
  echo
}
function showAllThemes() {
  declare -i COUNT=0

  echo
  for theme in $(ls -p $THEMES_PATH | grep -v / | sed 's/\.colors//g'); do
    declare FAV_COLOR=${W}
    [ -e $FAV_THEMES_PATH/$theme.colors ] && FAV_COLOR=${Y}

    if /bin/cat $CURRENT_THEME_FILE | grep -e ": $theme$" &>/dev/null; then
      printf "${B}%7s${W} ${FAV_COLOR}%s ${B}(active)${W}\n" "[$COUNT]" "• $theme"
    else
      printf "${G}%7s${W} ${FAV_COLOR}%s${W}\n" "[$COUNT]" "• $theme"
    fi
    COUNT=$COUNT+1
  done
  echo
}
function showFavThemes() {
  echo
  for theme in $(ls $FAV_THEMES_PATH | sed 's/\.colors//g'); do
    echo -e "${Y}•${W} $theme"
  done
  echo
}

function list() {
  case "$1" in
    "themes") showAllThemes;;
    "patterns") showPatterns;;
    "favs") showFavThemes;;
    *) echo -e "\n${R}[!]${W} Invalid option ${W_B}$1${W}!\n"; exit 1;;
  esac
}

function flagAsFavourite() {
  declare -a FAV_THEMES=($@)
  checkThemes "$@" 

  echo
  for theme in ${FAV_THEMES[@]}; do
    if [ -e $FAV_THEMES_PATH/$theme.colors ]; then
      rm $FAV_THEMES_PATH/$theme.colors
      echo -e "${G}[-]${W} Theme ${W_B}$theme${W} succesfully removed from favourites!\n"
    else
      ln -s ../$theme.colors $FAV_THEMES_PATH/$theme.colors
      echo -e "${G}[+]${W} Theme ${W_B}$theme${W} succesfully added to favourites!\n"
    fi
  done
}

function addPatterns() {
  declare -a ADD_PATTERNS=($@)
  checkPatterns "$@"

  echo
  for pattern in ${ADD_PATTERNS[@]}; do
    if [ -e $ACTIVE_PATTERNS_PATH/$pattern.pattern ]; then
      echo -e "${Y}[!]${W} The pattern ${W_B}$pattern${W} is already active!\n"
      continue
    fi

    echo -e "${Y}•${W} Creating symlink ${W_B}$ACTIVE_PATTERNS_PATH/$pattern.pattern${W}..."
    if ln -s ../$pattern.pattern $ACTIVE_PATTERNS_PATH/$pattern.pattern; then
      echo -e "${G}•${W} Pattern ${W_B}$pattern${W} succesfully activated!\n"
    else
      echo -e "${R}•${W} Error while activating the pattern $pattern!\n"
    fi
  done
}

function removePatterns() {
  declare -a REMOVE_PATTERNS=($@)
  checkPatterns "$@"

  echo
  for pattern in ${REMOVE_PATTERNS[@]}; do
    if [ ! -e $ACTIVE_PATTERNS_PATH/$pattern.pattern ]; then
      echo -e "${Y}[!]${W} The pattern ${W_B}$pattern${W} is already inactive!\n"
      continue
    fi

    echo -e "${Y}•${W} Deleting symlink ${W_B}$ACTIVE_PATTERNS_PATH/$pattern.pattern${W}..."
    if rm $ACTIVE_PATTERNS_PATH/$pattern.pattern; then
      echo -e "${G}•${W} Pattern ${W_B}$pattern${W} succesfully desactivated!\n"
    else
      echo -e "${R}•${W} Error while desactivating the pattern $pattern!\n"
    fi
  done
}

function checkPatterns() {
  declare -a PATTERNS=($@)

  for pattern in ${PATTERNS[@]}; do
    if [ ! -e $PATTERNS_PATH/$pattern.pattern ]; then
      echo -e "\n${R}[!]${W} The pattern ${W_B}$pattern${W} does not exist!\n"
      exit 1
    fi
  done
}

function checkThemes() {
  declare -a THEMES=($@)

  for theme in ${THEMES[@]}; do
    if [ ! -e $THEMES_PATH/$theme.colors ]; then
      echo -e "\n${R}[!]${W} The theme ${W_B}$theme${W} does not exist!\n"
      exit 1
    fi
  done
}

# INTERACTIVE SECTION

function gthemeLogo() {
  echo -e "${R} ██████╗ ${G} ████████╗${Y} ██╗  ██╗${B} ███████╗${M} ███╗   ███╗${C} ███████╗${W}"
  echo -e "${R}██╔════╝ ${G} ╚══██╔══╝${Y} ██║  ██║${B} ██╔════╝${M} ████╗ ████║${C} ██╔════╝${W}"
  echo -e "${R}██║  ███╗${G}    ██║   ${Y} ███████║${B} █████╗  ${M} ██╔████╔██║${C} █████╗  ${W}"
  echo -e "${R}██║   ██║${G}    ██║   ${Y} ██╔══██║${B} ██╔══╝  ${M} ██║╚██╔╝██║${C} ██╔══╝  ${W}"
  echo -e "${R}╚██████╔╝${G}    ██║   ${Y} ██║  ██║${B} ███████╗${M} ██║ ╚═╝ ██║${C} ███████╗${W}"
  echo -e "${R} ╚═════╝ ${G}    ╚═╝   ${Y} ╚═╝  ╚═╝${B} ╚══════╝${M} ╚═╝     ╚═╝${C} ╚══════╝${W}"
  echo -e "\n"
}

function keyInput() {
  read -rsn1 mode
  if [ "$mode" == $'\x1b' ]; then
    read -rsn2 mode
  fi

  case $mode in
    [A) echo "up";;
    [B) echo "down";;
    [D) echo "left";;
    [C) echo "right";;
    '') echo "enter";;
    f) echo "f";;
    e) echo "e";;
    p) echo "p";;
    c) echo "c";;
    i) echo "i";;
    q) echo "q";;
    h) echo "h";;
    v) echo "v";;
    w) echo "w";;
    1) echo "1";;
    2) echo "2";;
    3) echo "3";;
    4) echo "4";;
    *) echo "invalid"
  esac
}

function showDesktopsHelp() {
  while true; do
    clear
    gthemeLogo
    echo -e "${Y}╭─── HELP DESKTOPS ──────────────────────────╮"
    echo -e "${Y}│                                            │"

    echo -e "${Y}│  ${B}'up'${W}       previous desktop               ${Y}│"
    echo -e "${Y}│  ${B}'down'${W}     next desktop                   ${Y}│"
    echo -e "${Y}│  ${B}'enter'${W}    apply desktop                  ${Y}│"

    showCommonHelp || break
  done
}

function showPatternsHelp() {
  while true; do
    clear
    gthemeLogo
    echo -e "${Y}╭─── HELP PATTERNS ──────────────────────────╮"
    echo -e "${Y}│                                            │"

    echo -e "${Y}│  ${B}'enter'${W}    activate/desactivate pattern   ${Y}│"
    echo -e "${Y}│  ${B}'up'${W}       previous pattern               ${Y}│"
    echo -e "${Y}│  ${B}'down'${W}     next pattern                   ${Y}│"
    echo -e "${Y}│  ${B}'i'${W}        toggle invert pattern          ${Y}│"
    echo -e "${Y}│  ${B}'p'${W}        edit pattern's post-script     ${Y}│"
    echo -e "${Y}│  ${B}'e'${W}        edit file in \$VISUAL env var   ${Y}│"

    showCommonHelp || break
  done
}

function showThemesHelp() {
  while true; do
    clear
    gthemeLogo
    echo -e "${Y}╭─── HELP THEMES ────────────────────────────╮"
    echo -e "${Y}│                                            │"

    echo -e "${Y}│  ${B}'enter'${W}    apply theme                    ${Y}│"
    echo -e "${Y}│  ${B}'up'${W}       previous theme                 ${Y}│"
    echo -e "${Y}│  ${B}'down'${W}     next theme                     ${Y}│"
    echo -e "${Y}│  ${B}'left'${W}     10 previous themes             ${Y}│"
    echo -e "${Y}│  ${B}'right'${W}    10 next themes                 ${Y}│"
    echo -e "${Y}│  ${B}'f'${W}        flag/unflag as favourite       ${Y}│"
    echo -e "${Y}│  ${B}'e'${W}        edit file in \$VISUAL env var   ${Y}│"

    showCommonHelp || break
  done
}

function showCommonHelp() {
  echo -e "${Y}│  ${B}'c'${W}        toggle colors preview          ${Y}│"
  echo -e "${Y}│  ${B}'w'${W}        toggle apply wallpaper         ${Y}│"
  echo -e "${Y}│  ${B}'v'${W}        toggle apply vscode theme      ${Y}│"
  echo -e "${Y}│  ${B}'q'${W}        quit                           ${Y}│"
  echo -e "${Y}│  ${B}'h'${W}        show/hide this panel           ${Y}│"
  echo -e "${Y}│  ${B}'1|2|3|4'${W}  desktops|patterns|themes|favs  ${Y}│"

  echo -e "${Y}╰────────────────────────────────────────────╯${W}"

  INPUT=$(keyInput)
  [ "$INPUT" == "h" ] && return 1
  [ "$INPUT" == "q" ] && ctrl_c
  return 0
}

function backupFolder() {
  declare -r FOLDER_NAME="$1"

  declare -r USER_FOLDER=$HOME/.config/$FOLDER_NAME

  [ ! -e $USER_FOLDER ] && return 1

  cp -r $USER_FOLDER $BACKUP_PATH

  echo -e "${G}•${W} Folder ${W_B}$USER_FOLDER${W} already exists, backing it up in ${W_B}$BACKUP_PATH${W}..."
  return 0
}

function applyDesktop() {
  declare -r DESKTOP_NAME="$1"
  declare USER_FOLDER

  if [ -e $ACTIVE_DESKTOP ]; then
    echo -e "${B}•${W} Removing previous desktop folders...\n"
    for folder in $ACTIVE_DESKTOP/.config/*; do
      USER_FOLDER=$HOME/.config/$(basename $folder)
      [ $USER_FOLDER != "$HOME/.config/" ] && rm -rf $USER_FOLDER
      echo -e "${B}•${W} Removed ${W_B}$USER_FOLDER${W}"
    done
    echo
  fi

  for folder in $DESKTOPS_PATH/$DESKTOP_NAME/.config/*; do
    echo -e "${B}•${W} Moving ${W_B}$(basename $folder)/${W}..."
    cp -r $folder $HOME/.config
    echo -e "${G}• Done!${W}\n"
  done

  rm $DESKTOPS_PATH/active-desktop
  ln -s $DESKTOP_NAME $DESKTOPS_PATH/active-desktop
  echo -e "${G}•${W} Desktop ${B}$DESKTOP_NAME${W} applied!"

  declare -r DESKTOP_START_SCRIPT=$DESKTOPS_PATH/active-desktop/gtheme/post-scripts/desktop-start.sh
  echo -e "${B}•${W} Trying to execute ${W_B}$DESKTOP_START_SCRIPT${W} desktop start script...\n"
  if [ -e $DESKTOP_START_SCRIPT ]; then
    if ! $DESKTOP_START_SCRIPT; then
      echo -e "\n${R}[${W} Press any key to continue ${R}]${W}\n"
      keyInput &>/dev/null
    fi
  else
    echo -e "${R}[!]${W} There is no desktop start post-script, consider creating it to set a new theme on desktop change!\n"
  fi

  echo -e "${B}•${W} Trying to execute ${W_B}$POSTSCRIPTS_PATH/desktop-exit.sh${W} to exit the wm...\n"
  if [ -e $POSTSCRIPTS_PATH/desktop-exit.sh ]; then
    $POSTSCRIPTS_PATH/desktop-exit.sh && return 0

    echo -e "\n${R}[${W} Press any key to continue ${R}]${W}\n"
    keyInput &>/dev/null
  else
    echo -e "${R}[!]${W} There is no desktop exit post-script, consider creating it to restart your wm!\n"
  fi
}

function applyTheme() {
  clear
  gthemeLogo
  echo -e "\n${B}Applying $1...${W}\n"
  
  generateFiles "$1" "" "${INVERTED_PATTERNS[*]}" && return

  echo -e "\n${R}[${W} Press any key to continue ${R}]${W}\n"
  keyInput &>/dev/null
}

function editFile() {
  ${VISUAL:-nano} $1
  tput civis
}

function showFlagStatus() {
  echo -e "${C}╭─── OPTIONS ─────╮"
  echo -e "${C}│                 │"

  echo -en "${C}│${W} Wallpaper "
  if [ $IS_WALLPAPER -eq 0 ]; then
    printf "${G}%-7s${W} ${C}│\n" "• ON"
  else
    printf "${R}%-7s${W} ${C}│\n" "• OFF"
  fi

  echo -en "${C}│${W} VSCode    "
  if [ $IS_VSCODE -eq 0 ]; then
    printf "${G}%-7s${W} ${C}│\n" "• ON"
  else
    printf "${R}%-7s${W} ${C}│\n" "• OFF"
  fi

  echo -en "${C}│${W} Preview   "
  if [ $COLOR_PREV -eq 0 ]; then
    printf "${G}%-7s${W} ${C}│\n" "• ON"
  else
    printf "${R}%-7s${W} ${C}│\n" "• OFF"
  fi

  echo -e "${C}╰─────────────────╯${W}\n"
}

function showColorPreview() {
  [[ $COLOR_PREV -eq 1 || -z "$1" ]] && return
  F_C=$2

  colors=( $(/bin/cat $THEMES_PATH/$1.colors | grep -Ee '^background:|^foreground:' | awk -F ': ' '{print $2}') )
  colors+=( $(/bin/cat $THEMES_PATH/$1.colors | grep '\-hg' -B 1 | grep -v '\-hg' | awk -F ': ' '{print $2}') )

  echo
  echo -e "${F_C}╭─── PREVIEW ─────────────────────────────╮${W}"
  echo -e "${F_C}│                                         │${W}"
  E_COLORS=( $(perl -e 'foreach $a(@ARGV){print "\e[38:2::".join(":",unpack("C*",pack("H*",$a)))."m "};' "${colors[@]}") )
  ART=("███" "▀▀▀")

  for line_art in "${ART[@]}"; do
    echo -en "${F_C}│ ${W}"
    for color in ${E_COLORS[@]}; do
      echo -en "$color$line_art\e[39m "
    done
    echo -e "${F_C}│${W}"
  done
  echo -e "${F_C}│${W}${W_B} Bg  Fg  Bl  Re  Gr  Ye  Bl  Ma  Cy  Wh  ${W}${F_C}│"
  echo -e "${F_C}╰─────────────────────────────────────────╯${W}\n"
}

function showDesktopsInteractive() {
  declare -i SHOWN_ELEMS=0
  declare PRINT_DESKTOP

  declare -i c=$(( $DESKTOP_IDX - $NUM_ELEMS/2 - 1 ))
  [ $(( $c + $NUM_ELEMS + 2 )) -gt $TOTAL_DESKTOPS ] && (( c = $TOTAL_DESKTOPS - $NUM_ELEMS - 2 ))

  echo -e "${C}╭─── ${B_B}DESKTOPS${W}${C} ── PATTERNS ── THEMES ── FAVS ───╮"
  echo -e "${C}│                                              │"
  while [ $SHOWN_ELEMS -le $(( $NUM_ELEMS )) ]; do
    (( c += 1 ))
    [ $c -lt 0 ] && continue

    if [ $c -lt $TOTAL_DESKTOPS ]; then
      PRINT_DESKTOP="${DESKTOPS[$c]}"
      [ $(basename $(realpath $ACTIVE_DESKTOP)) == ${DESKTOPS[$c]} ] && PRINT_DESKTOP="$PRINT_DESKTOP [active]"

      if [ $c -eq $DESKTOP_IDX ]; then
        printf "${C}│ ${C}‣ %-46s ${C}│\n" "$PRINT_DESKTOP ↓ ↑"
      else
        printf "${C}│ ${DIM}  %-42s${W} ${C}│\n" "$PRINT_DESKTOP"
      fi

    else
      echo -e "${C}│                                              │"
    fi

    (( SHOWN_ELEMS += 1 ))
  done
  echo -e "${C}╰──────────────────────────────────────────────╯${W}"

  manageDesktops
}

function manageDesktops() {
  DESKTOP_NAME=${DESKTOPS[$DESKTOP_IDX]}
  INPUT=$(keyInput)
  case $INPUT in
    up)
      [ $DESKTOP_IDX -gt 0 ] && (( DESKTOP_IDX -= 1 ));;
    down)
      [ $DESKTOP_IDX -lt $(( $TOTAL_DESKTOPS - 1 )) ] && (( DESKTOP_IDX += 1 ));;
    enter)
      applyDesktop $DESKTOP_NAME;;
    c)
      COLOR_PREV=$(( ! $COLOR_PREV ));;
    v)
      IS_VSCODE=$(( ! $IS_VSCODE ));;
    w)
      IS_WALLPAPER=$(( ! $IS_WALLPAPER ));;
    q) 
      ctrl_c;;
    h)
      showDesktopsHelp;;
    1|2|3|4)
      CURRENT_WINDOW="$INPUT";;
  esac
}

function showFavsInteractive() {
  declare -i SHOWN_ELEMS=0

  declare -i c=$(( $FAV_IDX - $NUM_ELEMS/2 - 1 ))
  [ $(( $c + $NUM_ELEMS + 2 )) -gt $TOTAL_FAVS ] && (( c = $TOTAL_FAVS - $NUM_ELEMS - 2 ))

  echo -e "${G}╭─── DESKTOPS ── PATTERNS ── THEMES ── ${B_B}FAVS${W}${G} ───╮"
  echo -e "${G}│                                              │"
  while [ $SHOWN_ELEMS -le $(( $NUM_ELEMS )) ]; do
    (( c += 1 ))
    [ $c -lt 0 ] && continue

    if [ $c -lt $TOTAL_FAVS ]; then
      if [ $c -eq $FAV_IDX ]; then
        printf "${G}│ ${G}‣ %-46s ${G}│\n" "${FAV_THEMES[$c]} ↓ ↑"
      else
        printf "${G}│ ${DIM}  %-42s${W} ${G}│\n" "${FAV_THEMES[$c]}"
      fi
    else
      echo -e "${G}│                                              │"
    fi

    (( SHOWN_ELEMS += 1 ))
  done
  echo -e "${G}╰──────────────────────────────────────────────╯${W}"

  showColorPreview "${FAV_THEMES[$FAV_IDX]}" "${G}"

  manageFavs
}

function manageFavs() {
  FAV_NAME=${FAV_THEMES[$FAV_IDX]}
  INPUT=$(keyInput)
  case $INPUT in
    up)
      [ $FAV_IDX -gt 0 ] && (( FAV_IDX -= 1 ));;
    down)
      [ $FAV_IDX -lt $(( $TOTAL_FAVS - 1 )) ] && (( FAV_IDX += 1 ));;
    left)
      [ $FAV_IDX -ge 10 ] && (( FAV_IDX -= 10 ));;
    right) 
      [ $FAV_IDX -lt $(( $TOTAL_FAVS - 10 )) ] && (( FAV_IDX += 10 ));;
    enter)
      applyTheme $FAV_NAME;;
    f)
      flagAsFavourite $FAV_NAME
      FAV_THEMES=( $(ls $FAV_THEMES_PATH | sed 's/\.colors//g') )
      TOTAL_FAVS=${#FAV_THEMES[@]}
      [ $FAV_IDX -eq $TOTAL_FAVS ] && (( FAV_IDX = $TOTAL_FAVS - 1 ));;
    e)
      editFile "$THEMES_PATH/$FAV_NAME.colors";;
    c)
      COLOR_PREV=$(( ! $COLOR_PREV ));;
    v)
      IS_VSCODE=$(( ! $IS_VSCODE ));;
    w)
      IS_WALLPAPER=$(( ! $IS_WALLPAPER ));;
    q)
      ctrl_c;;
    h)
      showThemesHelp;;
    1|2|3|4)
      CURRENT_WINDOW="$INPUT";;
  esac
}

function showPatternsInteractive() {
  declare -i SHOWN_ELEMS=0

  declare -i c=$(( $PATTERN_IDX - $NUM_ELEMS/2 - 1 ))
  [ $(( $c + $NUM_ELEMS + 2 )) -gt $TOTAL_PATTERNS ] && (( c = $TOTAL_PATTERNS - $NUM_ELEMS - 2 ))

  echo -e "${M}╭─── DESKTOPS ── ${B_B}PATTERNS${W}${M} ── THEMES ── FAVS ───╮"
  echo -e "${M}│                                              │"
  while [ $SHOWN_ELEMS -le $(( $NUM_ELEMS )) ]; do
    (( c += 1 ))
    [ $c -lt 0 ] && continue

    if [ $c -lt $TOTAL_PATTERNS ]; then
      if [[ $c -eq $PATTERN_IDX ]]; then
        printf "${M}│ ${M}‣ %-25s" "${PATTERNS[$c]} ↓ ↑"
      else
        printf "${M}│ ${DIM}  %-21s${W}" "${PATTERNS[$c]}"
      fi

      if [ -e $ACTIVE_PATTERNS_PATH/${PATTERNS[$c]}.pattern ]; then
        printf "${B}%-11s" "Active"
      else
        printf "${Y}%-11s" "Not Active"
      fi

      if [[ " ${INVERTED_PATTERNS[@]} " =~ " ${PATTERNS[$c]} " ]]; then
        printf "${C}%-11s${M}│\n" "Inv"
      else
        printf "%-11s${M}│\n" " "
      fi
    else
      echo -e "${M}│                                              │"
    fi

    (( SHOWN_ELEMS += 1 ))
  done
  echo -e "${M}╰──────────────────────────────────────────────╯${W}"

  managePatterns
}

function managePatterns() {
  PATTERN_NAME=${PATTERNS[$PATTERN_IDX]}
  INPUT=$(keyInput)
  case $INPUT in
    up)
      [ $PATTERN_IDX -gt 0 ] && (( PATTERN_IDX -= 1 ));;
    down)
      [ $PATTERN_IDX -lt $(( $TOTAL_PATTERNS - 1 )) ] && (( PATTERN_IDX += 1 ));;
    enter)
      if [ -e $ACTIVE_PATTERNS_PATH/$PATTERN_NAME.pattern ]; then
        removePatterns $PATTERN_NAME &>/dev/null
      else
        addPatterns $PATTERN_NAME &>/dev/null
      fi;;
    i)
      for i in ${!INVERTED_PATTERNS[@]}; do
        if [ "${INVERTED_PATTERNS[i]}" == "$PATTERN_NAME" ]; then
          unset INVERTED_PATTERNS[i]
          return
        fi
      done
      INVERTED_PATTERNS+=( "$PATTERN_NAME" );;
    p)
      editFile "$POSTSCRIPTS_PATH/$PATTERN_NAME.sh";;
    e)
      editFile "$PATTERNS_PATH/$PATTERN_NAME.pattern";;
    c)
      COLOR_PREV=$(( ! $COLOR_PREV ));;
    v)
      IS_VSCODE=$(( ! $IS_VSCODE ));;
    w)
      IS_WALLPAPER=$(( ! $IS_WALLPAPER ));;
    h)
      showPatternsHelp;;
    q)
      ctrl_c;;
    1|2|3|4)
      CURRENT_WINDOW="$INPUT";;
  esac
}

function showThemesInteractive() {
  declare -i SHOWN_ELEMS=0

  declare -i c=$(( $THEME_IDX - $NUM_ELEMS/2 - 1 ))
  [ $(( $c + $NUM_ELEMS + 2 )) -gt $TOTAL_THEMES ] && (( c = $TOTAL_THEMES - $NUM_ELEMS - 2 ))

  echo -e "${B}╭─── DESKTOPS ── PATTERNS ── ${B_B}THEMES${W}${B} ── FAVS ───╮"
  echo -e "${B}│                                              │"
  while [ $SHOWN_ELEMS -le $(( $NUM_ELEMS )) ]; do
    (( c += 1 ))
    [ $c -lt 0 ] && continue

    if [ $c -lt $TOTAL_THEMES ]; then
      if [ $c -eq $THEME_IDX ]; then
        printf "${B}│ ${B}‣ %-46s ${B}│\n" "${THEMES[$c]} ↓ ↑"
      else
        printf "${B}│ ${DIM}  %-42s${W} ${B}│\n" "${THEMES[$c]}"
      fi
    fi

    (( SHOWN_ELEMS += 1 ))
  done
  echo -e "${B}╰──────────────────────────────────────────────╯${W}"

  showColorPreview "${THEMES[$THEME_IDX]}" "${B}"

  manageThemes
}

function manageThemes() {
  THEME_NAME=${THEMES[$THEME_IDX]}
  INPUT=$(keyInput)
  case $INPUT in
    up)
      [ $THEME_IDX -gt 0 ] && (( THEME_IDX -= 1 ));;
    down)
      [ $THEME_IDX -lt $(( $TOTAL_THEMES - 1 )) ] && (( THEME_IDX += 1 ));;
    left)
      [ $THEME_IDX -ge 10 ] && (( THEME_IDX -= 10 ));;
    right)
      [ $THEME_IDX -lt $(( $TOTAL_THEMES - 10 )) ] && (( THEME_IDX += 10 ));;
    enter)
      applyTheme $THEME_NAME;;
    f)
      flagAsFavourite $THEME_NAME
      FAV_THEMES=( $(ls $FAV_THEMES_PATH | sed 's/\.colors//g') )
      TOTAL_FAVS=${#FAV_THEMES[@]}
      sleep 1;;
    e)
      editFile "$THEMES_PATH/$THEME_NAME.colors";;
    c)
      COLOR_PREV=$(( ! $COLOR_PREV ));;
    v)
      IS_VSCODE=$(( ! $IS_VSCODE ));;
    w)
      IS_WALLPAPER=$(( ! $IS_WALLPAPER ));;
    q) 
      ctrl_c;;
    h)
      showThemesHelp;;
    1|2|3|4)
      CURRENT_WINDOW="$INPUT";;
  esac
}

function interactiveLoop() {
  declare -i NUM_ELEMS=0
  if [ $(tput lines) -gt $(( 25 + 8 )) ]; then
    NUM_ELEMS=$(( $(tput lines) - 28 ))
  else
    NUM_ELEMS=$(( $(tput lines) - 20 ))
  fi

  declare -a INVERTED_PATTERNS=()

  declare -a DESKTOPS=( $(ls $DESKTOPS_PATH | grep -v "active-desktop") )
  declare -i TOTAL_DESKTOPS=${#DESKTOPS[@]}

  declare -a PATTERNS=( $(ls -p $PATTERNS_PATH | grep -v / | sed 's/\.pattern//g') )
  declare -i TOTAL_PATTERNS=${#PATTERNS[@]}

  declare -a THEMES=( $(ls -p $THEMES_PATH | grep -v / | sed 's/\.colors//g') )
  declare -i TOTAL_THEMES=${#THEMES[@]}

  declare -a FAV_THEMES=( $(ls $FAV_THEMES_PATH | sed 's/\.colors//g') )
  declare -i TOTAL_FAVS=${#FAV_THEMES[@]}

  declare -i DESKTOP_IDX=0
  declare -i PATTERN_IDX=0
  declare -i THEME_IDX=0
  declare -i FAV_IDX=0

  declare CURRENT_WINDOW="1"
  declare -i COLOR_PREV=0

  tput civis
  echo
  while true; do
    clear
    [ $NUM_ELEMS -ge 15 ] && gthemeLogo
    showFlagStatus
    case $CURRENT_WINDOW in
      1)
        showDesktopsInteractive;;
      2)
        showPatternsInteractive;;
      3)
        showThemesInteractive;;
      4)
        showFavsInteractive;;
    esac
  done
  tput cnorm
}

declare -gi IS_VSCODE=1
declare -gi IS_WALLPAPER=1
function main() {
  while getopts "l:hi:n:p:vwa:r:f:" opt; do
    case $opt in
      l)
        list $OPTARG
        exit 0;;
      h) 
        helpPanel
        exit 0;;
      a)
        addPatterns "$(echo $OPTARG | sed 's/,/ /g')"
        exit 0;;
      r)
        removePatterns "$(echo $OPTARG | sed 's/,/ /g')"
        exit 0;;
      f)
        flagAsFavourite "$(echo $OPTARG | sed 's/,/ /g')"
        exit 0;;
      n)
        declare THEME_NAME=$OPTARG;;
      p)
        declare PATTERNS=$OPTARG;;
      i)
        declare INVERTED_PATTERNS=$OPTARG;;
      v)
        IS_VSCODE=0;;
      w)
        IS_WALLPAPER=0;;
      *)
        helpPanel
        exit 1;;
    esac
  done

  PATTERNS="$(echo $PATTERNS | sed 's/,/ /g')"
  INVERTED_PATTERNS="$(echo $INVERTED_PATTERNS | sed 's/,/ /g')"
  checkPatterns "$PATTERNS $INVERTED_PATTERNS"

  [ -z "$THEME_NAME" ] && interactiveLoop

  checkThemes $THEME_NAME
  generateFiles "$THEME_NAME" "$PATTERNS" "$INVERTED_PATTERNS"
}

main "$@"
