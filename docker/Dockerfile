FROM alpine:3
LABEL maintainer="dev@jasoncarloscox.com"
EXPOSE 22

# install needed packages
RUN apk add --no-cache coreutils findutils git openssh

# set up ssh
COPY ssh_config sshd_config /etc/ssh/

# copy in helper scripts
COPY scripts/* /usr/bin/

# set up git user
RUN which git-shell >> /etc/shells \
    && adduser --disabled-password --shell $(which git-shell) git \
    && echo git:git | chpasswd

# set up needed directories
RUN mkdir /home/git/.ssh /etc/git \
    && chown git:git /home/git/.ssh

# configure git
COPY git-shell-commands /etc/git/shell-commands
COPY hooks /etc/git/hooks
RUN git config --system core.hooksPath /etc/git/hooks

# set up git directory
ENV GIT_REPO_DIR=/home/git
RUN mkdir -p "$GIT_REPO_DIR" \
    && chown git:git "$GIT_REPO_DIR"

# declare volumes
VOLUME /etc/ssh/host_keys \
    /home/git/.ssh \
    $GIT_REPO_DIR

# run entrypoint script
COPY entrypoint.sh /
CMD ["/entrypoint.sh"]
