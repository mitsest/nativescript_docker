### Nativescript development environment Dockerfile 

This docker container offers an out-of-the-box environment for nativescript development. 
It includes an atom editor, an android emulator alongside a custom avd file (if you want to use another avd.ini and avd_config.ini file you can pass them as argument to the build script), and nativescript dependencies. It supports live-editing of code

##Requirements
Docker
You host machine should support KVM (run kvm-ok to check)

##Build container
If you want to use another avd name, or another avd.ini name you should genenerate a new avd.ini file. 

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

After this step you can build the container
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

I usually run it on Debian Stretch, which uses nvidia-legacy-340xx-driver. So I pass nvidia_driver_version to the build command, driver to install also in the container.

If you'd rather use the open source drivers you can omit this argument.

When docker finishes building,  don't forget to add the container to xhost
```bash
xhost +local:`docker inspect --format='{{ .Config.Hostname }}' nativescript_dev_env`
```

##Run container
TODO: add entry script
If all went well, you can add the function at your ~/.bashrc or ~/.bash_aliases (replace mAvd variable with the avd name you used)

If you want to run the container with the gpu turned off, you should change

./emulator @'"$avd_name"' -gpu on -verbose

to 

./emulator @'"$avd_name"' -gpu off -verbose

```bash
run_nativescript() {
	avd_name=mAvd
	docker run --privileged --rm \
			-v /tmp/.X11-unix/:/tmp/.X11-unix/ \
			-v /dev/shm:/dev/shm \
			-e DISPLAY \
			-t nativescript_dev_env \
	'git pull --rebase & /usr/bin/atom . & echo No | tns run android --path . --emulator --timeout 0 & cd $ANDROID_HOME/tools && ./emulator @'"$avd_name"' -gpu on -verbose'

}
```

Now, when you want to run your project all you have to do is issue the command run_nativescript at the console.

Have fun!

![Screenshot](/nativescript_dev_env.png)
