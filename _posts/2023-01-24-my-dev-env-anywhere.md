---
title: "My Dev Environment Anywhere"
---
So I recently bought a steam deck. If you don't know what a steam deck is go
check it out at [steamdeck.com](https://steamdeck.com)! Ultimately its a device
built for playing PC games but portable. Its got an AMD x86 APU with 16GB of
ram, which paired with its 1280x800 display lets it run a ton of games at very
decent graphics settings. Its a fantastic gaming device and I've had a ton of
fun recently working through my steam library. But really gaming is not the
thing that gets me the most excited about the steam deck. Under the hood the
steam deck runs Arch Linux and runs on a read-only root file system. This forces
a new paradigm for installing and running applications. The best solutions, in
my opinion, rely on running apps in containers, like flatpak. But I spend a
large amount of my time in the command line and installing command line tools
via flatpak is clunky. But wouldn't it be cool if I could run my entire
development environment inside a container...

## Distrobox to the rescue!
[Distrobox](https://distrobox.privatedns.org/) is a project that makes it simple to run and shell into a container
and share much of the host system into the container. This allows you to have a
read-write system that can interact much like the host its running on. You can
choose almost any base container to run but also you can create your own. Here's
my `Containerfile` at the time of writing this article
```
FROM registry.fedoraproject.org/fedora-toolbox:37

RUN dnf update -y

RUN dnf install -y \
  autojump-zsh \
  bat \
  bc \
  curl \
  diffutils \
  entr \
  exa \
  findutils \
  fzf \
  gh \
  git \
  httpie \
  jq \
  just \
  less \
  litecli \
  make \
  mycli \
  ncdu \
  ncurses \
  neofetch \
  neovim \
  openssl \
  passwd \
  pgcli \
  pinentry \
  prettyping \
  procps-ng \
  python-pip \
  rcm \
  ripgrep \
  shadow-utils \
  tig \
  tldr \
  tmux \
  util-linux \
  util-linux-user \
  vte-profile \
  wget \
  zsh

RUN dnf install -y \
  https://github.com/watchexec/watchexec/releases/download/v1.21.0/watchexec-1.21.0-x86_64-unknown-linux-gnu.rpm

RUN ln -s /usr/bin/distrobox-host-exec /usr/local/bin/podman
RUN ln -s /usr/bin/distrobox-host-exec /usr/local/bin/docker
RUN ln -s /usr/bin/distrobox-host-exec /usr/local/bin/distrobox
RUN ln -s /usr/bin/distrobox-host-exec /usr/local/bin/flatpak
RUN ln -s /usr/bin/distrobox-host-exec /usr/local/bin/xdg-open

RUN pip install neovim

# Install starship prompt
RUN wget -O /tmp/install_starship.sh https://starship.rs/install.sh
RUN sh /tmp/install_starship.sh --yes

# Install nvm
ENV NVM_DIR=/opt/nvm
RUN mkdir -p "${NVM_DIR}"
RUN wget -O /tmp/install_nvm.sh https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh
RUN bash /tmp/install_nvm.sh
RUN source "${NVM_DIR}/nvm.sh" && nvm install lts/*

# coc.vim language servers
RUN source "${NVM_DIR}/nvm.sh" && npm install -g \
  dockerfile-language-server-nodejs \
  bash-language-server

RUN chmod -R a+rw /opt/nvm

# Preinstall host-spawn
RUN wget -O /usr/bin/host-spawn "https://github.com/1player/host-spawn/releases/download/1.2.1/host-spawn-$(uname -m)"
RUN chmod +x /usr/bin/host-spawn

ENTRYPOINT ["/bin/zsh"]
```
There's a lot going on here but mostly I start with a fedora image, install a
bunch of tools that I enjoy, and add some symlinks to allow some commands to be
forwarded out of the container to the host.

I can run this container on any linux system by just installing distrobox and
podman/docker and running two commands. And when I want updates I just blow away
the container, pull the latest one and start it back up again. I can also run
all the tools I love on systems that may not be supported by the tools. This is
a super cool paradigm and I encourage everyone to go take a look!
