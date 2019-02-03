#!/usr/bin/python2.7

import ConfigParser
import csv
import datetime
import logging
import os
import sys

# http://python-fitbit.readthedocs.org/en/latest/
import fitbit

# set this appropriately per https://dev.fitbit.com/docs/basics/#units
config = ConfigParser.SafeConfigParser()
if not config.read(os.path.join(os.environ['HOME'], '.api_keys')):
    raise Error('Unable to read .api_keys file')
if not config.items('fitbit'):
    raise ValueError('No [fitbit] section in .api_keys file')

logging.basicConfig(level=logging.DEBUG)

def upload_weight(date, weight):
    logging.debug('Posting weight data for {}'.format(date))
    res = authd_client.body(date=date,
                            data={u'weight': weight })
    return res


authd_client = fitbit.Fitbit(
    config.get('fitbit', 'fitbit_uploader_oauth_consumer_key'),
    config.get('fitbit', 'fitbit_uploader_oauth_shared_secret'),
    resource_owner_key=config.get('fitbit', 'oauth_token'),
    resource_owner_secret=config.get('fitbit', 'oauth_token_secret'))
authd_client.system = config.get('fitbit', 'unit_system')

# if a start date is specified, use it.
if len(sys.argv) > 2:
    start_at_str = sys.argv[2]

start_at_date = datetime.datetime.strptime(start_at_str, '%Y-%m-%d')

with open(sys.argv[1], 'rb') as csvfile:
    csvreader = csv.reader(csvfile)
    for row in csvreader:
        if row[0] == 'Date':
            continue
        date = datetime.datetime.strptime(row[0], '%Y-%m-%d')

        if not start_at_date:
            start_at_date = date

        if date < start_at_date:
            logging.debug('{} is before {}, skipping'.format(date, start_at_date))
            continue
        
        weight = row[1].replace('.0', '')
        if weight == '0':
            logging.warn('Skipping weight for {} as it is zero'.format(date))
            continue

        try:
            res = upload_weight(date, weight)
        except fitbit.exceptions.HTTPTooManyRequests as e:
            logging.error('Rate limit exceeded when logging data for {}'.format(date))
            raise
        
        b = res.get(u'body')
        if not b:
            raise ValueError('Body tag not found when logging data for {}'.format(date))
        w = b.get(u'weight')
        if str(w) != str(weight):
            raise ValueError('{} != {} when logging data for {}'.format(w, weight, date))
