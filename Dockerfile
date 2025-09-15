FROM ubuntu:24.04

# Cài SSH + Xfce4 + TigerVNC
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      openssh-server sudo locales nano curl \
      xfce4 xfce4-goodies dbus-x11 xorg \
      tigervnc-standalone-server tigervnc-common && \
    rm -rf /var/lib/apt/lists/* && \
    locale-gen en_US.UTF-8

# Tạo user dev
RUN useradd -m -s /bin/bash dev && echo "dev:dev" | chpasswd && adduser dev sudo

# Tạo thư mục SSH
RUN mkdir /var/run/sshd

# Thiết lập VNC cho user dev
USER dev
RUN mkdir -p /home/dev/.vnc && \
    echo "dev" | vncpasswd -f > /home/dev/.vnc/passwd && \
    chmod 600 /home/dev/.vnc/passwd && \
    echo '#!/bin/sh\n' \
         'unset SESSION_MANAGER\n' \
         'unset DBUS_SESSION_BUS_ADDRESS\n' \
         'export XDG_RUNTIME_DIR=/tmp/runtime-$USER\n' \
         'mkdir -p "$XDG_RUNTIME_DIR"\n' \
         'chmod 700 "$XDG_RUNTIME_DIR"\n' \
         '[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources\n' \
         'exec startxfce4\n' \
         > /home/dev/.vnc/xstartup && \
    chmod +x /home/dev/.vnc/xstartup

USER root

# Expose SSH (22) + VNC (5901)
EXPOSE 22 5901

# Script khởi động: bật sshd và vncserver
CMD ["bash", "-c", "service ssh start && su - dev -c 'vncserver -localhost no -geometry 1366x768 -depth 24 :1' && tail -f /dev/null"]
