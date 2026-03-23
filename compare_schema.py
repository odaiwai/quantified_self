#!/usr/bin/env python3
"""Compare the schema from the database with the CSV file."""
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


def get_schema_from_csv(table, today):
    """Get the Schema from the CSV file."""
    df = pd.read_csv(DATADIR / f'{table}_{today}.csv')
    schema = {}
    for col in df.columns:
        dtype = df[col].dtype
        schema[col] = dtype

    return schema


def get_schema_from_database(table: str) -> dict:
    """Get the schems from an sqlite database."""
    with sqlite3.connect('health_data.sqlite') as db:
        df = pd.read_sql(f'select * from cronometer_{table}', db)

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


def main(timestamp: str) -> None:
    """Do the Main Tasks."""
    for table in TABLES:
        print(f'Reviewing {table.name} for columns...')
        # Get schema from database
        db_schema = get_schema_from_database(table.name)

        # Get Schema from CSV file
        csv_schema = get_schema_from_csv(table.name, timestamp)

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

    return None


if __name__ == '__main__':
    print('Call with the following arguments:')
    print(' - today in yyyymmdd (will assume today if not specified)')
    if len(sys.argv) > 1:
        today = sys.argv[1]
    else:
        today = datetime.now().strftime('%Y%m%d')
    main(today)
