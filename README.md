### Nativescript development environment Dockerfile 

![Screenshot](/nativescript_dev_env.png)

This docker container offers an out-of-the-box environment for nativescript development. 
It includes atom editor, an android emulator alongside a custom avd file (if you want to use another avd.ini and avd_config.ini file you can pass them as argument to the build script), and nativescript dependencies.

It supports live-editing of code (video will be added soon).

Below are the commands required for it to start (take extra note at the build args -exported as bash variables at the start)

I run it on Debian Stretch with nvidia-legacy-340xx-driver. So I pass nvidia_driver_version to the container. Replace with your own setup and let me know of the results.

If you'd rather use the open source drivers you can omit this argument.

If you want to run the container with the gpu turned off, you should change

./emulator @'"$avd_name"' -gpu on -verbose

to 

./emulator @'"$avd_name"' -gpu off -verbose

```bash
#!/bin/bash

export project_folder=HelloWorld
export avd_ini=mAvd.ini
export avd_config_ini=mAvd_config.ini
export nvidia_driver_version=nvidia-legacy-340xx-driver
export avd_name=mAvd


create_avd_ini_file() {
	echo -e "avd.ini.encoding=UTF-8\n"\
"path=/root/.android/avd/$avd_name.avd\n"\
"path.rel=avd/$avd_name.avd\n"\
"target=android-26" > $avd_ini
}

create_avd_ini_file

docker build  . -t nativescript_dev_env \
              --build-arg avd_name=$avd_name \
              --build-arg project_folder=$project_folder \
              --build-arg avd_ini=$avd_ini \
              --build-arg avd_config_ini=$avd_config_ini \
              --build-arg nvidia_driver=$nvidia_driver_version

xhost +local:`docker inspect --format='{{ .Config.Hostname }}' nativescript_dev_env`

run_nativescript() {
	avd_name=mAvd
	docker run --privileged --rm \
			-v /tmp/.X11-unix/:/tmp/.X11-unix/ \
			-v /dev/shm:/dev/shm \
			-e DISPLAY \
			-t nativescript_dev_env \
	'git pull --rebase & /usr/bin/atom . & echo No | tns run android --path . --emulator --timeout 0 & cd $ANDROID_HOME/tools && ./emulator @'"$avd_name"' -gpu on -verbose'

}

run_nativescript
```
