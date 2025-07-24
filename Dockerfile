FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cập nhật & cài XFCE4 + XRDP + trình duyệt + terminal
RUN apt-get update && apt-get install -y \
    xrdp xfce4 xfce4-terminal dbus-x11 x11-xserver-utils \
    firefox chromium-browser \
    wget curl gnupg sudo net-tools software-properties-common \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Cài Discord (.deb)
RUN wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb" && \
    apt-get install -y /tmp/discord.deb || apt-get -f install -y && \
    rm /tmp/discord.deb

# Tạo user ubuntu + thiết lập home và quyền sudo
RUN useradd -m -s /bin/bash ubuntu && \
    echo 'ubuntu:ubuntu' | chpasswd && \
    adduser ubuntu sudo && \
    mkdir -p /home/ubuntu && \
    echo "startxfce4" > /home/ubuntu/.xsession && \
    chown -R ubuntu:ubuntu /home/ubuntu

# Sửa cấu hình XRDP để dùng cổng cố định
RUN sed -i 's/port=ask-1/port=3389/g' /etc/xrdp/xrdp.ini && \
    echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Mở cổng RDP
EXPOSE 3389

# Sửa DNS runtime & khởi chạy XRDP
CMD sh -c 'echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /tmp/resolv.conf && \
    cp /tmp/resolv.conf /etc/resolv.conf && \
    /usr/sbin/xrdp -n'
