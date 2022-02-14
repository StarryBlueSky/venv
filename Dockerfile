# syntax = docker/dockerfile:1.3-labs
FROM archlinux:base-devel

ARG PACKAGES="git sudo htop curl ca-certificates openssh nano python python-pip rust jdk-openjdk nodejs npm go docker docker-compose xonsh python-prompt_toolkit"
ARG PYTHON_PACKAGES="flake8 pylint rope tweepy"

ENV TZ=Asia/Tokyo
ENV EDITOR=/usr/bin/nano

# Upgrade
RUN <<EOF
    pacman -Syu --noconfirm
    pacman -S --noconfirm ${PACKAGES}
    pacman -S --clean --noconfirm
EOF

# Create temporary user
RUN useradd -N -G wheel virtual
USER virtual

# yay
RUN <<EOF
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd /
    rm -rf /tmp/yay
EOF

# Delete temporary user
USER root
RUN <<EOF
    userdel virtual
    rm -rf /home/virtual
EOF

# Python
RUN pip install --no-cache-dir ${PYTHON_PACKAGES}

LABEL org.opencontainers.image.source https://github.com/StarryBlueSky/venv
CMD [ "/usr/sbin/sshd", "-D", "-e" ]
