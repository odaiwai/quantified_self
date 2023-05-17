#!/usr/bin/env python3

# import asyncio
from playwright.sync_api import Page, expect
from playwright.sync_api import sync_playwright
from playwright.async_api import async_playwright
from pathlib import Path

p = sync_playwright().start()
browser = p.chromium.launch(headless=False)
page = browser.new_page(viewport={'width': 1024, 'height': 970})
page.goto('http://cronometer.com')
page.get_by_role('link', name='LOG IN').click()
page.get_by_role('textbox', name='Email Address').fill('odaiwai@gmail.com')
page.get_by_role('textbox', name='Password').fill('-3W/GmHwZ&ZQm!5')
page.get_by_role('button').click()
page.wait_for_load_state('networkidle')
print(page.frames)
page.screenshot(path='screenshot002.png')
frame = page.frames[0]
roles = ['listitem']
for role in roles:
    locators = page.get_by_role(role).all()
    print(f'Role: {role}:')
    for locator in locators:
        latc = locator.all_text_contents()
        print(f'\t{role}/{locator}, {latc}')

# page.get_by_role('aria/Account').click()
# page.logator('aria/EXPORT DATA').click()
# page.locator('aria/Last 7 days[role="button"]').click()
# page.logator('aria/All Time').click()
# page.screenshot(path='screenshot002.png')
