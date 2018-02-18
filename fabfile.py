import configparser

from fabric.api import env
from fabric.api import execute
from fabric.api import parallel
from fabric.api import run
from fabric.api import settings
from fabric.api import task
from ocflib.infra.db import get_connection
# from fabric.api import reboot

env.use_ssh_config = True

MYSQL_CONFIG_FILE = 'mysql.conf'


def _db():
    conf = configparser.ConfigParser()
    conf.read(MYSQL_CONFIG_FILE)

    return get_connection(
        user=conf.get('mysql', 'user'),
        password=conf.get('mysql', 'password'),
        db=conf.get('mysql', 'db'),
    )


def _get_students(track):

    assert track in ('test', 'staff', 'basic', 'advanced'), 'invalid track: %s' % track

    if track == 'test' or track == 'staff':
        return (track,)

    with _db() as c:
        c.execute('SELECT `username` FROM `students` WHERE `track` = %s ORDER BY `username`', track)
        return [i['username'] for i in c]


def _fqdnify(users):
    return ['{}.decal.xcf.sh'.format(user) for user in users]


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
    with settings(user='root'):
        execute(hostname, hosts=hosts)


def bootstrap_puppet():
    run('apt -qq update')
    run('apt -qq install -y resolvconf')
    run('echo "domain decal.xcf.sh" > /etc/resolvconf/resolv.conf.d/base')
    run('resolvconf -u')
    run('systemctl start resolvconf')
    run('apt -qq install puppet -y')
    run('puppet agent --daemonize')


@task
def bootstrap(group):
    hosts = _fqdnify(_get_students(group))
    with settings(user='root'):
        execute(bootstrap_puppet, hosts=hosts)
