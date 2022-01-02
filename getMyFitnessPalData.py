#!/usr/bin/env python3
"""
    Python version of the script to download the MyFitnessPal data

"""

import os
import sys
import re
import time
import subprocess
from selenium import webdriver
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By


def get_credentials():
    credentials = {}
    with open('../health_data/credentials.txt', 'r') as infh:
        lines = list(infh)
        for line in lines:
            parts = line.strip('\n').split(':')
            if parts[0] == 'mfp':
                credentials['username'] = parts[1]
                credentials['email'] = parts[2]
                credentials['password'] = parts[3]
    return credentials

def is_it_a_leap_year(year):    
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
    print('Getting report for {:04d}-{:02d}'.format(year, month))
    lastday = last_day_of_month(year, month)
    dates = {'from': '{:04d}-{:02d}-01'.format(year, month), 
             'to': '{:04d}-{:02d}-{:02d}'.format(year, month, lastday)}
    outfile = '{}/mfp_report_{:04d}{:02d}'.format(datadir, year, month)
    agent.get(report_url)
    # agent.get_screenshot_as_file('screen5.png')
    for field in ['from', 'to']:
        entry = agent.find_element_by_name(field)
        # print(field, entry, dates[field])
        entry.clear()
        entry.send_keys(dates[field])
    # agent.get_screenshot_as_file('screen6.png')
    submits = agent.find_elements(By.CLASS_NAME, 'submit')
    for submit in submits:
        # print(submit, submit.text, dir(submit))
        submit.click()
    # submit_field = agent.find_element_by_partial_link_text('change report')
    # submit_field.click()
    # agent.get_screenshot_as_file('screen7.png')
    # print(agent.page_source)
    with open('{}.html'.format(outfile), 'w') as outfh:
        outfh.write(agent.page_source)
    
    cmd = 'lynx -dump {O}.html'.format(O=outfile).split(' ')
    print(cmd)
    results = subprocess.run(cmd, stdout = subprocess.PIPE, text = True)
    with open('{}.txt'.format(outfile), 'w') as outfh:
        outfh.write(results.stdout)
    
    # convert to text using lynx
    # print(dir(agent))
    
    return None    

def main(dates):
    """
        Algorithm:
            Open the URL
            Log in
            Navigate to the printable Diary for the dates
            save the html file
            make a txt version of the HTML file
    """
    # Login Phase
    print('Logging in...')
    agent.get(login_url)
    for field in ['email', 'password']:
        entry = agent.find_element_by_name(field)
        entry.clear()
        entry.send_keys(credentials[field])
    # agent.get_screenshot_as_file('screen1.png')
    buttons = agent.find_elements(By.TAG_NAME, 'button')
    for button in buttons:
        if button.text == 'GOT IT':
            button.click()
            
    # agent.get_screenshot_as_file('screen2.png')
    forms = agent.find_elements(By.TAG_NAME, 'form')
    forms[0].submit()
    # agent.get_screenshot_as_file('screen3.png')
        
    # Wait for the page to refresh to the logged in state
    while agent.current_url == login_url:
        time.sleep(1)
    print('Logged in')
    # agent.get_screenshot_as_file('screen4.png')
    for date in dates:
        year, month = date.split('-')
        get_printable_report(int(year), int(month))
    



if __name__ == '__main__':
    # Options
    VERBOSE = True
    # Initial Data
    credentials =  get_credentials()
    site_url = 'https://www.myfitnesspal.com'
    login_url = '{}/account/login'.format(site_url)
    report_url = '{}/reports/printable_diary/{}'.format(site_url,
                                                        credentials['username'])
    datadir = '../health_data/myFitnessPal_data/'
    dates = []
    # always have the current month
    dates.append('{:04d}-{:02d}'.format(int(time.strftime('%Y')), int(time.strftime('%m'))))
    for arg in sys.argv:
        is_date = re.search(r'^([0-9]{4})\-*([0-9]{2})', arg)
        print(is_date)
        if is_date:
            dates.append('{}-{}'.format(is_date[1], is_date[2]))
    print(dates)
    
    options = Options()
    options.set_headless()
    assert options.headless
    agent = webdriver.Firefox(firefox_options=options)

    main(dates)
    agent.close()