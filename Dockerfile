FROM ubuntu:bionic

ARG UID=1000
ARG GID=1000
ARG UNAME
ENV container docker
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
USER root

#add your user with same UID GID
RUN groupadd -g $GID $UNAME
RUN useradd -m -u $UID -g $GID -s /bin/bash $UNAME
RUN echo "kph:changeme" | chpasswd
#allow i386 packages
RUN dpkg --add-architecture i386

RUN echo 'APT::Install-Recommends "0"; \n\
APT::Get::Assume-Yes "true"; \n\
APT::Get::force-yes "true"; \n\
APT::Install-Suggests "0";' > /etc/apt/apt.conf.d/01buildconfig
RUN mkdir -p  /etc/apt/sources.d/
RUN echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic main restricted universe multiverse \n\
deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-updates main restricted universe multiverse \n\
deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-backports main restricted universe multiverse \n\
deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-security main restricted universe multiverse" > /etc/apt/sources.d/ubuntu-mirrors.list
RUN apt-get update && apt-get install systemd # && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN cd /lib/systemd/system/sysinit.target.wants/; ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1 \
#rm -f /lib/systemd/system/multi-user.target.wants/*;\
#rm -f /etc/systemd/system/*.wants/*;\
#rm -f /lib/systemd/system/local-fs.target.wants/*; \
#rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
#rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
#rm -f /lib/systemd/system/basic.target.wants/*;\
#rm -f /lib/systemd/system/anaconda.target.wants/*; \
#rm -f /lib/systemd/system/plymouth*; \
#rm -f /lib/systemd/system/systemd-update-utmp*;

RUN systemctl set-default multi-user.target

RUN apt-get install openssh-server
ENV init /lib/systemd/systemd
VOLUME [ "/sys/fs/cgroup" ]
# docker run -it --privileged=true -v /sys/fs/cgroup:/sys/fs/cgroup:ro 444c127c995b /lib/systemd/systemd systemd.unit=emergency.service




ENTRYPOINT ["/lib/systemd/systemd"]