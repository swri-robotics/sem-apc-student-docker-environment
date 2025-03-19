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
    pip \
    python3-dev \
    python3-pybind11 \
    python3-pip \
    build-essential \
    python3-colcon-common-extensions \
    git

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

# Install CARLA dependencies and CARLA client library
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install numpy pygame && \
    python3 -m pip install 'carla==0.9.15'

# TODO: Copy/git clone carla_shell_bridge and carla_ros_bridge

SHELL ["/bin/bash", "-c"]

# Setup ROS automatic ROS sourcing
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc

RUN mkdir -p /home/$UNAME/shell_ws/src

# Reset ROS entrypoint
ENTRYPOINT []

CMD ["/bin/bash", "-c", "sleep infinity"]
