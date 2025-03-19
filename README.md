# Student Docker Environment

A Docker development environment for students to run CARLA and ROS.

CARLA Version: `0.9.15`

ROS Version: `Humble`

## First Time Container Setup
1. Install Docker: <https://docs.docker.com/engine/install/debian>
2. Download/clone this repository:
    
    *(Currently the docker environment is not set up to download the other repos needed to interface with CARLA: the carla-ros-bridge, the carla-shell-interface, and the student example project. You will need to download them seperately and put them into your ROS workspace.)*

3. Navigate to the directory in the repository containing the `docker-compose.yaml` file and modify this line in the file to mount your ROS src directory:

    ``` yaml
    - <SRC>:/home/shell_ws/src # Replace "<SRC>" with the full path to your ROS src directory
    ```

4. Set up environment variables by running:

    ``export GID=`id -g` ``

    ``export UID=`id -u` ``

5. Build and start up the Docker environment in the background with:

    `docker compose --profile gpu up --build -d`

    If your machine does not have a dedicated Nvidia graphics card, use the `nogpu` profile:

    `docker compose --profile nogpu up --build -d`

    After the build is complete, you should now see the CARLA server window open.

6. You can also now see the two Docker containers you've created with the following:

    `docker ps -a`

    ```
    CONTAINER ID   IMAGE                              COMMAND                  CREATED          STATUS           PORTS     NAMES
    60abd086c576   carlasim/carla:0.9.15              "/bin/bash CarlaUE4.…"   20 seconds ago   Up 20 seconds              carla_server
    a2a46daa1484   humble-docker-ros_environment      "/ros_entrypoint.sh …"   2 minutes ago    Up 20 seconds              ros_environment
    ```

    *NOTE: If you are using the no_gpu version, your carla_server image and container name will look different since it builds a custom Docker image.*

    The first container `carla_server` (or `carla_server_nogpu` if you built that version) hosts the simulated environment that your vehicle will be driving in. The second container `ros_environment` is a ROS development environment where you will build and run your control algorithms to control the vehicle.

7. To stop both containers, run:

    `docker stop carla_server ros_environment`

    This should close the CARLA server window and stop all ROS nodes running in the environment.

8. To start the containers back up again, run:

    `docker start carla_server ros_environment`

    You should see the CARLA server window open again.

    *NOTE: Closing the CARLA server window will stop the server and container. You will need to start the server container again using `docker start carla_server`*

## First Time ROS Environment Setup
1. To enter in your ROS environment container, run:

    `docker exec -it ros_environment /bin/bash`

    `cd shell_ws`

2. Update the system:

    `sudo apt update`

    `sudo apt upgrade -y`

3. Update and install ROS dependencies:

    `rosdep update`

    `rosdep install --from-paths src -y --ignore-src`

## Developing in the Environtment
After completing the first time Docker and ROS environment setup, you should now be able to develop, build, and run your code to control the vehicle in simulation as you would in a normal ROS environment. Let's run an example that moves the vehicle forward to show you how to build and run your code to control the vehicle. 

1. If your containers are not running, start them and enter the ROS environment container:

    `docker start carla_server ros_environment`

    `docker exec -it ros_environment /bin/bash`

    `cd shell_ws`

2. Build the ROS packages:

    `colcon build`

3. Source your workspace:

    `source install/setup.bash`

4. Set up the CARLA simulated environment:

    There are a variety of parameters to set up the server and simulated environment in the `carla_config.yaml` file within the `carla-interface` package: `~/shell_ws/src/carla-interface/config/carla_config.yaml` 

    This includes things like selected a map, loading/unloading map layers, setting a spawn point, and generating traffic.

5. Launch the carla_shell_bridge interface to setup the server world and spawn a vehicle to control:

    `ros2 launch carla_shell_bridge main.launch.py`

6. Finally, open a new terminal, enter the ROS container as shown in step 1 and source your workspace as shown in step 3. You can now run the example node that moves the vehicle forward!

    `ros2 run test_control example_control`

## General Tips

If you've already built most of the ROS packages before and only need to rebuild a specific package that you have been modifying, you can use:

`colcon build --packages-select <YOUR_PACKAGE_NAME>`

Since your workspace is mounted to the ROS environment Docker container, you can simply edit your code locally on your machine with your favorite text editor, and all the changes will be synced to the Docker container automatically.

If you encounter a spawning error with the Ego vehicle (`Exception caught: Spawn failed because of collision at spawn position` ) you may need to change the spawn point parameter in the `carla_config.yaml` file. The Z coordinate may need to be set to something greater than 0. You can also change this parameter to `"None"` which will spawn the vehicle in a random, valid position on the map.

## Known Bugs

- Traffic generation does not work in `Town03_Opt`. Please use a differnt map for traffic generation. 