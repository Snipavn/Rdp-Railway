FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y && \
    apt install -y lxqt xrdp sudo curl wget git xterm unzip dbus-x11 software-properties-common unzip --no-install-recommends && \
    apt clean && rm -rf /var/lib/apt/lists/*

RUN useradd -m snipavn && echo 'snipavn:meobell' | chpasswd && adduser snipavn sudo

RUN wget --no-check-certificate -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt install -y ./chrome.deb || apt --fix-broken install -y && rm chrome.deb

RUN wget --no-check-certificate -O discord.deb "https://discord.com/api/download?platform=linux&format=deb" && \
    apt install -y ./discord.deb || apt --fix-broken install -y && rm discord.deb

RUN git clone https://github.com/vinceliuice/Fluent-gtk-theme /opt/fluent-theme && \
    /opt/fluent-theme/install.sh -d /usr/share/themes -t all && \
    git clone https://github.com/vinceliuice/Fluent-icon-theme /opt/fluent-icon && \
    /opt/fluent-icon/install.sh -d /usr/share/icons -a

RUN git clone https://github.com/mrbvrz/segoe-ui-linux /opt/segoe-ui-linux && \
    chmod +x /opt/segoe-ui-linux/install.sh && \
    /opt/segoe-ui-linux/install.sh && \
    fc-cache -fv

RUN mkdir -p /home/snipavn/.config/lxqt && \
    echo "[General]\ntheme=Fluent-dark\nicon_theme=Fluent-dark" > /home/snipavn/.config/lxqt/session.conf && \
    echo "startlxqt" > /home/snipavn/.xsession && \
    chown -R snipavn:snipavn /home/snipavn

RUN echo '#!/bin/sh' > /etc/xrdp/startwm.sh && \
    echo 'export LANG=en_US.UTF-8' >> /etc/xrdp/startwm.sh && \
    echo 'export LC_ALL=en_US.UTF-8' >> /etc/xrdp/startwm.sh && \
    echo 'startlxqt' >> /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh
RUN echo "lxsession -s LXDE -e LXDE" >> /etc/xrdp/startwm.sh
RUN wget --no-check-certificate -O /alive.sh https://github.com/Snipavn/Rdp-Railway/raw/refs/heads/main/keepalive.sh && \
    chmod +x /alive.sh

EXPOSE 3389

CMD mkdir -p /run/resolvconf && echo "nameserver 8.8.8.8" > /run/resolvconf/resolv.conf && \
    service dbus start && service xrdp restart && bash /alive.sh
