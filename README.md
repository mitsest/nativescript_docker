# Nativescript development environment dockerfile

This docker container offers an out-of-the-box environment for nativescript development.
It includes an atom editor, an android emulator alongside a custom avd file, and nativescript dependencies.
It supports live-editing of code through tns.

## Requirements

docker

Your host machine should support KVM (run kvm-ok to check), or the emulator will be too slow

## AVD Configuration (Optional)


## Build container

```bash
export project_folder=HelloWorld
export nvidia_driver_version=nvidia-legacy-340xx-driver

docker build  . -t nativescript_dev_env \
              --build-arg project_folder=$project_folder \
              --build-arg nvidia_driver=$nvidia_driver_version \
							--build-arg git_username="your_git_username" \
							--build-arg git_email="your_git_email"
```


#### project_folder
It should be at the same level as the Dockerfile. Replace HelloWorld with your project folder's name.

### nvidia_driver
I usually run it on Debian Stretch, which uses nvidia-legacy-340xx-driver. So I pass nvidia_driver_version to the build command, in order for the container to be able to make use of the host's gpu.

If you'd rather use the open source drivers, or if you 're planning to not use the gpu at all, you can omit this argument.

## Run container

xhost +local:`docker inspect --format='{{ .Config.Hostname }}' nativescript_dev_env`

```bash
export avd_name=API_21
docker run --privileged --rm \
		-v /tmp/.X11-unix/:/tmp/.X11-unix/ \
		-v /dev/shm:/dev/shm \
		-e DISPLAY \
		-t nativescript_dev_env \
'git pull --rebase & /usr/bin/atom . & cd - && echo No | tns run android --path . --timeout 0 --device '"$avd_name"
```

Have fun and let me know if something went wrong!

![Screenshot](/nativescript_dev_env.png)
