#!/bin/bash
####################################
#
# Backup to NFS mount script for weras application.
# Developer: Menard Cu
# Date: Oct. 26, 2020
#
####################################

# What to backup.
backup_files_frontend_logs="/weras/webroot/frontend/var/logs"
backup_files_backend_logs="/weras/webroot/backend/storage/logs"

first_param="$1"
second_param="$2"
older_date=$(date --date="-$first_param month" +$second_param"_%m")
older_date_dash=$(date --date="-$first_param month" +"$second_param-%m")

create_folder="${backup_files_backend_logs}/${older_date}"
move_folder="${backup_files_backend_logs}/${older_date_dash}"
create_folder_frontend="${backup_files_frontend_logs}/${older_date}"
move_folder_frontend="${backup_files_frontend_logs}/${older_date_dash}"


moving_files_function () {
	mv ${move_folder}-* ${create_folder} 2>/dev/null
	if [ $? -eq 0 ]
	then
   		echo "--- All files has been successfully for backend!"
	else
		echo "--- Nothing to move right now for backend."
		rm -rf $create_folder
	fi
}

moving_files_frontend_function () {
	mv ${move_folder_frontend}-* ${create_folder_frontend} 2>/dev/null
	if [ $? -eq 0 ]
	then
   		echo "--- All files has been successfully moved for frontend!"
	else
		echo "--- Nothing to move right now for frontend."
		rm -rf $create_folder_frontend
	fi
}

echo "Moving all the separated logs into one folder."
if [ -d "$create_folder" ]; then
	moving_files_function
else
	echo "Creating new folder for backend"
	mkdir $create_folder
	moving_files_function
fi

if [ -d "$create_folder_frontend" ]; then
	moving_files_frontend_function
else
	echo "Creating new folder for frontend"
	mkdir $create_folder_frontend
	moving_files_frontend_function
fi

# Where to backup to.
dest="/data/weras_backup_files"

# Create archive filename.
backend_file="backend-$older_date.tgz"
frontend_file="fronend-$older_date.tgz"

if [[ -f "$dest/$backend_file" ]]
then
	echo
	echo -e "The backup file already been created! ${backend_file}"
	echo

	# Long listing of files in $dest to check file sizes.
	ls -lh $dest
else
	# Print start status message.
	echo "Backing up $create_folder to $dest/$backend_file"
	date
	echo

	cd $backup_files_backend_logs
	# Backup the files using tar.
	tar cvzf $dest/$backend_file $older_date
	#
	# Print end status message.
	echo
	echo "Backup finished for backend"
	date

	# Long listing of files in $dest to check file sizes.
	ls -lh $dest

	# removing the entire folders.
	echo
	echo "Removing the compiled folder for backend. ${create_folder}"
	rm -Rf $create_folder
fi


if [[ -f "$dest/$frontend_file" ]]
then
	echo
	echo -e "The backup file already been created! ${frontend_file}"
	echo

	# Long listing of files in $dest to check file sizes.
	ls -lh $dest
else
	# Print start status message.
	echo
	echo "Backing up $create_folder_frontend to $dest/$frontend_file"
	date
	echo

	cd $backup_files_frontend_logs
	# Backup the files using tar.
	tar cvzf $dest/$frontend_file $older_date
	#
	# Print end status message.
	echo
	echo "Backup finished for frontend"
	date

	# Long listing of files in $dest to check file sizes.
	ls -lh $dest

	# removing the entire folders.
	echo
	echo "Removing the compiled folder for frontend. ${create_folder_frontend}"
	rm -Rf $create_folder_frontend
fi
