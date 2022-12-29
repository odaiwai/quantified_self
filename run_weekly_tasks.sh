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
SQL="${sqlite} -csv -header health_data.sqlite"
DOWNLOAD=0
VERBOSE=0
PARSE=1
MONTH=1
OS=`uname -s` # Which system are we on? Mac or Linux?
echo "Running on $OS"

# Parse the Command line options
for arg in "$@"; do
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

if [[ $DOWNLOAD -gt 0 ]]; then
	# Download this years myfitnesspal report
	# ./getMyFitnessPalData.py
	# Download thie cronometer Data - Currently manually exported
	# ./get_cronometer_data.py
    print_elapsed_time

    # Get the updated Apple Health Export
	cd ../health_data/apple_health_export
    if [[ "$OS" = "Darwin" ]]; then
		cp -pv ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/Health_Data/Health\ Data.csv ./
		cp -pv ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/Health_Data/Sleep\ Analysis.csv ./
		cp -pv ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/Health_Data/moodpath_exported_data*.zip ./
	else
		onedrive --synchronize
		cp -pv ~/OneDrive/Health_Data/Health\ Data.csv ./
		cp -pv ~/OneDrive/Health_Data/Sleep\ Analysis.csv ./
		cp -pv ~/OneDrive/Health_Data/moodpath_exported_data*.zip ./
		# cp -pv ~/OneDrive/Spreadsheets/daves_weight_v4.xlsx ../
		# Cronometer Data 
	    cd ../cronometer_data
        for file in notes biometrics exercises servings dailySummary; do
            cp -pv ~/OneDrive/Health_Data/${file}.csv ./
        done
	fi
	# Add these files to the repository and commit
	git add Health\ Data.csv Sleep\ Analysis.csv
	git commit -m "updated QS exported data" Health\ Data.csv Sleep\ Analysis.csv

    for file in notes biometrics exercises servings dailySummary; do
        git add ${file}.csv
    done
    git commit -m "Updated the Cronometer data"


    # Go back to the main dir
	cd ../../analyse_health_data

    # get the Fitbit Data - not doing this anymore
    # ./get_fitbit_data.pl
fi


if [[ $PARSE -gt 0 ]]; then
	# Parse this years myfitnesspal report into a database
    # Don't need to do this any more!
	#./parse_myfitnesspaldata.pl
    # Parse the combined export files into daily tables
    declare -A table_specs
    table_specs[Measurement]="Fitbit_body_fatpct, CAST(sum(Fitbit_steps) AS NUMERIC) AS 'Fitbit_steps', CAST(sum(Fitbit_tracked_sleep_minutes) AS NUMERIC) AS 'Fitbit_tracked_sleep_minutes', Hips, Neck, Waist, Weight"
    table_specs[Exercise]="CAST(sum(Exercise_Calories) AS NUMERIC) AS 'Exercise_Calories', CAST(sum(Exercise_Minutes) AS NUMERIC) AS 'Exercise_Minutes', CAST(sum(Sets) AS NUMERIC) AS 'Sets', CAST(sum(Reps_Per_Set) AS NUMERIC) AS 'Reps_Per_Set', CAST(sum(Kilograms) AS NUMERIC) AS 'Kilograms', CAST(sum(Steps) AS NUMERIC) AS 'Steps'"
    table_specs[Nutrition]="CAST(sum(Calories) AS NUMERIC) AS 'Calories', CAST(sum(Fat_g) AS NUMERIC) AS 'Fat_g', CAST(sum(Saturated_Fat) AS NUMERIC) AS 'Saturated_Fat', CAST(sum(Polyunsaturated_Fat) AS NUMERIC) AS 'Polyunsaturated_Fat', CAST(sum(Monounsaturated_Fat) AS NUMERIC) AS 'Monounsaturated_Fat', CAST(sum(Trans_Fat) AS NUMERIC) AS 'Trans_Fat', CAST(sum(Cholesterol) AS NUMERIC) AS 'Cholesterol', CAST(sum(Sodium_mg) AS NUMERIC) AS 'Sodium_mg', CAST(sum(Potassium) AS NUMERIC) AS 'Potassium', CAST(sum(Carbohydrates_g) AS NUMERIC) AS 'Carbohydrates_g', CAST(sum(Fiber) AS NUMERIC) AS 'Fiber', CAST(sum(Sugar) AS NUMERIC) AS 'Sugar', CAST(sum(Protein_g) AS NUMERIC) AS 'Protein_g', CAST(sum(Vitamin_A) AS NUMERIC) AS 'Vitamin_A', CAST(sum(Vitamin_C) AS NUMERIC) AS 'Vitamin_C', CAST(sum(Calcium) AS NUMERIC) AS 'Calcium', CAST(sum(Iron) AS NUMERIC) AS 'Iron'"
    for table in Measurement Nutrition Exercise; do
        lc_table=`echo $table | tr [A-Z] [a-z]`
        dates="2014-08-18-to-2022-11-27"
        basedir="../health_data/myFitnessPal_data"
        echo "--DROP $table" > temp.sql
        echo "DROP TABLE IF EXISTS mfp_${lc_table}_input;" >> temp.sql
        echo "DROP TABLE IF EXISTS mfp_${lc_table}_daily;" >> temp.sql
        echo "-- IMPORT" >> temp.sql
        echo ".import --csv  ${basedir}/File-Export-${dates}/${table}-Summary-${dates}.csv mfp_${lc_table}_input" >> temp.sql
        echo "--Consolidate" >> temp.sql
        echo "CREATE TABLE mfp_${lc_table}_daily as SELECT Date, CAST(Timestamp as Integer) AS 'Timestamp', ${table_specs[$table]} from mfp_${lc_table}_input GROUP BY Timestamp;" >> temp.sql
        $sqlite health_data.sqlite < temp.sql
    done
    print_elapsed_time

	# Parse the cronometer Data once that's setup
	# ./parse_cronometer_data.py
    for file in dailySummary servings notes biometrics exercises; do
        DAY="Day"
        if [[ "${file}" = "dailySummary" ]]; then
            DAY="Date"
        fi
        echo "${file}"
        echo "DROP TABLE IF EXISTS cronometer_${file};" > temp.sql
        echo ".import --csv ../health_data/cronometer_data/${file}.csv temp" >> temp.sql
        echo ".schema temp" >> temp.sql
        echo "CREATE TABLE 'cronometer_${file}' as 
            select CAST(substr(${DAY}, 1, 4) || 
                        substr(${DAY}, 6, 2) || 
                        substr(${DAY}, 9,2) AS INTEGER) as 'Timestamp', * 
                   from temp;" >> temp.sql
        echo "DROP TABLE temp;" >> temp.sql
        cat temp.sql
        $sqlite health_data.sqlite < temp.sql
    done
    print_elapsed_time

# The other FitBit data is exported from the FitBit site on a monthly basis, but that can't be
	# done automatically at the moment. At least, not by me.
	#./parse_fitbit_export.pl
    # print_elapsed_time

	# Fitbit Data is automatically downloaded to the Dropbox folder
	# This is just the daily report in a single line, and only includes a certain subset of data
	# This needs to be run after the other one, as all the fitbit_* tables get deleted in that step
	# while this step only deletes it's own table
	#./parse_fitbit_data.pl
    # print_elapsed_time

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

# Make a unified timestamp table
SQL_COMMAND="DROP Table Timestamp;
    CREATE TABLE Timestamp (Date Text, Timestamp Integer Primary Key);
    INSERT INTO Timestamp (Date, Timestamp) SELECT
        substr(timestamp, 1, 4) || '-' || 
        substr(timestamp, 5, 2) || '-' || 
        substr(timestamp, 7, 2) ,  timestamp
    from mfp_daily_summary;
    INSERT or IGNORE INTO Timestamp (Date, Timestamp) SELECT
        substr(timestamp, 1,4) || '-' || 
        substr(timestamp, 5, 2) || '-' || 
        substr(timestamp, 7, 2), timestamp 
        from apple_qs_health_data;"
$sqlite health_data.sqlite -csv -header "$SQLCOMMAND"

# Dump out the standard Report
echo "Standard Report"
SQLCOMMAND="SELECT Timestamp.``Date, 
    IFNULL(MFPN.Calories, CDS.'Energy (kcal)'),
    IFNULL(MFPN.Carbohydrates_g, CDS.'Carbs (g)'),
    IFNULL(MFPN.Fat_g, CDS.'Fat (g)'),
    IFNULL(MFPN.Protein_g, CDS.'Protein (g)'),
    IFNULL(MFPN.Cholesterol, CDS.'Cholesterol (mg)'),
    IFNULL(MFPN.Sodium_mg, CDS.'Sodium (mg)'),
    IFNULL(MFPN.Sugar, CDS.'Sugars (g)'),
    IFNULL(MFPN.Fiber, CDS.'Fiber (g)'),
    IFNULL(MFPE.Exercise_Calories, 0), 
    0, 
    IFNULL(AQH.Active_Calories, 0),
    IFNULL(AQH.Resting_Calories, 0)
    FROM [Timestamp]
    FULL OUTER JOIN mfp_nutrition_daily as MFPN using (Timestamp)
    FULL OUTER JOIN mfp_exercise_daily as MFPE using (Timestamp)
    FULL OUTER JOIN apple_qs_health_data as AQH using (Timestamp)
    FULL OUTER JOIN cronometer_dailySummary as CDS using (Timestamp)
    Where Timestamp > $TIMESTAMP;"
echo "$SQLCOMMAND"

$sqlite health_data.sqlite -csv -header "$SQLCOMMAND"
$sqlite health_data.sqlite -csv -header "$SQLCOMMAND" > excel_import.csv

print_elapsed_time
## Older commands
#$sqlite health_data.sqlite -csv -header "select timestamp, activeCalories, CAST(sum(value) AS NUMERIC) AS value from apple_activity_summary JOIN apple_BasalEnergyBurned using (timestamp) where timestamp > $TIMESTAMP and sourceName not like 'Sync Solver' group by timestamp;"

#echo "Fitbit Calories_burned for this month:"
#$sqlite fitbit_data.sqlite -csv -header "select date, calories_burned from fitbit_data where date like ' $MONTH % $YEAR';"
#$sqlite health_data.sqlite -csv -header "select timestamp, date, calories_burned from fitbit_data where timestamp > $TIMESTAMP ;"

#echo "FitBit Data for this month:"
#$sqlite fitbit_data.sqlite -csv -header "select date, Calories_burned, Total_steps, Traveled, Floors_climbed, Sedentary, Lightly_active, Fairly_active, Very_active from [fitbit_data] where date like ' $MONTH % $YEAR';"
#$sqlite fitbit_data.sqlite -csv -header "select date, Calories_burned, Total_steps, Traveled, Floors_climbed, Sedentary, Lightly_active, Fairly_active, Very_active from [fitbit_data] where timestamp > $TIMESTAMP;"
# SQLCOMMAND="SELECT
 #    mfp_nutrition.date, CAST(sum(mfp_nutrition.Calories) AS NUMERIC) AS mfp_nutrition.Calories, CAST(sum(Carbohydrates) AS NUMERIC) AS Carbohydrates/1000, CAST(sum(Fat_g) AS NUMERIC) AS Fat_g,
#   CAST(sum(mfp_nutrition.Protein_g) AS NUMERIC) AS mfp_nutrition.Protein_g, CAST(sum(mfp_nutrition.Cholesterol) AS NUMERIC) AS mfp_nutrition.Cholesterol, CAST(sum(mfp_nutrition.Sodium_mg) AS NUMERIC) AS mfp_nutrition.Sodium_mg,
#  CAST(sum(mfp_nutrition.Sugar) AS NUMERIC) AS mfp_nutrition.Sugar, CAST(sum(mfp_nutrition.Fiber) AS NUMERIC) AS mfp_nutrition.Fiber, CAST(sum(mfp_exercise.Exercise_calories) AS NUMERIC) AS mfp_exercise.Exercise_calories,
# 0, apple_qs_health_data.Active_Calories, apple_qs_health_data.Resting_Calories
#     FROM [mfp_nutrition]
#     JOIN apple_qs_health_data using (timestamp) 
#     JOIN mfp_exercise using (timestamp)
# 	WHERE mfp_nutrition.timestamp > $TIMESTAMP group by timestamp;"

# SQLCOMMAND="SELECT
# 	mfp_daily_summary.date, mfp_daily_summary.Calories, Carbs, Fat, mfp_daily_summary.Protein,
# 	mfp_daily_summary.Cholesterol, mfp_daily_summary.Sodium, Sugars, mfp_daily_summary.Fiber,
# 	0, 0, apple_qs_health_data.Active_Calories, apple_qs_health_data.Resting_Calories
# 	FROM [mfp_daily_summary]
# 	JOIN apple_qs_health_data using (timestamp)
# 	WHERE mfp_daily_summary.timestamp > $TIMESTAMP group by timestamp;"

