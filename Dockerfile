FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cập nhật & cài gói cần thiết
RUN apt update && apt upgrade -y && \
    apt install -y xrdp xfce4 xfce4-goodies sudo curl wget dbus-x11 xterm software-properties-common gnupg2

# Tạo user
RUN useradd -m snipavn && echo 'snipavn:meobell' | chpasswd && adduser snipavn sudo

# Cài Google Chrome (tránh bị lỗi GPG key)
RUN wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt install -y ./chrome.deb || apt --fix-broken install -y && \
    rm chrome.deb

# Cài Discord AppImage qua link mirror không bị chặn
RUN mkdir -p /home/snipavn/Apps && \
    wget -O /home/snipavn/Apps/Discord.AppImage "https://github.com/Snipavn/Discord-AppImage/releases/download/0.0.102/Discord.AppImage" && \
    chmod +x /home/snipavn/Apps/Discord.AppImage && \
    chown -R snipavn:snipavn /home/snipavn/Apps

# Cấu hình XFCE cho xrdp
RUN echo "startxfce4" > /home/snipavn/.xsession && \
    chown snipavn:snipavn /home/snipavn/.xsession

# Ghi lại DNS để tránh mất mạng trong Railway
RUN rm -f /etc/resolv.conf && \
    echo "nameserver 1.1.1.1" > /etc/resolv.conf

# Copy script giữ mạng Railway
RUN wget -O keep.sh https://github.com/Snipavn/Rdp-Railway/raw/refs/heads/main/keepalive.sh
# Mở port XRDP
EXPOSE 3389

# CMD khởi động XRDP và keepalive
CMD service dbus start && service xrdp start && sh keep.sh
