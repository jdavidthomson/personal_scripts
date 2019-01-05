#!/bin/bash
#trap "exit 1" TERM
trap "exit -1" TERM
trap "exit 0" TERM
trap "exit -2" TERM

#export TOP_PID=$$

#abort_script() {
#   echo "Goodbye"
#   kill -s TERM $TOP_PID
#}

global_destination_tag_full_pat=""
global_interested_running_tag_ps_id=0
global_new_commit_tag=""

build_new_image() {
	if [ "$global_destination_tag_full_path" == "" ]; then
		echo "ERRORERRORERROR: error in build_new_image with global_destination_tag_full_path being empty..."
		exit -1
	fi
	which docker
	DOCKER_DESTINATION_TAG=$1
	echo $DOCKER_DESTINATION_TAG
	echo "that's the DOCKER_DESTINATION_TAG"
	if [ "$DOCKER_DESTINATION_TAG" == "" ]; then
		echo "ERRORERRORERROR: error in build_new_image with DOCKER_DESTINATION_TAG being empty..."
                exit -1
	fi

	docker build $global_destination_tag_full_path -t $DOCKER_DESTINATION_TAG
	docker_build_return_code=$?
	if [ $docker_build_return_code -ne 0 ]; then
		echo "ERRORERRORERROR: error in build_new_image with return code: $docker_build_return_code"
                exit -1
	fi
}

make_new_dockerfile() {
	DOCKERFILE_NAME="Dockerfile"
	DOCKER_DESTINATION_TAG=$1
	if [ "$DOCKER_DESTINATION_TAG" == "" ]; then
                echo "ERRORERRORERROR: error in make_new_dockerfile with DOCKER_DESTINATION_TAG being empty..."
                exit -1
        fi
	DOCKER_BASE_IMAGE_TAG=$2
	if [ "$DOCKER_BASE_IMAGE_TAG" == "" ]; then
                echo "ERRORERRORERROR: error in make_new_dockerfile with DOCKER_BASE_IMAGE_TAG being empty..."
                exit -1
        fi

	DOCKERFILE_FROM="FROM $DOCKER_BASE_IMAGE_TAG"
	DOCKERFILE=$(echo "$DOCKERFILE_FROM")

	echo $DOCKERFILE > $global_destination_tag_full_path/$DOCKERFILE_NAME

	create_dockerfile_command_exit_code=$?
	if [ $create_dockerfile_command_exit_code -ne 0 ]; then
                echo "ERRORERRORERROR: error in make_new_dockerfile with return code: $create_dockerfile_command_exit_code"
                exit $create_dockerfile_command_exit_code
	fi
}

create_image_path() {
	if [ "$DOCKER_DEV_IMAGES_PATH" == "" ]; then
		echo "ERRORERRORERROR: environmental setup error..."
		echo "DEVELOPMENT_DOCKERFILES_PATH is: $DEVELOPMENT_DOCKERFILES_PATH"
		echo "DEV_IMAGES_PATH is: $DEV_IMAGES_PATH"
		echo "both need to be set to valid paths.  thanks!"
		exit -1
	fi
	DOCKER_DESTINATION_TAG="$1"
	if [ "$DOCKER_DESTINATION_TAG" == "" ]; then
		echo "ERRORERRORERROR: error in create_image_path with DOCKER_DESTINATION_TAG being empty..."
                exit -1
	fi

	destination_tag_full_path="$DOCKER_DEV_IMAGES_PATH/$DOCKER_DESTINATION_TAG"
	mkdir -p $destination_tag_full_path
	mkdir_exit_code=$?
	if [ $mkdir_exit_code -ne 0 ]; then
		echo "ERRORERRORERROR: error in create_image_path with return code: $mkdir_exit_code"
		exit $mkdir_exit_code
	fi
	global_destination_tag_full_path=$destination_tag_full_path	
}

build_image() {
	DOCKER_BASE_IMAGE_TAG=$1
	DOCKER_DESTINATION_TAG=$2

	echo "building image from $DOCKER_BASE_IMAGE_TAG and saving it as: $DOCKER_DESTINATION_TAG"
	create_image_path $DOCKER_DESTINATION_TAG
	make_new_dockerfile $DOCKER_DESTINATION_TAG $DOCKER_BASE_IMAGE_TAG
	build_new_image $DOCKER_DESTINATION_TAG	
	#docker build $DOCKER_AG -t $DOCKER_DESTINATION_TAG
}

run_image() {
	echo "run_image"
	DOCKER_IMAGE_TAG=$1
        #CONTINUATION_COMMAND=$2

        #echo "starting instance...$DOCKER_IMAGE_TAG"
        #echo "...using this command:  $CONTINUATION_COMMAND"
        docker_run_command="docker run --name $DOCKER_IMAGE_TAG -d -t $DOCKER_IMAGE_TAG"
	$docker_run_command
	docker_run_exit_status=$?
	echo "docker run exit status done..."
        echo $docker_run_exit_status
        
        if [ "$docker_run_exit_status" != 0 ]; then
                echo "ERRORERRORERROR: error in dt_run_image with docker_run_exit_status being empty..."
                exit -1
        fi
	echo "run_image() run..."
}

dt_run_image() {
	DOCKER_IMAGE_TAG=$1
	#CONTINUATION_COMMAND=$2

	#echo "starting instance...$DOCKER_IMAGE_TAG"
	#echo "...using this command:  $CONTINUATION_COMMAND"
	docker_run_command="docker run -d -t $DOCKER_IMAGE_TAG; echo $?"
	
	#echo $docker_run_command
	#sleep 10000
	docker_run_exit_status=$($docker_run_command)
	echo $docker_run_exit_status
	sleep 1000
	#docker run -d -t $DOCKER_IMAGE_TAG $CONTINUATION_COMMAND; echo $?)
	
	#echo "ERROROROR: docker run exit status:"
	#echo $docker_run_exit_status
	#pses=$(docker ps)
	#echo $pses
	#echo "ok...."
	if [ "$docker_run_exit_status" == 0 ]; then
		echo "ERRORERRORERROR: error in dt_run_image with docker_run_exit_status being empty..."
                exit -1		
	fi
}

get_running_container_id() {
	echo "get_running_container_id..."

	DOCKER_IMAGE_TAG=$1

	echo "getting $DOCKER_IMAGE_TAG container id"
	echo "$DOCKER_IMAGE_TAG"
	echo $(docker ps)
	INTERESTED_RUNNING_TAG_PS_ID=$(docker ps|grep $DOCKER_IMAGE_TAG |cut -d" " -f1)
	global_interested_running_tag_ps_id=$INTERESTED_RUNNING_TAG_PS_ID
	echo $INTERESTED_RUNNING_TAG_PS_ID
	echo $global_interested_running_tag_ps_id
	echo "those were the values..."
	echo "get_running_container_id...done"
}

autosaver_get_tag() {
	VERSION="VERSION"
	TODAY_NOW=$(date +%Y/%m/%d)
        TODAY_YEAR=$(echo $TODAY_NOW|awk -F'/' '{print $1}')
        TODAY_MONTH=$(echo $TODAY_NOW|awk -F'/' '{print $2}')
        TODAY_DAY=$(echo $TODAY_NOW|awk -F'/' '{print $3}')

	RUNNING_CONTAINER_PS_ID=$1

	RUNNING_DOCKER_PROCESSES=$(docker ps --format "{{.ID}}|{{.Image}}")
        RUNNING_DOCKER_PROCESS_IMAGE_TAG=$(echo $RUNNING_DOCKER_PROCESSES|grep $RUNNING_CONTAINER_PS_ID|cut -d"|" -f2)
        KEEP_RUNNING=$RUNNING_DOCKER_PROCESS_IMAGE_TAG
	echo "$KEEP_RUNNING" >> /home/david/development/commit_log.log
	COMMIT_SAVE_TAG_IMAGE=$(echo $KEEP_RUNNING|cut -d":" -f1)
	echo "$COMMIT_SAVE_TAG_IMAGE" >> /home/david/development/commit_log.log
        COMMIT_SAVE_TAG_VERSION=$(echo $RUNNING_DOCKER_PROCESS_IMAGE_TAG|cut -d":" -f1|cut -c${#VERSION}-)
	echo "$COMMIT_SAVE_TAG_VERSION" >> /home/david/development/commit_log.log
	
	exit -2
	if [ "$KEEP_RUNNING" == "" ]; then
		return
	fi

	echo "$COMMIT_SAVE_TAG_VERSION"
	echo "that as the  tag we wanted...?"

        if [ "$COMMIT_SAVE_TAG_VERSION" == "latest" ]; then
                COMMIT_SAVE_TAG_VERSION=1
        else
                COMMIT_SAVE_TAG_VERSION=$COMMIT_SAVE_TAG_VERSION+1
        fi

	NEW_COMMIT_TAG=$COMMIT_SAVE_TAG_IMAGE:$TODAY_YEAR-$TODAY_MONTH-$TODAY_DAY_$COMMIT_SAVE_TAG_VERSION
	global_new_commit_tag=$NEW_COMMIT_TAG
}

start_autosaver() {
	#INFINIT_LOOP_SLEEP=5
	TEST_INFINIT_LOOP_SLEEP=1
	INFINITE_LOOP_SLEEP=$TEST_INFINIT_LOOP_SLEEP

	RUNNING_CONTAINER_PS_ID=$1
	DOCKER_DESTINATION_TAG=$2

	#UNIT_SECONDS=60
	TEST_UNIT_SECONDS=10
	UNIT_SECONDS=$TEST_UNIT_SECONDS

	DEFAULT_INTERVAL_MINUTES=5
	#INTERVAL_MINUTES=${3:-$DEFAULT_INTERVAL_MINUTES}
	TEST_INTERVAL_MINUTES=1
	INTERVAL_MINUTES=$TEST_INTERVAL_MINUTES
	INTERVAL_SECONDS=$(( $INTERVAL_MINUTES*$UNIT_SECONDS ))
	
	autosaver_get_tag $RUNNING_CONTAINER_PS_ID
	NEW_COMMIT_TAG=$global_new_commit_tag

	echo "starting process to commit the instance state for running container: $RUNNING_CONTAINER_PS_ID of variant: $NEW_COMMIT_TAG every $INTERVAL_MINUTES  minutes ..."
	backup_counter=0
	while : ; do
		while [ "$NEW_COMMIT_TAG" != "" ]; do 
			echo "saving...?"
			docker commit $RUNNING_CONTAINER_PS_ID $NEW_COMMIT_TAG
			NEW_COMMIT_TAG=""
			backup_counter+=1
			if [ $(($backup_counter % 1)) -eq 0 ]; then
				docker commit $RUNNING_CONTAINER_PS_ID $DOCKER_DESTINATION_TAG
			fi
			sleep $INTERVAL_SECONDS
			autosaver_get_tag $RUNNING_CONTAINER_PS_ID
		done
		sleep $INFINIT_LOOP_SLEEP
		autosaver_get_tag $RUNNING_CONTAINER_PS_ID
		NEW_COMMIT_TAG=$global_new_commit_tag
		if [ "$NEW_COMMIT_TAG" == "" ]; then
			echo "$NEW_COMMIT_TAG" >> /home/david/development/taglog.log 
			break
		fi
	done
}

attach_to_container(){
	if [ "$global_interested_running_tag_ps_id" == "" ]; then
		echo "ERRORERRORERROR: inside of attach_to_containter and global_interested_running_tag_ps_id is empty."
		exit -1
	fi

	TAG=$1

	if [ "$TAG" == "" ]; then
		echo "ERRORERRORERROR: error in attach_to_container with TAG being empty..."
                exit -1
	fi
	echo "attaching to image $TAG container $global_interested_running_tag_ps_id"
	echo "here we go..."
	#sleep 1000
	#docker attach $global_interested_running_tag_ps_id
	docker_attachment_command="docker exec -it $TAG /bin/bash"
	echo "$docker_attachment_command"
	$docker_attachment_command
}

__main__() {

	#DOCKER_BASE_IMAGES=$(docker images --format "{{.|grep base)

	OUTPUT_OF_UUID_CMD=$(cat /proc/sys/kernel/random/uuid)	
	INSTANCE_UUID="${OUTPUT_OF_UUID_CMD//\-}"
	echo "instance uuid"
	echo "$INSTANCE_UUID"
	SCRATCHPAD="$ENV_SCRATCHPAD_NAME"
	#DOCKER_DESTINATION_TAG=$INSTANCE_UUID-$SCRATCHPAD
	DOCKER_INSTANCE_TAG="$INSTANCE_UUID$SCRATCHPAD"
	echo "$DOCKER_INSTANCE_TAG"
	DOCKER_DESTINATION_TAG=$2

	CONTINUATION_COMMAND="/bin/bash"

	DOCKER_BASE_IMAGE_TAG=$1
	#DOCKER_DESTINATION_TAG=$2

	build_image $DOCKER_BASE_IMAGE_TAG $DOCKER_INSTANCE_TAG
	echo $DOCKER_INSTANCE_TAG
	echo "that was DOCKER_INSTANCE_TAG"
	echo "$CONTINUATION_COMMAND"
	echo "that was CONTINUATION_COMMAND"
	#dt_run_image $DOCKER_INSTANCE_TAG $CONTINUATION_COMMAND
	echo "__ run_image __ "
	run_image $DOCKER_INSTANCE_TAG
	echo "__ image run __ "
	get_running_container_id $DOCKER_INSTANCE_TAG
	start_autosaver $DOCKER_DESTINATION_TAG &
	AUTOSAVER_PID=$!
	#echo $AUTOSAVER_PID
	attach_to_container $DOCKER_INSTANCE_TAG
	echo "doneski..."
	#kill ${AUTOSAVER_PID}
}

__main__ "$@"
