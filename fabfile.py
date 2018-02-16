import configparser
from fabric.api import *
from ocflib.infra.db import get_connection

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
    assert track in ('basic', 'advanced'), 'invalid track: %s' % track

    with _db() as c:
        c.execute('SELECT `username` FROM `students` WHERE `track` = %s ORDER BY `username`', track)
        return [i['username'] for i in c]

def _fqdnify(users):
    return ["{}.decal.xcf.sh".format(user) for user in users]

@task
def powercycle(group):
    hosts = _fqdnify(_get_students(group))
    with settings(user='root'):
        execute(reboot, hosts=hosts)


@parallel
def hostname():
    return run('hostname')


@task
def list(group):
    hosts = _fqdnify(_get_students(group))
    with settings(user='root'):
        execute(hostname, hosts=hosts)

def bootstrap_puppet():
    run('apt install -y resolvconf')
    run('echo "domain decal.xcf.sh" > /etc/resolvconf/resolv.conf.d/base')
    run('resolvconf -u')
    run('systemctl start resolvconf')
    run('apt install puppet -y')
    run('puppet agent -e')
    run('puppet agent -t')

@task
def bootstrap(group):
    hosts = _fqdnify(_get_students(group)):
    with settings(user='root'):
        execute(bootstrap_puppet, hosts=hosts)


