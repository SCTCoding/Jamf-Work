#! /bin/bash

currentRulesHash="$4"

if [[ "$currentRulesHash" != "$(/sbin/md5 -q /Library/CORP_FOLDER/.rules.txt | /usr/bin/xargs)" ]] && [[ -e "/Library/CORP_FOLDER/.rules.txt" ]]
then
	cat << EOD > /Library/CORP_FOLDER/.rules.txt
  
block return in proto tcp from any to any port 27017
pass in quick on lo0 all
pass out quick on lo0 all
EOD

	/usr/bin/chflags hidden /Library/CORP_FOLDER/.rules.txt
    
    if [[ -e "/Library/CORP_FOLDER/pf.conf.bak" ]]
    then
    	cat /Library/CORP_FOLDER/pf.conf.bak > /etc/pf.conf
        
        echo "" >> /etc/pf.conf
		echo "# CORP_FOLDER Rules" >> /etc/pf.conf
    fi
    
    cat /Library/CORP_FOLDER/.rules.txt >> /etc/pf.conf

	if [[ ! -z $(/sbin/pfctl -si 2>/dev/null | grep -E "^Status: Enabled") ]]
	then
		/sbin/pfctl -f /etc/pf.conf
		/sbin/pfctl -E
	fi

else
	echo "Nothing to do. Rules are fine..."
fi

exit 0
