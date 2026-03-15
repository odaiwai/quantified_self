#!/usr/bin/env python3
"""Purpose of Script."""
# import sys
import json
from datetime import datetime
from time import sleep

from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

from selenium_methods import TIMEOUT, get_chromedriver

# Constants


def get_credentials() -> dict:
    """ Get the credentials from the external file.
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


def parse_export_page(driver, wait):
    """Export the Required data, from a logged in state."""

    xpath = '//*[@id="Int_RESULTS"]/button/span'
    results = wait.until(EC.presence_of_element_located((By.XPATH, xpath)))
    results.click()

    # We are now at the results page
    # if we have a date change to match the date

    wait.until(EC.element_to_be_clickable((By.CLASS_NAME, 'table-cell')))
    # we should have rows of draw results
    table_rows = driver.find_elements(By.CLASS_NAME, 'table-row')
    for idx, row in enumerate(table_rows):
        # Second time around the row object can be stable, so we
        # need to wait for the table_row to be visible again.
        wait.until(EC.element_to_be_clickable((By.CLASS_NAME, 'table-row')))
        table_rows = driver.find_elements(By.CLASS_NAME, 'table-row')
        row = table_rows[idx]
        row_data = {}
        for item in row.find_elements(By.CLASS_NAME, 'table-cell'):
            class_name = item.get_attribute('class').split(' ')[1]
            row_data[class_name] = item.text

        # parse the draw results
        links = row.find_elements(By.TAG_NAME, 'a')
        links[0].click()
        wait.until(EC.presence_of_element_located(
            (By.CLASS_NAME, 'marksix-result-detail'))
        )
        container = driver.find_element(
            By.CLASS_NAME, 'marksix-result-detail')
        # Get the balls
        balls = balls_from_container(container)
        match = regexp.search(container.text).groupdict()
        if row_data['cell-sbName'] != '':
            match['sbnameE'] = row_data['cell-sbName']

        print(f'Balls: {balls}')
        print(match)
        draw = Draw(match, balls)
        print(draw)
        draws.append(draw)

        # Go back to the results page
        container.find_element(By.CLASS_NAME, 'arrow-icon').click()

    end = datetime.strptime(draws[0].date, '%d/%m/%Y')
    start = datetime.strptime(draws[-1].date, '%d/%m/%Y')
    timestamp = '_'.join([start.strftime('%Y%m%d'),
                          end.strftime('%Y%m%d')])
    with open(f'JSON/{timestamp}.json', 'w',
              encoding='utf-8') as outfh:
        print(json.dumps([d.to_dict() for d in draws]), file=outfh)
    add_draws_to_database(draws)

    return draws


def main() -> None:
    """Do the Main Tasks."""
    creds = get_credentials()
    base_url = 'https://www.cronometer.com'
    driver = get_chromedriver(headless=False)
    driver.get(base_url)
    wait = WebDriverWait(driver, TIMEOUT)
    wait.until(EC.element_to_be_clickable((By.CLASS_NAME, 'nav-link')))
    driver.get(base_url + '/login/')
    for field, value in (('username', creds['email']),
                         ('password', creds['password']),
                         ('login-button', None)):
        # breakpoint()
        # element = driver.find_element(By.ID, field)
        element = wait.until(EC.element_to_be_clickable((By.ID, field)))
        print(element, element.text)
        if value is not None:
            element.send_keys(value)
        else:
            element.click()

    wait.until(EC.presence_of_all_elements_located((By.TAG_NAME, 'body')))

    driver.get(base_url + '/#account')
    sleep(5)
    wait.until(EC.presence_of_element_located(
        (By.CLASS_NAME, 'container-raised')))

    buttons = driver.find_elements(By.TAG_NAME, 'button')
    export_button = [b for b in buttons if b.text == 'EXPORT DATA'][0]
    export_button.click()
    wait.until(EC.presence_of_element_located(
        (By.CLASS_NAME, 'pretty-dialog')))

    categories = ['Export Daily Nutrition',
                  'Export Food & Recipe Entries',
                  'Export Exercises',
                  'Export Biometrics',
                  'Export Notes',
                  'Export Fasts',]
    for category in categories:
        wait.until(EC.presence_of_element_located(
            (By.CLASS_NAME, 'dropdown-btn')))
        buttons = driver.find_elements(By.CLASS_NAME, 'dropdown-btn')
        duration_button = [b for b in buttons if b.text == 'Last 7 days'][0]
        duration_button.click()

        durations = driver.find_elements(By.CLASS_NAME, 'dropdown-item')
        last_year = [i for i in durations if i.text == 'Last year'][0]
        last_year.click()

        buttons = driver.find_elements(By.TAG_NAME, 'button')
        cat_button = [b for b in buttons if b.text == category][0]
        cat_button.click()
        # file goes to ~/Downloads folder

    breakpoint()

    # Login

    # Do the Export stuff
    parse_export_page(driver, creds)

    return None


if __name__ == '__main__':
    main()
