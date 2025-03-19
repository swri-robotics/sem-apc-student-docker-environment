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

choose_ros_version() {
  read -p "Which version of ROS would you like to use? Enter '1' to select ROS1 Noetic or '2' to select ROS2 Humble (recommended): " -e ros_version_response
  if [ $ros_version_response == 1 ] || [ $ros_version_response == 2 ]; then
    >&2 echo "Setting up environment for ROS$ros_version_response."
  else
    >&2 echo "Invalid response."
    exit 1
  fi

  echo $ros_version_response
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
  echo "Docker build has started. This may take some time..."
  export GID=`id -g`
  export UID=`id -u`
  export ROS_WS=$1
  if [ $2 == "true" ]; then
    if [ $3 == 1 ]; then
      docker compose --profile gpu --profile ros1 up --build -d
    else
      docker compose --profile gpu --profile ros2 up --build -d
    fi
  else
    if [ $3 == 1 ]; then
      docker compose --profile nogpu --profile ros1 up --build -d
    else
      docker compose --profile nogpu --profile ros2 up --build -d
    fi
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
selected_ros_version=$(choose_ros_version)
if [ $? == 1 ]; then
  echo "Exiting script."
  exit 1
fi
create_docker $ros_ws_path $gpu $selected_ros_version
