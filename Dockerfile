FROM ubuntu:17.04

LABEL author="Dimitris Garofalakis<kascrew1@gmail.com>"

# Dockerfile arguments
ARG project_folder=nativescript_src
ARG nvidia_driver
ARG git_username=your_git_username
ARG git_email="your@email.com"

# Home
ENV HOME /home/root
WORKDIR $HOME

# Environment setup
# apt-get
ENV DEBIAN_FRONTEND noninteractive
# Java
ENV JAVA_HOME "/usr/lib/jvm/java-8-oracle"
# Android
ENV ANDROID_HOME $HOME/sdktools
ENV ANDROID_AVD_HOME $HOME/.android/avd
ENV PATH ${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:$PATH
# https://stackoverflow.com/questions/26974644/no-keyboard-input-in-qt-creator-after-update-to-qt5
ENV QT_XKB_CONFIG_ROOT /usr/share/X11/xkb
# https://github.com/jamesnetherton/docker-atom-editor/blob/master/Dockerfile
ENV ATOM_VERSION v1.22.1

# Create directories & files required by installers
# Run apt update
RUN mkdir -p $HOME && \
    mkdir -p $HOME/.android && \
    mkdir -p $ANDROID_AVD_HOME && \
    mkdir -p /root/.android/ && \
    touch /root/.android/repositories.cfg && \
    apt-get update -qq

# Install curl and add node.js repo (apt update required afterwards)
# Install java, emulator & atom dependencies
RUN apt-get install -qq -y curl && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get update -qq && \
    apt-get install -qq -y \
        ca-certificates \
        fakeroot \
        g++ \
        gconf2 \
        gconf-service \
        git \
        gvfs-bin \
        libasound2 pulseaudio alsa-utils mplayer \
        libcanberra-gtk3-module \
        libcanberra-gtk-module \
        libcap2 \
        libgconf-2-4 \
        libglu1-mesa \
        libgtk2.0-0 \
        libnotify4 \
        libnss3 \
        libxkbfile1 \
        libxss1 \
        libxtst6 \
        libgl1-mesa-glx \
        libgl1-mesa-dri \
        nodejs \
        python \
        python-software-properties \
        qemu-system-i386 \
        qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils \
        software-properties-common \
        ttf-freefont \
        unzip \
        xdg-utils

# Add Java 8 repo  (apt update required afterwards)
# Auto-accept oracle's license
# Install Java 8
# Download and unzip android sdktools
# Accept all Android licenses
# Download tools for targeting API 26
# Add downloaded libstdc++.so.6 file to /usr/lib (required by emulator)
RUN add-apt-repository -y ppa:webupd8team/java && \
    apt-get update -qq && \
    echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
    apt-get install -qq -y --no-install-recommends oracle-java8-installer && \
    wget -O sdktools.zip https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip && \
    unzip -qq sdktools.zip -d sdktools && \
    rm -f sdktools.zip && \
    yes | sdkmanager --licenses && \
    sdkmanager --verbose "tools" "platform-tools" "platforms;android-26" "build-tools;26.0.2" \
                   "extras;android;m2repository" "extras;google;m2repository" && \
    ln -sf /usr/lib/libstdc++.so.6  ${ANDROID_HOME}/emulator/lib64/libstdc++/libstdc++.so.6

# Create emulators
ADD avd_conf avd_conf
ADD create_emulators.sh create_emulators.sh
RUN chmod +x create_emulators.sh && ./create_emulators.sh

# Install atom
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update -qq && \
    curl -L https://github.com/atom/atom/releases/download/${ATOM_VERSION}/atom-amd64.deb > /tmp/atom.deb && \
    dpkg -i /tmp/atom.deb && \
    rm -f /tmp/atom.deb


# Disable atom welcome screen
# Install git-plus and terminal emulator for atom
# Configure git
RUN mkdir -p $HOME/.atom
ADD atom_config.cson $HOME/.atom/config.cson
RUN apm disable welcome && \
    apm install git-plus && \
    apm install term3 && \
    git config --global user.email $git_email && git config --global user.name $git_username

# Add nvidia drivers if argument was supplied
RUN if [ "x$nvidia_driver" = "x" ] ; then echo "Skipping installation of nvidia driver" ; else \
    for key in \
7638D0442B90D010 \
8B48AD6246925553 \
EF0F382A1A7B6500; do \
	apt-key adv --keyserver pgp.mit.edu --recv-keys $key || \
	apt-key adv --keyserver keyserver.pgp.com --recv-keys $key || \
	apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys $key ; done && \
    echo "deb http://httpredir.debian.org/debian/ stretch main contrib non-free" >> /etc/apt/sources.list && \
    apt-get -qq update && \
    apt install -y -qq linux-headers-$(uname -r1.81M|sed 's/[^-]*-[^-]*-//') $nvidia_driver nvidia-xconfig && \
    nvidia-xconfig ; fi


# Adding nativescript source to docker image
# TODO: Maybe also add this as an entry script in case switch between projects is required
ADD $project_folder $project_folder

# Install nativescript
# Build nativescript project
RUN npm install -g nativescript --unsafe-perm &&  cd $project_folder && tns build android

WORKDIR $HOME/$project_folder
ENTRYPOINT ["/bin/sh", "-c"]
