#!/bin/bash

export DEBIAN_FRONTEND='noninteractive'

packages=(
  locales-all
  software-properties-common
  pv
  sshfs
  dialog
  libterm-readline-gnu-perl
  libterm-readline-perl-perl
  iptables
  python
  ca-certificates
  openssl
  curl
  wget
  nano
  tcpdump
  lsof
  strace
  nmap
  tmux
  git
  rake
  openssh-server
)

env_fix()
{
  if [ `id -u` == 0 ]; then
    export HOME='/root'
  else
    printf "Must be root\n"
    exit 1
  fi
}

install_packages()
{
  (apt-get update && \
  apt-get -y --no-install-recommends install ${packages[@]}) || exit 1
}

set_password()
{
  if [ `id -u` == 0 ]; then
    (echo "ubuntu:ubuntu" | chpasswd) || exit 1
  else
    printf "Must be root\n"
    exit 1
  fi
}

env_fix
install_packages
set_password
