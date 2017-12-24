#!/bin/bash

  export project_folder=HelloWorld
  export nvidia_driver_version=nvidia-legacy-340xx-driver

  docker build  . -t nativescript_dev_env \
                --build-arg project_folder=$project_folder \
                --build-arg nvidia_driver=$nvidia_driver_version \
                --build-arg git_username="mitsest" \
                --build-arg git_email="kascrew1@gmail.com"
