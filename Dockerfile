FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cập nhật và cài các gói cần thiết
RUN apt update && apt upgrade -y && \
    apt install -y xrdp lxde-core lxde-common lxterminal sudo wget curl dbus-x11 xterm --no-install-recommends && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Tạo user mới
RUN useradd -m snipavn && echo 'snipavn:meobell' | chpasswd && adduser snipavn sudo

# Cài Google Chrome
RUN wget --no-check-certificate -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt update && apt install -y ./chrome.deb || apt --fix-broken install -y && rm -f chrome.deb

# Cài Discord
RUN wget --no-check-certificate -O discord.deb "https://discord.com/api/download?platform=linux&format=deb" && \
    apt install -y ./discord.deb || apt --fix-broken install -y && rm -f discord.deb

# Cấu hình XRDP chạy LXDE đúng cách để tránh lỗi màn hình xám
RUN echo "lxsession -s LXDE -e LXDE" > /home/snipavn/.xsession && \
    chown snipavn:snipavn /home/snipavn/.xsession && \
    sed -i 's|test -x /etc/X11/Xsession && exec /etc/X11/Xsession|exec /bin/bash --login -c /home/snipavn/.xsession|' /etc/xrdp/startwm.sh

# Tải script giữ mạng Railway
RUN wget --no-check-certificate -O /alive.sh https://github.com/Snipavn/Rdp-Railway/raw/refs/heads/main/keepalive.sh && \
    chmod +x /alive.sh

# Mở cổng XRDP
EXPOSE 3389

# CMD khởi động các dịch vụ
CMD mkdir -p /run/resolvconf && echo "nameserver 8.8.8.8" > /run/resolvconf/resolv.conf && \
    service dbus start && service xrdp start && bash /alive.sh
