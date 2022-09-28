#! /bin/bash

loggedInUser=$(/usr/bin/stat -f%Su /dev/console)
loggedInUID=$(/usr/bin/id -u "$loggedInUser")

APNSCurrentToken=$(/System/Library/PrivateFrameworks/ApplePushService.framework/apsctl status | /usr/bin/grep -A 10 "com.apple.aps.mdmclient.daemon.push.production" | /usr/bin/grep "token" | /usr/bin/awk -F '<|>' '{print $2}')

/bin/launchctl asuser "$loggedInUID" sudo -iu "$loggedInUser" osascript << EOD &
display dialog "The APNS Token for this machine is: {"$APNSCurrentToken"} please send to engineering for futher assistnace." buttons {"Dismiss"} default button 1
EOD

exit 0
