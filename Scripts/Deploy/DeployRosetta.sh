#! /bin/bash

if [[ -z $(/usr/sbin/sysctl -n machdep.cpu.brand_string | /usr/bin/grep -o "Intel") ]] && [[ ! -f "/Library/Apple/System/Library/LaunchDaemons/com.apple.oahd.plist" ]]
then
	/usr/sbin/softwareupdate --install-rosetta --agree-to-license
    if [[ $? -gt 0 ]]
    then
    	echo "Rosetta did not install successfully..."
        exit 1
    fi
else
    echo "Rosetta is not needed on this machine..."
fi

exit 0
