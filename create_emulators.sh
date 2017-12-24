#!/bin/bash

echo "Updating sdk libraries"
sdkmanager --verbose --update
yes | sdkmanager --licenses

for folder in avd_conf/*/; do
		android_version=$(basename $folder)
		printf "Downloading system image for emulator (android version: $android_version)\n"

		avd_ini_file=`find "$folder" -name '*.ini' | grep -v 'config.ini'`
		avd_config_ini_file=`find "$folder" -name 'config.ini'`

		avd_name=$(basename "$avd_ini_file" .ini)

		if sdkmanager "system-images;android-$android_version;google_apis_playstore;x86" > /dev/null 2>&1 ; then
				printf "Creating emulator...\n"
				echo no | avdmanager create avd --force --name $avd_name --package "system-images;android-$android_version;google_apis_playstore;x86"
		else
			printf "$android_version has no system image with bundled playstore. Fallbacking to one without. \n"
			sdkmanager "system-images;android-$android_version;google_apis;x86"
			printf "Creating emulator...\n"
			echo no | avdmanager create avd --force --name $avd_name --package "system-images;android-$android_version;google_apis;x86"
		fi


		mkdir -p $ANDROID_AVD_HOME/${avd_name}.avd && cp $avd_config_ini_file $ANDROID_AVD_HOME/${avd_name}.avd/config.ini
		cp $avd_ini_file $ANDROID_AVD_HOME/
done
