FROM ubuntu:22.04

# This makes apt run non-interactively, which prevents problems with packages
# stopping the system for keyboard input
ENV DEBIAN_FRONTEND noninteractive

LABEL maintainer="fillip.cannard@swri.org"
LABEL description="Docker image used to install and run CARLA server that is compatible with integrated graphics cards."

# Update the system and install several useful packages and common dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        apt-utils \
        bash-completion \
        build-essential \
        ca-certificates \
        clang-format \
        curl \
        dirmngr \
        gcc \
        gnupg2 \
        git \
        git-lfs \
        gpg-agent \
        iputils-ping \
        libcanberra-gtk-module \
        libcanberra-gtk3-module \
        libccd-dev \
        libccd2 \
        libgl1-mesa-glx \
        libyaml-cpp-dev \
        libvulkan1 \
        libvulkan-dev \
        libxext6 \
        locales \
        lsb-release \
        mesa-utils \
        mesa-vulkan-drivers \
        nano \
        openssh-client \
        pip \
        python3-dev \
        python3-pybind11 \
        python3-pip \
        software-properties-common \
        sudo \
        vim \
        vulkan-tools \
        wget \
        xdg-user-dirs \
        xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# These arguments set up the name, group ID, and user ID of the user inside the container
ARG UNAME=carla
ARG UID=1000
ARG GID=1000

# Allow us to run sudo commands without a password
RUN echo "$UNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Add a normal user with the same name/uid/gid as the host user.
RUN groupadd -g $GID $UNAME
RUN useradd -l -m -u $UID -g $GID -s /bin/bash $UNAME
RUN chown $UID:$GID /home/$UNAME

# Switch to our sudo user
USER $UNAME
WORKDIR /home/$UNAME

# Download CARLA Server
RUN wget -q -O carla_0.9.15 https://tiny.carla.org/carla-0-9-15-linux
RUN tar -xvzf carla_0.9.15

# Install CARLA dependencies and CARLA client library
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install numpy pygame && \
    python3 -m pip install 'carla==0.9.15'

# Run CARLA server on low presets
CMD ./CarlaUE4.sh -quality-level=Low