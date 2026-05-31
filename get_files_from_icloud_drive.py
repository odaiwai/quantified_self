#!/usr/bin/env python3
""" Script to import files from iCloud Drive.

    Notes:
        Post iOS 8, the api.files functionality points to the
        Ubiquity service, not iCloud drive:
        https://developer.apple.com/library/archive/technotes/tn2348/_index.html#//apple_ref/doc/uid/DTS40014955-CH1-TNTAG5
"""
import os
import sys
from datetime import datetime
from shutil import copyfileobj  # https://docs.python.org/3/library/shutil.html

import click  # https://click.palletsprojects.com/
from pyicloud import PyiCloudService

# # https://pypi.org/project/pyicloud/
# if '../pyicloud/' not in sys.path:
#     sys.path.insert(0, '../pyicloud/')
#     from pyicloud import PyiCloudService  # isort:skip
# #     #  20250112: Changed to https://github.com/timlaing/pyicloud

OVERWRITE = False


def get_credentials():
    """Get the credential s from the external file."""
    creds = {}
    with open('../health_data/credentials.txt', 'r', encoding='utf8') as infh:
        lines = list(infh)
        for line in lines:
            parts = line.strip('\n').split(':')
            if parts[0] == 'icloud':
                creds['username'] = parts[1]
                creds['email'] = parts[2]
                creds['password'] = parts[3]
    return creds


def login() -> PyiCloudService:
    """Get the credentials and login to the Apple iCloud service."""
    creds = get_credentials()
    icloud = PyiCloudService(
        creds['email'], creds['password'])

    # This code mostly from https://pypi.org/project/pyicloud/
    # It has been refactored a little
    if icloud.requires_2fa:
        security_key_names = icloud.security_key_names

        if security_key_names:
            print('Security Keys required: '
                  'Plug in one of: ',
                  ', '.join(security_key_names)
                  )
            devices = icloud.fido2_devices
            print('Available FIDO2 Devices:')
            for idx, device in enumerate(devices, start=1):
                print(f'{idx}: {device}')

            choice = click.prompt(
                'Select device by number',
                type=click.IntRange(1, len(devices)),
                default=1,
            )
            selected_device = devices[choice-1]
            print(f'Confirm action using the device {selected_device}')
            icloud.confirm_security_key(selected_device)
        else:
            print('Two-factor authentication required.')
            icloud.request_2fa_code()
            code = input('Enter the code you received on an approved device: ')
            result = icloud.validate_2fa_code(code)
            print(f'Code validation result: {result}')
            if not result:
                print('Failed to verify security code')
                sys.exit(1)
            if not icloud.is_trusted_session:
                print('Session is not trusted. Requesting trust...')
                result = icloud.trust_session()
                print(f'Session trust result {result}')
                if not result:
                    print('Failed to request trust. You will likely be '
                          'prompted '
                          'for the code again in the coming weeks')
    elif icloud.requires_2sa:
        print('Two-step authentication required. Your trusted devices are:')
        devices = icloud.trusted_devices
        for i, device in enumerate(devices):
            device_name = device.get('deviceName')
            phone_number = device.get('phoneNumber')
            print(f'{i}: {device_name} SMS to {phone_number}')
        device = click.prompt('Which device would you like to use?', default=0)
        device = devices[device]
        if not icloud.send_verification_code(device):
            print('Failed to send verification code')
            sys.exit(1)
        code = click.prompt('Please enter validation code')
        if not icloud.validate_verification_code(device, code):
            print('Failed to verify verification code')
            sys.exit(1)

    return icloud


def main():
    """Main routine."""
    icloud = login()
    today = datetime.strftime(datetime.now(), '%Y%m%d')
    files_to_copy = {'apple_health_export': ['Health Data.csv',
                                             'Sleep Analysis.csv'],
                     'cronometer_data': [f'biometrics_{today}.csv',
                                         f'dailysummary_{today}.csv',
                                         f'exercises_{today}.csv',
                                         f'fasts_{today}.csv',
                                         f'notes_{today}.csv',
                                         f'servings_{today}.csv']
                     }
    icloud_files = icloud.drive['Health_Data'].dir()
    for local_dir, files in files_to_copy.items():
        local_path = f'../health_data/{local_dir}'
        dest_files = {f.name: f for f in os.scandir(local_path)}
        for file in files:
            drive_files = {}
            try:
                drive_files[file] = icloud.drive['Health_Data'][file]
            except KeyError:
                # All files are in the list: icloud.drive['Health_Data'].dir()
                # print(f'Unable to find file {file} on iCloud:\n\t{kerr}')
                prefix = file.split('_', maxsplit=1)[0]
                for icloud_file in icloud_files:
                    icloud_prefix = icloud_file.split('_')[0]
                    if icloud_prefix == prefix:
                        drive_files[icloud_file] = icloud.drive['Health_Data'][icloud_file]
                        # print(f'\tCopying {icloud_file} instead...')
                # quit()
            # copy it to the local copy of the file
            # print(drive_files.keys())
            # breakpoint()
            for file, drive_file in drive_files.items():
                dest_file = f'../health_data/{local_dir}/{file}'
                identical = None
                if file in dest_files and not OVERWRITE:
                    # check file sizes and dates
                    d_stat = dest_files[file].stat()
                    dest_time = datetime.fromtimestamp(d_stat.st_mtime)
                    if ((dest_time <= drive_file.date_modified) and
                            (d_stat.st_size != drive_file.size)):
                        identical = False
                        print(f'File {file} iCloud != local, copying')
                    else:
                        print(f'File {file} iCloud == local, skipping copy')
                        identical = True
                if not identical:
                    with drive_file.open(stream=True) as contents:
                        print((f'Copying file from iCloud to {file}: '
                               f'{contents.status_code}'))
                        with open(dest_file, 'wb') as outfh:
                            copyfileobj(contents.raw, outfh)
                            # we could also parse the text in contents.text


if __name__ == '__main__':
    main()
