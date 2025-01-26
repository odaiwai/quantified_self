#!/usr/bin/env python3
"""
Parses the data stored in the spreadsheet.

Makes tables for upload to Apple Health using an uploader.
"""
import datetime
import sqlite3  # https://docs.python.org/2/library/sqlite3.html

# import ipdb
import matplotlib.pyplot as plt
import openpyxl  # https://openpyxl.readthedocs.io/en/stable/
import pandas as pd

# Constants
VERBOSE = 0
SPREADSHEET = '/home/odaiwai/OneDrive/Spreadsheets/daves_weight_v4.xlsx'


class DataRow():
    """Dataclass for the main spreadsheet table."""

    def __init__(self, timestamp: datetime.datetime, person: str = '',
                 height: float = 0, age: float = 0, weight: float = 0,
                 bodyfat_kg: float = 0, bodyfat_pct: float = 0,
                 bodywater_pct: float = 0, bonemass_pct: float = 0,
                 systolic: int = 0, diastolic: int = 0, pulse: int = 0):
        self.timestamp: datetime.datetime = timestamp
        self.person: str = person
        self.height: float = height
        self.age: float = age

        # Floats
        self.weight = self.bodyfat_kg = self.bodyfat_pct = 0
        self.bodywater_pct = self.bonemass_pct = 0.0
        if weight is not None:
            self.weight: float = weight
        if bodyfat_kg is not None:
            self.bodyfat_kg: float = bodyfat_kg
        if bodyfat_pct is not None:
            self.bodyfat_pct: float = bodyfat_pct
        if bodywater_pct is not None:
            self.bodywater_pct: float = bodywater_pct
        if bonemass_pct is not None:
            self.bonemass_pct: float = bonemass_pct

        # Ints
        self.systolic = self.diastolic = self.pulse = 0
        if systolic is not None:
            self.systolic: int = systolic
        if diastolic is not None:
            self.diastolic: int = diastolic
        if pulse is not None:
            self.pulse: int = pulse

        # Calculate some additional fields
        # Mifflin StJohn BMR
        self.bmr_miffl: int = int((10 * self.weight) +
                                  (625 * self.height) -
                                  (5 * self.age) + 5)
        self.bmi: float = round(self.weight / (self.height ** 2), 2)
        self.ponderal: float = round(self.weight / (self.height ** 3), 2)

        # We need bodyfat to calculate this - not always available
        self.bmr_katch: int = 0
        if self.bodyfat_kg is not None:
            # Katch McArdle BMR formula
            self.bmr_katch = int(370 + 21.6 * (self.weight - self.bodyfat_kg))

    def __str__(self):
        return (f'{self.timestamp}'
                f' {self.person}'
                f' {self.height:5.2f}'
                f' {self.age:5.2f}'
                f' {self.weight:5.2f}'
                f' {self.bodyfat_kg:5.2f}'
                f' {self.bodyfat_pct:5.2f}'
                f' {self.bodywater_pct:5.2f}'
                f' {self.bonemass_pct:5.2f}'
                f' {self.systolic: 3d}'
                f' {self.diastolic: 3d}'
                f' {self.pulse: 3d}'
                f' {self.bmr_miffl: 5d}'
                f' {self.bmi:5.2f}'
                f' {self.ponderal:5.2f}'
                f' {self.bmr_katch: 5d}')

    def values_for_db(self) -> tuple:
        return (self.timestamp, self.age, self.height, self.weight,
                self.bodyfat_kg, self.bodyfat_pct, self.bodywater_pct,
                self.bonemass_pct, self.systolic, self.diastolic, self.pulse,
                self.bmr_katch, self.bmr_miffl, self.bmi, self.ponderal)

    def as_dict(self) -> dict:
        return {'timestamp': self.timestamp, 'age': self.age,
                'height': self.height, 'weight': self.weight,
                'bodyfat_kg': self.bodyfat_kg, 'bodyfat_pct': self.bodyfat_pct,
                'bodywater_pct': self.bodywater_pct,
                'bonemass_pct': self.bonemass_pct, 'systolic': self.systolic,
                'diastolic': self.diastolic, 'pulse': self.pulse,
                'bmr_katch': self.bmr_katch, 'bmr_miffl': self.bmr_miffl,
                'bmi': self.bmi, 'ponderal': self.ponderal}


def printif(*args) -> None:
    """VERBOSE Print for debugging."""
    if VERBOSE:
        print(' '.join([str(arg) for arg in args]))


def dbdo(dbc: sqlite3.Cursor, command: str):
    """Execute a DB command."""
    printif(command)
    status = dbc.execute(command)
    return status


def make_tables(dbc):
    """Define the database Tables, dropping and making them."""
    tabledef = {}  # type: Dict[str, str]
    tabledef['ss_physical'] = ('timestamp TEXT Primary Key, age REAL,'
                               ' height REAL, weight REAL, bodyfat REAL,'
                               ' bodyfat_pct REAL, bodyh2o_pct REAL,'
                               ' bonemass_pct REAL, systolic Integer,'
                               ' Diastolic Integer, Pulse Integer,'
                               ' bmr_katch Integer, bmr_miffl Integer,'
                               ' bmi REAL, ponderal REAL')
    tabledef['ss_resting_hr'] = ('timestamp TEXT Primary Key, resting_hr Int,'
                                 ' comment Text, notes TEXT, location TEXT')

    for table, definition in tabledef.items():
        # This is not the recommended way, but it's hard to loop this otherwise
        dbdo(dbc, f'DROP TABLE IF EXISTS [{table}]')
        dbdo(dbc, f'CREATE TABLE [{table}] ({definition})')


def read_body_info_sheet(dbc: sqlite3.Cursor,
                         workbook: openpyxl.Workbook) -> pd.DataFrame:
    """
    Read in the sheet and store in the database.

    Read in the sheet as read_only with the results of Formulas computed
    (data_only) as of last save.

    This was all mostly done before I knew about pandas, which is why it's so
    clunky.
    """
    datasheet = workbook['dave']

    # Parse through the spreadsheet getting the height/weight data I want and
    # put it in the database
    db_fields = ('timestamp, height, weight, bodyfat, bodyfat_pct,'
                 ' bonemass_pct, systolic, diastolic, pulse, bmr_katch,'
                 ' bmr_miffl bmi')
    # Row = namedtuple('Row', ('timestamp person, height age weight'
    #                         ' bodyfat_kg bodyfat_pct bodywater_pct'
    #                         ' bonemass_pct systolic diastolic pulse'))
    print('Parsing Physical Data')
    data_for_df = []
    row_count = 0
    for row_count, row in enumerate(datasheet.rows):
        printif(row_count, [n.value for n in row])
        # Determine if we have a valid record
        if row_count > 9:
            printif([row[c].value for c in range(0, 12)])
            data = (row[c].value for c in range(0, 12))
            data = DataRow(*data)
            data_for_df.append(data.as_dict())
            printif(data)

            values = data.values_for_db()
            cmd = f'Insert or UPDATE into [ss_physical] ({db_fields}) VALUES ({
                values})'
            printif(cmd)
            dbc.execute(('INSERT or REPLACE into [ss_physical]'
                         ' (timestamp, age, height, weight, bodyfat,'
                         ' bodyfat_pct, bodyh2o_pct, bonemass_pct, systolic,'
                         ' diastolic, pulse, bmr_katch, bmr_miffl, bmi,'
                         ' ponderal)'
                         ' VALUES'
                         ' (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'),
                        values)
    breakpoint()
    data_df = pd.DataFrame(data_for_df)
    print(f'{row_count} rows added to HR')
    return data_df


def read_resting_heart_rate_data(dbc: sqlite3.Cursor,
                                 workbook: openpyxl.Workbook) -> None:
    """Parse the Resting Heart Rate Data."""
    datasheet = workbook['Resting Heart Rate']
    fields = 'Timestamp, resting_hr, comments, notes, location'
    print('Parsing Resting Heart Rate Data')
    for row_count, row in enumerate(datasheet.rows):
        printif(row)

        timestamp = row[1].value
        resting_hr = row[2].value
        comment = row[4].value
        notes = row[5].value
        location = row[6].value

        # Determine if we have a valid record
        record_is_valid = 0
        if row_count > 2:
            record_is_valid = 1

        if resting_hr is not None:
            record_is_valid = 1
        if timestamp is None:
            record_is_valid = 0

        if record_is_valid:
            values = (timestamp, resting_hr, comment, notes,  location)
            cmd = ('Insert or UPDATE into [ss_resting_hr]'
                   f' ({fields}) VALUES ({values})')
            printif(cmd)
            dbc.execute('INSERT or REPLACE into [ss_resting_hr] '
                        '(timestamp, resting_hr, comment, notes, location) '
                        'VALUES (?, ?, ?, ?, ?)', values)

    print(f'{row_count} rows added to HR')


def main():
    """Connect to the database and make the tables."""
    print('Making the Tables...')
    with sqlite3.connect('health_data.sqlite') as db:
        dbc = db.cursor()
        make_tables(dbc)
        db.commit()

        print('Loading and parsing the spreadsheet')
        workbook = openpyxl.load_workbook(SPREADSHEET,
                                          read_only=True,
                                          data_only=True)
        data = read_body_info_sheet(db, workbook)
        read_resting_heart_rate_data(db, workbook)
        db.commit()

        print('Finishing Up')

    # Produce some plots
    # data.plot(x='timestamp', y=('weight', 'bodyfat_kg'), kind='scatter')
    plt.show()

    return None


if __name__ == '__main__':
    # Script to parse some data from the main health spreadsheet
    # 20190210
    main()
