#! /bin/bash

loggedInUser=$(/usr/bin/stat -f%Su /dev/console)
loggedInUID=$(/usr/bin/id -u "$loggedInUser")

if [[ -e "/usr/local/bin/osqueryi" ]]
then
	extensionsList=$(echo $(/bin/launchctl asuser "$loggedInUID" sudo -iu "$loggedInUser" /usr/local/bin/osqueryi --header=no --json 'select name from chrome_extensions;') | /usr/bin/sed -e 's/{//g' | /usr/bin/sed -e 's/}//g' | /usr/bin/sed -e 's/"name"://g' | /usr/bin/sed -e 's/\[//g' | /usr/bin/sed -e 's/\]//g' | /usr/bin/xargs | /usr/bin/sed -e 's/,/;/g')
else
    extensionsList="Error"
fi

if [[ -z "$extensionsList" ]]
then
	extensionsList="None"
fi

echo "<result>$extensionsList</result>"

exit 0
