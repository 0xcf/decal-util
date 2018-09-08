#!/usr/bin/env python3
from textwrap import dedent

from ocflib.account.search import user_attrs
from ocflib.infra.db import get_connection
from ocflib.misc.mail import send_mail

CCN = '28246'
SUBJECT = '[Linux SysAdmin Decal] Fall 2018 Enrollment Code'
FROM = 'decal@ocf.berkeley.edu'
CC = 'decal+enrollment@ocf.berkeley.edu'
MYSQL_PWD = open('mysqlpwd', 'r').read().strip()

message = dedent('''
Hello {name},

Welcome to the Fall 2018 edition of the Linux Sysadmin DeCal. Please use the code {code} to enroll in CS 198-8, CCN #{ccn}.

Thank you,

DeCal Staff
''').strip()

with get_connection('decal', MYSQL_PWD, 'decal') as c:
    c.execute('SELECT `username`, `enrollment_code` FROM students WHERE semester = 4;')
    for c in c.fetchall():
        username = c['username']
        enrollment_code = c['enrollment_code']
        name = user_attrs(username)['cn'][0]
        email = '{}@ocf.berkeley.edu'.format(username)
        materialized_message = message.format(name=name, code=enrollment_code, ccn=CCN)
        print('Sending enrollment email to:', email)
        send_mail(email, SUBJECT, materialized_message, cc=CC, sender=FROM)
