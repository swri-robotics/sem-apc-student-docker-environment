# Shell APC Docker Environment

This is the Docker development environment for the Shell Eco-marathon APC. Designed to automate the setup process for CARLA and ROS, this package will download and set up CARLA, ROS1 or ROS2, and all other code needed to develop and test code for the Shell Eco-marathon APC.

CARLA Version: `0.9.15`

Supported ROS Versions: `ROS1 Noetic` `ROS2 Humble`

## First Time Container Setup
1. Install Docker: <https://docs.docker.com/engine/install/debian>
    
    If your computer has a Nvidia GPU, you will also want to install the [Nvidia Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
    
    - After installing the Nvidia container toolkit, you will need to restart the Docker daemon:

        `sudo systemctl restart docker`

2. Add your user to the docker group so that you do not need to run all commands with sudo privileges. To make this modification, run the following command and log out and back into your computer:

    `sudo usermod -aG docker $USER`

3. Download/clone this repository.
4. Navigate to the cloned repository directory and run the `run.sh` bash script. This will take you through the setup process for configuring your Docker environment. 
5. After answering the prompts and waiting for the script to build the containers, you should now see the CARLA server window open.
6. You can also now see the two Docker containers you've created by running the following Docker command:

    `docker ps -a`

    ```
    CONTAINER ID   IMAGE                              COMMAND                  CREATED          STATUS           PORTS     NAMES
    60abd086c576   carlasim/carla:0.9.15              "/bin/bash CarlaUE4.…"   20 seconds ago   Up 20 seconds              carla_server
    a2a46daa1484   humble-docker-ros_environment      "/ros_entrypoint.sh …"   2 minutes ago    Up 20 seconds              ros_environment
    ```

    The first container `carla_server` hosts the simulated environment that your vehicle will be driving in. The second container `ros_environment` is a ROS development environment where you will build and run your control algorithms to control the vehicle.

7. To stop both containers, run:

    `docker stop carla_server ros_environment`

    This should close the CARLA server window and stop all ROS nodes running in the environment.

8. To start the containers back up again, run:

    `docker start carla_server ros_environment`

    You should see the CARLA server window open again.

    *NOTE: Closing the CARLA server window will stop the server and container. You will need to start the server container again using `docker start carla_server`*

## First Time ROS Environment Setup
1. To enter into your ROS workspace in your ros_environment container, run:

    `docker exec -it ros_environment /bin/bash`

    `cd shell_ws`

2. Update and install ROS dependencies:

    `sudo apt update`

    `rosdep update`

    `rosdep install --from-paths src -y --ignore-src`

## Running a Basic Example Project
You should now have a Docker environment for developing and testing your vehicle. To run an example project see the example_project repository.