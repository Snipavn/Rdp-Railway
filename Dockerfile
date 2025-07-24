FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cập nhật và cài đặt gói cần thiết
RUN apt-get update && apt-get install -y \
    xrdp lxde-core lxterminal xterm gnome-terminal \
    dbus-x11 x11-xserver-utils sudo net-tools wget curl gnupg \
    software-properties-common firefox chromium-browser \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Cài Discord (.deb)
RUN wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb" && \
    apt-get install -y /tmp/discord.deb || apt-get -f install -y && \
    rm /tmp/discord.deb

# Tạo user ubuntu + home + sudo
RUN useradd -m -s /bin/bash ubuntu && \
    echo 'ubuntu:ubuntu' | chpasswd && \
    adduser ubuntu sudo && \
    mkdir -p /home/ubuntu && \
    echo "lxsession -s LXDE -e LXDE" > /home/ubuntu/.xsession && \
    chown -R ubuntu:ubuntu /home/ubuntu

# Cấu hình XRDP
RUN sed -i 's/port=ask-1/port=3389/g' /etc/xrdp/xrdp.ini && \
    echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Thiết lập DNS tĩnh
RUN echo "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf

# Mở cổng Remote Desktop
EXPOSE 3389

# Chạy XRDP
CMD sh -c 'echo "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf && /usr/sbin/xrdp -n'
