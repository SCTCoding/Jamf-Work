#! /bin/bash

loggedInUser=$(stat -f%Su /dev/console)
loggedInUID=$(id -u "$loggedInUser")

pid=$(pgrep -U $loggedInUID NotificationCenter)

if [[ -n $pid ]]
then
	kill $pid
	
	until [[ -n $(pgrep -U $loggedInUID NotificationCenter) ]]
	do
		sleep 0.2
	done
	
	pidNow=$(pgrep -U $loggedInUID NotificationCenter)
	
	echo "PID was: $pid and is now: $pidNow"

elif [[ -z $pid ]]
then
	echo "Notification Center process not found..."
fi

exit 0
