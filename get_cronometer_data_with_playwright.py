#!/usr/bin/env python3
"""
    Get the cronometer data with Playwright
"""
# import os
# import sys
import re
import asyncio
from pathlib import Path
from playwright.async_api import Page, expect
# from playwright.sync_api import sync_playwright
from playwright.async_api import async_playwright


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


def test_homepage_has_correct_title(page: Page):
    """
    Unit Tests
    """
    page.goto('https://playwright.org')
    expect(page).to_have_title(re.compile('Playwright'))
    get_started = page.get_by_role('link', name='Get started')
    expect(get_started).to_have_attribute('href', '/docs/intro')
    get_started.click()
    expect(page).to_have_url(re.compile('.*intro'))


async def get_data(creds: dict, urls: list, datadir: str):
    """
        Main routine.
    """
    headless = False
    async with async_playwright() as apw:
        browser = await apw.chromium.launch(headless=headless)
        print(browser)
        page = await browser.new_page(viewport={'width': 1024, 'height': 970})
        # page.viewport_size = {'width': 1024, 'height': 970}
        await page.goto(urls[0])
        await page.get_by_role('link', name='LOG IN').click()
        await page.get_by_role('textbox',
                               name='Email Address').fill(creds['email'])
        await page.get_by_role('textbox',
                               name='Password').fill(creds['password'])
        await page.get_by_role('button').click()
        # await page.wait_for_load_state('load')
        # await page.wait_for_load_state('domcontentloaded')
        await page.wait_for_load_state('networkidle')

        roles = ['alert', 'alertdialog', 'application', 'article', 'banner',
                 'blockquote', 'button', 'caption', 'cell', 'checkbox',
                 'code', 'columnheader', 'combobox', 'complementary',
                 'contentinfo', 'definition', 'deletion', 'dialog',
                 'directory', 'document', 'emphasis', 'feed', 'figure',
                 'form', 'generic', 'grid', 'gridcell', 'group', 'heading',
                 'img', 'insertion', 'link', 'list', 'listbox', 'listitem',
                 'log', 'main', 'marquee', 'math', 'meter', 'menu', 'menubar',
                 'menuitem', 'menuitemcheckbox', 'menuitemradio', 'navigation',
                 'none', 'note', 'option', 'paragraph', 'presentation',
                 'progressbar', 'radio', 'radiogroup', 'region', 'row',
                 'rowgroup', 'rowheader', 'scrollbar', 'search', 'searchbox',
                 'separator', 'slider', 'spinbutton', 'status', 'strong',
                 'subscript', 'superscript', 'switch', 'tab', 'table',
                 'tablist', 'tabpanel', 'term', 'textbox', 'time', 'timer',
                 'toolbar', 'tooltip', 'tree', 'treegrid', 'treeitem']
        for role in roles:
            locators = await page.get_by_role(role).all()
            print(f'Role: {role}:')
            for locator in locators:
                latc = await locator.get_all_text_contents()
                print(f'\t{role}/{locator}, {latc}')

        await page.get_by_text('Settings').click()
        await page.get_by_text('EXPORT DATA').click()
        await expect(page).to_have_url(urls[0], timeout=5000)
        await page.screenshot(path='screenshot_002.png')
        await browser.close()


def main():
    """
    Do the non-async stuff first, then let the async
    part work.
    """
    creds = get_credentials()
    urls = ['https://cronometer.com/',
            'https://cronometer.com/#account']
    data_dir = Path(__file__)
    print(creds, urls, data_dir)

    asyncio.run(get_data(creds, urls, data_dir))


if __name__ == '__main__':
    main()
