FROM osrf/ros:humble-desktop

# This makes apt run non-interactively, which prevents problems with packages
# stopping the system for keyboard input
ENV DEBIAN_FRONTEND noninteractive

LABEL maintainer="fillip.cannard@swri.org"
LABEL description="ROS2 Humble docker environment for students in the Shell APC to develop autonomous software to control a simulated vehicle in CARLA."

# Update dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        pip \
        python3-colcon-common-extensions \
        python3-dev \
        python3-pip \
        python3-pybind11 \
    && rm -rf /var/lib/apt/lists/*

# Install CARLA dependencies and CARLA client library
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install numpy pygame && \
    python3 -m pip install 'carla==0.9.15'

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

SHELL ["/bin/bash", "-c"]

# Setup ROS automatic ROS sourcing
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc

RUN mkdir -p /home/$UNAME/shell_ws/src

# Git clone carla_shell_bridge, carla_ros_bridge, and example_project repos
RUN cd /home/$UNAME/shell_ws/src
RUN git clone -b main --single-branch https://github.com/swri-robotics/sem-apc-ros-bridge
RUN git clone -b ros2 --single-branch https://github.com/swri-robotics/sem-apc-carla-interface.git
RUN git clone -b ros2 --single-branch https://github.com/swri-robotics/sem-apc-example-project.git

# Reset ROS entrypoint
ENTRYPOINT []

CMD ["/bin/bash", "-c", "sleep infinity"]
