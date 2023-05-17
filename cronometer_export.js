import url from 'url';
import { createRunner } from '@puppeteer/replay';

export async function run(extension) {
    const runner = await createRunner(extension);

    await runner.runBeforeAllSteps();

    await runner.runStep({
        type: 'setViewport',
        width: 1086,
        height: 971,
        deviceScaleFactor: 1,
        isMobile: false,
        hasTouch: false,
        isLandscape: false
    });
    await runner.runStep({
        type: 'navigate',
        url: 'https://cronometer.com/#dashboard',
        assertedEvents: [
            {
                type: 'navigation',
                url: 'https://cronometer.com/#dashboard',
                title: 'Cronometer: Eat smarter. Live better.'
            }
        ]
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 15.578125,
        offsetX: 66.265625,
        assertedEvents: [
            {
                type: 'navigation',
                url: 'https://cronometer.com/login/',
                title: ''
            }
        ]
    });
    await runner.runStep({
        type: 'change',
        value: 'odaiwai@gmail.com',
        selectors: [
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
        ],
        target: 'main'
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 16,
        offsetX: 24.546875,
        assertedEvents: [
            {
                type: 'navigation',
                url: 'https://cronometer.com/',
                title: ''
            }
        ]
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 13,
        offsetX: 50,
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 21,
        offsetX: 45,
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 20,
        offsetX: 67.671875,
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 21,
        offsetX: 309,
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 10,
        offsetX: 59,
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 26,
        offsetX: 175,
        assertedEvents: [
            {
                type: 'navigation'
            }
        ]
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 18,
        offsetX: 34.671875,
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 24,
        offsetX: 187,
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 15,
        offsetX: 71,
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 15,
        offsetX: 201,
        assertedEvents: [
            {
                type: 'navigation'
            }
        ]
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 25,
        offsetX: 82.671875,
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 6,
        offsetX: 246,
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 10,
        offsetX: 77,
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 25,
        offsetX: 244,
        assertedEvents: [
            {
                type: 'navigation'
            }
        ]
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 29,
        offsetX: 78.671875,
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 28,
        offsetX: 313,
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 8,
        offsetX: 100,
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 10,
        offsetX: 242,
        assertedEvents: [
            {
                type: 'navigation'
            }
        ]
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 18,
        offsetX: 108.671875,
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 29,
        offsetX: 284,
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 12,
        offsetX: 124,
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
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
        ],
        offsetY: 28,
        offsetX: 155,
        assertedEvents: [
            {
                type: 'navigation'
            }
        ]
    });

    await runner.runAfterAllSteps();
}

if (process && import.meta.url === url.pathToFileURL(process.argv[1]).href) {
    run()
}
