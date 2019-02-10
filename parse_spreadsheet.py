#!/usr/bin/env python
import openpyxl # uses openpyxl - https://openpyxl.readthedocs.io/en/stable/
import sqlite3  # uses sqlite   - https://docs.python.org/2/library/sqlite3.html
import types

def make_tables(dbc):
    """Define the Tables"""
    tabledef = {}  # type: Dict[str, str]
    tabledef["ss_physical"] = "timestamp TEXT Primary Key, height REAL, weight REAL, bodyfat REAL, bodyfat_pct REAL, bodyh2o_pct REAL, bonemass_pct REAL, systolic Integer, Diastolic Integer, Pulse Integer"
    tabledef["ss_resting_hr"] = "timestamp TEXT Primary Key, RHR Int, comment Text"

    for table in tabledef.keys():
        cmd = 'DROP TABLE IF EXISTS [%s]' % table
        print cmd
        dbc.execute(cmd)
        cmd = 'CREATE TABLE [%s] (%s)' % (table, tabledef[table])
        print cmd
        dbc.execute(cmd)


# main code
db = sqlite3.connect('health_data.sqlite')
dbc = db.cursor()
make_tables(dbc)

# read in the sheet as read_only with the results of Formulas computed (data_only) as of last save
workbook = openpyxl.load_workbook("../daves_weight_v3.xlsx", read_only=True, data_only=True)
datasheet = workbook['dave']

# Parse through the spreadsheet getting the height/weight data I want and put it in the database
fields = 'timestamp, height, weight, bodyfat, bodyfat_pct, bonemass_pct, systolic, diastolic, pulse'
rows = 0
for row in datasheet.rows:
    #print(row)
    timestamp    = row[0].value
    height       = row[2].value
    weight       = row[4].value
    bodyfat      = row[5].value
    bodyfat_pct  = row[6].value
    bodyh2o_pct  = row[7].value
    bonemass_pct = row[8].value
    systolic     = row[9].value
    diastolic    = row[10].value
    pulse        = row[11].value

    record_is_valid = 0
    if (height > 0 and weight > 0):
        record_is_valid += 1
    if (type(timestamp) is types.NoneType):
        record_is_valid = 0
    if (type(timestamp) is types.UnicodeType):
        record_is_valid = 0

    rows = rows + 1
    if record_is_valid:
        data = (timestamp, height, weight, bodyfat, bodyfat_pct, bodyh2o_pct, bonemass_pct, systolic, diastolic, pulse)
        print "Insert or UPDATE into [ss_physical] (", fields, ") VALUES (", timestamp, height, weight, bodyfat, bodyfat_pct, bonemass_pct, systolic, diastolic, pulse, ")"
        dbc.execute('INSERT or REPLACE into [ss_physical] (timestamp, height, weight, bodyfat, bodyfat_pct, bodyh2o_pct, bonemass_pct, systolic, diastolic, pulse) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', data)

db.commit()
print "Rows", rows


