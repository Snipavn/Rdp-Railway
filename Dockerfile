FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cập nhật & cài gói cơ bản + LXQt + XRDP
RUN apt update && apt upgrade -y && \
    apt install -y lxqt xrdp sudo curl wget git xterm unzip dbus-x11 software-properties-common --no-install-recommends && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Tạo user
RUN useradd -m snipavn && echo 'snipavn:meobell' | chpasswd && adduser snipavn sudo

# Cài Google Chrome
RUN wget --no-check-certificate -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt install -y ./chrome.deb || apt --fix-broken install -y && rm -f chrome.deb

# Cài Discord
RUN wget --no-check-certificate -O discord.deb "https://discord.com/api/download?platform=linux&format=deb" && \
    apt install -y ./discord.deb || apt --fix-broken install -y && rm -f discord.deb

# Cài Fluent theme + icon + font giả Windows 11
RUN git clone https://github.com/vinceliuice/Fluent-gtk-theme /opt/fluent-theme && \
    /opt/fluent-theme/install.sh -d /usr/share/themes -t all && \
    git clone https://github.com/vinceliuice/Fluent-icon-theme /opt/fluent-icon && \
    /opt/fluent-icon/install.sh -d /usr/share/icons -a && \
    mkdir -p /usr/share/fonts/segoe && \
    wget --no-check-certificate -O /tmp/segoe.zip https://github.com/seogle/segoe-ui/raw/main/Segoe-UI-Windows-Font.zip && \
    unzip /tmp/segoe.zip -d /usr/share/fonts/segoe && \
    fc-cache -fv

# Cấu hình LXQt cho user
RUN mkdir -p /home/snipavn/.config/lxqt && \
    echo "[General]\ntheme=Fluent-dark\nicon_theme=Fluent-dark" > /home/snipavn/.config/lxqt/session.conf && \
    echo "startlxqt" > /home/snipavn/.xsession && \
    chown -R snipavn:snipavn /home/snipavn

# Fix lỗi xám XRDP
RUN echo '#!/bin/sh' > /etc/xrdp/startwm.sh && \
    echo 'export LANG=en_US.UTF-8' >> /etc/xrdp/startwm.sh && \
    echo 'export LC_ALL=en_US.UTF-8' >> /etc/xrdp/startwm.sh && \
    echo 'startlxqt' >> /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh

# Copy script giữ mạng Railway
RUN wget --no-check-certificate -O /alive.sh https://github.com/Snipavn/Rdp-Railway/raw/refs/heads/main/keepalive.sh && \
    chmod +x /alive.sh

# Mở port XRDP
EXPOSE 3389

# CMD khởi động dịch vụ
CMD mkdir -p /run/resolvconf && echo "nameserver 8.8.8.8" > /run/resolvconf/resolv.conf && \
    service dbus start && service xrdp start && bash /alive.sh
