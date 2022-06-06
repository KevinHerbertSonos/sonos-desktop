FROM ubuntu:bionic

ARG UID=1000
ARG GID=1000
ARG UNAME
# in case DNS isn't working via VPN packages.sonos.com = packages.sonos.com
ARG REPO=packages.sonos.com

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ENV container docker
ENV DEBIAN_FRONTEND=noninteractive
ENV init /lib/systemd/systemd
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
USER root

#add your user with same UID GID
#and add 32 bit intel packages
#and install base packages

RUN groupadd -g $GID $UNAME && \
    useradd -m -u $UID -g $GID -s /bin/bash $UNAME && \
    echo "kph:changeme" | chpasswd && \
    dpkg --add-architecture i386 && \
    yes | /usr/local/sbin/unminimize && \
    apt-get update && apt-get install -y \
        apt-utils \
        gnupg \
        locales locales-all \
        software-properties-common \
        wget

RUN wget --no-check-certificate -nv -O - -o /dev/null https://packages.sonos.com/ubuntu/keys/8E2CB5FF.gpg | apt-key add - && \
    wget -nv -O - -o /dev/null https://apt.llvm.org/llvm-snapshot.gpg.key| apt-key add - && \
    add-apt-repository 'deb http://packages.sonos.com/ubuntu bionic main' && \
    add-apt-repository 'deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-10 main' && \
    apt-get update && apt-get install -y \
    aptitude \
    bear \
    clang-format-10 \
    emacs \
    host \
    iputils-ping \
    liblz4-tool \
    libtinfo-dev \
    net-tools \
    openconnect \
    openssh-server \
    python-rbtools \
    quilt \
    rsync \
    sonos-desktop \
    sudo \
    systemd \
    xxd

RUN systemctl set-default multi-user.target && \
    adduser $UNAME sudo

ENTRYPOINT ["/lib/systemd/systemd"]
