#! /bin/bash

curlStatus=1
tryCount=0

until [[ $curlStatus -eq 0 ]] || [[ $tryCount -ge 3 ]]
do
	/usr/bin/curl -L "https://macadmins.software/tools/MailToOutlook.pkg" -o /private/tmp/MailToOutlook.pkg
	curlStatus=$?
    if [[ $curlStatus -eq 0 ]]
    then
    	break 
    fi
	
    tryCount=$(( tryCount + 1 ))
    /bin/sleep $(( ( RANDOM % 5 )  + 1 ))
done

if [[ $curlStatus -gt 0 ]]
then
    echo "Failed to download..."
    rm /private/tmp/MailToOutlook.pkg
    exit 1
fi

if [[ -e "/private/tmp/MailToOutlook.pkg" ]]
then
	/usr/sbin/installer -pkg /private/tmp/MailToOutlook.pkg -target /
    rm /private/tmp/MailToOutlook.pkg
else
	echo "Unable to get package. Failing..."
    exit 1
fi

exit 0
