#!/bin/bash

# echo "Updating sdk libraries"
sdkmanager --verbose --update
yes | sdkmanager --licenses

for folder in avd_conf/*/; do
		avd_name=$(basename $folder)
		avd_ini_file=$(find $folder -name "$avd_name.ini")
		avd_config_ini_file=`find "$folder" -name 'config.ini'`
		android_version_grep=$(grep 'image.sysdir.1=' $avd_config_ini_file)
		system_image_awk=$(echo $android_version_grep | awk -F/ '{ print $2 }' $NF)
		android_version=$(echo $system_image_awk | cut -d'-' -f 2)

		printf "Downloading system image for emulator (android version: $android_version)\n"
		if sdkmanager --verbose "system-images;android-$android_version;google_apis_playstore;x86" > /dev/null 2>&1 ; then
				printf "Creating emulator...\n"
				echo no | avdmanager create avd --force --name $avd_name --package "system-images;android-$android_version;google_apis_playstore;x86" -verbosetwi
		else
			printf "$android_version has no system image with bundled playstore. Fallbacking to one without. \n"
			sdkmanager --verbose "system-images;android-$android_version;google_apis;x86"
			printf "Creating emulator...\n"
			echo no | avdmanager create avd --force --name $avd_name --package "system-images;android-$android_version;google_apis;x86" -verbose
		fi


		mkdir -p $ANDROID_AVD_HOME/${avd_name}.avd && cp $avd_config_ini_file $ANDROID_AVD_HOME/${avd_name}.avd/config.ini
		cp $avd_ini_file $ANDROID_AVD_HOME/
done
