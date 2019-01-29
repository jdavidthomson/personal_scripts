#!/bin/bash

UBUNTU_SETTINGS_FILE=$1
global_user_iput=""

get_input() {
	PROMPT=$1

	input=""
        while IFS= read -p "$PROMPT :>     " -r line; do
                input="$line"
                if [ ! -z "${input##*[!yn]*}" ]; then
                        global_user_input="$input"
                        return
                fi
        done
}
get_confirmation_choice() {
	get_input "Confirm with y or n"
}

extract_file() {
	tar -xvf $1
}
recreate_environment() {
	environment=$(echo "$1"|cut -d"." -f0)
	extract_file $1

	sudo apt-key add $environment/Repo.keys
	sudo cp -R $environment/sources.list* /etc/apt/
	sudo apt-get update
	sudo apt-get install dselect
	sudo dselect update
	apt-cache dumpavail > $environment/temp_avail
	sudo dpkg --merge-avail $environment/temp_avail
	rm ~/temp_avail
	sudo dpkg --set-selections < $environment/Package.list
	sudo apt-get dselect-upgrade -y
}

echo "Ubuntu settings file:  $1"
echo "Are you SURE you want to recreate the system from this dump?"
get_confirmation_choice

if [ ! -z "${global_user_input##*[!y]*}" ]; then
	echo "ok...we're good"
fi

echo "done."
