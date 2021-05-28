#!/bin/sh

# exit on error
set -e

# create ssh host keys if not present, and put them in a separate directory that
# can be volume mounted
ssh-keygen -A
mkdir -p /etc/ssh/host_keys
mv --no-clobber /etc/ssh/ssh_host_*_key* /etc/ssh/host_keys/
rm -f /etc/ssh/ssh_host_*_key*

# set up the git repo dir
if ! [ -d "$GIT_REPO_DIR" ]; then
    mkdir "$GIT_REPO_DIR"
    chown git:git "$GIT_REPO_DIR"
fi

sed -i "s#SetEnv GIT_REPO_DIR=.*#SetEnv GIT_REPO_DIR=\"$GIT_REPO_DIR\"#" /etc/ssh/sshd_config

# generate host key arguments for sshd so it uses the moved keys
host_key_args=`for f in /etc/ssh/host_keys/ssh_host_*_key; do echo -h $f; done`

# link git shell commands to where git expects them (this is done at runtime
# because a volume or host directory is likely mounted at /home/git)
ln -sf /etc/git/shell-commands /home/git/git-shell-commands

# run sshd in foreground with logs printed to stderr, and pass on args
exec /usr/sbin/sshd -D -e $host_key_args "$@"
