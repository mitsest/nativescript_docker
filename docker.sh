#!/bin/bash

export project_folder=HelloWorld
export avd_ini=mAvd.ini
export avd_config_ini=mAvd_config.ini
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

run_nativescript
