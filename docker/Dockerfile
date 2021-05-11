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

USER git
WORKDIR /home/git

RUN mkdir .ssh

COPY --chown=git:git git-shell-commands git-shell-commands

COPY --chown=git:git hooks .githooks
RUN git config --global core.hooksPath ~/.githooks

USER root
WORKDIR /

# set up git directory
ENV GIT_REPO_DIR=/home/git/repos
RUN mkdir -p "$GIT_REPO_DIR" \
    && chown git:git "$GIT_REPO_DIR"

# declare volumes
VOLUME /etc/ssh/host_keys \
    /home/git/.ssh \
    $GIT_REPO_DIR

# run entrypoint script
COPY entrypoint.sh /
CMD ["/entrypoint.sh"]
