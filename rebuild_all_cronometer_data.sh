#!/bin/bash
# Script to rebuild the cronometer data
# Dave O'Brien

# Error Handling
# set -e
handle_error() {
	echo "ERROR! Check last file run."
	exit 1
}

print_elapsed_time() {
	declare -i now
	now=$(date +%s)
	declare -i elapsed=$((now - starttime))
	echo "Operation took $elapsed seconds"
}

log_print() {
	if [[ $VERBOSE -eq 1 ]]; then
		echo "$*"
	fi
}

log_cat() {
	if [[ $VERBOSE -eq 1 ]]; then
		echo "$VERBOSE"
		cat "$*"
	fi
}

trap handle_error ERR
declare -i starttime
starttime=$(date +%s)

# Use this one, not the one that got installed with Anaconda
sqlite='/usr/bin/sqlite3'
VERBOSE=0
OS=$(uname -s) # Which system are we on? Mac or Linux?
today=$(date +%Y%m%d)
echo "Running on $OS"
# ./parse_cronometer_data.py
PREFIX="cronometer2"
echo "---- Processing All cronometer Data ----"
$sqlite health_data.sqlite <create_cronometer_tables.sql 2>/dev/null

for file in dailysummary servings notes biometrics exercises; do
	for today in 20230625 20240602 20250309; do
		echo "Importing ${today} ${file}"
		# TODO: handle fasting in the Cronometer app - premium feature
		DAY="Day"
		if [[ "${file}" = "dailysummary" ]]; then
			DAY="Date"
		fi
		echo "${file}"
		# TODO: need to handle a new table being added here...
		# TODO: need to add a UUID to servings.csv, as there are multiple
		# entries per date, and no way to distinguish or prevent multiple
		# copies of each day.
		{
			echo ".import --csv ../health_data/cronometer_data/${file}_${today}.csv temp"
			# echo ".schema temp"
			echo "CREATE TABLE 'temp2' as
                    select
                        CAST(substr(${DAY}, 1, 4) ||
                             substr(${DAY}, 6, 2) ||
                             substr(${DAY}, 9, 2) AS INTEGER) as 'Timestamp',
                        CAST('${today}' AS TEXT) as 'Reported',"
        
                        CASE
                            WHEN (SELECT 'Group' from pragma_table_info('temp2') WHERE name='Group') IS NULL THEN 
                            'Ungrouped'
                        END \"Group\",
                        *
                    from temp;"
			echo ".schema temp2"
			echo "INSERT OR IGNORE INTO ${PREFIX}_${file} SELECT * from temp2;"
			echo "DROP TABLE temp;"
			echo "DROP TABLE temp2;"
		} >temp.sql
		# log_cat temp.sql
		$sqlite health_data.sqlite <temp.sql # 2>/dev/null
	done
done
print_elapsed_time
