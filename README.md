# Nativescript development environment dockerfile

This docker container offers an out-of-the-box environment for nativescript development.
It includes an atom editor, an android emulator alongside a custom avd file, and nativescript dependencies.
It supports live-editing of code through tns.

## Requirements

docker

Your host machine should support KVM (run kvm-ok to check), or the emulator will be too slow

## AVD Configuration (Optional)

If you want to test your app on another emulator configuration than the one provided inside avd_conf folder, I created the following tool:

https://mitsest.github.io/avd_conf_generator/

It will produce a zip file with the required configuration.
Extract its contents to avd_conf.
After that, avd_conf should contain one or more folders (21, 22, 23 etc.) representing SDK versions.

The build script will take care of creating those emulators for you.

## Build container

```bash
export project_folder=HelloWorld
export nvidia_driver_version=nvidia-legacy-340xx-driver

docker build  . -t nativescript_dev_env \
              --build-arg project_folder=$project_folder \
              --build-arg nvidia_driver=$nvidia_driver_version \
							--build-arg git_username="your_git_username" \
							--build-arg git_email="your@email.com"
```


#### project_folder
It should be at the same level as the Dockerfile. Replace HelloWorld with your project folder's name.

### nvidia_driver
I usually run it on Debian Stretch, which uses nvidia-legacy-340xx-driver. So I pass nvidia_driver_version to the build command, in order for the container to be able to make use of the host's gpu.

If you'd rather use the open source drivers, or if you 're planning to not use the gpu at all, you can omit this argument.

## Run container


```bash
xhost +local:`docker inspect --format='{{ .Config.Hostname }}' nativescript_dev_env`

export avd_name=API_26
docker run --privileged --rm \
		-v /tmp/.X11-unix/:/tmp/.X11-unix/ \
		-v /dev/shm:/dev/shm \
		-e DISPLAY \
		-t nativescript_dev_env \
'git pull --rebase & /usr/bin/atom . && echo No | tns run android --path . --timeout 0 --device '"$avd_name"
```

Take extra note at the exported variable(avd_name).

If you have used the tool described above to produce your own emulator configuration,

change this to reflect the name you 've chosen.

Have fun and let me know if something went wrong!

![Screenshot](/nativescript_dev_env.png)
