#! /bin/bash

loggedInUser=$(/usr/bin/stat -f%Su /dev/console)
loggedInUID=$(/usr/bin/id -u "$loggedInUser")

interface=$(/sbin/route -n get 0.0.0.0 2>/dev/null | /usr/bin/awk '/interface: / {print $2}')

ipAddress=$(ifconfig "$interface" | /usr/bin/grep "inet " | /usr/bin/awk '{print $2}' | /usr/bin/xargs)

if [[ -z "$ipAddress" ]] || [[ -z $(echo -n "$ipAddress" | /usr/bin/grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}") ]]
then
	echo "IP not found..."
	/bin/launchctl asuser "$loggedInUID" sudo -iu "$loggedInUser" osascript << EOD
display dialog "Unable to determine your IP address." buttons {"Dismiss"} default button 1 giving up after 120
EOD
fi	

/bin/launchctl asuser "$loggedInUID" sudo -iu "$loggedInUser" osascript << EOD
display dialog "Your IP address is: $ipAddress" buttons {"Dismiss"} default button 1 giving up after 120
EOD

exit 0
