#!/bin/bash

sqlite='/usr/bin/sqlite3'
# script to run the weekly tasks
./getMyFitnessPalData.pl
./parse_myfitnesspaldata.pl
./parse_fitbit_data.pl
$sqlite myfitnesspal.sqlite -csv 'select * from daily_summary join calories_burned using (date);'
#$sqlite fitbit_data.sqlite -csv 'select date, calories_burned from fitbit_data;'
$sqlite fitbit_data.sqlite -csv 'select date, Calories_burned, Total_steps, Traveled, Floors_climbed, Sedentary, Lightly_active, Fairly_active, Very_active from [fitbit_data];'
