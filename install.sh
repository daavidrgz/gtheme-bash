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
BACKUP_PATH=/etc/gtheme/backup

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
	# echo -e "\n${Y}•${W} Rolling back the installation...\n"
	# [ -e /usr/bin/gtheme ] && sudo rm /usr/bin/gtheme &>/dev/null
	# rm -rf $GTHEME_PATH &>/dev/null
	exit 1
}

function backupConfig() {
	[ ! -e $BACKUP_PATH ] && sudo mkdir -p $BACKUP_PATH
	echo -e "\n${G}•${W} Copying all your files. This may take a while..."
	sudo cp -r $HOME/.config $BACKUP_PATH
	echo -e "${G}•${W} Backup done!\n"
}

function askBackup() {
	while true; do
		echo -en "${B}[!]${W} Do you want to make a backup? All your ${W_B}$HOME/.config${W} folder will be copied to ${W_B}$BACKUP_PATH${W} ${G}(y/n)${W} "
		read INPUT
		case $INPUT in 
			y | Y) 
				backupConfig
				return 0;;
			n | N)
				echo -e "\n${R}•${W} Skipping backup creation...\n"
				return 0;;
			*)
				echo -e "\n${R}•${W} Incorrect option!\n";;
		esac
	done
}

function copyFiles() {
	declare -a GTHEME_FOLDERS=("themes" "patterns" "post-scripts" "wallpapers")

	if [ ! -e "$GTHEME_PATH" ]; then
		echo -e "${G}•${W} Creating main gtheme folder in ${W_B}$GTHEME_PATH${W}..."
		mkdir $GTHEME_PATH &>/dev/null

		for FOLDER in ${GTHEME_FOLDERS[@]}; do
			echo -e "${G}•${W} Transfering ${W_B}$FOLDER${W}..."
			if ! cp -r $SRC_PATH/$FOLDER/ $GTHEME_PATH/$FOLDER; then
				echo -e "${R}[!]${W} There was an error while transfering ${W_B}$SRC_PATH/$FOLDER/${W}!\n"
				rollback
			fi

			[ "$FOLDER" == "themes" ] && mkdir $GTHEME_PATH/$FOLDER/fav-themes
		done
		echo -e "${G}• Done!${W}\n"

	else
		echo -e "${Y}•${W} It looks like you have already installed gtheme. Skipping the main gtheme folder copy in ${W_B}$GTHEME_PATH${W}...\n"
	fi

	echo -e "${G}•${W} Copying gtheme script to ${W_B}/usr/bin${W}..."
	echo -e "${G}•${W} You must be root to proceed!"
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
	askBackup
	
	echo -e "${B}• Installation finished!${W}\n"
	echo -e "${B}•${W} To get more information about gtheme usage refer to the repo: ${B}https://github.com/daavidrgz/gtheme${W}"
	echo -e "${B}•${W} Feel free to also check my dotfiles: ${B}https://github.com/daavidrgz/dotfiles${W}
  (Provided patterns and post-scripts were made to perfectly work with them)\n"

	exit 0
}

main
