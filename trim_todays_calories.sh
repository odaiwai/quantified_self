#!/usr/bin/bash
# Small script to trim the stray calories sometimes recorded in the morning.
TODAY=$(date +%Y%m%d)

echo "These are the data from today"
QUERY="from apple_qs_health_data where timestamp like '$TODAY%';"
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
