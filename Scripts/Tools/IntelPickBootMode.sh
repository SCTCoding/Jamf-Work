#! /bin/bash

loggedInUser=$(/usr/bin/stat -f%Su /dev/console)
loggedInUID=$(/usr/bin/id -u "$loggedInUser")

bootArg=$(/bin/launchctl asuser "$loggedInUID" sudo -iu "$loggedInUser" /usr/bin/osascript << EOD
set nvramPicks to {"Safe Mode", "Verbose Boot", "Single User Mode", "Recovery Mode", "Clear Arguments"}
set nvramSelected to choose from list nvramPicks with prompt "Pick your startup mode:" default items {"Safe Mode"} OK button name {"Select"} cancel button name {"Cancel"}
nvramSelected
EOD
)

case "$bootArg" in
	
"Safe Mode")
	echo "Safe mode picked"
	/usr/sbin/nvram boot-args="-x"
	/bin/launchctl asuser "$loggedInUID" sudo -iu "$loggedInUser" /usr/bin/osascript << EOD
display dialog "You have selected to boot into Safe Mode. To prevent continually booting into Safe Mode: please be sure to reboot and reset the PRAM when you are finished." buttons {"Dismiss"} default button 1
EOD
	;;
	
"Verbose Boot")
	echo "Verbose boot picked"
	/usr/sbin/nvram boot-args="-v"
	/bin/launchctl asuser "$loggedInUID" sudo -iu "$loggedInUser" /usr/bin/osascript << EOD
display dialog "You have selected to boot into Verbose Boot. To prevent continually booting into Verbose Boot: please be sure to use the Clear Arguments choice when you are finished." buttons {"Dismiss"} default button 1
EOD
	;;
	
"Single User Mode")
	echo "Single user mode picked"
	/usr/sbin/nvram boot-args="-s"
	/bin/launchctl asuser "$loggedInUID" sudo -iu "$loggedInUser" /usr/bin/osascript << EOD
display dialog "You have selected to boot into Single User Mode. To prevent continually booting into Single User Mode: please be sure to reboot and reset the PRAM when you are finished." buttons {"Dismiss"} default button 1
EOD
	;;
	
"Recovery Mode")
	echo "Recovery mode picked"
	/usr/sbin/nvram "recovery-boot-mode=unused"
	/bin/launchctl asuser "$loggedInUID" sudo -iu "$loggedInUser" /usr/bin/osascript << EOD
display dialog "You have selected to boot into Recovery Mode. To prevent continually booting into Recovery Mode: please be sure to use the Clear Arguments choice when you are finished." buttons {"Dismiss"} default button 1
EOD
	;;
	
"Clear Arguments")
	echo "Clear arguments picked"
	if [[ ! -z $(/usr/sbin/nvram -p | /usr/bin/grep "boot-args" | /usr/bin/awk '{print $2}' | /usr/bin/xargs) ]]
	then
		/usr/sbin/nvram -d boot-args
	fi
	
	if [[ $(/usr/sbin/nvram -p | /usr/bin/grep "recovery-boot-mode" | /usr/bin/awk '{print $2}' | /usr/bin/xargs) == "unused" ]]
	then
		/usr/sbin/nvram -d recovery-boot-mode
	fi
	;;
	
"false")
	echo "User did not pick anything..."
	exit 0
	;;
	
esac

/bin/launchctl asuser "$loggedInUID" sudo -iu "$loggedInUser" /usr/bin/osascript << EOD
display dialog "REMEMBER: reset the PRAM when you are finished. NOTE: Windows and wireless keyboards may have issues resetting the PRAM." buttons {"Dismiss"} default button 1
EOD

exit 0
