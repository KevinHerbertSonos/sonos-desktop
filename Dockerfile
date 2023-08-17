FROM ubuntu:bionic

ARG UID=1000
ARG GID=1000
ARG UNAME
# in case DNS isn't working via VPN packages.sonos.com = packages.sonos.com
# ARG REPO=packages.sonos.com

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ENV container docker
ENV DEBIAN_FRONTEND=noninteractive
ENV init /lib/systemd/systemd
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
USER root

EXPOSE 51222/udp

#add your user with same UID GID
#and add 32 bit intel packages
#and install base packages

RUN groupadd -g $GID $UNAME && \
    useradd -m -u $UID -g $GID -s /bin/bash $UNAME && \
    echo "kph:changeme" | chpasswd && \
    dpkg --add-architecture i386 && \
    yes | /usr/local/sbin/unminimize

RUN apt-get update && apt-get install -y \
        apache2 \
	apache2-utils \
        aptitude \
        apt-utils \
        bear \
        emacs \
        gnupg \
        gtk+3.0 \
        host \
        iputils-ping \
        liblz4-tool \
        libtinfo-dev \
        locales locales-all \
        mosh \
        net-tools \
        openconnect \
        openssh-server \
        python-rbtools \
        quilt \
        rsync \
        screen \
        software-properties-common \
        sudo \
        systemd \
        tk \
        wget && \
        xxd

RUN sed -i "s/^.*X11UseLocalhost.*$/X11UseLocalhost no/" /etc/ssh/sshd_config && \
    a2enmod userdir && \
    systemctl set-default multi-user.target && \
    adduser $UNAME sudo

RUN wget --no-check-certificate -nv -O - -o /proc/self/fd/2 https://packages.sonos.com/ubuntu/keys/8E2CB5FF.gpg | apt-key add - && \
    wget -nv -O - -o /dev/null https://apt.llvm.org/llvm-snapshot.gpg.key| apt-key add - && \
    add-apt-repository 'deb http://packages.sonos.com/ubuntu bionic main' && \
    add-apt-repository 'deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-10 main'

RUN apt-get update && apt-get install -y \
    clang-format-10 \
    sonos-desktop

RUN sed -i "s/^.*Port 22*$/Port 2222/" /etc/ssh/sshd_config

ENTRYPOINT ["/lib/systemd/systemd"]
