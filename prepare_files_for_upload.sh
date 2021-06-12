#!/bin/bash

# Script to prepare the ss_whatever files
sqlite3 -header -csv health_data.sqlite "select timestamp, systolic, Diastolic, Pulse from [ss_physical] order by timestamp" > ss_blood_pressure.csv

sqlite3 -header -csv health_data.sqlite "select timestamp, bmi from [ss_physical] order by timestamp" > ss_height_bmi.csv

sqlite3 -header -csv health_data.sqlite "select timestamp, height, weight from [ss_physical] order by timestamp" > ss_height_weight.csv

sqlite3 -header -csv health_data.sqlite "select timestamp, height, weight, bodyfat, bodyfat_pct, bodyh2o_pct, bonemass_pct from [ss_physical] order by timestamp" > ss_height_weight_other.csv

# Definitions of files
#==> ss_blood_pressure.csv <==
#timestamp,systolic,Diastolic,Pulse
#
#==> ss_height_bmi.csv <==
#timestamp,bmi
#
#==> ss_height_weight.csv <==
#timestamp,height,weight
#
#==> ss_height_weight_other.csv <==
#timestamp,height,weight,bodyfat,bodyfat_pct,bodyh2o_pct,bonemass_pct
#
#CREATE TABLE [ss_physical] (timestamp TEXT Primary Key, age REAL, height REAL, weight REAL, bodyfat REAL, bodyfat_pct REAL, bodyh2o_pct REAL, bonemass_pct REAL, systolic Integer, Diastolic Integer, Pulse Integer, bmr_katch Integer, bmr_miffl Integer, bmi REAL, ponderal REAL);
#CREATE TABLE [ss_resting_hr] (timestamp TEXT Primary Key, RHR Int, comment Text, notes TEXT, location TEXT);
