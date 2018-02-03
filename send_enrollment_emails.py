import sys
from textwrap import dedent

from ocflib.account.search import user_attrs
from ocflib.misc.mail import send_mail

CCN = '42610'
SUBJECT = '[UNIX SysAdmin Decal] Spring 2018 Enrollment Code'
FROM = 'decal@ocf.berkeley.edu'
CC = 'decal@ocf.berkeley.edu'

DATA_FILE = sys.argv[1]

message = dedent('''
Hello {name},

Please use the code {code} to enroll in CS 198-8, CCN #{ccn}.

Thank you,

DeCal Staff
''').strip()

students = {}

with open(DATA_FILE, 'r') as d:
    for i in d.read().strip().split('\n'):
        code, student = i.split(' ')
        name = user_attrs(student)['cn'][0]
        email = '{}@ocf.berkeley.edu'.format(student)
        print(name, student, code)
        send_mail(email,
                  SUBJECT,
                  message.format(name=name,
                                 code=code,
                                 ccn=CCN),
                  cc=CC,
                  sender=FROM)
