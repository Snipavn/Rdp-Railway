FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /root

# Cập nhật và cài môi trường giao diện + xrdp + Chrome
RUN apt update && apt install -y \
    xfce4 xfce4-goodies xrdp wget curl sudo gnupg2 \
    python3 python3-pip \
    && apt clean

# Cài Chrome nếu chưa có trong repo chính
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list' && \
    apt update && apt install -y google-chrome-stable
RUN useradd -m rdpuser && echo "rdpuser:123456" | chpasswd && adduser rdpuser sudo

# Cấu hình xrdp
RUN echo xfce4-session >~/.xsession && \
    sed -i 's/port=3389/port=3389/' /etc/xrdp/xrdp.ini && \
    adduser xrdp ssl-cert

# Cài Flask để giữ container sống nếu muốn Railway không tắt
RUN pip install flask
RUN wget -O server.py https://github.com/Snipavn/Rdp-Railway/raw/refs/heads/main/service.py

# Mở cổng RDP
EXPOSE 3389 8080

# Chạy dịch vụ RDP + server giữ container sống
CMD bash -c "\
    service xrdp start && \
    python3 /root/server.py"
