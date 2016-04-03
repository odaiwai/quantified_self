#!/bin/bash

# script to run the weekly tasks
./getMyFitnessPalData.pl
./parse_myfitnesspaldata.pl
./parse_fitbit_data.pl
sqlite3 myfitnesspal.sqlite -csv -cmd 'select * from daily_summary join calories_burned using (date);'
sqlite fitbit_data.sqlite -csv -cmd 'select dtae, calories_burned from fitbit_data;'
