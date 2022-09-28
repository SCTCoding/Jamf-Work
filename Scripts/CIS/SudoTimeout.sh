#! /bin/bash

if [[ -e "/etc/sudoers.d/defaults_timestamp_timeout" ]] && [[ -z $(cat "/etc/sudoers.d/defaults_timestamp_timeout" | /usr/bin/grep "Defaults timestamp_timeout = 0") ]]
then
	echo "Nothing to do."
	exit
else
	if [[ ! -e "/etc/sudoers.d/defaults_timestamp_timeout" ]]
	then
		/usr/bin/touch "/etc/sudoers.d/defaults_timestamp_timeout"
	fi

	echo "Defaults timestamp_timeout = 0" > "/etc/sudoers.d/defaults_timestamp_timeout"

	/bin/chmod 644 "/etc/sudoers.d/defaults_timestamp_timeout"
	/usr/sbin/chown root:wheel "/etc/sudoers.d/defaults_timestamp_timeout"
fi

exit 0
