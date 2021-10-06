#!/bin/bash

# •• Colors
R="\e[1;31m"
G="\e[1;32m"
Y="\e[1;33m"
B="\e[1;34m"
M="\e[1;35m"
C="\e[1;36m"
W="\e[0m"
W_B="\e[1m"

# •• Global variables
SRC_PATH=$(realpath $(dirname $0))
GTHEME_PATH=$HOME/.config/gtheme

function gthemeLogo() {
	echo
  echo -e "${R} ██████╗ ${G} ████████╗${Y} ██╗  ██╗${B} ███████╗${M} ███╗   ███╗${C} ███████╗${W}"
  echo -e "${R}██╔════╝ ${G} ╚══██╔══╝${Y} ██║  ██║${B} ██╔════╝${M} ████╗ ████║${C} ██╔════╝${W}"
  echo -e "${R}██║  ███╗${G}    ██║   ${Y} ███████║${B} █████╗  ${M} ██╔████╔██║${C} █████╗  ${W}"
  echo -e "${R}██║   ██║${G}    ██║   ${Y} ██╔══██║${B} ██╔══╝  ${M} ██║╚██╔╝██║${C} ██╔══╝  ${W}"
  echo -e "${R}╚██████╔╝${G}    ██║   ${Y} ██║  ██║${B} ███████╗${M} ██║ ╚═╝ ██║${C} ███████╗${W}"
  echo -e "${R} ╚═════╝ ${G}    ╚═╝   ${Y} ╚═╝  ╚═╝${B} ╚══════╝${M} ╚═╝     ╚═╝${C} ╚══════╝${W}"
	echo -e "\n"
}

function rollback() {
	echo -e "\n${Y}•${W} Rolling back the installation...\n"
	[ -e /usr/bin/gtheme ] && sudo rm /usr/bin/gtheme &>/dev/null
	rm -rf $GTHEME_PATH &>/dev/null
	exit 1
}

function copyFiles() {
	declare -a GTHEME_FOLDERS=("themes" "patterns" "post-scripts" "wallpapers")

	echo -e "${G}•${W} Creating main gtheme folder in ${W_B}$GTHEME_PATH${W}..."
	mkdir $GTHEME_PATH &>/dev/null

	for FOLDER in ${GTHEME_FOLDERS[@]}; do
		echo -e "${G}•${W} Transfering ${W_B}$FOLDER${W}..."
		if ! cp -r $SRC_PATH/$FOLDER/ $GTHEME_PATH/$FOLDER; then
			echo -e "${R}[!]${W} There was an error while transfering ${W_B}$SRC_PATH/$FOLDER/${W}!\n"
			rollback
		fi

		[ "$FOLDER" == "patterns" ] && mkdir $GTHEME_PATH/$FOLDER/active-patterns
		[ "$FOLDER" == "themes" ] && mkdir $GTHEME_PATH/$FOLDER/fav-themes
	done
	echo -e "${G}• Done!${W}\n"

	echo -e "${G}•${W} Copying gtheme script to ${W_B}/usr/bin${W}..."
	echo -e "${G}•${W} You must be root to proceed"
	if ! sudo cp $SRC_PATH/gtheme /usr/bin; then
		echo -e "${R}[!]${W} There was an error while copying script to ${W_B}/usr/bin${W}\n"
		rollback
	fi
	echo -e "${G}• Done!${W}\n"
}

function main() {
	echo
	gthemeLogo
	copyFiles
	
	echo -e "${B}• Installation finished!${W}\n"
	echo -e "${B}•${W} To get more information about its usage refer to the repo: ${B}https://github.com/daavidrgz/gtheme${W}"
	echo -e "${B}•${W} Feel free to also check my dotfiles: ${B}https://github.com/daavidrgz/dotfiles${W}
  (Provided patterns and post-scripts were made to perfectly work with them)\n\n"

	exit 0
}

main
