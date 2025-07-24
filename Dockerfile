FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cài mọi thứ cần thiết
RUN apt-get update && apt-get install -y \
    xrdp xfce4 xfce4-terminal dbus-x11 x11-xserver-utils \
    pulseaudio pulseaudio-utils git make autoconf libtool \
    firefox chromium-browser \
    wget curl gnupg sudo net-tools software-properties-common \
    init-system-helpers pkg-config \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Cài Discord
RUN wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb" && \
    apt-get install -y /tmp/discord.deb || apt-get -f install -y && \
    rm /tmp/discord.deb

# Tạo user ubuntu
RUN useradd -m -s /bin/bash ubuntu && \
    echo 'ubuntu:ubuntu' | chpasswd && \
    adduser ubuntu sudo && \
    echo "startxfce4" > /home/ubuntu/.xsession && \
    chown -R ubuntu:ubuntu /home/ubuntu

# ✅ Fix màn hình xám
RUN sed -i '/fi/a echo "startxfce4" > ~/.xsession' /etc/xrdp/startwm.sh

# ✅ Sửa port XRDP
RUN sed -i 's/port=ask-1/port=3389/' /etc/xrdp/xrdp.ini

# ✅ Không yêu cầu sudo password
RUN echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


# ✅ Script restart pulseaudio
RUN echo '#!/bin/bash\nwhile true; do pulseaudio --start; sleep 5; done' > /usr/local/bin/pulseaudio-loop.sh && \
    chmod +x /usr/local/bin/pulseaudio-loop.sh

# ✅ Script restart xrdp bằng lệnh "service"
RUN echo '#!/bin/bash\nwhile true; do service xrdp restart; sleep 5; done' > /usr/local/bin/xrdp-loop.sh && \
    chmod +x /usr/local/bin/xrdp-loop.sh

# .xsession cho ubuntu
RUN echo '#!/bin/bash\nstartxfce4' > /home/ubuntu/.xsession && \
    chmod +x /home/ubuntu/.xsession && chown ubuntu:ubuntu /home/ubuntu/.xsession

# Mở port XRDP
EXPOSE 3389

# ✅ CMD: Fix DNS + start pulseaudio + xrdp (auto-restart)
CMD sh -c 'echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf && \
    /usr/local/bin/pulseaudio-loop.sh & \
    /usr/local/bin/xrdp-loop.sh'
