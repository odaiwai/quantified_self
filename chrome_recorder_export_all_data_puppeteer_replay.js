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
        url: 'https://cronometer.com/#account',
        assertedEvents: [
            {
                type: 'navigation',
                url: 'https://cronometer.com/#account',
                title: 'Cronometer'
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
                '#cronometerApp > div:nth-child(11) > div > div.container-raised.my-4 > div:nth-child(2) > div.col > button'
            ],
            [
                'xpath///*[@id="cronometerApp"]/div[11]/div/div[6]/div[2]/div[2]/button'
            ]
        ],
        offsetY: 31,
        offsetX: 91.671875
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
            [
                'aria/Last 7 days[role="button"]'
            ],
            [
                '#gwt-uid-965'
            ],
            [
                'xpath///*[@id="gwt-uid-965"]'
            ]
        ],
        offsetY: 13,
        offsetX: 176
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
            [
                'aria/All Time'
            ],
            [
                'body > div.pretty-dialog > div > div > table.mt-4 > tbody > tr:nth-child(1) > td > div > div > div:nth-child(2) > div > div > a:nth-child(10)'
            ],
            [
                'xpath//html/body/div[5]/div/div/table[2]/tbody/tr[1]/td/div/div/div[2]/div/div/a[10]'
            ]
        ],
        offsetY: 17,
        offsetX: 100
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
            [
                'aria/EXPORT DAILY NUTRITION[role="button"]'
            ],
            [
                'body > div.pretty-dialog > div > div > table.mt-4 > tbody > tr:nth-child(3) > td > button'
            ],
            [
                'xpath//html/body/div[5]/div/div/table[2]/tbody/tr[3]/td/button'
            ],
            [
                'text/Export Daily'
            ]
        ],
        offsetY: 15,
        offsetX: 146,
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
                '#cronometerApp > div:nth-child(11) > div > div.container-raised.my-4 > div:nth-child(2) > div.col > button'
            ],
            [
                'xpath///*[@id="cronometerApp"]/div[11]/div/div[6]/div[2]/div[2]/button'
            ]
        ],
        offsetY: 28,
        offsetX: 76.671875
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
            [
                'aria/Last 7 days[role="button"]'
            ],
            [
                '#gwt-uid-966'
            ],
            [
                'xpath///*[@id="gwt-uid-966"]'
            ]
        ],
        offsetY: 25,
        offsetX: 124
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
            [
                'aria/All Time'
            ],
            [
                'body > div.pretty-dialog > div > div > table.mt-4 > tbody > tr:nth-child(1) > td > div > div > div:nth-child(2) > div > div > a:nth-child(10)'
            ],
            [
                'xpath//html/body/div[5]/div/div/table[2]/tbody/tr[1]/td/div/div/div[2]/div/div/a[10]'
            ]
        ],
        offsetY: 15,
        offsetX: 84
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
            [
                'aria/EXPORT SERVINGS[role="button"]'
            ],
            [
                'body > div.pretty-dialog > div > div > table.mt-4 > tbody > tr:nth-child(4) > td > button'
            ],
            [
                'xpath//html/body/div[5]/div/div/table[2]/tbody/tr[4]/td/button'
            ],
            [
                'text/Export Servings'
            ]
        ],
        offsetY: 13,
        offsetX: 177,
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
                '#cronometerApp > div:nth-child(11) > div > div.container-raised.my-4 > div:nth-child(2) > div.col > button'
            ],
            [
                'xpath///*[@id="cronometerApp"]/div[11]/div/div[6]/div[2]/div[2]/button'
            ]
        ],
        offsetY: 14,
        offsetX: 98.671875
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
            [
                'aria/Last 7 days[role="button"]'
            ],
            [
                '#gwt-uid-967'
            ],
            [
                'xpath///*[@id="gwt-uid-967"]'
            ]
        ],
        offsetY: 14,
        offsetX: 164
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
            [
                'aria/All Time'
            ],
            [
                'body > div.pretty-dialog > div > div > table.mt-4 > tbody > tr:nth-child(1) > td > div > div > div:nth-child(2) > div > div > a:nth-child(10)'
            ],
            [
                'xpath//html/body/div[5]/div/div/table[2]/tbody/tr[1]/td/div/div/div[2]/div/div/a[10]'
            ]
        ],
        offsetY: 3,
        offsetX: 80
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
            [
                'aria/EXPORT EXERCISES[role="button"]'
            ],
            [
                'body > div.pretty-dialog > div > div > table.mt-4 > tbody > tr:nth-child(5) > td > button'
            ],
            [
                'xpath//html/body/div[5]/div/div/table[2]/tbody/tr[5]/td/button'
            ],
            [
                'text/Export Exercises'
            ]
        ],
        offsetY: 10,
        offsetX: 164,
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
                '#cronometerApp > div:nth-child(11) > div > div.container-raised.my-4 > div:nth-child(2) > div.col > button'
            ],
            [
                'xpath///*[@id="cronometerApp"]/div[11]/div/div[6]/div[2]/div[2]/button'
            ]
        ],
        offsetY: 35,
        offsetX: 81.671875
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
            [
                'aria/Last 7 days[role="button"]'
            ],
            [
                '#gwt-uid-968'
            ],
            [
                'xpath///*[@id="gwt-uid-968"]'
            ]
        ],
        offsetY: 39,
        offsetX: 229
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
            [
                'aria/All Time'
            ],
            [
                'body > div.pretty-dialog > div > div > table.mt-4 > tbody > tr:nth-child(1) > td > div > div > div:nth-child(2) > div > div > a:nth-child(10)'
            ],
            [
                'xpath//html/body/div[5]/div/div/table[2]/tbody/tr[1]/td/div/div/div[2]/div/div/a[10]'
            ]
        ],
        offsetY: 18,
        offsetX: 65
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
            [
                'aria/EXPORT BIOMETRICS[role="button"]'
            ],
            [
                'body > div.pretty-dialog > div > div > table.mt-4 > tbody > tr:nth-child(6) > td > button'
            ],
            [
                'xpath//html/body/div[5]/div/div/table[2]/tbody/tr[6]/td/button'
            ],
            [
                'text/Export Biometrics'
            ]
        ],
        offsetY: 8,
        offsetX: 151,
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
                '#cronometerApp > div:nth-child(11) > div > div.container-raised.my-4 > div:nth-child(2) > div.col > button'
            ],
            [
                'xpath///*[@id="cronometerApp"]/div[11]/div/div[6]/div[2]/div[2]/button'
            ]
        ],
        offsetY: 12,
        offsetX: 87.671875
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
            [
                'aria/Last 7 days[role="button"]'
            ],
            [
                '#gwt-uid-969'
            ],
            [
                'xpath///*[@id="gwt-uid-969"]'
            ]
        ],
        offsetY: 23,
        offsetX: 187
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
            [
                'aria/All Time'
            ],
            [
                'body > div.pretty-dialog > div > div > table.mt-4 > tbody > tr:nth-child(1) > td > div > div > div:nth-child(2) > div > div > a:nth-child(10)'
            ],
            [
                'xpath//html/body/div[5]/div/div/table[2]/tbody/tr[1]/td/div/div/div[2]/div/div/a[10]'
            ]
        ],
        offsetY: 19,
        offsetX: 75
    });
    await runner.runStep({
        type: 'click',
        target: 'main',
        selectors: [
            [
                'aria/EXPORT NOTES[role="button"]'
            ],
            [
                'body > div.pretty-dialog > div > div > table.mt-4 > tbody > tr:nth-child(7) > td > button'
            ],
            [
                'xpath//html/body/div[5]/div/div/table[2]/tbody/tr[7]/td/button'
            ],
            [
                'text/Export Notes'
            ]
        ],
        offsetY: 22,
        offsetX: 145,
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
