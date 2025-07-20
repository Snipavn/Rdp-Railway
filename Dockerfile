FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cập nhật và cài đầy đủ xrdp + LXDE
RUN apt update && apt upgrade -y && \
    apt install -y xrdp lxde sudo wget curl dbus-x11 xterm --no-install-recommends && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Tạo user
RUN useradd -m snipavn && echo 'snipavn:meobell' | chpasswd && adduser snipavn sudo

# Cài Chrome
RUN wget --no-check-certificate -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt install -y ./chrome.deb || apt --fix-broken install -y && rm -f chrome.deb

# Cài Discord
RUN wget --no-check-certificate -O discord.deb "https://discord.com/api/download?platform=linux&format=deb" && \
    apt install -y ./discord.deb || apt --fix-broken install -y && rm -f discord.deb

# Cấu hình startwm.sh để ép xrdp dùng đúng LXDE
RUN bash -c 'cat > /etc/xrdp/startwm.sh <<EOF
#!/bin/sh
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export DISPLAY=:0
export XDG_SESSION_TYPE=x11
export DESKTOP_SESSION=lxde
export XDG_CURRENT_DESKTOP=lxde
exec startlxde
EOF' && chmod +x /etc/xrdp/startwm.sh

# Copy script giữ mạng Railway
RUN wget --no-check-certificate -O /alive.sh https://github.com/Snipavn/Rdp-Railway/raw/refs/heads/main/keepalive.sh && \
    chmod +x /alive.sh

# Mở port XRDP
EXPOSE 3389

# CMD
CMD mkdir -p /run/resolvconf && echo "nameserver 8.8.8.8" > /run/resolvconf/resolv.conf && \
    service dbus start && service xrdp start && bash /alive.sh
