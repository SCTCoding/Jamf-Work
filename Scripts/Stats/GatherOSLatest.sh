#! /bin/bash

versionDump=$(/usr/bin/curl "https://support.apple.com/en-us/HT201260" | /usr/bin/grep -E '[0-9]{2}\.[0-9]{1,2}' | /usr/bin/grep "<td>")
curlResult=$?
latestVersion=$(echo "$versionDump" | /usr/bin/head -n 1)
installedOS=$(/usr/bin/sw_vers -productVersion)

if [[ ! -z $(echo "$latestVersion" | /usr/bin/grep "$installedOS" | /usr/bin/awk -F '>|<' '{print $3}') ]] && [[ ! -z $(echo "$versionDump" | /usr/bin/grep "$installedOS") ]]
then
	RESULT="Latest"
elif [[ -z "$latestResult" ]] && [[ ! -z $(echo "$versionDump" | /usr/bin/grep "$installedOS") ]]
then
	RESULT="Not Latest"
elif [[ $curlResult -gt 0 ]]
then
	RESULT="Error"
else
	RESULT="Error"
fi

if [[ ! -e "/Library/CORP_FOLDER/.osReleaseCheck" ]]
then
	touch /Library/CORP_FOLDER/.osReleaseCheck
	chflags hidden /Library/CORP_FOLDER/.osReleaseCheck
	
	echo "$RESULT" > /Library/CORP_FOLDER/.osReleaseCheck

else
	if [[ "$(cat /Library/CORP_FOLDER/.osReleaseCheck)" == "$RESULT" ]]
	then
		echo "Nothing to change."
	elif [[ "$(cat /Library/CORP_FOLDER/.osReleaseCheck)" != "$RESULT" ]] && [[ "$RESULT" == "Error" ]]
	then
		echo "Nothing to change."
	else
		echo "$RESULT" > /Library/CORP_FOLDER/.osReleaseCheck
	fi
fi

exit 0
