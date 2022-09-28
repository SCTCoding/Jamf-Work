#! /bin/bash

loggedInUser=$(/usr/bin/stat -f%Su /dev/console)
loggedInUID=$(/usr/bin/id -u "$loggedInUser")

if [[ ! -z $(/usr/bin/pgrep -i "iTerm") ]] || [[ ! -z $(/bin/ps -Ac | /usr/bin/grep "Terminal") ]] || [[ ! -z $(/usr/bin/pgrep -i "xterm") ]]
then
    echo "Terminal application running..."
     /bin/launchctl asuser "$loggedInUID" sudo -iu "$loggedInUser" osascript << EOD
display dialog "You will need to relaunch any currently running terminal applications for changes to take effect." buttons {"Acknowledge"} default button 1 giving up after 90
EOD

fi

function versionLogic {
	compareVersion="$1"
	fullOSVersionString=$(/usr/bin/sw_vers -productVersion)
	
	if [[ $(/bin/echo -n "$fullOSVersionString" | /usr/bin/awk -F '.' '{print $1}') -gt $(/bin/echo -n "$compareVersion" | /usr/bin/awk -F '.' '{print $1}') ]]
	then
		versionResult="INSTALL NEWER"
	elif [[ $(/bin/echo -n "$fullOSVersionString" | /usr/bin/awk -F '.' '{print $1}') -lt $(/bin/echo -n "$compareVersion" | /usr/bin/awk -F '.' '{print $1}') ]]
	then
		versionResult="INSTALL OLDER"
	elif [[ $(/bin/echo -n "$fullOSVersionString" | /usr/bin/awk -F '.' '{print $1}') -eq $(/bin/echo -n "$compareVersion" | /usr/bin/awk -F '.' '{print $1}') ]]
	then
		if [[ $(/bin/echo -n "$fullOSVersionString" | /usr/bin/awk -F '.' '{print $2}') -gt $(/bin/echo -n "$compareVersion" | /usr/bin/awk -F '.' '{print $2}') ]]
		then
			versionResult="INSTALL NEWER"
		elif [[ $(/bin/echo -n "$fullOSVersionString" | /usr/bin/awk -F '.' '{print $2}') -lt $(/bin/echo -n "$compareVersion" | /usr/bin/awk -F '.' '{print $2}') ]]
		then
			versionResult="INSTALL OLDER"
		elif [[ $(/bin/echo -n "$fullOSVersionString" | /usr/bin/awk -F '.' '{print $2}') -eq $(/bin/echo -n "$compareVersion" | /usr/bin/awk -F '.' '{print $2}') ]]
		then
			if [[ ! -z $(/bin/echo -n "$compareVersion" | /usr/bin/awk -F '.' '{print $3}') ]]
			then
				if [[ $(/bin/echo -n "$fullOSVersionString" | /usr/bin/awk -F '.' '{print $3}') -gt $(/bin/echo -n "$compareVersion" | /usr/bin/awk -F '.' '{print $3}') ]]
				then
					versionResult="INSTALL NEWER"
				elif [[ $(/bin/echo -n "$fullOSVersionString" | /usr/bin/awk -F '.' '{print $3}') -lt $(/bin/echo -n "$compareVersion" | /usr/bin/awk -F '.' '{print $3}') ]]
				then
					versionResult="INSTALL OLDER"
				elif [[ $(/bin/echo -n "$fullOSVersionString" | /usr/bin/awk -F '.' '{print $3}') -eq $(/bin/echo -n "$compareVersion" | /usr/bin/awk -F '.' '{print $3}') ]]
				then
					versionResult="INSTALL SAME"
				fi
			elif [[ -z $(/bin/echo -n "$compareVersion" | /usr/bin/awk -F '.' '{print $3}') ]]
			then
				versionResult="INSTALL SAME"
			fi
		fi
	fi
	
	/bin/echo -n "$versionResult"

}

osCheck=$(versionLogic "10.15")

if [[ "$osCheck" == "INSTALL OLDER" ]]
then
    osPick="bash"
elif [[ "$osCheck" == "INSTALL SAME" ]] || [[ "$osCheck" == "INSTALL NEWER" ]]
then
    osPick="zsh"
fi

userPick=$(/bin/launchctl asuser "$loggedInUID" sudo -iu "$loggedInUser" osascript << EOD
tell me to activate
set shellChoices to {"sh", "bash", "csh", "ksh", "tcsh", "zsh"}
set theSelectedShell to choose from list shellChoices with prompt "Please select your desired Shell:" default items {"$osPick"}
theSelectedShell
EOD
)

case "$userPick" in
        sh)
            /usr/bin/chsh -s /bin/sh "$loggedInUser"
            shellChange=$?
            ;;
         
        bash)
            /usr/bin/chsh -s /bin/bash "$loggedInUser"
            shellChange=$?
            ;;
         
        csh)
            /usr/bin/chsh -s /bin/csh "$loggedInUser"
            shellChange=$?
            ;;
        ksh)
            /usr/bin/chsh -s /bin/ksh "$loggedInUser"
            shellChange=$?
            ;;
        tcsh)
            /usr/bin/chsh -s /bin/tcsh "$loggedInUser"
            shellChange=$?
            ;;
        zsh)
            /usr/bin/chsh -s /bin/zsh "$loggedInUser"
            shellChange=$?
            ;;
        false)
            echo "User cancelled the dialog..."
            ;;
 
esac


if [[ $shellChange -eq 0 ]] && [[ "$userPick" != "false" ]]
then
    echo "Shell changed to ${userPick}..."
    /bin/launchctl asuser "$loggedInUID" sudo -iu "$loggedInUser" osascript << EOD
display dialog "Your default Shell has been changed to ${userPick}." buttons {"Dismiss"} default button 1 giving up after 90
EOD

else
    echo "Shell was not changed or process was cancelled..."
fi

exit 0
