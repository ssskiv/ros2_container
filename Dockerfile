ARG ROS_DISTRO=jazzy
ARG BASE_IMAGE=osrf/ros:$ROS_DISTRO-desktop
FROM $BASE_IMAGE

ARG USERNAME=developer
ARG TEAM_NAME="HZ Robotics"
#ARG USERNAME=$USERNAME
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG DEBIAN_FRONTEND=noninteractive
# ARG UID=1000

# Delete user if it exists in container (e.g Ubuntu Noble: ubuntu)
RUN if id -u $USER_UID ; then userdel `id -un $USER_UID` ; fi

RUN useradd -d /$USERNAME -m \
    -u 1000 -U \
    -s /usr/bin/bash \
    -G dialout \
    -c "$TEAM_NAME" $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers 
# | EDITOR='tee -a' visudo

# Essentials
RUN apt-get update && apt-get install --no-install-recommends -y -o Dpkg::Options::="--force-overwrite" \
    ros-$ROS_DISTRO-navigation2 \
    ros-$ROS_DISTRO-nav2-bringup \
    ros-$ROS_DISTRO-rviz2 \
    ros-$ROS_DISTRO-teleop-twist-keyboard \
    ros-$ROS_DISTRO-dynamixel-sdk \
    ros-$ROS_DISTRO-can-msgs \
    ros-$ROS_DISTRO-ruckig \
    ros-$ROS_DISTRO-laser-filters \
    ros-$ROS_DISTRO-domain-bridge \
    ros-$ROS_DISTRO-rmw-cyclonedds-cpp \
    ros-$ROS_DISTRO-ros2-control \
    ros-$ROS_DISTRO-ros2-controllers \
    ros-$ROS_DISTRO-rqt-common-plugins \
    ros-$ROS_DISTRO-ros-gz \
    ros-$ROS_DISTRO-nav2-common \
    ros-$ROS_DISTRO-dynamixel-workbench-toolbox \
    ros-$ROS_DISTRO-behaviortree-cpp \
    libopencv-dev \
    python3-pip \
    python3-pil \
    alsa \
    libxshmfence1 \
    libgtk-3-dev \
    git \
    git-lfs \
    curl \
    wget \
    vim \
    rsync \
    dialog \
    nano \
    software-properties-common \
    fuse

RUN apt install --yes xvfb ffmpeg lsb-release g++ make libavcodec-extra libglu1-mesa libegl1 libxkbcommon-x11-dev libxcb-keysyms1 libxcb-image0 libxcb-icccm4 libxcb-randr0 libxcb-render-util0 libxcb-xinerama0 libxcomposite-dev libxtst6 libnss3    

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update && apt-get install -y nodejs

# VS Code https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
RUN curl -L -o /tmp/vscode.deb \
    'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' && \
    apt-get install -y /tmp/vscode.deb && \
    rm -f /tmp/vscode.deb

#ENV DONT_PROMPT_WSL_INSTALL=No_Prompt_please

# RUN su $USERNAME -c 'code --install-extension eamodio.gitlens' && \
#     su $USERNAME -c 'code --install-extension ms-python.python' && \
#     su $USERNAME -c 'code --install-extension ms-vscode.cpptools-extension-pack' && \
#     su $USERNAME -c 'code --install-extension usernamehw.errorlens' && \
#     su $USERNAME -c 'code --install-extension redhat.vscode-xml' && \
#     su $USERNAME -c 'code --install-extension ms-iot.vscode-ros'


# VS Code server
# RUN su $USERNAME -c 'curl -fsSL https://code-server.dev/install.sh | sh' && \
#     su $USERNAME -c 'code-server --install-extension eamodio.gitlens' && \
#     su $USERNAME -c 'code-server --install-extension ms-python.python' && \
#     su $USERNAME -c 'code-server --install-extension ms-vscode.cpptools-extension-pack' && \
#     su $USERNAME -c 'code-server --install-extension usernamehw.errorlens' && \
#     su $USERNAME -c 'code-server --install-extension redhat.vscode-xml' && \
#     su $USERNAME -c 'code-server --install-extension ms-iot.vscode-ros'
RUN su $USERNAME -c 'curl -fsSL https://code-server.dev/install.sh | sh' 

# Webots
# RUN curl -L -o /tmp/webots.deb \
#     'https://github.com/cyberbotics/webots/releases/download/R2023b/webots_2023b_amd64.deb' 
# RUN apt-get update && \
#     apt-get install -y /tmp/webots.deb && \
#     rm -f /tmp/webots.deb && \
#     mkdir -p /$USERNAME/.config/Cyberbotics

# Groot
# RUN curl -L -o /opt/Groot2.AppImge \
#     'https://s3.us-west-1.amazonaws.com/download.behaviortree.dev/groot2_linux_installer/Groot2-v1.5.2-x86_64.AppImage' && \
#     chmod +x /opt/Groot2.AppImge && \
#     ln -sf /opt/Groot2.AppImge /usr/bin/groot2

# RUN apt-get install --no-install-recommends -y -o Dpkg::Options::="--force-overwrite" \
#     python3-xyz

#RUN pip3 install  --no-cache-dir --break-system-packages  transforms3d fastseg prometheus_client cameratransform cherrypy pyyaml lapx ultralytics pyserial json-rpc shapely pyproj geopy 
#tensorflow scikit-learn scipy

#HOTFIX: https://github.com/ros-controls/ros2_controllers/issues/482
# RUN wget -O /tmp/diff_drive_controller.deb http://snapshots.ros.org/$ROS_DISTRO/2022-11-23/ubuntu/pool/main/r/ros-$ROS_DISTRO-diff-drive-controller/ros-$ROS_DISTRO-diff-drive-controller_2.12.0-1jammy.20221108.202153_amd64.deb && \
#     apt install -y --allow-downgrades /tmp/diff_drive_controller.deb && \
#     rm -f /tmp/diff_drive_controller.deb

# User config
COPY ./config/bashrc /tmp/bashrc
COPY ./config/vscode-server/config.yaml /$USERNAME/.config/code-server/config.yaml
COPY ./config/vscode/. /$USERNAME/ros2_ws/.vscode/
# COPY ./config/Cyberobotics/. /$USERNAME/.config/Cyberbotics/
COPY --chmod=755 ./config/setup.sh /usr/bin/

RUN cat /tmp/bashrc >> /$USERNAME/.bashrc && \
    rm -f /tmp/bashrc && \
    mkdir -p /$USERNAME/repositories && \
    mkdir  -p /$USERNAME/ros2_ws/src && \
    chown -R $USERNAME:$USERNAME /$USERNAME


#RUN sudo -E rosdep init 
RUN apt-get install -y python3-vcstool
RUN rosdep --rosdistro "${ROS_DISTRO}" update 
RUN cd /$USERNAME/ros2_ws && yes | rosdep --rosdistro "${ROS_DISTRO}" install -r --from-paths src --ignore-src

#RUN pip3 install matplotlib scipy --upgrade 

USER $USERNAME
WORKDIR /$USERNAME/ros2_ws

EXPOSE 31415
EXPOSE 8008
EXPOSE 1234
