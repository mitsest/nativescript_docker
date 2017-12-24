# Nativescript development environment dockerfile

This docker container offers an out-of-the-box environment for nativescript development.
It includes an atom editor, an android emulator alongside a custom avd file, and nativescript dependencies.
It supports live-editing of code through tns.

## Requirements

docker

Your host machine should support KVM (run kvm-ok to check), or the emulator will be too slow

## AVD Configuration (Optional)

If you want to use another avd name(multiple emulators on the same docker image maybe?), you should genenerate a new avd.ini file.


```bash
export avd_ini=mAvd.ini
export avd_name=mAvd
create_avd_ini_file() {
	echo -e "avd.ini.encoding=UTF-8\n"\
"path=/root/.android/avd/$avd_name.avd\n"\
"path.rel=avd/$avd_name.avd\n"\
"target=android-26" > $avd_ini
}


create_avd_ini_file
```

TODO: Add support for "target" argument

mAvd_Config.ini contains configuration for the avd image, like screen density etc.
You can pass your own configuration file as an argument to the build script, if you want.

## Build container

```bash
export project_folder=HelloWorld
export avd_ini=mAvd.ini
export avd_config_ini=mAvd_config.ini
export nvidia_driver_version=nvidia-legacy-340xx-driver
export avd_name=mAvd

docker build  . -t nativescript_dev_env \
              --build-arg avd_name=$avd_name \
              --build-arg project_folder=$project_folder \
              --build-arg avd_ini=$avd_ini \
              --build-arg avd_config_ini=$avd_config_ini \
              --build-arg nvidia_driver=$nvidia_driver_version
```


#### project_folder
It should be at the same level as the Dockerfile. Replace HelloWorld with your project folder's name.

### nvidia_driver
I usually run it on Debian Stretch, which uses nvidia-legacy-340xx-driver. So I pass nvidia_driver_version to the build command, in order for the container to be able to make use of the host's gpu.

If you'd rather use the open source drivers, or if you 're planning to not use the gpu at all, you can omit this argument.

### avd configuration
Replace all other arguments with regards to the avd configuration you need.

If all you want is an API 26 emulator leave those intact.


## Run container

TODO: add entry script

If all went well, you can add the following function at your ~/.bashrc or ~/.bash_aliases (replace mAvd variable with the avd name you used)

If you want to run the container with the gpu turned off, you should change

./emulator @'"$avd_name"' -gpu on -verbose

to

./emulator @'"$avd_name"' -gpu off -verbose

```bash
run_nativescript() {
	xhost +local:`docker inspect --format='{{ .Config.Hostname }}' nativescript_dev_env`

	avd_name=mAvd
	docker run --privileged --rm \
			-v /tmp/.X11-unix/:/tmp/.X11-unix/ \
			-v /dev/shm:/dev/shm \
			-e DISPLAY \
			-t nativescript_dev_env \
	'git pull --rebase & /usr/bin/atom . & echo No | tns run android --path . --emulator --timeout 0 & cd $ANDROID_HOME/tools && ./emulator @'"$avd_name"' -gpu on -verbose'

}

```

Now, when you want to run your project all you have to do is issue the command run_nativescript at the console. Phew!

Have fun and let me know if something went wrong!

![Screenshot](/nativescript_dev_env.png)
