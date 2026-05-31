#!/usr/bin/bash
# Small script to trim the stray calories sometimes recorded in the morning.
TODAY=$(date +%Y%m%d)
if [[ "$1" != "" ]]; then
	echo "Using given date: $1"
	TODAY=$(date +%Y%m%d -d "$1")
fi
for TABLE in apple_qs_health_data cronometer_dailysummary; do
	echo "These are the data from $TODAY for $TABLE"
	QUERY="from $TABLE where timestamp like '$TODAY%';"
	sqlite3 health_data.sqlite "select * $QUERY"
	read -p "Delete this line? (y/n)" -n1 -r REPLY
	echo -e -n "\n$REPLY: "
	case "$REPLY" in
	y | Y)
		echo "Deleting..."
		sqlite3 health_data.sqlite "delete $QUERY;"
		;;
	n | N)
		echo "Not Deleting."
		;;
	*)
		echo "Invalid response, taking no action."
		;;
	esac
done
