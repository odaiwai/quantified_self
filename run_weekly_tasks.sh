#!/bin/bash

# Script to run the various weekly tasks
# Dave O'Brien

# Use this one, not the one that got installed with Anaconda
sqlite='/usr/bin/sqlite3'

# run the weekly tasks
# Download this years myfitnesspal report and parse it into a database
#./getMyFitnessPalData.pl
#./parse_myfitnesspaldata.pl

# Fitbit Data is automatically downloaded to the Dropbox folder
# This is just the daily report in a single line, and only includes a certain subset of data
#./parse_fitbit_data.pl

# The other FitBit data is exported from the FitBit site on a monthly basis, but that can't be 
# done automatically at the moment. At least, not by me.
#./parse_fitbit_export.pl

MONTH=`date +"%B"`
YEAR=`date +"%Y"`
# Print out the data collected
echo "MyFitnessPal Data for this month:"
$sqlite myfitnesspal.sqlite -csv "select * from daily_summary join calories_burned using (date) where date like '%$MONTH $YEAR';"

echo "Fitbit Calories_burned for this month:"
$sqlite fitbit_data.sqlite -csv "select date, calories_burned from fitbit_data where date like ' $MONTH % $YEAR';"
echo "FitBit Data for this month:"
$sqlite fitbit_data.sqlite -csv "select date, Calories_burned, Total_steps, Traveled, Floors_climbed, Sedentary, Lightly_active, Fairly_active, Very_active from [fitbit_data] where date like ' $MONTH % $YEAR';"
