#!/usr/bin/env bash

check_docker() {
  echo "Checking if Docker is installed..."
  if [ -x "$(command -v docker)" ]; then
    echo "Success! Docker is installed."
  else
    echo "Docker is not installed. Please follow the instructions at: https://docs.docker.com/engine/install/debian to install Docker"
  fi
}

create_ros_ws() {
  read -p "Please provide the filesystem path to your ROS workspace: " -e ros_ws_path
  
  if [ ! -d $ros_ws_path ]; then
    read -p "$ros_ws_path does not exist. Would you like to create it? Enter 'y' to create the directory or 'n' to quit: " -e create_response
    if [ "$create_response" == "y" ]; then
      if mkdir -p $ros_ws_path ; then
        >&2 echo "Successfully created $ros_ws_path."
      else
        >&2 echo "Could not create $ros_ws_path."
        exit 1
      fi
    else
      exit 1
    fi
  else
    >&2 echo "Success! $ros_ws_path exists."
  fi

  echo $ros_ws_path
}

choose_gpu() {
  >&2 echo "Checking if Nvidia support is enabled for Docker..."
  gpu="false"
  if dpkg -s nvidia-container-toolkit &>/dev/null; then
    >&2 echo "The Nvidia container toolkit is installed, GPU support will be enabled."
    gpu="true"
  else
    >&2 echo "the Nvidia container toolkit is not installed, GPU support will be disabled."
  fi

  echo $gpu
}

create_docker() {
  echo "Cloning source code into ROS workspace directory..."
  mkdir -p "$1/src"
  git clone -b main --single-branch --recurse-submodules https://github.com/swri-robotics/sem-apc-ros-bridge "$1/src/sem-apc-ros-bridge"
  git clone -b ros2 --single-branch https://github.com/swri-robotics/sem-apc-carla-interface.git "$1/src/sem-apc-carla-interface"
  git clone -b ros2 --single-branch https://github.com/swri-robotics/sem-apc-example-project.git "$1/src/sem-apc-example-project"

  echo "Docker build has started. This may take some time..."
  export GID=$(id -g)
  export UID=$(id -u)
  export ROS_WS="$1"

  if [ "$2" == "true" ]; then
    docker compose --profile gpu --profile ros2 up --build -d
  else
    docker compose --profile nogpu --profile ros2 up --build -d
  fi
}

# set -e
check_docker
gpu=$(choose_gpu)
ros_ws_path=$(create_ros_ws)
if [ $? == 1 ]; then
  echo "Exiting script."
  exit 1
fi
create_docker $ros_ws_path $gpu
