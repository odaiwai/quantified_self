#!/usr/bin/env python
""" Parses the data stored in the spreadsheet and makes tables for upload to 
    Apple Health using an uploader
"""

import openpyxl # uses openpyxl - https://openpyxl.readthedocs.io/en/stable/
import sqlite3  # uses sqlite   - https://docs.python.org/2/library/sqlite3.html
import types

def make_tables(dbc, verbose):
    """Define the database Tables, dropping and making them"""
    tabledef = {}  # type: Dict[str, str]
    tabledef["ss_physical"] = "timestamp TEXT Primary Key, age REAL, height REAL, " \
                              "weight REAL, bodyfat REAL, bodyfat_pct REAL, " \
                              "bodyh2o_pct REAL, bonemass_pct REAL, systolic Integer," \
                              " Diastolic Integer, Pulse Integer, bmr_katch Integer, " \
                              "bmr_miffl Integer, bmi REAL, ponderal REAL"
    tabledef["ss_resting_hr"] = "timestamp TEXT Primary Key, RHR Int, comment Text, " \
                                "notes TEXT, location TEXT"

    for table in tabledef.keys():
        # This is not the recommended way, but it's hard to loop this otherwise
        cmd = 'DROP TABLE IF EXISTS [%s]' % table
        if verbose: print cmd
        dbc.execute(cmd)
        cmd = 'CREATE TABLE [%s] (%s)' % (table, tabledef[table])
        if verbose: print cmd
        dbc.execute(cmd)

# Script to parse some data from the main health spreadsheet
# 20190210

# Constants
verbose = 0
spreadsheet = "../daves_weight_v3.xlsx"

# main code - Connect to the database and make the tables
print "Making the Tables..."
db = sqlite3.connect('health_data.sqlite')
dbc = db.cursor()
make_tables(dbc, verbose)
db.commit()

# read in the sheet as read_only with the results of Formulas computed
# (data_only) as of last save
print "Loading and parsing the Spreadsheet"
workbook = openpyxl.load_workbook(spreadsheet, read_only=True, data_only=True)
datasheet = workbook['dave']

# Parse through the spreadsheet getting the height/weight data I want and
# put it in the database
fields = 'timestamp, height, weight, bodyfat, bodyfat_pct, bonemass_pct, systolic, ' \
         'diastolic, pulse, bmr_katch, bmr_miffl, bmi'
rows = 0
print "Parsing Physical Data"
for row in datasheet.rows:
    #print(row)
    timestamp    = row[0].value
    height       = row[2].value
    age          = row[3].value
    weight       = row[4].value
    bodyfat      = row[5].value
    bodyfat_pct  = row[6].value
    bodyh2o_pct  = row[7].value
    bonemass_pct = row[8].value
    systolic     = row[9].value
    diastolic    = row[10].value
    pulse        = row[11].value

    # Determine if we have a valid record
    record_is_valid = 0
    if (height > 0 and weight > 0):
        record_is_valid += 1
    if (type(timestamp) is types.NoneType):
        record_is_valid = 0
    if (type(timestamp) is types.UnicodeType):
        record_is_valid = 0

    rows += 1
    if record_is_valid:
        # Calculate some additional fields
        # Mifflin StJohn BMR
        bmr_miffl = int((10 * weight) + (625 * height) - (5 * age) + 5)
        bmi       = round(weight / (height ** 2), 1)
        ponderal  = round(weight / (height ** 3), 1)

        # We need bodyfat to calculate this - not always available
        bmr_katch = 0
        if ( type(bodyfat) is not types.NoneType):
            bmr_katch = int(370 + 21.6 * (weight - bodyfat)) # Katch McArcle BMR formula

        data = (timestamp, age, height, weight, bodyfat, bodyfat_pct, bodyh2o_pct,
                bonemass_pct, systolic, diastolic, pulse, bmr_katch, bmr_miffl,
                bmi, ponderal)
        cmd = "Insert or UPDATE into [ss_physical] (", fields, ") VALUES (", data, ")"
        if verbose: print cmd
        dbc.execute('INSERT or REPLACE into [ss_physical] '
                    '(timestamp, age, height, weight, bodyfat, bodyfat_pct, '
                    'bodyh2o_pct, bonemass_pct, systolic, diastolic, '
                    'pulse, bmr_katch, bmr_miffl, bmi, ponderal) '
                    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', data)

db.commit()
print "Rows", rows, "added to Physical"

# Parse the Resting Heart Rate Data
datasheet = workbook['Resting Heart Rate']
fields = 'Timestamp, RHR, comments, notes, location'
print "Parsing Resting Heart Rate Data"
rows = 0
for row in datasheet.rows:
    if verbose: print(row)
    timestamp = row[1].value
    RHR       = row[2].value
    comment   = row[4].value
    notes     = row[5].value
    location  = row[6].value

    # Determine if we have a valid record
    record_is_valid = 0
    if (RHR > 0):
        record_is_valid = 1
    if (type(timestamp) is types.NoneType):
        record_is_valid = 0
    if (type(timestamp) is types.UnicodeType):
        record_is_valid = 0

    if record_is_valid:
        rows += 1
        data = (timestamp, RHR, comment, notes,  location)
        cmd = "Insert or UPDATE into [ss_resting_hr] (", fields, ") VALUES (", data, ")"
        if verbose: print cmd
        dbc.execute('INSERT or REPLACE into [ss_resting_hr] '
                    '(timestamp, RHR, comment, notes, location) '
                    'VALUES (?, ?, ?, ?, ?)', data)

db.commit()
print "Rows", rows, "added to HR"

print "Finishing Up"
db.close()
