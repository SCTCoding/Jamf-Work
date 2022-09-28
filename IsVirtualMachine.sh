#! /bin/bash

vmStat=$(/usr/sbin/ioreg -l | /usr/bin/grep -e Manufacturer | /usr/bin/grep -cE 'VirtualBox|Oracle|VMware|Parallels|Veertu')

if [[ $vmStat -lt 1 ]]
then
	## Handles if Apple Silicon and running in Apple's virtualization framework. If Intel, then the ioreg search will work.
	sysctlCheck=$(/usr/sbin/sysctl hw.targettype | /usr/bin/awk -F ': ' '{print $NF}' | /usr/bin/xargs)
	
	if [[ ! -z $(echo "$sysctlCheck" | /usr/bin/grep -i "VMA2MACOS") ]]
	then
		echo "<result>YES</result>"
	else
		echo "<result>NO</result>"
	fi
else
    echo "<result>YES</result>"
fi

exit 0
