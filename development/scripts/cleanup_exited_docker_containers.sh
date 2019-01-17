#!/bin/bash

PROMT_FOR_DELETE=false

SAMPLE_TARGET_IMAGE_ID="90e2f90cf846"
SAMPLE_TI_LEN=$(echo $SAMPLE_TARGET_IMAGE_ID|wc -c)
EXITED_DOCKER_CONTAINERS=$(docker container ls -f "status=exited" --format='{{.ID}}|{{.Image}}')

if [ $PROMT_FOR_DELETE == true ]; then
	prompt_delete_containers
fi
prompt_delete_containers() {
	EXITED_DOCKER_CONTAINERS=$(docker container ls -f "status=exited" --format='{{.ID}}|{{.Image}}')
	for i in $EXITED_DOCKER_CONTAINERS;do
	    id=$(echo $i| cut -d"|" -f1)
	    image=$(echo $i | cut -d"|" -f2)
	    IMAGE_LEN=$(echo $image|wc -c)
	    if [ $PROMT_FOR_DELETE == true ]; then 
			input="" 
		        IFS= read -p "Delete this container id: $i ? ...>     " -r line
	        	input="$line" 
			if [ $(expr "$input" : "^[yYnN]$") ]; then
		        	if [ "$input" == "y" ] || [ "$input" == "Y" ]; then 
		        		#echo "deleted - not deleted" 
	    	            		docker container rm $id 
	       		 	fi 
	       		fi 
	    fi
	done
}


delete_containers() {
        EXITED_DOCKER_CONTAINERS=$(docker container ls -f "status=exited" --format='{{.ID}}|{{.Image}}')
        for i in $EXITED_DOCKER_CONTAINERS;do
            id=$(echo $i| cut -d"|" -f1)
            image=$(echo $i | cut -d"|" -f2)
            if [ $PROMT_FOR_DELETE == false ]; then
                #echo "deleting container $id"
                docker container rm $id
            fi
        done
}

if [ $PROMT_FOR_DELETE == false ]; then
	input=""
        IFS= read -p "This is going to remove all exited containers.  Continue ? ...>     " -r line
        input="$line"
        if [ $(expr "$input" : "^[yYnN]$") ]; then
        	if [ "$input" == "y" ] || [ "$input" == "Y" ]; then
        		#echo "deleted - not deleted" 
			delete_containers
                fi
        fi
fi
echo "done!"
