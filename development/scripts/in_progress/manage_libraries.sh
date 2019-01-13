#!/bin/bash

global_var=()
global_userinput=-1
global_user_input_string=""

usage() {
	command=$(echo $0|rev|cut -d"/" -f1|rev)

	echo ""
	echo ""
	echo "Incorrect number of parameters.  The correct usage is:"
	echo "$command [image tag to build from] [destination tag to build to]"
	echo ""
	exit
}

get_local_dockerfiles() {
	local_dockerfiles=()

	DOCKERFILE=$1
	TRAILING_SLASH="/"

	IFS=$'\n'
	for filename in $(find $DEVELOPMENT_DOCKERFILES_PATH -name $DOCKERFILE); do
		filename_length=${#filename}
		substring_length=$(expr ${#DOCKERFILE} + ${#TRAILING_SLASH})
		filename=$(echo $filename|rev)
		filename=${filename:$substring_length}
		filename=$(echo $filename|rev)
    		image_path_length_to_remove=$(expr ${#DEVELOPMENT_DOCKERFILES_PATH} + ${#TRAILING_SLASH})
    		image_name=${filename:${#DEVELOPMENT_DOCKERFILES_PATH}}
		global_var+=($image_name)
  	done
  	unset IFS
}

get_dockerfile_choice() {
	input=""
	while IFS= read -p "feed me...>     " -r line; do
		input="$line"
		if [ ! -z "${input##*[!0-9]*}" ]; then
			global_userinput="$input"
			return
		fi
	done
}

display_dockerfiles_for_selection() {
	_SCRATCHPAD_=$ENV_SCRATCHPAD_NAME

	echo "	0)        Create New Dockerfile"
	for index in ${!global_var[@]}; do
		if [[ ${global_var[$index]} != *"$_SCRATCHPAD_"* ]]; then
			asdf=$(expr $index + 1)
			echo "	$asdf)        ${global_var[$index]}"
		fi
	done

	echo "	---------------	"
	echo "Please choose one of the above dockerfiles by number:"
	get_dockerfile_choice
}

get_dockerfiles() {
        LOCAL="LOCAL"

        LOCATION=${1:-$LOCAL}
        DOCKERFILE=${2:-$STANDARD_DOCKERFILE_FILENAME}

        if [ "$LOCATION" == "$LOCAL" ]; then
		get_local_dockerfiles $DOCKERFILE
		if [ ${#global_var} -eq 0 ]; then
			echo "${#global_var} ... "
			echo "...this shouldn't happen..."
			exit
		fi
		display_dockerfiles_for_selection
		user_input_less_one=$(expr $global_userinput-1)
		global_user_input_string=${global_var[$user_input_less_one]}
		
		if [ "$global_user_input_string" == "" ]; then
			echo "**********ERROROROROROROROR:   display_dockerfiles_for_selection"
			echo "**********ERROROROROROROROR:   display_dockerfiles_for_selection"
			echo "**********ERROROROROROROROR:   display_dockerfiles_for_selection"
			echo "**********ERROROROROROROROR:   display_dockerfiles_for_selection"
			echo "**********ERROROROROROROROR:   display_dockerfiles_for_selection"
			exit
                fi
        fi
}

choose_base_image() {
	echo ""
}
add_build_options() {
	echo ""
}
save_dockerfile() {
	echo ""
}
create_new_dockerfile() {
	#choose_base_image
	#add_build_options
	#save_dockerfile
	echo ""
}
__main__() {

	if [ "$#" -ne  1 ]; then
		usage "$@"
	fi

	DOCKER_COMMAND="docker"
	DOCKER_BUILD_COMMAND="$DOCKER_COMMAND build"

	global_user_input=-1
	#echo "$global_user_input"

	while [ $global_user_input -le 0 ]; do
		get_dockerfiles
		if [ $global_user_input == 0 ]; then
			create_new_dockerfile
			global_user_input=-1
		else
			break
		fi
		echo "$global_user_input"
	done

	DOCKERFILE_LOCATION="$DEVELOPMENT_DOCKERFILES_PATH/$global_user_input_string"
	if [ "${DOCKERFILE_LOCATION:$(expr ${#DOCKERFILE_LOCATION} - 1)}" != "/" ]; then
		DOCKERFILE_LOCATION="$DOCKERFILE_LOCATION/"
	fi

	DESTINATION_TAG_OPTION_FLAG="-t"
	DESTINATION_IMAGE_TAG="$1"
	DESTINATION_FLAGS="$DESTINATION_TAG_OPTION_FLAG $DESTINATION_IMAGE_TAG"

	echo "$DOCKER_BUILD_COMMAND $DOCKERFILE_LOCATION $DESTINATION_FLAGS"
	$DOCKER_BUILD_COMMAND $DOCKERFILE_LOCATION $DESTINATION_FLAGS

	if [ $? == 0 ]; then
		echo "#####################################"
		echo "Image Built."
		echo "#####################################"
	else
		echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
		echo "ERROR BUILDING IMAGE..."
		echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	fi	
}

__main__ "$@"
