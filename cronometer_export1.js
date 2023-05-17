const puppeteer = require('puppeteer'); // v13.0.0 or later

(async () => {
    const browser = await puppeteer.launch({'headless': false});
    const page = await browser.newPage();
    const timeout = 10000;
    page.setDefaultTimeout(timeout);

    {
        const targetPage = page;
        await targetPage.setViewport({
            width: 1024,
            height: 768
        })
    }
    {
        const targetPage = page;
        const promises = [];
        promises.push(targetPage.waitForNavigation());
        await targetPage.goto('https://cronometer.com/#dashboard');
        await Promise.all(promises);
    }
    {
        const targetPage = page;
        const promises = [];
        promises.push(targetPage.waitForNavigation());
        await scrollIntoViewIfNeeded([
            [
                'aria/LOG IN'
            ],
            [
                'div.div__nav-right > div > a'
            ],
            [
                'xpath//html/body/div[1]/div[1]/div[1]/div[2]/div/a'
            ],
            [
                'pierce/div.div__nav-right > div > a'
            ],
            [
                'text/Log In'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/LOG IN'
            ],
            [
                'div.div__nav-right > div > a'
            ],
            [
                'xpath//html/body/div[1]/div[1]/div[1]/div[2]/div/a'
            ],
            [
                'pierce/div.div__nav-right > div > a'
            ],
            [
                'text/Log In'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 66.265625,
            y: 15.578125,
          },
        });
        await Promise.all(promises);
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'aria/Email Address'
            ],
            [
                '#usernameBox'
            ],
            [
                'xpath///*[@id="usernameBox"]'
            ],
            [
                'pierce/#usernameBox'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/Email Address'
            ],
            [
                '#usernameBox'
            ],
            [
                'xpath///*[@id="usernameBox"]'
            ],
            [
                'pierce/#usernameBox'
            ]
        ], targetPage, { timeout, visible: true });
        const inputType = await element.evaluate(el => el.type);
        if (inputType === 'select-one') {
          await changeSelectElement(element, 'odaiwai@gmail.com')
        } else if ([
            'textarea',
            'text',
            'url',
            'tel',
            'search',
            'password',
            'number',
            'email'
        ].includes(inputType)) {
          await typeIntoElement(element, 'odaiwai@gmail.com');
        } else {
          await changeElementValue(element, 'odaiwai@gmail.com');
        }
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'aria/Password'
            ],
            [
                '#password'
            ],
            [
                'xpath///*[@id="password"]'
            ],
            [
                'pierce/#password'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/Password'
            ],
            [
                '#password'
            ],
            [
                'xpath///*[@id="password"]'
            ],
            [
                'pierce/#password'
            ]
        ], targetPage, { timeout, visible: true });
        const inputType = await element.evaluate(el => el.type);
        if (inputType === 'select-one') {
          await changeSelectElement(element, '-3W/GmHwZ&ZQm!5')
        } else if ([
            'textarea',
            'text',
            'url',
            'tel',
            'search',
            'password',
            'number',
            'email'
        ].includes(inputType)) {
          await typeIntoElement(element, '-3W/GmHwZ&ZQm!5');
        } else {
          await changeElementValue(element, '-3W/GmHwZ&ZQm!5');
        }
    }
    {
        const targetPage = page;
        const promises = [];
        promises.push(targetPage.waitForNavigation());
        await scrollIntoViewIfNeeded([
            [
                'aria/LOG IN',
                'aria/[role="generic"]'
            ],
            [
                '#login_txt'
            ],
            [
                'xpath///*[@id="login_txt"]'
            ],
            [
                'pierce/#login_txt'
            ],
            [
                'text/LOG IN'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/LOG IN',
                'aria/[role="generic"]'
            ],
            [
                '#login_txt'
            ],
            [
                'xpath///*[@id="login_txt"]'
            ],
            [
                'pierce/#login_txt'
            ],
            [
                'text/LOG IN'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 24.546875,
            y: 16,
          },
        });
        await Promise.all(promises);
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'li:nth-of-type(5) span'
            ],
            [
                'xpath///*[@id="settingsLink"]/span'
            ],
            [
                'pierce/li:nth-of-type(5) span'
            ],
            [
                'text/Settings'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'li:nth-of-type(5) span'
            ],
            [
                'xpath///*[@id="settingsLink"]/span'
            ],
            [
                'pierce/li:nth-of-type(5) span'
            ],
            [
                'text/Settings'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 50,
            y: 13,
          },
        });
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'aria/Account'
            ],
            [
                'li:nth-of-type(5) li:nth-of-type(1) > a'
            ],
            [
                'xpath///*[@id="settings-collapse"]/ul/li[1]/a'
            ],
            [
                'pierce/li:nth-of-type(5) li:nth-of-type(1) > a'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/Account'
            ],
            [
                'li:nth-of-type(5) li:nth-of-type(1) > a'
            ],
            [
                'xpath///*[@id="settings-collapse"]/ul/li[1]/a'
            ],
            [
                'pierce/li:nth-of-type(5) li:nth-of-type(1) > a'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 45,
            y: 21,
          },
        });
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'aria/EXPORT DATA'
            ],
            [
                'div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ],
            [
                'xpath///*[@id="cronometerApp"]/div[11]/div/div[6]/div[2]/div[2]/button'
            ],
            [
                'pierce/div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/EXPORT DATA'
            ],
            [
                'div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ],
            [
                'xpath///*[@id="cronometerApp"]/div[11]/div/div[6]/div[2]/div[2]/button'
            ],
            [
                'pierce/div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 67.671875,
            y: 20,
          },
        });
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'aria/Last 7 days[role="button"]'
            ],
            [
                '#gwt-uid-1019'
            ],
            [
                'xpath///*[@id="gwt-uid-1019"]'
            ],
            [
                'pierce/#gwt-uid-1019'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/Last 7 days[role="button"]'
            ],
            [
                '#gwt-uid-1019'
            ],
            [
                'xpath///*[@id="gwt-uid-1019"]'
            ],
            [
                'pierce/#gwt-uid-1019'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 309,
            y: 21,
          },
        });
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'aria/All Time'
            ],
            [
                'div.pretty-dialog a:nth-of-type(10)'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[1]/td/div/div/div[2]/div/div/a[10]'
            ],
            [
                'pierce/div.pretty-dialog a:nth-of-type(10)'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/All Time'
            ],
            [
                'div.pretty-dialog a:nth-of-type(10)'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[1]/td/div/div/div[2]/div/div/a[10]'
            ],
            [
                'pierce/div.pretty-dialog a:nth-of-type(10)'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 59,
            y: 10,
          },
        });
    }
    {
        const targetPage = page;
        const promises = [];
        promises.push(targetPage.waitForNavigation());
        await scrollIntoViewIfNeeded([
            [
                'aria/EXPORT DAILY NUTRITION[role="button"]'
            ],
            [
                'tr:nth-of-type(3) button'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[3]/td/button'
            ],
            [
                'pierce/tr:nth-of-type(3) button'
            ],
            [
                'text/Export Daily'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/EXPORT DAILY NUTRITION[role="button"]'
            ],
            [
                'tr:nth-of-type(3) button'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[3]/td/button'
            ],
            [
                'pierce/tr:nth-of-type(3) button'
            ],
            [
                'text/Export Daily'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 175,
            y: 26,
          },
        });
        await Promise.all(promises);
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'aria/EXPORT DATA'
            ],
            [
                'div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ],
            [
                'xpath///*[@id="cronometerApp"]/div[11]/div/div[6]/div[2]/div[2]/button'
            ],
            [
                'pierce/div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/EXPORT DATA'
            ],
            [
                'div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ],
            [
                'xpath///*[@id="cronometerApp"]/div[11]/div/div[6]/div[2]/div[2]/button'
            ],
            [
                'pierce/div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 34.671875,
            y: 18,
          },
        });
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'aria/Last 7 days[role="button"]'
            ],
            [
                '#gwt-uid-1020'
            ],
            [
                'xpath///*[@id="gwt-uid-1020"]'
            ],
            [
                'pierce/#gwt-uid-1020'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/Last 7 days[role="button"]'
            ],
            [
                '#gwt-uid-1020'
            ],
            [
                'xpath///*[@id="gwt-uid-1020"]'
            ],
            [
                'pierce/#gwt-uid-1020'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 187,
            y: 24,
          },
        });
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'aria/All Time'
            ],
            [
                'div.pretty-dialog a:nth-of-type(10)'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[1]/td/div/div/div[2]/div/div/a[10]'
            ],
            [
                'pierce/div.pretty-dialog a:nth-of-type(10)'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/All Time'
            ],
            [
                'div.pretty-dialog a:nth-of-type(10)'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[1]/td/div/div/div[2]/div/div/a[10]'
            ],
            [
                'pierce/div.pretty-dialog a:nth-of-type(10)'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 71,
            y: 15,
          },
        });
    }
    {
        const targetPage = page;
        const promises = [];
        promises.push(targetPage.waitForNavigation());
        await scrollIntoViewIfNeeded([
            [
                'aria/EXPORT FOOD & RECIPE ENTRIES[role="button"]'
            ],
            [
                'tr:nth-of-type(4) button'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[4]/td/button'
            ],
            [
                'pierce/tr:nth-of-type(4) button'
            ],
            [
                'text/Export Food &'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/EXPORT FOOD & RECIPE ENTRIES[role="button"]'
            ],
            [
                'tr:nth-of-type(4) button'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[4]/td/button'
            ],
            [
                'pierce/tr:nth-of-type(4) button'
            ],
            [
                'text/Export Food &'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 201,
            y: 15,
          },
        });
        await Promise.all(promises);
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'aria/EXPORT DATA'
            ],
            [
                'div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ],
            [
                'xpath///*[@id="cronometerApp"]/div[11]/div/div[6]/div[2]/div[2]/button'
            ],
            [
                'pierce/div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/EXPORT DATA'
            ],
            [
                'div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ],
            [
                'xpath///*[@id="cronometerApp"]/div[11]/div/div[6]/div[2]/div[2]/button'
            ],
            [
                'pierce/div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 82.671875,
            y: 25,
          },
        });
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'aria/Last 7 days[role="button"]'
            ],
            [
                '#gwt-uid-1021'
            ],
            [
                'xpath///*[@id="gwt-uid-1021"]'
            ],
            [
                'pierce/#gwt-uid-1021'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/Last 7 days[role="button"]'
            ],
            [
                '#gwt-uid-1021'
            ],
            [
                'xpath///*[@id="gwt-uid-1021"]'
            ],
            [
                'pierce/#gwt-uid-1021'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 246,
            y: 6,
          },
        });
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'aria/All Time'
            ],
            [
                'div.pretty-dialog a:nth-of-type(10)'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[1]/td/div/div/div[2]/div/div/a[10]'
            ],
            [
                'pierce/div.pretty-dialog a:nth-of-type(10)'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/All Time'
            ],
            [
                'div.pretty-dialog a:nth-of-type(10)'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[1]/td/div/div/div[2]/div/div/a[10]'
            ],
            [
                'pierce/div.pretty-dialog a:nth-of-type(10)'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 77,
            y: 10,
          },
        });
    }
    {
        const targetPage = page;
        const promises = [];
        promises.push(targetPage.waitForNavigation());
        await scrollIntoViewIfNeeded([
            [
                'aria/EXPORT EXERCISES[role="button"]'
            ],
            [
                'tr:nth-of-type(5) button'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[5]/td/button'
            ],
            [
                'pierce/tr:nth-of-type(5) button'
            ],
            [
                'text/Export Exercises'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/EXPORT EXERCISES[role="button"]'
            ],
            [
                'tr:nth-of-type(5) button'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[5]/td/button'
            ],
            [
                'pierce/tr:nth-of-type(5) button'
            ],
            [
                'text/Export Exercises'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 244,
            y: 25,
          },
        });
        await Promise.all(promises);
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'aria/EXPORT DATA'
            ],
            [
                'div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ],
            [
                'xpath///*[@id="cronometerApp"]/div[11]/div/div[6]/div[2]/div[2]/button'
            ],
            [
                'pierce/div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/EXPORT DATA'
            ],
            [
                'div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ],
            [
                'xpath///*[@id="cronometerApp"]/div[11]/div/div[6]/div[2]/div[2]/button'
            ],
            [
                'pierce/div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 78.671875,
            y: 29,
          },
        });
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'aria/Last 7 days[role="button"]'
            ],
            [
                '#gwt-uid-1022'
            ],
            [
                'xpath///*[@id="gwt-uid-1022"]'
            ],
            [
                'pierce/#gwt-uid-1022'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/Last 7 days[role="button"]'
            ],
            [
                '#gwt-uid-1022'
            ],
            [
                'xpath///*[@id="gwt-uid-1022"]'
            ],
            [
                'pierce/#gwt-uid-1022'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 313,
            y: 28,
          },
        });
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'aria/All Time'
            ],
            [
                'div.pretty-dialog a:nth-of-type(10)'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[1]/td/div/div/div[2]/div/div/a[10]'
            ],
            [
                'pierce/div.pretty-dialog a:nth-of-type(10)'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/All Time'
            ],
            [
                'div.pretty-dialog a:nth-of-type(10)'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[1]/td/div/div/div[2]/div/div/a[10]'
            ],
            [
                'pierce/div.pretty-dialog a:nth-of-type(10)'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 100,
            y: 8,
          },
        });
    }
    {
        const targetPage = page;
        const promises = [];
        promises.push(targetPage.waitForNavigation());
        await scrollIntoViewIfNeeded([
            [
                'aria/EXPORT BIOMETRICS[role="button"]'
            ],
            [
                'tr:nth-of-type(6) button'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[6]/td/button'
            ],
            [
                'pierce/tr:nth-of-type(6) button'
            ],
            [
                'text/Export Biometrics'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/EXPORT BIOMETRICS[role="button"]'
            ],
            [
                'tr:nth-of-type(6) button'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[6]/td/button'
            ],
            [
                'pierce/tr:nth-of-type(6) button'
            ],
            [
                'text/Export Biometrics'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 242,
            y: 10,
          },
        });
        await Promise.all(promises);
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'aria/EXPORT DATA'
            ],
            [
                'div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ],
            [
                'xpath///*[@id="cronometerApp"]/div[11]/div/div[6]/div[2]/div[2]/button'
            ],
            [
                'pierce/div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/EXPORT DATA'
            ],
            [
                'div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ],
            [
                'xpath///*[@id="cronometerApp"]/div[11]/div/div[6]/div[2]/div[2]/button'
            ],
            [
                'pierce/div:nth-of-type(11) > div > div.my-4 > div:nth-of-type(2) button'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 108.671875,
            y: 18,
          },
        });
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'aria/Last 7 days[role="button"]'
            ],
            [
                '#gwt-uid-1023'
            ],
            [
                'xpath///*[@id="gwt-uid-1023"]'
            ],
            [
                'pierce/#gwt-uid-1023'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/Last 7 days[role="button"]'
            ],
            [
                '#gwt-uid-1023'
            ],
            [
                'xpath///*[@id="gwt-uid-1023"]'
            ],
            [
                'pierce/#gwt-uid-1023'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 284,
            y: 29,
          },
        });
    }
    {
        const targetPage = page;
        await scrollIntoViewIfNeeded([
            [
                'aria/All Time'
            ],
            [
                'div.pretty-dialog a:nth-of-type(10)'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[1]/td/div/div/div[2]/div/div/a[10]'
            ],
            [
                'pierce/div.pretty-dialog a:nth-of-type(10)'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/All Time'
            ],
            [
                'div.pretty-dialog a:nth-of-type(10)'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[1]/td/div/div/div[2]/div/div/a[10]'
            ],
            [
                'pierce/div.pretty-dialog a:nth-of-type(10)'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 124,
            y: 12,
          },
        });
    }
    {
        const targetPage = page;
        const promises = [];
        promises.push(targetPage.waitForNavigation());
        await scrollIntoViewIfNeeded([
            [
                'aria/EXPORT NOTES[role="button"]'
            ],
            [
                'tr:nth-of-type(7) button'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[7]/td/button'
            ],
            [
                'pierce/tr:nth-of-type(7) button'
            ],
            [
                'text/Export Notes'
            ]
        ], targetPage, timeout);
        const element = await waitForSelectors([
            [
                'aria/EXPORT NOTES[role="button"]'
            ],
            [
                'tr:nth-of-type(7) button'
            ],
            [
                'xpath//html/body/div[6]/div/div/table/tbody/tr[7]/td/button'
            ],
            [
                'pierce/tr:nth-of-type(7) button'
            ],
            [
                'text/Export Notes'
            ]
        ], targetPage, { timeout, visible: true });
        await element.click({
          offset: {
            x: 155,
            y: 28,
          },
        });
        await Promise.all(promises);
    }

    await browser.close();

    async function waitForSelectors(selectors, frame, options) {
      for (const selector of selectors) {
        try {
          return await waitForSelector(selector, frame, options);
        } catch (err) {
          console.error(err);
        }
      }
      throw new Error('Could not find element for selectors: ' + JSON.stringify(selectors));
    }

    async function scrollIntoViewIfNeeded(selectors, frame, timeout) {
      const element = await waitForSelectors(selectors, frame, { visible: false, timeout });
      if (!element) {
        throw new Error(
          'The element could not be found.'
        );
      }
      await waitForConnected(element, timeout);
      const isInViewport = await element.isIntersectingViewport({threshold: 0});
      if (isInViewport) {
        return;
      }
      await element.evaluate(element => {
        element.scrollIntoView({
          block: 'center',
          inline: 'center',
          behavior: 'auto',
        });
      });
      await waitForInViewport(element, timeout);
    }

    async function waitForConnected(element, timeout) {
      await waitForFunction(async () => {
        return await element.getProperty('isConnected');
      }, timeout);
    }

    async function waitForInViewport(element, timeout) {
      await waitForFunction(async () => {
        return await element.isIntersectingViewport({threshold: 0});
      }, timeout);
    }

    async function waitForSelector(selector, frame, options) {
      if (!Array.isArray(selector)) {
        selector = [selector];
      }
      if (!selector.length) {
        throw new Error('Empty selector provided to waitForSelector');
      }
      let element = null;
      for (let i = 0; i < selector.length; i++) {
        const part = selector[i];
        if (element) {
          element = await element.waitForSelector(part, options);
        } else {
          element = await frame.waitForSelector(part, options);
        }
        if (!element) {
          throw new Error('Could not find element: ' + selector.join('>>'));
        }
        if (i < selector.length - 1) {
          element = (await element.evaluateHandle(el => el.shadowRoot ? el.shadowRoot : el)).asElement();
        }
      }
      if (!element) {
        throw new Error('Could not find element: ' + selector.join('|'));
      }
      return element;
    }

    async function waitForElement(step, frame, timeout) {
      const {
        count = 1,
        operator = '>=',
        visible = true,
        properties,
        attributes,
      } = step;
      const compFn = {
        '==': (a, b) => a === b,
        '>=': (a, b) => a >= b,
        '<=': (a, b) => a <= b,
      }[operator];
      await waitForFunction(async () => {
        const elements = await querySelectorsAll(step.selectors, frame);
        let result = compFn(elements.length, count);
        const elementsHandle = await frame.evaluateHandle((...elements) => {
          return elements;
        }, ...elements);
        await Promise.all(elements.map((element) => element.dispose()));
        if (result && (properties || attributes)) {
          result = await elementsHandle.evaluate(
            (elements, properties, attributes) => {
              for (const element of elements) {
                if (attributes) {
                  for (const [name, value] of Object.entries(attributes)) {
                    if (element.getAttribute(name) !== value) {
                      return false;
                    }
                  }
                }
                if (properties) {
                  if (!isDeepMatch(properties, element)) {
                    return false;
                  }
                }
              }
              return true;

              function isDeepMatch(a, b) {
                if (a === b) {
                  return true;
                }
                if ((a && !b) || (!a && b)) {
                  return false;
                }
                if (!(a instanceof Object) || !(b instanceof Object)) {
                  return false;
                }
                for (const [key, value] of Object.entries(a)) {
                  if (!isDeepMatch(value, b[key])) {
                    return false;
                  }
                }
                return true;
              }
            },
            properties,
            attributes
          );
        }
        await elementsHandle.dispose();
        return result === visible;
      }, timeout);
    }

    async function querySelectorsAll(selectors, frame) {
      for (const selector of selectors) {
        const result = await querySelectorAll(selector, frame);
        if (result.length) {
          return result;
        }
      }
      return [];
    }

    async function querySelectorAll(selector, frame) {
      if (!Array.isArray(selector)) {
        selector = [selector];
      }
      if (!selector.length) {
        throw new Error('Empty selector provided to querySelectorAll');
      }
      let elements = [];
      for (let i = 0; i < selector.length; i++) {
        const part = selector[i];
        if (i === 0) {
          elements = await frame.$$(part);
        } else {
          const tmpElements = elements;
          elements = [];
          for (const el of tmpElements) {
            elements.push(...(await el.$$(part)));
          }
        }
        if (elements.length === 0) {
          return [];
        }
        if (i < selector.length - 1) {
          const tmpElements = [];
          for (const el of elements) {
            const newEl = (await el.evaluateHandle(el => el.shadowRoot ? el.shadowRoot : el)).asElement();
            if (newEl) {
              tmpElements.push(newEl);
            }
          }
          elements = tmpElements;
        }
      }
      return elements;
    }

    async function waitForFunction(fn, timeout) {
      let isActive = true;
      const timeoutId = setTimeout(() => {
        isActive = false;
      }, timeout);
      while (isActive) {
        const result = await fn();
        if (result) {
          clearTimeout(timeoutId);
          return;
        }
        await new Promise(resolve => setTimeout(resolve, 100));
      }
      throw new Error('Timed out');
    }

    async function changeSelectElement(element, value) {
      await element.select(value);
      await element.evaluateHandle((e) => {
        e.blur();
        e.focus();
      });
    }

    async function changeElementValue(element, value) {
      await element.focus();
      await element.evaluate((input, value) => {
        input.value = value;
        input.dispatchEvent(new Event('input', { bubbles: true }));
        input.dispatchEvent(new Event('change', { bubbles: true }));
      }, value);
    }

    async function typeIntoElement(element, value) {
      const textToType = await element.evaluate((input, newValue) => {
        if (
          newValue.length <= input.value.length ||
          !newValue.startsWith(input.value)
        ) {
          input.value = '';
          return newValue;
        }
        const originalValue = input.value;
        input.value = '';
        input.value = originalValue;
        return newValue.substring(originalValue.length);
      }, value);
      await element.type(textToType);
    }
})().catch(err => {
    console.error(err);
    process.exit(1);
});
