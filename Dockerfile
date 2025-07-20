FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cập nhật & cài gói cần thiết
RUN apt update && apt upgrade -y && \
    apt install -y xrdp xfce4 xfce4-goodies sudo curl wget dbus-x11 xterm software-properties-common gnupg2

# Tạo user
RUN useradd -m snipavn && echo 'snipavn:meobell' | chpasswd && adduser snipavn sudo

# Cài Google Chrome
RUN wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt install -y ./chrome.deb || apt --fix-broken install -y && \
    rm -f chrome.deb

# Cài Discord bản chính chủ (.deb)
RUN wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb" && \
    apt install -y ./discord.deb || apt --fix-broken install -y && \
    rm -f discord.deb

# Cấu hình XFCE cho xrdp
RUN echo "startxfce4" > /home/snipavn/.xsession && \
    chown snipavn:snipavn /home/snipavn/.xsession

# Ghi lại DNS để tránh mất mạng trong Railway
RUN rm -f /etc/resolv.conf && \
    echo "nameserver 1.1.1.1" > /etc/resolv.conf

# Copy script giữ mạng Railway
RUN wget -O alive.sh https://github.com/Snipavn/Rdp-Railway/raw/refs/heads/main/keepalive.sh

# Mở port XRDP
EXPOSE 3389

# CMD khởi động XRDP và keepalive
CMD service dbus start && service xrdp start && bash alive.sh
