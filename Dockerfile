FROM ubuntu:bionic

ARG UID=1000
ARG GID=1000
ARG UNAME
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
RUN groupadd -g $GID $UNAME
RUN useradd -m -u $UID -g $GID -s /bin/bash $UNAME
RUN echo "kph:changeme" | chpasswd
#allow i386 packages
RUN dpkg --add-architecture i386

#base packages
RUN apt-get update && apt-get install -y \
        apt-utils \
        gnupg \
        locales locales-all \
        software-properties-common \
        wget

RUN apt-get install -y host && host packages.sonos.com

RUN wget -qO - https://packages.sonos.com/ubuntu/keys/8E2CB5FF.gpg | apt-key add -
RUN wget -qO - https://apt.llvm.org/llvm-snapshot.gpg.key| apt-key add -
RUN add-apt-repository 'deb http://packages.sonos.com/ubuntu bionic main'
RUN add-apt-repository 'deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-10 main'
RUN apt-get update

RUN apt-get install -y \
    bear \
    clang-format-10 \
    liblz4-tool \
    libtinfo-dev \
    openssh-server \
    python-rbtools \
    quilt \
    rsync \
    sonos-dev \
    sudo \
    systemd \
    xxd

RUN systemctl set-default multi-user.target

VOLUME [ "/sys/fs/cgroup" ]

ENTRYPOINT ["/lib/systemd/systemd"]
