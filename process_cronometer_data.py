#!/usr/bin/env python3
"""Compare the schema from the database with the CSV file."""
import os
import re
import sqlite3
import sys
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path

import pandas as pd


@dataclass
class Table:
    name: str
    day_date: str


DATADIR = Path('..', 'health_data', 'cronometer_data')
TABLES = [
    Table('dailysummary', 'Date'),
    Table('servings', 'Day'),
    Table('notes', 'Day'),
    Table('biometrics', 'Day'),
    Table('exercises', 'Day'),
]


def timer(func):
    """Time other functions."""
    def _wrapper(*args, **kwargs):
        now = datetime.now()

        # Call the function
        result = func(*args, **kwargs)

        elapsed = datetime.now() - now
        print(f'{func.__name__} run in {elapsed}')

        # return the
        return result

    # Decorators return the wrapper
    return _wrapper


def join_uniq_str(series: pd.Series) -> str | None:
    """Join a set of strings together."""
    uniq = series.dropna().unique()
    if len(uniq) == 0:
        return ''
    elif len(uniq) == 1:
        return uniq[0]
    else:
        return ';'.join([str(u) for u in uniq])


def join_uniq_float(series: pd.Series) -> str | None:
    """Aggregate a pd.Series to a Comma Separated List.

    The input is anything, output will be unique value or the mode.
    """
    # print(series, series.dtype)
    uniq = series.dropna().unique()
    if len(uniq) == 0:
        return 0
    elif len(uniq) == 1:
        return uniq[0]
    else:
        mode = series.mode()
        mean = float(sum(mode) / len(mode))
        count = len(series)
        small = mean / 1000.0
        count = len(series)
        diffs = []
        num_eq_mean = 0
        outliers = 0
        for val in series:
            diffs.append(val - mean)
            num_eq_mean += (val < mean) <= small
            outliers += abs(val - mean) > small
        # print(f'{uniq=}, {mean=}, {diffs=}, {num_eq_mean=}, '
        #       f'{num_eq_mean/count=}, {outliers=}')
        if (outliers / count) > 0.50:
            # return the average
            return sum(series)/count
        else:
            return mean


@timer
def build_database_from_csv(table: Table):
    """Get the Schema from the CSV file."""
    tables = {}
    schemas = {}
    input_file_re = re.compile(r'^(?P<table>[A-z]+)_'
                               r'(?P<date>[0-9]{8})\.'
                               r'(?P<ftype>[A-z]{3})$')
    filenames = [f for f in os.listdir(DATADIR) if table.name in f]
    for filename in filenames:
        if match := input_file_re.search(filename):
            filetype = match['ftype']
            date = match['date']
            filepath = DATADIR / Path(filename)
            print(f'Processing {filepath}...', end='\r')
            if filetype == 'csv':
                df = pd.read_csv(filepath)
                df['reported'] = date
                df['daily_item'] = df.groupby(table.day_date).cumcount()
                df['timestamp'] = (pd.to_datetime(df[table.day_date]).
                                   dt.strftime('%Y%m%d'))
                df['uuid'] = (df['timestamp']
                              + df['daily_item'].map('{:03d}'.format))
                tables[date] = df
                schema = {}
                for col in df.columns:
                    dtype = df[col].dtype
                    schema[col] = dtype
                schemas[date] = schema
    print()
    all_df = pd.concat(tables).sort_values([table.day_date, 'reported'])

    schema_history = pd.DataFrame.from_dict(schemas, orient='index')
    agg_func = {}
    for col, dtype in all_df.dtypes.items():
        if dtype in ('float64', 'int64'):
            agg_func[col] = join_uniq_float
        elif dtype in ('object', 'bool'):
            agg_func[col] = join_uniq_str
        else:
            print(f'unknown dtype: {col}: {dtype}')

    for field in 'Completed reported daily_item'.split():
        if field in agg_func:
            del agg_func[field]

    print(f'Grouping {table.name}...')
    final_table = all_df.groupby('uuid').agg(agg_func)

    if len(final_table) > 0:
        print(f'{table.name} has {len(final_table)} records. Saving.')
        with sqlite3.connect('health_data.sqlite') as db:
            final_table.to_sql(f'cronometer_{table.name}', db,
                               index=False, if_exists='replace')
    else:
        print(f'No Entries in {table.name}')

    return


def get_schema_from_csv(table: Table, today: str):
    """Get the Schema from the CSV file."""
    df = pd.read_csv(DATADIR / f'{table.name}_{today}.csv')
    schema = {}
    for col in df.columns:
        dtype = df[col].dtype
        schema[col] = dtype

    return schema


def get_schema_from_database(table: Table) -> dict:
    """Get the schems from an sqlite database."""
    with sqlite3.connect('health_data.sqlite') as db:
        df = pd.read_sql(f'select * from cronometer_{table.name}', db)

    schema = {}
    for col in df.columns:
        dtype = df[col].dtype
        schema[col] = dtype

    return schema


def diff_cols(schema1, schema2) -> list:
    """Find the columns that are different between two dictionaries."""
    not_in_this = []
    for col in schema1:
        if col not in schema2:
            not_in_this.append(col)
    return not_in_this


def make_sql_script(timestamp: str, table: Table):
    """Make the SQL script to add the additional fields."""
    print(f'Reviewing {table.name} for columns...')
    # Get schema from database
    db_schema = get_schema_from_database(table)

    # Get Schema from CSV file
    csv_schema = get_schema_from_csv(table, timestamp)

    # compare and prepare a
    removed_cols = diff_cols(db_schema, csv_schema)
    added_cols = diff_cols(csv_schema, db_schema)

    print(f'Cols not in CSV: {removed_cols}')
    print(f'Cols not in DB: {added_cols}')
    # make a SQL statement to join the tables
    terms = []
    for field in csv_schema:
        if field in db_schema and field != 'Timestamp':
            terms.append(
                f"COALESCE(new.'{field}', old.'{field}', 0) as '{field}'")
        else:
            terms.append(f"COALESCE(new.'{field}', 0) as '{field}'")

    with open(f'{table.name}_merge.sql', 'w', encoding='utf-8') as outfh:
        print('DROP TABLE IF EXISTS temp1;', file=outfh)
        print('CREATE TABLE temp1 as SELECT ', file=outfh)
        for idx, term in enumerate(terms):
            if idx == 0:
                comma = ''
            else:
                comma = ', '
            print(f'\t{comma}{term}', file=outfh)
        print(f'\tfrom cronometer_{table.name}', file=outfh)
        print(f'\tFULL OUTER JOIN cronometer_{table.name} '
              f'as old using({table.day_date})', file=outfh)
        print('\tFULL OUTER JOIN temp as new '
              f'using ({table.day_date});', file=outfh)


def main(timestamp: str) -> None:
    """Do the Main Tasks."""
    for table in TABLES:
        # make_sql_script(timestamp, table)
        build_database_from_csv(table)

    return None


if __name__ == '__main__':
    print('Call with the following arguments:')
    print(' - today in yyyymmdd (will assume today if not specified)')
    if len(sys.argv) > 1:
        today = sys.argv[1]
    else:
        today = datetime.now().strftime('%Y%m%d')
    main(today)
