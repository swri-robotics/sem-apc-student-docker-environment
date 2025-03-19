FROM osrf/ros:noetic-desktop

# This makes apt run non-interactively, which prevents problems with packages
# stopping the system for keyboard input
ENV DEBIAN_FRONTEND noninteractive

LABEL maintainer="fillip.cannard@swri.org"
LABEL description="ROS1 Noetic docker environment for students in the Shell APC to develop autonomous software to control a simulated vehicle in CARLA."

# Update dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        pip \
        python3-dev \
        python3-pip \
        python3-pybind11 \
        python3-rosdep \
        python-is-python3 \
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

# Set up ROS automatic ROS sourcing
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc

# Set up ROS URL
RUN echo "export ROS_HOSTNAME=localhost" >> ~/.bashrc
RUN echo "export ROS_MASTER_URI=http://localhost:11311" >> ~/.bashrc

RUN mkdir -p /home/$UNAME/shell_ws/src

# TODO: Copy/git clone carla_shell_bridge and carla_ros_bridge

# Reset ROS entrypoint
ENTRYPOINT []

CMD ["/bin/bash", "-c", "sleep infinity"]
