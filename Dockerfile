FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cập nhật & cài gói cần thiết
RUN apt update && apt upgrade -y && \
    apt install -y xrdp xfce4 xfce4-goodies wget sudo curl dbus-x11 xterm software-properties-common gnupg2

# Tạo user
RUN useradd -m snipavn && echo 'snipavn:meobell' | chpasswd && adduser snipavn sudo

# Cài Google Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt update && apt install -y google-chrome-stable

# Cài Discord (AppImage từ link chính chủ + fix 403 bằng User-Agent)
RUN mkdir -p /home/snipavn/Apps && \
    wget --header="User-Agent: Mozilla/5.0" -O /home/snipavn/Apps/Discord.AppImage "https://discord.com/api/download?platform=linux&format=AppImage" && \
    chmod +x /home/snipavn/Apps/Discord.AppImage && \
    chown -R snipavn:snipavn /home/snipavn/Apps

# Cấu hình XFCE cho xrdp
RUN echo "startxfce4" > /home/snipavn/.xsession && \
    chown snipavn:snipavn /home/snipavn/.xsession

# Copy script keepalive
RUN wget -O keep.sh https://github.com/Snipavn/Rdp-Railway/raw/refs/heads/main/keepalive.sh

# Mở port 3389
EXPOSE 3389

# CMD khởi động dịch vụ + keepalive
CMD service dbus start && service xrdp start && bash keep.sh
