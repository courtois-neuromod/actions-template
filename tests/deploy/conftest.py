import os
import subprocess
import pytest
import ssh_agent_setup
from datalad.api import install
from datalad.config import ConfigManager

@pytest.fixture(scope="session", autouse=True)
def setup_git(
        username=os.environ['GIT_USERNAME'],
        email=os.environ['GIT_EMAIL']):

    config = ConfigManager()
    config.set('user.name', username, scope='global')
    config.set('user.email', email, scope='global')

    os.makedirs(os.path.join(os.environ['HOME'],'.ssh'), mode=700, exist_ok=True)

    subprocess.call(["sh", '-c', f"ssh-keyscan -H github.com | install -m 600 /dev/stdin /{os.environ['HOME']}/.ssh/known_hosts"])

    with open(f"/{os.environ['HOME']}/.ssh/known_hosts") as f:
        print(f.read())

    ssh_agent_setup.setup()
    # ensure a single line return at the end of the key
    secret_key = os.environ['SECRET_KEY'].rstrip('\n')+"\n"
    # add bot ssh key
    process = subprocess.run(['ssh-add', '-'], input=secret_key.encode())
    assert process.returncode == 0, 'fail to pass the ssh key to ssh-agent'


@pytest.fixture(scope="session")
def dataset(setup_git):
    ds = install(f"git@github.com:{os.environ['GITHUB_REPOSITORY']}.git")
    ds.repo.fetch(os.environ['GITHUB_REF'])
    ds.repo.checkout(os.environ['GITHUB_SHA'])
    yield ds
    ds.uninstall(check=False, recursive=True) #teardown
