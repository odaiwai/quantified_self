#!/usr/bin/env python3
"""
    Python version of the script to download the MyFitnessPal data

"""

# import os
import re
import sys
import time
import subprocess
from selenium import webdriver
from selenium.webdriver.firefox.options import Options
i#  from selenium.webdriver.support.ui import Select
from selenium.webdriver.common.keys import Keys
# from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By


def get_credentials():
    """ Get the credential s from the external file.
    """
    creds = {}
    with open('../health_data/credentials.txt', 'r', encoding='utf8') as infh:
        lines = list(infh)
        for line in lines:
            parts = line.strip('\n').split(':')
            if parts[0] == 'cronometer':
                creds['username'] = parts[1]
                creds['email'] = parts[2]
                creds['password'] = parts[3]
    return creds


def is_it_a_leap_year(year):
    """ Check if the supplied year is a leap year.
    """
    leap_year = False
    if year % 4 == 0:
        leap_year = True
    if year % 100 == 0:
        leap_year = False
    if year % 400 == 0:
        leap_year = True
    return leap_year


def last_day_of_month(year, month):
    """ return the last day of the month for a given month/year
        month should be in 1-12 range
    """
    lastdays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if is_it_a_leap_year(year):
        lastdays[1] = 29
    return lastdays[month-1]


def get_printable_report(year, month):
    """ Get Monthly Reports Phase given the month and the years.
        month in mm format, 1 or 2 digits
        year in yyyy format
    """
    print(f'Getting report for {year:04d}-{month:02d}')
    lastday = last_day_of_month(year, month)
    report_dates = {'from': f'{year:04d}-{month:02d}-01',
                    'to': f'{year:04d}-{month:02d}-{lastday:02d}'}
    outfile = f'{DATADIR}/cronometer_data_{year:04d}{month:02d}'
    agent.get(ACCOUNTURL)
    # agent.get_screenshot_as_file('screen5.png')
    for field in ['from', 'to']:
        entry = agent.find_element_by_name(field)
        # print(field, entry, report_dates[field])
        entry.clear()
        entry.send_keys(report_dates[field])
    # agent.get_screenshot_as_file('screen6.png')
    submits = agent.find_elements(By.CLASS_NAME, 'submit')
    for submit in submits:
        # print(submit, submit.text, dir(submit))
        submit.click()
    # submit_field = agent.find_element_by_partial_link_text('change report')
    # submit_field.click()
    # agent.get_screenshot_as_file('screen7.png')
    # print(agent.page_source)
    with open(f'{outfile}.html', 'w', encoding='utf8') as outfh:
        outfh.write(agent.page_source)

    cmd = f'lynx -dump {outfile}.html'.split(' ')
    print(cmd)
    results = subprocess.run(cmd, stdout=subprocess.PIPE,
                             text=True, check=True)
    with open(f'{outfile}.txt', 'w', encoding='utf8') as outfh:
        outfh.write(results.stdout)

    # convert to text using lynx
    # print(dir(agent))

    # return None


def main(agent, dates):
    """
        Algorithm:
            Open the URL
            Log in
            save the html file
            make a txt version of the HTML file
    """
    # Login Phase
    print('Logging in...')
    agent.get(LOGINURL)
    # Debugging
    for field in ['username', 'password']:
        entry = agent.find_element_by_name(field)
        entry.clear()
        if field == 'username':
            entry.send_keys(credentials['email'])
        else:
            entry.send_keys(credentials[field])
    agent.get_screenshot_as_file('login_screen1.png')
    buttons = agent.find_elements_by_tag_name('button')
    for button in buttons:
        if button.text == 'LOG IN':
            button.click()

    forms = agent.find_elements_by_tag_name('form')
    forms[0].submit()
    agent.get_screenshot_as_file('login_screen3.png')

    # Wait for the page to refresh to the logged in state
    while agent.current_url == LOGINURL:
        time.sleep(1)
    print('Logged in')
    agent.get_screenshot_as_file('login_screen4.png')

    # Go to the account page and work the export function
    # This is non trivial!
    agent.get(ACCOUNTURL)
    for date in dates:
        year, month = date.split('-')
        get_printable_report(int(year), int(month))


if __name__ == '__main__':
    # Options
    VERBOSE = True
    # Initial Data
    credentials = get_credentials()
    SITEURL = 'https://www.cronometer.com'
    LOGINURL = f'{SITEURL}/login/'
    ACCOUNTURL = f'{SITEURL}/#account/'
    DATADIR = '../health_data/cronometer_data/'

    # Dates can be supplied on the command line
    # always have the current month
    this_year = int(time.strftime('%Y'))
    this_month = int(time.strftime('%m'))
    dates = [f'{this_year:04d}-{this_month:02d}']

    # If in the first week of the month, get last month's too
    # Probably won't have to do this for cronometer...
    if int(time.strftime('%d')) < 8:
        last_year = this_year
        last_month = this_month - 1
        if this_month == 1:
            last_year = this_year - 1
            dates.append(f'{last_year:04d}-12')
        else:
            last_month = this_month - 1
            dates.append(f'{this_year:04d}-{last_month:02d}')

    for arg in sys.argv:
        is_date = re.search(r'^([0-9]{4})\-*([0-9]{2})', arg)
        print(is_date)
        if is_date:
            dates.append(f'{is_date[1]}-{is_date[2]}')
    print(dates)

    options = Options()
    options.headless = True
    assert options.headless
    agent = webdriver.Firefox(options=options)

    main(agent, dates)

    agent.close()
