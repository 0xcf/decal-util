#!/usr/bin/env python3
import configparser
import crypt
import os
import random
import string
from textwrap import dedent

from fabric.api import env
from fabric.api import execute
from fabric.api import parallel
from fabric.api import run
from fabric.api import settings
from fabric.api import task
from ocflib.infra.db import get_connection
from ocflib.misc.mail import send_mail

env.use_ssh_config = True

MYSQL_DEFAULT_CONFIG = 'mysql.conf'
PW_LENGTH = 16
CURRENT_SEMESTER_FKID = '4'


def _db():
    conf = configparser.ConfigParser()
    if os.path.exists('mysql.conf'):
        conf.read('mysql.conf')
    else:
        conf.read(MYSQL_DEFAULT_CONFIG)

    return get_connection(
        user=conf.get('mysql', 'user'),
        password=conf.get('mysql', 'password'),
        db=conf.get('mysql', 'db'),
    )


def _get_students(track):

    assert track in ('basic', 'advanced'), 'invalid track: %s' % track

    with _db() as c:
        c.execute('SELECT `username` FROM `students` WHERE `track` = %s AND `semester` = %s ORDER BY `username`',
                  (track, CURRENT_SEMESTER_FKID,))

    for i in c.fetchall():
        yield i['username']


def _fqdnify(users):
    for user in users:
        yield '{}.decal.xcf.sh'.format(user)


def restart():
    return run('reboot now')


@task
def powercycle(group):
    hosts = _fqdnify(_get_students(group))
    with settings(user='root'):
        execute(restart, hosts=hosts)


@parallel
def hostname():
    return run('hostname')


@task
def list(group):
    hosts = _fqdnify(_get_students(group))
    with settings(user='root', key_filename='~/.ssh/id_decal'):
        execute(hostname, hosts=hosts)


def create_user():
    username = env.host.split('.')[0]

    # Generate a random temporary password to be emailed out to each student
    rand = random.SystemRandom()
    password = ''.join(rand.choice(string.ascii_letters + string.digits) for _ in range(PW_LENGTH))

    # Create a new user account in the sudo group so they have root access
    run('useradd -m -g sudo -s /bin/bash {}'.format(username))

    # Set their password to the temporary password previously generated
    run("echo '{}:{}' | chpasswd -e".format(username, crypt.crypt(password)))

    # Set password expiration for the user so that they have to change their
    # password immediately upon login
    run('chage -d 0 {}'.format(username))

    # Send an email out to the user with their new password
    message = dedent("""
        Hello {username},

        We have created a virtual machine for you for the Linux SysAdmin DeCal!

        You should be able to connect to it at {hostname} by running
        'ssh {username}@{hostname}' and entering your temporary
        password {password}.

        You should see a prompt to change your temporary password to something
        more secure after your first login.

        Let us know if you have any questions or issues,

        DeCal Staff
    """).strip()

    send_mail(
        '{}@ocf.berkeley.edu'.format(username),
        '[Linux SysAdmin DeCal] Virtual Machine Information',
        message.format(
            username=username,
            hostname=env.host,
            password=password,
        ),
        cc='decal+vms@ocf.berkeley.edu',
        sender='decal@ocf.berkeley.edu',
    )


@task
def create_users(group):
    hosts = _fqdnify(_get_students(group))
    with settings(user='root'):
        execute(create_user, hosts=hosts)
