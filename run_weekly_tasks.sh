#!/bin/bash

# Script to run the various weekly tasks
# Dave O'Brien

# Use this one, not the one that got installed with Anaconda
sqlite='/usr/bin/sqlite3'
DOWNLOAD=0
VERBOSE=0
PARSE=1
# PArse the Command line options
for arg in "$@"
do
	echo "Argument: $arg"
	case $arg in
		-d|--download)
			DOWNLOAD=1
			echo "Downloading On"
			shift
			;;
		-p|--noparse)
			PARSE=0
			echo "Don't Parse the Data"
			;;
		-v|--verbose)
			VERBOSE=1
			echo "Verbose On"
			;;
		-h|--help|*)
			echo "Usage:"
			echo "-d, --download: get MyFitnessPal data"
			echo "-h, --help: show this help"
			shift
			;;
	esac
done

if [[ $DOWNLOAD -gt 0 ]]
then
	# Download this years myfitnesspal report
	./getMyFitnessPalData.pl
fi

if [[ $PARSE -gt 0 ]]
then
	# Parse this years myfitnesspal report into a database
	./parse_myfitnesspaldata.pl

	# The other FitBit data is exported from the FitBit site on a monthly basis, but that can't be
	# done automatically at the moment. At least, not by me.
	./parse_fitbit_export.pl

	# Fitbit Data is automatically downloaded to the Dropbox folder
	# This is just the daily report in a single line, and only includes a certain subset of data
	# This needs to be run after the other one, as all the fitbit_* tables get deleted in that step
	# while this step only deletes it's own table
	./parse_fitbit_data.pl

    # Parse the Apple Health Data
	./parse_apple_health_data.pl
fi

# Print out the data collected
## FIXME: Need to make this show the last 30 days, not the current month
MONTH=`date +"%B"`
YEAR=`date +"%Y"`
#Get a timestamp for 1 month ago
OS=`uname -s`
if [[ $OS = "Linux" ]]
then
	TIMESTAMP=`date -d '-1 month' +%Y%m%d ` # for Linux
else
	TIMESTAMP=`date -j -v-1m +%Y%m%d` # MacOS
fi

echo "MyFitnessPal Data for this month: ($OS, $TIMESTAMP)"
$sqlite health_data.sqlite -csv -header "select mfp_daily_summary.date, mfp_daily_summary.Calories, Carbs, Fat, Protein, Cholesterol, Sodium, Sugars, Fiber, mfp_calories_burned.calories, fitbit_data.calories_burned from [mfp_daily_summary] JOIN mfp_calories_burned using (timestamp, date) JOIN fitbit_data using (timestamp) where mfp_daily_summary.timestamp > $TIMESTAMP;"

#echo "Fitbit Calories_burned for this month:"
#$sqlite fitbit_data.sqlite -csv -header "select date, calories_burned from fitbit_data where date like ' $MONTH % $YEAR';"
#$sqlite health_data.sqlite -csv -header "select timestamp, date, calories_burned from fitbit_data where timestamp > $TIMESTAMP ;"

#echo "FitBit Data for this month:"
#$sqlite fitbit_data.sqlite -csv -header "select date, Calories_burned, Total_steps, Traveled, Floors_climbed, Sedentary, Lightly_active, Fairly_active, Very_active from [fitbit_data] where date like ' $MONTH % $YEAR';"
#$sqlite fitbit_data.sqlite -csv -header "select date, Calories_burned, Total_steps, Traveled, Floors_climbed, Sedentary, Lightly_active, Fairly_active, Very_active from [fitbit_data] where timestamp > $TIMESTAMP;"
