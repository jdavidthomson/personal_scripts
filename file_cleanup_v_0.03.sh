#!/bin/bash
data_dir="data/"
#
#
#
# print_help
print_help (){
	echo ""
	echo "###########     file_cleanup.sh     ###########"
	echo ""
	echo ""
	echo "Command:"
	echo "	./file_cleanup.sh test run_script threshold"
	echo "		... this command copies files of a minimum filesize to a directory in the format of YYYY-MM-DD-HH; if the directory doesn't exist, creates it."
	echo ""
	echo "Command:"
        echo "	./file_cleanup.sh test cleanup_previous_test"
        echo "          ... this command copies files of a minimum filesize to a directory in the format of YYYY-MM-DD-HH; if the directory doesn't exist, creates it."
        echo ""
	echo "Command:"
	echo "	./file_cleanup live cleanup"
	echo "		... this command removes all directories and contents"
	echo ""
	echo ""
	echo "###########     END OF HELP	###########"
	echo ""
}
#
#
#
# fix YYYY-MM-DD-HH-MM bug by making them all YYYY-MM-DD-HH folders
fix_old_to_new_folders (){
	if [ -d $2 ]; then
		if [ ! -d $3 ]; then
			mkdir $3
			if [ $? -ne 0 ];then
				echo "directory could not be created for some reason..."
				exit
			fi
		fi
		file_count=$(ls -1q | wc -l)
		if [ $file_count -ne 0 ]; then
			$1 $2/* $3/
		fi
		rmdir $2
	fi
}
#
#
#
# work_on_files 
work_on_files (){
	$2 $1 $3/$1
}
#
#
#
# iterate_over_files
iterate_over_files () {
	test_or_live=$1
	filetype=$2
	threshold=$3

	command=""

	if [ $test_or_live == "test" ]; then
		command="cp"
	elif [ $test_or_live == "live" ]; then
		command="mv"
	else
		echo "Invalid command!!"
		exit
	fi

	for filename in $data_dir$filetype; do
		year=${filename:0:4}
		month=${filename:5:2}
		day=${filename:8:2}
		hour=${filename:11:2}
		min=${filename:14:2}
		sec=${filename:18:2}

		v_0_01_folder=$data_dir$year-$month-$day-$hour-$min
		v_0_02_folder=$data_dir$year-$month-$day-$hour

		fix_old_to_new_folders $command $v_0_01_folder $v_0_02_folder

		if [ -f $data_dir$filename ]; then
			filesize_str=$(du -h "${filename}"|cut -f1)
			if [ $filesize_str != "" ]; then
				fs_size=${filesize_str:(-4)}
				if [ ${#fs_size} != 0 ]; then
					fs_cardinal=${fs_size:0:(-1)}
					fs_cardinal_eval=$(echo "$fs_cardinal > $threshold"|bc -l)
					if (( $fs_cardinal_eval )); then
						if [ ! -d $v_0_02_folder ]; then
                                                        mkdir $v_0_02_folder
						fi
						work_on_files $data_dir$filename $command $v_0_02_folder
					fi
				fi
			fi
		fi
	done
}

main () {
	if [ "$#" -lt 1 ]; then
		print_help
	elif [ $1 == "test" ]; then
		if [ $2 == "run_script" ]; then
			if [ "$#" -eq 3 ]; then
				iterate_over_files "test" "*" $3
			else
				echo "... missing some parameters ..."
			fi
		fi
	elif [ $1 == "live" ]; then
		if [ $2 == "cleanup" ]; then
			if [ "$#" -eq 3 ]; then
        			iterate_over_files "live" "*" $3
			else
				echo "... missing some parameters ..."
			fi
		fi
	fi
}

echo "Starting cleanup..."
main "$@"
echo "...done cleanup."
