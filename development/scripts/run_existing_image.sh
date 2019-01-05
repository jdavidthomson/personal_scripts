#!/bin/bash

whoami
docker build "one_for_grace:latest" -t "be41b71d-1ad6-49a2-b76c-0dcf093d2e6a-scratchpad"
exit

build_image() {
	DOCKER_BASE_IMAGE_TAG=$1
	DOCKER_DESTINATION_TAG=$2

	echo "building image from $DOCKER_BASE_IMAGE_TAG and saving it as: $DOCKER_DESTINATION_TAG""
	docker build $DOCKER_BASE_IMAGE_TAG -t $DOCKER_DESTINATION_TAG"

}

run_image() {
	DOCKER_IMAGE_TAG=$1
	CONTINUATION_COMMAND=$2

	echo "starting instance...$DOCKER_IMAGE_TAG"
	docker run -t $DOCKER_IMAGE_TAG $CONTINUATION_COMMAND
}

get_running_container_id() {
	DOCKER_IMAGE_TAG=$1

	echo "getting $DOCKER_IMAGE_TAG container id"
	INTERESTED_RUNNING_TAG_PS_ID=$(docker ps|grep $DOCKER_IMAGE_TAG |cut -f1)
	return $INTERESTED_RUNNING_TAG_PS_ID

}

autosaver_get_tag() {
	TODAY_NOW=$(date +%Y/%m/%d)
        TODAY_YEAR=$(echo $TODAY_NOW|awk -F'/' '{print $1}')
        TODAY_MONTH=$(echo $TODAY_NOW|awk -F'/' '{print $2}')
        TODAY_DAY=$(echo $TODAY_NOW|awk -F'/' '{print $3}')

	RUNNING_CONTAINER_PS_ID=$1

	RUNNING_DOCKER_PROCESSES=$(docker ps --format "{{.ID}}|{{.Image}}")
        RUNNING_DOCKER_PROCESS_IMAGE_TAG=$(echo $RUNNING_DOCKER_PROCESSES|grep $RUNNING_CONTAINER_PS_ID|cut -d"|" -f2)
        KEEP_RUNNING=$RUNNING_DOCKER_PROCESS_IMAGE_TAG
	COMMIT_SAVE_TAG_IMAGE=$(echo $RUNNING_DOCKER_PROCESS_IMAGE_TAG|cut -d":" -f0)
        COMMIT_SAVE_TAG_VERSION=$(echo $RUNNING_DOCKER_PROCESS_IMAGE_TAG|cut -d":" -f1|cut -d"_")

	if [ $KEEP_RUNNING -eq "" ]; then
		return
	fi

        if [ $COMMIT_SAVE_TAG_VERSION -eq "latest"]; then
                COMMIT_SAVE_TAG_VERSION=1
        else
                COMMIT_SAVE_TAG_VERSION=$COMMIT_SAVE_TAG_VERSION+1
        fi

	NEW_COMMIT_TAG=$COMMIT_SAVE_TAG_IMAGE:$TODAY_YEAR-$TODAY_MONTH-$TODAY_DAY_$COMMIT_SAVE_TAG_VERSION
	return $NEW_COMMIT_TAG
}

start_autosaver() {

	RUNNING_CONTAINER_PS_ID=$1
	DOCKER_DESTINATION_TAG=$2

	UNIT_SECONDS=60
	DEFAULT_INTERVAL_MINUTES=5
	INTERVAL_MINUTES=${3:-$DEFAULT_INTERVAL_MINUTES}
	INTERVAL_SECONDS=INTERVAL_MINUTES * UNIT_SECONDS
	
	NEW_COMMIT_TAG=autosaver_get_tag $RUNNING_CONTAINER_PS_ID

	echo "starting process to commit the instance state for running container: $RUNNING_CONTAINER_PS_ID of variant: $COMMIT_SAVE_TAG every $INTERVAL_MINUTES  minutes ..."
	backup_counter=0
	while [ $NEW_COMMIT_TAG ]; do 
		docker commit $RUNNING_CONTAINER_PS_ID $NEW_COMMIT_TAG
		backup_counter+=1
		if [ $(($backup_counter % 5)) -eq 0 ]; then
			docker commit $RUNNING_CONTAINER_PS_ID $DOCKER_DESTINATION_TAG
		fi
		sleep $INTERVAL_SECONDS
		NEW_COMMIT_TAG=autosaver_get_tag $RUNNING_CONTAINER_PS_ID
	done
}

attach_to_container(){
	TAG=$1
	TAG_PS=$2

	echo "attaching to image $TAG container $TAG_PS"
	docker attach $TAG_PS
}

__main__() {

	#DOCKER_BASE_IMAGES=$(docker images --format "{{.|grep base)

	
	INSTANCE_UUID=$(cat /proc/sys/kernel/random/uuid)

	SCRATCHPAD="scratchpad"
	#DOCKER_DESTINATION_TAG=$INSTANCE_UUID-$SCRATCHPAD
	DOCKER_INSTANCE_TAG=$INSTANCE_UUID-$SCRATCHPAD
	DOCKER_DESTINATION_TAG=$2

	BASH_COMMAND="/bin/bash"

	DOCKER_BASE_IMAGE_TAG=$1
	#DOCKER_DESTINATION_TAG=$2

	build_image $DOCKER_BASE_IMAGE_TAG $DOCKER_INSTANCE_TAG
	run_image $DOCKER_INSTANCE_TAG $BASH_COMMAND
	RUNNING_CONTAINER_ID=get_running_container_id $DOCKER_INSTANCE_TAG
	start_autosaver $RUNNING_CONTAINER_ID $DOCKER_DESTINATION_TAG &
	attach_to_container $RUNNING_CONTAINER_ID
}

__main__ "$@"
