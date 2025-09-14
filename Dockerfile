FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y openssh-server sudo locales nano curl && \
    rm -rf /var/lib/apt/lists/* && \
    locale-gen en_US.UTF-8

RUN useradd -m -s /bin/bash dev && echo "dev:dev" | chpasswd && adduser dev sudo

RUN mkdir /var/run/sshd
EXPOSE 22 5901

CMD ["/usr/sbin/sshd","-D"]
