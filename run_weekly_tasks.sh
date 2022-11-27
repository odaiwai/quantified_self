#!/bin/bash

# Script to run the various weekly tasks
# Dave O'Brien

declare -i starttime=`date +%s`

function print_elapsed_time {
    declare -i now=`date +%s`
    declare -i elapsed=$(( now - starttime ))
    echo "Operation took $elapsed seconds"
}

# Use this one, not the one that got installed with Anaconda
sqlite='/usr/bin/sqlite3'
DOWNLOAD=0
VERBOSE=0
PARSE=1
MONTH=1
OS=`uname -s` # Which system are we on? Mac or Linux?
echo "Running on $OS"

# Parse the Command line options
for arg in "$@"
do
	echo "Argument: $arg"
	case $arg in
		-d|--download)
			DOWNLOAD=1
			echo "Downloading On."
			shift
			;;
		-p|--noparse)
			PARSE=0
			echo "Don't Parse the Data."
			shift
			;;
		-v|--verbose)
			VERBOSE=1
			echo "Verbose On"
			shift
			;;
		-m|--months)
			MONTH=$(( MONTH + 1 ))
			echo "Showing $MONTH months of data."
			shift
			;;
		-h|--help|*)
			echo "Usage:"
			echo "-d, --download: get MyFitnessPal data"
			echo "-p, --parse: Don't parse the data, just run the query"
			echo "-v, --verbose: be more verbose"
			echo "-m, --months : show one more months data. -m -m = show two more"
			echo "-h, --help: show this help"
			shift
			;;
	esac
done
if [[ $DOWNLOAD -gt 0 ]]
then
	# Download this years myfitnesspal report
	# ./getMyFitnessPalData.py
	# Download thie cronometer Data
	./get_cronometer_data.py
    print_elapsed_time

    # Get the updated Apple Health Export
	cd ../health_data/apple_health_export
    if [[ "$OS" = "Darwin" ]]
    then
		cp -pv ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/Health_Data/Health\ Data.csv ./
		cp -pv ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/Health_Data/Sleep\ Analysis.csv ./
		cp -pv ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/Health_Data/moodpath_exported_data*.zip ./
	else
		onedrive --synchronize
		cp -pv ~/OneDrive/Health_Data/Health\ Data.csv ./
		cp -pv ~/OneDrive/Health_Data/Sleep\ Analysis.csv ./
		cp -pv ~/OneDrive/Health_Data/moodpath_exported_data*.zip ./
		cp -pv ~/OneDrive/Spreadsheets/daves_weight_v4.xlsx ../
	fi
	# Add these files to the repository and commit
	git add Health\ Data.csv Sleep\ Analysis.csv
	git commit -m "updated QS exported data" Health\ Data.csv Sleep\ Analysis.csv

    # Go back to the main dir
	cd ../../analyse_health_data

    # get the Fitbit Data - not doing this anymore
    # ./get_fitbit_data.pl
fi


if [[ $PARSE -gt 0 ]]
then
	# Parse this years myfitnesspal report into a database
    # Don't need to do this any more!
	#./parse_myfitnesspaldata.pl
    print_elapsed_time

	# Parse thCronometer Data once that's setup
    # Don't need to do this any more!
	#./parse_cro ometer_data.py
    print_elapsed_time

# The other FitBit data is exported from the FitBit site on a monthly basis, but that can't be
	# done automatically at the moment. At least, not by me.
	#./parse_fitbit_export.pl
    print_elapsed_time

	# Fitbit Data is automatically downloaded to the Dropbox folder
	# This is just the daily report in a single line, and only includes a certain subset of data
	# This needs to be run after the other one, as all the fitbit_* tables get deleted in that step
	# while this step only deletes it's own table
	#./parse_fitbit_data.pl
    print_elapsed_time

    # Parse the Apple Health Data from QS
    ./parse_apple_health_data.pl
    print_elapsed_time

	# Parse the Spreadsheet data
	./parse_spreadsheet.py
    print_elapsed_time

    # Parse the Apple Health Data from XML
    # This isn't exporting properly so use the QS data above
	# Also, this takes a lot of time (like 5+ hours!)
	#unzip -o ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/Health_Data/export.zip -d ../health_data
    #./xml_rules_apple_health.pl
    print_elapsed_time
fi

# Print out the data collected
YEAR=`date +"%Y"`
echo "$MONTH"
#Get a timestamp for $MONTH months ago
if [[ $OS = "Linux" ]]
then
	TIMESTAMP=`date -d "-${MONTH} month" +%Y%m%d ` # for Linux
else
	TIMESTAMP=`date -j -v-${MONTH}m +%Y%m%d` # MacOS
fi

# Show the last dates for each of the databases just to make sure the retrieval process worked.
echo "Last Dates:"
echo "mfp_daily_summary         : `$sqlite health_data.sqlite "select timestamp from mfp_daily_summary order by timestamp DESC limit 1;"`"
echo "apple_qs_health_data      : `$sqlite health_data.sqlite "select timestamp from apple_qs_health_data order by timestamp DESC limit 1;"`"
echo "apple_qs_sleep_analysis   : `$sqlite health_data.sqlite "select timestamp from apple_qs_sleep_analysis order by timestamp DESC limit 1;"`"
echo ""
print_elapsed_time
# Currently, there is a problem with the Apple QS Health Data (Write an App?)

echo "MyFitnessPal Data for this month: ($OS, $TIMESTAMP)"
#$sqlite health_data.sqlite -csv -header "select mfp_daily_summary.date, mfp_daily_summary.Calories, Carbs, Fat, Protein, Cholesterol, Sodium, Sugars, Fiber, mfp_calories_burned.calories, fitbit_data.calories_burned from [mfp_daily_summary] JOIN mfp_calories_burned using (timestamp, date) JOIN fitbit_data using (timestamp) where mfp_daily_summary.timestamp > $TIMESTAMP;"
#$sqlite health_data.sqlite -csv -header "select mfp_daily_summary.date, mfp_daily_summary.Calories, Carbs, Fat, Protein, Cholesterol, Sodium, Sugars, Fiber, mfp_calories_burned.calories from [mfp_daily_summary] JOIN mfp_calories_burned using (timestamp, date) where mfp_daily_summary.timestamp > $TIMESTAMP;"
#$sqlite health_data.sqlite -csv -header "select mfp_daily_summary.date, mfp_daily_summary.Calories, Carbs, Fat, Protein, Cholesterol, Sodium, Sugars, Fiber, mfp_calories_burned.calories, 0, apple_xml_activity_summary.activeCalories, basalEnergyBurnedAdj from [mfp_daily_summary] JOIN mfp_calories_burned using (timestamp, date) JOIN apple_xml_activity_summary using (timestamp) JOIN apple_xml_BasalEnergyBurnedAdj using (timestamp) where mfp_daily_summary.timestamp > $TIMESTAMP group by timestamp;"

# Vacuum the database (Saves and compacts space)
echo "Vacuum the Database"
$sqlite health_data.sqlite "vacuum"
print_elapsed_time

# Dump out the standard Report
SQLCOMMAND="SELECT
	mfp_daily_summary.date, mfp_daily_summary.Calories, Carbs, Fat, mfp_daily_summary.Protein, 
	mfp_daily_summary.Cholesterol, mfp_daily_summary.Sodium, Sugars, mfp_daily_summary.Fiber, 
	0, 0, apple_qs_health_data.Active_Calories, apple_qs_health_data.Resting_Calories 
	FROM [mfp_daily_summary] 
	JOIN apple_qs_health_data using (timestamp) 
	WHERE mfp_daily_summary.timestamp > $TIMESTAMP group by timestamp;"
echo "Standard Report"
SQLCOMMAND="SELECT
    mfp_nutrition.date, sum(mfp_nutrition.Calories), sum(Carbohydrates)/1000, sum(Fat_g), 
    sum(mfp_nutrition.Protein_g), sum(mfp_nutrition.Cholesterol), sum(mfp_nutrition.Sodium_mg), 
    sum(mfp_nutrition.Sugar), sum(mfp_nutrition.Fiber), sum(mfp_exercise.Exercise_calories), 
    0, apple_qs_health_data.Active_Calories, apple_qs_health_data.Resting_Calories 
    FROM [mfp_nutrition] 
	JOIN apple_qs_health_data using (timestamp) 
    JOIN mfp_exercise using (timestamp) 
	WHERE mfp_nutrition.timestamp > $TIMESTAMP group by timestamp;"
echo "    $SQLCOMMAND"
$sqlite health_data.sqlite -csv -header "$SQLCOMMAND"
$sqlite health_data.sqlite -csv -header "$SQLCOMMAND" > excel_import.csv

print_elapsed_time
## Older ccommands
#$sqlite health_data.sqlite -csv -header "select timestamp, activeCalories, sum(value) from apple_activity_summary JOIN apple_BasalEnergyBurned using (timestamp) where timestamp > $TIMESTAMP and sourceName not like 'Sync Solver' group by timestamp;"

#echo "Fitbit Calories_burned for this month:"
#$sqlite fitbit_data.sqlite -csv -header "select date, calories_burned from fitbit_data where date like ' $MONTH % $YEAR';"
#$sqlite health_data.sqlite -csv -header "select timestamp, date, calories_burned from fitbit_data where timestamp > $TIMESTAMP ;"

#echo "FitBit Data for this month:"
#$sqlite fitbit_data.sqlite -csv -header "select date, Calories_burned, Total_steps, Traveled, Floors_climbed, Sedentary, Lightly_active, Fairly_active, Very_active from [fitbit_data] where date like ' $MONTH % $YEAR';"
#$sqlite fitbit_data.sqlite -csv -header "select date, Calories_burned, Total_steps, Traveled, Floors_climbed, Sedentary, Lightly_active, Fairly_active, Very_active from [fitbit_data] where timestamp > $TIMESTAMP;"
