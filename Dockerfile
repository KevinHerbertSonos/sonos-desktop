FROM ubuntu:bionic

ARG UID=1000
ARG GID=1000
ARG UNAME

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ENV container docker
ENV DEBIAN_FRONTEND=noninteractive
ENV init /lib/systemd/systemd
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
USER root

#and add 32 bit intel packages
#and install base packages
RUN    dpkg --add-architecture i386 && \
    yes | /usr/local/sbin/unminimize

# Install the packages from Ubuntu
RUN apt-get update && apt-get install -y \
        aptitude \
        apt-utils \
        bear \
        emacs \
        gnupg \
        gtk+3.0 \
        host \
        iputils-ping \
        libpam-ssh-agent-auth \
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
        wget \
        xxd

# Set up Sonos packages
RUN wget --no-check-certificate -nv -O - -o /proc/self/fd/2 https://packages.sonos.com/ubuntu/keys/8E2CB5FF.gpg | \
        apt-key add - && \
    wget -nv -O - -o /proc/self/fd/2 https://apt.llvm.org/llvm-snapshot.gpg.key| \
        apt-key add - && \
    add-apt-repository 'deb http://packages.sonos.com/ubuntu bionic main' && \
    add-apt-repository 'deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-10 main' && \
    apt-get update

RUN apt-get install -y \
        clang-format-10 \
        sonos-desktop

# Set up sudo via ssh agent
COPY pam-sudo /etc/pam.d/sudo

RUN sed -i -e "s/^.*X11UseLocalhost.*$/X11UseLocalhost no/" \
           -e "s/^.*Port 22*$/Port 2222/" /etc/ssh/sshd_config && \
    echo "Defaults env_keep += SSH_AUTH_SOCK" >> /etc/sudoers && \
    systemctl set-default multi-user.target && \
    groupadd -g $GID $UNAME && \
    useradd -m -u $UID -g $GID -s /bin/bash $UNAME && \
    adduser $UNAME sudo

ENTRYPOINT ["/lib/systemd/systemd"]
