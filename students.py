#!/usr/bin/env python3

import argparse
import functools
from configparser import ConfigParser

from ocflib.infra import db
from ocflib.misc.mail import email_for_user


parser = argparse.ArgumentParser(
    description='Get emails for decal students',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter,
)
parser.add_argument(
    '-c',
    '--config',
    default='/etc/decal_mysql.conf',
    help='Config file to sql creds read from.',
)
parser.add_argument(
    '-t',
    '--track',
    default='%',
    help='Which track to dump emails from (basic, advanced).',
)

args = parser.parse_args()

config = ConfigParser()
config.read(args.config)

user = config.get('mysql', 'user')
pw = config.get('mysql', 'password')
dbname = config.get('mysql', 'db')

conn = functools.partial(
    db.get_connection,
    user=user,
    password=pw,
    db=dbname,
)

with conn() as c:
    c.execute(
        'SELECT `username` FROM `students` WHERE `track` LIKE %s',
        (args.track,)
    )
    for student in c.fetchall():
        print(email_for_user(student['username']))
