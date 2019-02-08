#!/usr/bin/env python
#import openpyxl
from datetime import datetime
from openpyxl import load_workbook

# read in the sheet as read only with the results of Formulas computed
workbook = load_workbook("../daves_weight_v3.xlsx", read_only=True, data_only=True)
datasheet = workbook['dave']
print (datasheet.rows)

for row in datasheet.rows:
    #print(row)
    timestamp     = row[0].value
    height       = row[2].value
    weight       = row[4].value
    bodyfat      = row[5].value
    bodyfat_pct  = row[6].value
    bodyh2o_pct  = row[7].value
    bonemass_pct = row[8].value
    systolic     = row[9].value
    diastolic    = row[10].value
    pulse        = row[11].value
    if ( weight > 0):
        print timestamp, height, weight, bodyfat, bodyfat_pct, bonemass_pct, systolic, diastolic, pulse
    


