FROM debian

# Install necessary packages and set up environment
RUN dpkg --add-architecture i386 \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt install -y \
        wine qemu-kvm zenity xz-utils dbus-x11 curl firefox-esr \
        gnome-system-monitor mate-system-monitor git xfce4 \
        xfce4-terminal tightvncserver wget sudo

# Install Docker and docker-compose
RUN apt-get update \
    && apt-get install -y apt-transport-https ca-certificates curl software-properties-common \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce docker-ce-cli containerd.io \
    && curl -sSL https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Download and set up noVNC
RUN wget https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.tar.gz \
    && tar -xvf v1.2.0.tar.gz \
    && mkdir $HOME/.vnc \
    && echo 'Sophia' | vncpasswd -f > $HOME/.vnc/passwd \
    && echo '/bin/env MOZ_FAKE_NO_SANDBOX=1 dbus-launch xfce4-session' > $HOME/.vnc/xstartup \
    && chmod 600 $HOME/.vnc/passwd \
    && chmod 755 $HOME/.vnc/xstartup

# Create and set up launch script
RUN echo '#!/bin/bash' > /Sophia.sh \
    && echo 'whoami' >> /Sophia.sh \
    && echo 'cd' >> /Sophia.sh \
    && echo "su -l -c 'vncserver :2000 -geometry 1360x768'" >> /Sophia.sh \
    && echo 'cd /noVNC-1.2.0' >> /Sophia.sh \
    && echo './utils/launch.sh --vnc localhost:7900 --listen 8900' >> /Sophia.sh \
    && chmod +x /Sophia.sh

EXPOSE 8900

CMD ["/Sophia.sh"]
