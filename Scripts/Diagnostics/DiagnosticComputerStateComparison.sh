#! /bin/bash

outputPick="$4"
outputPick=$(echo -n "$outputPick" | /usr/bin/xargs | /usr/bin/tr '[:lower:]' '[:upper:]')

if [[ ! -e "/usr/local/bin/osqueryi" ]]
then
	echo "OSQuery is missing. Please install the princess..."
	exit 1
fi

nameValue=$(echo -n "$(/usr/sbin/scutil --get ComputerName)-$(date +%s)" | /usr/bin/xargs)

if [[ ! -e "/Library/YOUR_ORG/State Information" ]]
then
	mkdir -p "/Library/YOUR_ORG/State Information"
else
	if [[ -z $(du -h -d 0 "/Library/YOUR_ORG/State Information" | /usr/bin/awk '{print $1}' | /usr/bin/grep -E '[BKM]$') ]]
    then
    	rm -r "/Library/YOUR_ORG/State Information"
        mkdir -p "/Library/YOUR_ORG/State Information"
    elif [[ $(du -h -d 0 "/Library/YOUR_ORG/State Information" | /usr/bin/awk '{print $1}' | /usr/bin/sed -e 's/[A-Z]$//g') -gt 20 ]]
    then
    	rm -r "/Library/YOUR_ORG/State Information"
        mkdir -p "/Library/YOUR_ORG/State Information"
    fi
fi

if [[ "$outputPick" != "JSON" ]]
then
	/usr/local/bin/osqueryi --line 'select * from system_info; select * from virtual_memory_info; select * from smc_keys; select * from startup_items; select * from usb_devices; select * from processes; select * from process_open_sockets; select * from package_install_history; select * from launchd; select * from launchd_overrides; select * from kernel_info; select * from kernel_extensions; select * from kernel_panics; select * from gatekeeper_approved_apps; select * from nvram; select * from apps; select * from authorizations; select * from authorization_mechanisms; select * from block_devices; select * from disk_encryption;' > "/Library/YOUR_ORG/State Information/${nameValue}.txt"
else
	/usr/local/bin/osqueryi --json 'select * from system_info; select * from virtual_memory_info; select * from smc_keys; select * from startup_items; select * from usb_devices; select * from processes; select * from process_open_sockets; select * from package_install_history; select * from launchd; select * from launchd_overrides; select * from kernel_info; select * from kernel_extensions; select * from kernel_panics; select * from gatekeeper_approved_apps; select * from nvram; select * from apps; select * from authorizations; select * from authorization_mechanisms; select * from block_devices; select * from disk_encryption;' > "/Library/YOUR_ORG/State Information/${nameValue}.json"
fi

exit 0
