#!/bin/bash

# script to run the weekly tasks
./getMyFitnessPalData.pl
./parse_myfitnesspaldata.pl
./parse_fitbit_data.pl
sqlite3 myfitnesspal.sqlite -csv 'select * from daily_summary join calories_burned using (date) limit 21;'
sqlite3 fitbit_data.sqlite -csv 'select date, calories_burned from fitbit_data limit 21;'
