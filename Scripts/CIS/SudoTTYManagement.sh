#! /bin/bash

if [[ -e "/etc/sudoers.d/defaults_tty_tickets" ]] && [[ -z $(cat "/etc/sudoers.d/defaults_tty_tickets" | /usr/bin/grep 'Default !tty_tickets') ]]
then
	echo "Nothing to do."
	exit
else
	if [[ ! -e "/etc/sudoers.d/defaults_tty_tickets" ]]
	then
		/usr/bin/touch "/etc/sudoers.d/defaults_tty_tickets"
	fi

	echo "Defaults !tty_tickets" > "/etc/sudoers.d/defaults_tty_tickets"

	/bin/chmod 644 "/etc/sudoers.d/defaults_tty_tickets"
	/usr/sbin/chown root:wheel "/etc/sudoers.d/defaults_tty_tickets"
fi

exit 0
