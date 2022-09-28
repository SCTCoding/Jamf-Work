#! /bin/bash

loggedInUser=$(/usr/bin/stat -f%Su /dev/console)
loggedInUID=$(/usr/bin/id -u "$loggedInUser")

if [[ -e "/tmp/showLogAround.command" ]]
then
    rm "/tmp/showLogAround.command"
fi

/bin/launchctl asuser "$loggedInUID" sudo -iu "$loggedInUser" osascript << EOD
display dialog "NOTE: If you pick a shutdown casue from the list a terminal window will open showing the last 30 lines prior to the shutdown log entry." buttons {"Dismiss"} default button 1 giving up after 90
EOD

shutdownEvents=$(/usr/bin/log show --style compact --predicate 'eventMessage contains "Previous shutdown cause"' --last 336h)

logEvents=$(echo -n "$shutdownEvents" |  /usr/bin/grep "Previous shutdown cause:" | /usr/bin/awk '{print "?" $1 "%" $2 "%Shutdown Cause:%" $9 "?" "+"}')

eventArray=()
for event in ${logEvents[@]}
do
    eventArray+=("$event" )
done

formattedList=$(echo -n "${eventArray[@]}" | /usr/bin/xargs | /usr/bin/sed -e 's/?/"/g' | /usr/bin/sed -e 's/%/ /g' | /usr/bin/sed -e 's/+/, /g' | /usr/bin/sed -e 's/..$//')

pickedValue=$(/bin/launchctl asuser "$loggedInUID" sudo -iu "$loggedInUser" osascript << EOD
set listOfCauses to {$formattedList}
set outCauses to choose from list listOfCauses with prompt "Shutdown Causes: last two weeks:"
outCauses
EOD
)

if [[ "$pickedValue" == "false" ]]
then
    echo "User dismissed window..."
    exit 0
fi

cat << EOD >> /tmp/showLogAround.command
#! /bin/bash
#/usr/bin/log show --end "$(echo -n "$pickedValue" | /usr/bin/awk -F '.' '{print $1}')" | /usr/bin/tail -n 30
/usr/bin/log show | grep -B 30 -A 30 "$(echo -n "$pickedValue" | /usr/bin/awk -F '.' '{print $1}')"
EOD

/bin/chmod +x /tmp/showLogAround.command

/bin/launchctl asuser "$loggedInUID" sudo -iu "$loggedInUser" /usr/bin/open -a Terminal /tmp/showLogAround.command

exit 0
