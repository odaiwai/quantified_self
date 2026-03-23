#!/usr/bin/env python3
"""Purpose of Script."""
# import sys
from time import sleep

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
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


def main() -> None:
    """Do the Main Tasks."""
    creds = get_credentials()
    base_url = 'https://www.cronometer.com'
    driver = get_chromedriver(headless=False)
    driver.get(base_url)
    wait = WebDriverWait(driver, TIMEOUT)
    wait.until(EC.element_to_be_clickable((By.CLASS_NAME, 'nav-link')))
    login_to_account(driver, wait, base_url, creds)

    driver.get(base_url + '/#account')

    wait.until(EC.presence_of_element_located(
        (By.CLASS_NAME, 'container-raised')))

    categories = ['Export Daily Nutrition',
                  'Export Food & Recipe Entries',
                  'Export Exercises',
                  'Export Biometrics',
                  'Export Notes',
                  'Export Fasts',]
    for category in categories:
        # Push the Export button
        buttons = wait.until(
            EC.presence_of_all_elements_located((By.TAG_NAME, 'button')))
        sleep(1)
        breakpoint()
        # FAILING here sometimes: FIXME
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
        breakpoint()
        wait.until(EC.presence_of_all_elements_located(
            (By.CLASS_NAME, 'gwt-Button')))

        buttons = driver.find_elements(By.CLASS_NAME, 'button')
        cat_button = [b for b in buttons if b.text == category][0]
        cat_button.send_keys(Keys.RETURN)
        # file goes to ~/Downloads folder

    breakpoint()

    # Login

    # Do the Export stuff
    parse_export_page(driver, creds)

    return None


if __name__ == '__main__':
    main()
