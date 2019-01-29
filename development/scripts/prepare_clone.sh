#!/bin/bash

# https://askubuntu.com/a/99151
SETUP_NAME=$1

mkdir $SETUP_NAME
dpkg --get-selections > ./$SETUP_NAME/Package.list
sudo cp -R /etc/apt/sources.list* ./$SETUP_NAME
sudo apt-key exportall > $SETUP_NAME/Repo.keys
pip && pip freeze > $SETUP_NAME/requirements_python2.txt
pip3 && pip3 freeze > $SETUP_NAME/requirements_python3.txt
tar -cvzf $SETUP_NAME.tar.gz $SETUP_NAME
