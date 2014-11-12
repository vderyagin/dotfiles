import subprocess
import os.path

passwd_file = os.path.expanduser('~/.offlineimap-google-password.gpg')

def get_password():
    raw_password =  subprocess.check_output(['gpg', '-d', passwd_file])
    return raw_password.strip().decode('utf-8')

def filter_folders(name):
    if name in ['[Gmail]/All Mail', '[Gmail]/Trash']:
        return False
    if name.startswith('mailing-lists/'):
        return False
    return True
