#!/usr/bin/env python3
"""Purpose of Script."""
import os
from datetime import datetime
from pathlib import Path
from time import sleep

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

from selenium_methods import TIMEOUT, get_chromedriver

# Constants
DATADIR = Path('..', 'health_data', 'cronometer_data')
DOWNLOADS = Path(os.environ['HOME'], 'Downloads')


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


def login_to_account(driver, wait, base_url, creds: dict) -> bool:
    """Login to account and check status."""
    logged_in = False
    while not logged_in:
        driver.get(base_url + '/login/')
        for field, value in (('username', creds['email']),
                             ('password', creds['password']),
                             ('login-button', None)):
            # element = driver.find_element(By.ID, field)
            element = wait.until(EC.element_to_be_clickable((By.ID, field)))
            print(element, element.text)
            if value is not None:
                element.send_keys(value)
            else:
                element.click()
        print('Waiting for the main page')
        wait.until(EC.presence_of_all_elements_located(
            (By.CLASS_NAME, 'nav-title-with-children')))
        # breakpoint()
        # Search for something that means we're logged in.
        collapsed_buttons = driver.find_elements(By.CLASS_NAME, 'btn-toggle')
        if 'More' in [e.text for e in collapsed_buttons]:
            logged_in = True
            print('logged in')

    return logged_in


def scroll_into_view(driver, wait, element) -> None:
    driver.execute_script('arguments[0].scrollIntoView(true);', element)


def push_dropdown_button(driver, wait, condition, label):
    """Push a drop down button."""
    button_pushed = False
    while not button_pushed:
        buttons = wait.until(EC.presence_of_all_elements_located(
            condition))
        print([b.text for b in buttons])
        button = [b for b in buttons if b.text == label]
        if len(button) > 0:
            button[0].send_keys(Keys.RETURN)
            button_pushed = True
        else:
            sleep(1)


def delete_files(folder: Path, file_root: str) -> None:
    """Delete all files starting with the file_root in the folder."""
    files = [file for file in os.listdir(folder) if file_root in file]
    for file in files:
        filename = folder / Path(file)
        print(f'Deleting {filename}...')
        os.unlink(filename)

    return None


def wait_for_filename_to_download(filename: Path) -> bool:
    """Wait for a file to be downloaded."""
    print(f'Waiting for {filename}...')
    found = False
    while not found:
        if os.path.isfile(filename):
            print()
            return True
        else:
            print('.', end='')
            sleep(0.1)


def main() -> None:
    """Do the Main Tasks."""
    creds = get_credentials()
    base_url = 'https://www.cronometer.com'
    driver = get_chromedriver(headless=False)
    driver.get(base_url)
    wait = WebDriverWait(driver, TIMEOUT)
    wait.until(EC.element_to_be_clickable((By.CLASS_NAME, 'nav-link')))
    login_to_account(driver, wait, base_url, creds)
    timestamp = datetime.now().strftime('%Y%m%d')

    driver.get(base_url + '/#account')

    categories = {
        'Export Daily Nutrition': 'dailysummary',
        'Export Food & Recipe Entries': 'servings',
        'Export Exercises': 'exercises',
        'Export Biometrics': 'biometrics',
        'Export Notes': 'notes',
        'Export Fasts': 'fasts',
    }
    for category, filename in categories.items():
        # delete any previous files with this name:
        delete_files(DOWNLOADS, filename)
        wait.until(EC.presence_of_element_located(
            (By.CLASS_NAME, 'container-raised')))

        # Push the Export button
        buttons = wait.until(
            EC.presence_of_all_elements_located((By.TAG_NAME, 'button')))
        # sleep(1)
        export_button = [b for b in buttons if b.text == 'EXPORT DATA'][0]
        export_button.send_keys(Keys.RETURN)
        # push_dropdown_button(driver, wait, (By.TAG_NAME, 'button'), 'EXPORT DATA')
        dialog = wait.until(EC.presence_of_element_located(
            (By.CLASS_NAME, 'pretty-dialog')))
        # Choose the Duration
        push_dropdown_button(driver, wait, (By.CLASS_NAME,
                             'dropdown-btn'), 'Last 7 days')
        push_dropdown_button(driver, wait, (By.CLASS_NAME,
                             'dropdown-item'), 'Last year')
        buttons = wait.until(EC.presence_of_all_elements_located(
            (By.CLASS_NAME, 'gwt-Button')))
        cat_button = [b for b in buttons if b.text.upper() ==
                      category.upper()][0]
        cat_button.send_keys(Keys.RETURN)
        # file goes to ~/Downloads folder - rename it to have todays date
        filepath = DOWNLOADS / Path(f'{filename}.csv')
        wait_for_filename_to_download(filepath)
        os.rename(filepath, DATADIR / Path(f'{filename}_{timestamp}.csv'))

    return None


if __name__ == '__main__':
    main()
