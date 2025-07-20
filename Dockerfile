FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /root

RUN apt update && apt install -y \
    xfce4 xfce4-goodies xrdp wget curl sudo gnupg2 \
    software-properties-common apt-transport-https ca-certificates \
    xfce4-terminal xterm gnome-terminal pulseaudio

RUN useradd -m snipavn && echo "snipavn:meobell" | chpasswd && adduser snipavn sudo

RUN echo xfce4-session > /home/snipavn/.xsession && \
    chown snipavn:snipavn /home/snipavn/.xsession && \
    touch /home/snipavn/.Xauthority && \
    chown snipavn:snipavn /home/snipavn/.Xauthority && \
    adduser xrdp ssl-cert && \
    update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/xfce4-terminal 50

RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
    > /etc/apt/sources.list.d/google-chrome.list && \
    apt update && apt install -y google-chrome-stable

RUN wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb" && \
    apt install -y ./discord.deb || true && \
    apt --fix-broken install -y && \
    rm discord.deb

EXPOSE 3389

CMD service xrdp start && tail -f /dev/null
