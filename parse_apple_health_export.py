#!/usr/bin/env python3
""" Parse the apple health Export data
"""

from dataclasses import dataclass
from pathlib import Path

import pandas as pd

DATADIR = Path('..', 'health_data', 'apple_health_export')


@dataclass
class SourceFile:
    prefix: str
    table: str
    multiple: bool = False


SOURCES = {
    'Health Data.csv': SourceFile('Health Data.csv', 'old_health'),
    'Sleep Analysis.csv': SourceFile('Sleep Analysis.csv', 'old_sleep'),
    'HealthExport': SourceFile('HealthExport', 'new_health', True),
}
old_headers = {
    0: 'Start',
    1: 'Finish',
    2: 'Active Calories (kcal)',
    3: 'Blood Pressure (Diastolic) (mmHg)',
    4: 'Blood Pressure (Systolic) (mmHg)',
    5: 'Body Mass Index (count)',
    6: 'Body Temperature (degC)',
    7: 'Basal Body Temperature (degC)',
    8: 'Caffeine (mg)',
    9: 'Calcium (mg)',
    10: 'Carbohydrates (mg)',
    11: 'Cholesterol (mg)',
    12: 'Dietary Calories (cal)',
    13: 'Distance (km)',
    14: 'Flights Climbed (count)',
    15: 'Number of Times Fallen (count)',
    16: 'Oxygen Saturation (%)',
    17: 'Peak Expiratory Flow Rate (L/min)',
    18: 'Peripheral Perfusion Index (%)',
    19: 'Polyunsaturated Fat (g)',
    20: 'Potassium (mg)',
    21: 'Protein (g)',
    22: 'Resting Calories (kcal)',
    23: 'Riboflavin (mg)',
    24: 'Saturated Fat (g)',
    25: 'Steps (count)',
    26: 'Sugar (g)',
    27: 'Thiamin (mg)',
    28: 'Total Fat (g)',
    29: 'Vitamin A (mcg)',
    30: 'Vitamin B12 (mcg)',
    31: 'Vitamin B6 (mg)',
    32: 'Vitamin C (mg)',
    33: 'Vitamin D (mcg)',
    34: 'Vitamin E (mg)',
    35: 'Vitamin K (mcg)',
    36: 'Weight (lb)',
    37: 'datetime'
}

new_headers = {
    0: 'Date',
    1: 'Active Calories (kcal)',
    2: 'Blood Glucose (mmol/L)',
    3: 'Blood Oxygen (%)',
    4: 'Blood Pressure (mmHg)',
    5: 'Body Fat (%)',
    6: 'Body Mass Index',
    7: 'Body Temperature (degC)',
    8: 'Caffeine (mg)',
    9: 'Calcium (mg)',
    10: 'Calories (kcal)',
    11: 'Carbohydrates (g)',
    12: 'Cardio Fitness (mL/min·kg)',
    13: 'Chloride (mg)',
    14: 'Cholesterol (mg)',
    15: 'Chromium (mcg)',
    16: 'Copper (mg)',
    17: 'Dietary Sugar (g)',
    18: 'Fiber (g)',
    19: 'Folate (mcg)',
    20: 'Forced Expiratory Volume, 1 Sec (L)',
    21: 'Heart Rate (bpm)',
    22: 'Heart Rate Variability (ms)',
    23: 'Height (cm)',
    24: 'Iodine (mcg)',
    25: 'Iron (mg)',
    26: 'Lean Body Mass (kg)',
    27: 'Magnesium (mcg)',
    28: 'Manganese (mg)',
    29: 'Mindful Minutes',
    30: 'Molybdenum (mcg)',
    31: 'Monounsaturated Fat (g)',
    32: 'Niacin (mg)',
    33: 'Pantothenic Acid (mg)',
    34: 'Phosphorus (mg)',
    35: 'Polyunsaturated Fat (g)',
    36: 'Potassium (mg)',
    37: 'Protein (g)',
    38: 'Respiratory Rate (br/min)',
    39: 'Resting Heart Rate (bpm)',
    40: 'Riboflavin (mg)',
    41: 'Saturated Fat (g)',
    42: 'Selenium (mcg)',
    43: 'Sexual Activity (times)',
    44: 'Sodium (mg)',
    45: 'Thiamin (mg)',
    46: 'Total Fat (g)',
    47: 'Vitamin A (mcg)',
    48: 'Vitamin B12 (mcg)',
    49: 'Vitamin B6 (mg)',
    50: 'Vitamin C (mg)',
    51: 'Vitamin D (mcg)',
    52: 'Vitamin E (mg)',
    53: 'Vitamin K (mcg)',
    54: 'Waist Circumference (cm)',
    55: 'Water (mL)',
    56: 'Weight (kg)',
    57: 'Zinc (mg)',
    58: 'Constipation',
    59: 'Cycling Distance (km)',
    60: 'Diarrhea',
    61: 'Double Support Time (%)',
    62: 'Exercise Minutes',
    63: 'Flights Climbed (floors)',
    64: 'Handwashing',
    65: 'Insulin Delivery (U)',
    66: 'Nike Fuel',
    67: 'Peak Expiratory Flow Rate (L/min)',
    68: 'Pushes (pushes)',
    69: 'Resting Calories (kcal)',
    70: 'Six-Minute Walk (m)',
    71: 'Sleep',
    72: 'Stair Speed: Down (m/s)',
    73: 'Stair Speed: Up (m/s)',
    74: 'Stand Hours (hr)',
    75: 'Stand Minutes (min)',
    76: 'State of Mind',
    77: 'Step Length (cm)',
    78: 'Steps (steps)',
    79: 'Swimming Distance (m)',
    80: 'Swimming Strokes (strokes)',
    81: 'Walking + Running (km)',
    82: 'Walking Asymmetry (%)',
    83: 'Walking Heart Rate (bpm)',
    84: 'Walking Speed (km/hr)',
    85: 'Wheelchair Distance (km)',
    86: 'Workout Type',
    87: ' DURATION',
    88: 'datetime'
}


def read_data():
    """Read in the mentioned files from the export directory."""
    tables = {}
    prefixes = [f.prefix for f in SOURCES.values()]
    count = 0
    for root, _,  files in DATADIR.walk():
        for file in files:
            file_prefix = file
            if '_' in file:
                file_prefix = file.split('_', maxsplit=1)[0]
            # print(file, file_prefix)
            if file_prefix in prefixes:
                source_file = SOURCES[file_prefix]
                table_key = source_file.table
                if source_file.multiple:
                    table_key = f'{source_file.table}_{count}'
                    count += 1
                print(f'Reading {file}...')
                tables[table_key] = pd.read_csv(root / Path(file))

    breakpoint()

    old_health = tables['old_health']
    old_health['datetime'] = pd.to_datetime(old_health['Finish'])
    old_sleep = tables['old_sleep']

    new_health = pd.concat([tables[f'new_health_{n}'] for n in range(count)])
    new_health.drop_duplicates(inplace=True)
    new_health['datetime'] = pd.to_datetime(new_health['Date'], dayfirst=True)
    new_health.sort_values('datetime', inplace=True).reset_index(drop=True, inpalce=True)
    breakpoint()
    return 


def main():
    data = read_data()
    return None


if __name__ == '__main__':
    VERBOSE = 1
    main()
