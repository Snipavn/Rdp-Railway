FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Update & cài cơ bản
RUN apt update && apt install -y \
    xfce4 xfce4-goodies xrdp curl sudo dbus-x11 \
    wget libasound2 libgconf-2-4 libnss3 libxss1 libxtst6 \
    libatk1.0-0 libgtk-3-0 libnotify4 libx11-xcb1 x11-xserver-utils \
    fonts-dejavu-core unzip

# Tạo user snipavn
RUN useradd -m -s /bin/bash snipavn && echo "snipavn:meobell" | chpasswd && adduser snipavn sudo

# Cấu hình Xrdp + session
RUN echo xfce4-session > /home/snipavn/.xsession && \
    chown snipavn:snipavn /home/snipavn/.xsession && \
    touch /home/snipavn/.Xauthority && \
    chown snipavn:snipavn /home/snipavn/.Xauthority && \
    adduser xrdp ssl-cert

# Fix lỗi terminal chưa được register
RUN ln -sf /usr/bin/xfce4-terminal /usr/bin/x-terminal-emulator

# Cài Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt install -y ./google-chrome-stable_current_amd64.deb || apt --fix-broken install -y && \
    rm google-chrome-stable_current_amd64.deb

# Cài Discord AppImage
RUN mkdir -p /home/snipavn/Apps && \
    wget -O /home/snipavn/Apps/Discord.AppImage https://discord.com/api/download?platform=linux&format=AppImage && \
    chmod +x /home/snipavn/Apps/Discord.AppImage && \
    chown -R snipavn:snipavn /home/snipavn/Apps

# Ghi đè DNS để tránh mất mạng
RUN rm -f /etc/resolv.conf && echo "nameserver 1.1.1.1" > /etc/resolv.conf

# Tạo script giữ mạng Railway
RUN wget -O keepalive.sh https://github.com/Snipavn/Rdp-Railway/raw/refs/heads/main/keepalive.sh

EXPOSE 3389

CMD service dbus start && service xrdp start && sh keepalive.sh
