FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cập nhật & cài desktop + browser + wine
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
    xrdp lxde-core lxterminal xterm gnome-terminal \
    dbus-x11 x11-xserver-utils sudo net-tools wget curl gnupg \
    software-properties-common firefox chromium-browser \
    wine64 wine32 winbind cabextract unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Cài Discord
RUN wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb" && \
    apt-get install -y /tmp/discord.deb || apt-get -f install -y && \
    rm /tmp/discord.deb

# Tạo user ubuntu
RUN useradd -m -s /bin/bash snipavn && \
    echo 'snipavn:ubuntu' | chpasswd && \
    adduser snipavn sudo

# Tạo session LXDE khi login XRDP
RUN echo "lxsession -s LXDE -e LXDE" > /home/ubuntu/.xsession && \
    chown ubuntu:ubuntu /home/ubuntu/.xsession

# Cấu hình XRDP dùng cổng cố định
RUN sed -i 's/port=ask-1/port=3389/g' /etc/xrdp/xrdp.ini && \
    echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Cài Roblox bằng Wine
USER ubuntu
RUN wineboot --init && \
    mkdir -p /home/ubuntu/.roblox && \
    cd /home/ubuntu/.roblox && \
    wget -O RobloxPlayerLauncher.exe "https://setup.rbxcdn.com/RobloxPlayerLauncher.exe" || true

# Khởi động lại root để XRDP
USER root

# DNS (Google + Cloudflare)
RUN echo "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf

# Expose cổng RDP
EXPOSE 3389

# Start XRDP
CMD sh -c 'echo "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf && /usr/sbin/xrdp -n'
