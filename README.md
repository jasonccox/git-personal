# git-personal

A Docker image for a simple, single-user Git server. Available on [GitHub](https://github.com/jasonccox/git-personal) or as a [pre-built image on Docker Hub](https://hub.docker.com/r/jasonccox/git-personal).

- Built-in commands to create, list, and delete repos
- Support for mirroring repos to other Git servers
- Accessible over SSH only
- Intended for use by a single user or a team where everyone has permission to do anything with any repo
- Allows interaction only via `git-shell`

## Running the Server

First, you'll need to create an `authorized_keys` file containing your current public SSH key and generate an SSH key pair to be used by the server. Put them all inside a single directory:

```
$ mkdir git-personal-ssh
$ cat ~/.ssh/id_rsa.pub > git-personal-ssh/authorized_keys
$ ssh-keygen -f git-personal-ssh/id_rsa -C git-personal # leave passphrase empty
```

Then you can start the server:

```
$ docker run \
    --publish 2222:22 \
    --volume git-repos:/home/git \
    --volume ssh-host-keys:/etc/ssh/host_keys \
    --volume ./git-personal-ssh:/home/git/.ssh \
    jasonccox/git-personal
```

See the [example Compose file](./examples/docker-compose.yaml) for documentation about the volume mounts.

## Interacting with the Server

Once the server is running, you can access it over SSH like so:

```
$ ssh -p 2222 git@some.host # or whatever host it's running on
```

Doing so will drop you into `git-shell` on the server, where a few commands are available:

```
help                            Print available commands
mkrepo NAME                     Create a repo NAME
rmrepo NAME                     Remove the repo NAME
lsrepos                         List all repos
mirror NAME REMOTE              Set repo NAME to mirror to REMOTE
mirror -r|--remove NAME REMOTE  Set repo NAME to stop mirroring to REMOTE
mirror -l|--list NAME           List remotes to which repo NAME is mirroring
```

These commands can also be run directly over ssh, e.g. `ssh -p 2222 git@some.host mkrepo my-repo`. When accessing the server non-interactively like this, a few additional server-side Git commands are also available; see `man git-shell` for more information.

Once you've created a repo, you can interact with it via Git over SSH. By default, repos are created in `/home/git/` on the server.

For example, if you had a local repo called `my-repo`, you might do the following to create a repository, push some code to it, and mirror it to GitHub:

```
# create the repo on the server
$ ssh -p 2222 git@some.host mkrepo my-repo

# add the server repo as a remote and push to it
$ cd my-repo
$ git remote add origin ssh://git@some.host:2222/~git/my-repo.git
$ git push -u origin master

# mirror to GitHub (the repo must already exist on GitHub, and your server's SSH
# key must have access)
$ ssh -p 2222 git@some.host mirror my-repo git@github.com/me/my-repo.git
```

## Customization

You can change the server directory in which the Git repos are stored by setting the `GIT_REPO_DIR` environment variable in the Docker container.

Additional customization is possible by building your own Docker image based on git-personal.

## Docker Compose

Check out the [example Compose file](./examples/docker-compose.yaml).

## Tips

### Making SSH Easier

If your git-personal server is available over a port other than SSH's standard 22, you can eliminate the need to specify the port by adding the following to the end of your SSH config:

```
Host some.host # the hostname you use to access git-personal
    Port 2222  # the port exposed for git-personal
```

Notably, this allows you to access the server without the `-p` flag (e.g. `ssh git@some.host` instead of `ssh -p 2222 git@some.host`) and provide scp-style URLs to Git (e.g. `git clone git@some.host:my-repo.git` instead of `git clone ssh://git@some.host:2222/~git/my-repo.git`).

You can even take this one step further and eliminate the need to specify the `git` user by adding `User git` to your SSH config as well.

### Organizing Repos

You can organize your repos in subdirectories by specifying a path as the repo name:

```
$ ssh -p 2222 git@some.host
git> mkrepo cool-project
git> mkrepo code/awesome-sauce
git> mkrepo code/web/my-site
git> lsrepos
cool-project
code/awesome-sauce
code/web/my-site
git> exit
$ git clone ssh://git@some.host:2222/~git/cool-project.git
$ git clone ssh://git@some.host:2222/~git/code/awesome-sauce.git
$ git clone ssh://git@some.host:2222/~git/code/web/my-site.git
```
