#! /bin/bash

userList=/Users/*

for user in $userList
do
	user=$(echo -n $user | /usr/bin/awk -F '/' '{print $3}')
	echo "Fixing Finder Settings for: $user"
    
	if [[ -e "/Users/$user/Library/Preferences/.GlobalPreferences.plist" ]]
	then
		idOfUser=$(/usr/bin/id -u "$user")
        
		if [[ $(/bin/launchctl asuser "$idOfUser" sudo -iu "$user" /usr/bin/defaults read NSGlobalDomain AppleShowAllExtensions) == "1" ]]
		then
			echo "Already properly set for $user"
		else
			/bin/launchctl asuser "$idOfUser" sudo -iu "$user" /usr/bin/defaults write NSGlobalDomain AppleShowAllExtensions -bool TRUE
		fi
	else
		echo "Unable to find the preference file for $user"
	fi
done

exit 0
