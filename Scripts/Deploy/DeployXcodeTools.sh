#!/bin/bash

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

osVersion=$(versionLogic "10.15")

/usr/bin/touch "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"

if [[ "$osVersion" == "INSTALL NEWER" ]] || [[ "$osVersion" == "INSTALL SAME" ]]
then
    cmd_line_tools=$(/usr/sbin/softwareupdate -l | /usr/bin/awk '/\*\ Label: Command Line Tools/ { $1=$1;print }' | /usr/bin/sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | /usr/bin/cut -c 9-)
elif [[ "$osVersion" == "INSTALL OLDER" ]]
then
    macos_vers=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F "." '{print $2}')
    cmd_line_tools=$(/usr/sbin/softwareupdate -l | /usr/bin/awk '/\*\ Command Line Tools/ { $1=$1;print }' | /usr/bin/grep "$macos_vers" | /usr/bin/sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | /usr/bin/cut -c 2-)
fi

cmd_line_tools=$(/usr/bin/printf "$cmd_line_tools" | /usr/bin/tail -n 1)

installOutput=$(/usr/sbin/softwareupdate -i "$cmd_line_tools" 2>&1)
installAttempt=$(echo "$installOutput" | /usr/bin/grep "Done with Command Line Tools")

if [[ -e "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress" ]]
then
    rm "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
fi

if [[ -z "$installAttempt" ]]
then
    echo "Xcode Tools Install Failed..."
    exit 1
else
    echo "Xcode Tools Install Succeeded..."
    exit 0
fi
