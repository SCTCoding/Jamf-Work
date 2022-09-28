#! /bin/bash

if [[ ! -e "/Library/CORP_FOLDER/pf.conf.bak" ]]
then
	cp /etc/pf.conf /Library/CORP_FOLDER/pf.conf.bak
fi

policyReturn=1
counter=0

until [[ $policyReturn -eq 0 ]] || [[ $counter -ge 4 ]]
do

	/usr/local/bin/jamf policy -event firewallRules
	policyReturn=$?
    
    if [[ $policyReturn -eq 0 ]]
    then
    	break
	fi
    
    sleep $(( ( RANDOM % 5 )  + 1 ))

    counter=$(( $counter + 1 ))
done

if [[ -z $(/sbin/pfctl -si 2>/dev/null | grep -E "^Status: Enabled") ]] && [[ $policyReturn -eq 0 ]]
then
	/sbin/pfctl -f /etc/pf.conf
	/sbin/pfctl -E
fi

exit 0
