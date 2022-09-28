#! /bin/bash

imagePath="$4"

if [[ -e "$imagePath" ]] && [[ -e "/var/tmp/deplog.log" ]]
then
	echo "Command: MainTextImage: $imagePath" >> /var/tmp/deplog.log
fi

exit 0
