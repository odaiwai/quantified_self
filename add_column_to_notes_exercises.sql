-- Add columns to Notes and Exercises
DROP TABLE TEMP;
CREATE TABLE TEMP AS SELECT
    Timestamp,
    Day,
    'none' as "Group",
    Note
FROM CRONOMETER_NOTES;
DROP TABLE cronometer_notes;
CREATE TABLE CRONOMETER_NOTES AS SELECT * FROM TEMP;
--
-- Exercises
--
DROP TABLE TEMP;
CREATE TABLE TEMP AS SELECT
    Day,
    'None' as "Group",
    Timestamp,
    Exercise,
    Minutes,
    "Calories Burned"
FROM cronometer_exercises;
DROP TABLE CRONOMETER_EXERCISES;
CREATE TABLE CRONOMETER_EXERCISES AS SELECT * FROM TEMP;
DROP TABLE TEMP;
