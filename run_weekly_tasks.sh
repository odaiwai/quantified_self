#!/bin/bash

# Script to run the various weekly tasks
# Dave O'Brien

# Use this one, not the one that got installed with Anaconda
sqlite='/usr/bin/sqlite3'
DOWNLOAD=0
 VERBOSE=0
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

# Parse this years myfitnesspal report into a database
./parse_myfitnesspaldata.pl

# Fitbit Data is automatically downloaded to the Dropbox folder
# This is just the daily report in a single line, and only includes a certain subset of data
./parse_fitbit_data.pl

# The other FitBit data is exported from the FitBit site on a monthly basis, but that can't be
# done automatically at the moment. At least, not by me.
./parse_fitbit_export.pl

# Print out the data collected
MONTH=`date +"%B"`
YEAR=`date +"%Y"`
echo "MyFitnessPal Data for this month:"
$sqlite myfitnesspal.sqlite -csv -header "select * from daily_summary join calories_burned using (date) where date like '%$MONTH $YEAR';"

echo "Fitbit Calories_burned for this month:"
$sqlite fitbit_data.sqlite -csv -header "select date, calories_burned from fitbit_data where date like ' $MONTH % $YEAR';"
echo "FitBit Data for this month:"
$sqlite fitbit_data.sqlite -csv -header "select date, Calories_burned, Total_steps, Traveled, Floors_climbed, Sedentary, Lightly_active, Fairly_active, Very_active from [fitbit_data] where date like ' $MONTH % $YEAR';"
