#!/bin/bash

PROMT_FOR_DELETE=false

SAMPLE_TARGET_IMAGE_ID="90e2f90cf846"
SAMPLE_TI_LEN=$(echo $SAMPLE_TARGET_IMAGE_ID|wc -c)
RELEVANT_DOCKER_PROCESSES=$(docker container ls -a --format='{{.ID}}|{{.Image}}')

for i in $RELEVANT_DOCKER_PROCESSES;do 
    id=$(echo $i| cut -d"|" -f1)
    image=$(echo $i | cut -d"|" -f2)
    #echo $i
    #echo $id
    #echo $image
    #echo $SAMPLE_TI_LEN
    IMAGE_LEN=$(echo $image|wc -c)
    if [ $IMAGE_LEN == $SAMPLE_TI_LEN ] && [[ $image =~ [:alnum] ]]; then
	    echo $i
    fi
done

RELEVANT_DOCKER_PROCESSES=$(docker container ls -a --format='{{.ID}}|{{.Image}}')
for i in $RELEVANT_DOCKER_PROCESSES;do
    id=$(echo $i| cut -d"|" -f1)
    image=$(echo $i | cut -d"|" -f2)
    IMAGE_LEN=$(echo $image|wc -c)
    if [ $PROMT_FOR_DELETE == true ] && [ $IMAGE_LEN == $SAMPLE_TI_LEN ] && [[ $image =~ [:alnum] ]]; then 
		input="" 
	        IFS= read -p "Delete this container id: $i ? ...>     " -r line
        	input="$line" 
		if [ $(expr "$input" : "^[yYnN]$") ]; then
	        	if [ "$input" == "y" ] || [ "$input" == "Y" ]; then 
	        		#echo "deleted - not deleted" 
    	            		docker container rm $id 
       		 	fi 
       		fi 
    else
	if [ $IMAGE_LEN == $SAMPLE_TI_LEN ] && [[ $image =~ [:alnum] ]]; then
		#echo "all delete - not deleted"
		docker container rm $id
	fi	
    fi
done
