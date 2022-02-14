# syntax = docker/dockerfile:1.3-labs
FROM archlinux:base-devel

ARG USERNAME=virtual
ARG UID=1000
ARG GID=1000
ARG SSHD_PORT=22
ARG PACKAGES="git sudo curl ca-certificates openssh nano python python-pip rust jdk-openjdk nodejs npm go docker docker-compose"
ARG PYTHON_PACKAGES="flake8 pylint rope xonsh"

ENV TZ=Asia/Tokyo
ENV EDITOR=/usr/bin/nano

# Upgrade
RUN <<EOF
    pacman -Syu --noconfirm
    pacman -S --noconfirm ${PACKAGES}
    pacman -S --clean --noconfirm
EOF

# Grand sudo
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create user
RUN <<EOF
    groupadd --gid ${GID} ${USERNAME}
    useradd -m --uid ${UID} --gid ${GID} ${USERNAME}
EOF

USER virtual

# yay
RUN <<EOF
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd /
    rm -rf /tmp/yay
EOF

# Python
RUN pip install --no-cache-dir ${PYTHON_PACKAGES}

# SDKMAN
RUN <<EOF
    sudo pacman -Sy zip unzip
    curl -s https://get.sdkman.io | bash
    bash -c "source ${HOME}/.sdkman/bin/sdkman-init.sh"
    sudo pacman -S --clean --noconfirm
EOF

# openssh
USER root
RUN ssh-keygen -A

CMD [ "/usr/sbin/sshd", "-D" ]
