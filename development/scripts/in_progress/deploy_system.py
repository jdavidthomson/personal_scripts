#!/usr/bin/python
import sys
import os
from multiprocessing import Pool
import subprocess

#####################################
#                                   #
#           CONSTANTS               #
#                                   #
#####################################

#### commands and scripts ####
DOCKER_COMMAND="docker"
BUILD_NEW_DOCKER_IMAGE_SUB_COMMAND="build"

#### base name variables ####
DEVELOPMENT_FOLDER="~/development"
DOCKER_FOLDER=os.path.join(DEVELOPMENT_FOLDER, "docker")
DOCKER_IMAGES_FOLDER_NAME="docker_files"

BASE="base"

BASE_IMAGES_FOLDER_NAME="base_images"
TOOLS_IMAGES_FOLDER_NAME="tools_images"
PLATFORM_TOOLS_FOLDER_NAME="platform_tools"

UBUNTU_NAME="ubuntu"
UBUNTU_STANDARD_VERSION_NUMBER="16_04"

DEVELOPMENT="development"
PYTHON="python"

#### concatenated names ####
BI_PATH=os.path.join(DOCKER_FOLDER, DOCKER_IMAGES_FOLDER_NAME, BASE_IMAGES_FOLDER_NAME)
TI_PATH=os.path.join(DOCKER_FOLDER, DOCKER_IMAGES_FOLDER_NAME, TOOLS_IMAGES_FOLDER_NAME)
PT_PATH=os.path.join(DOCKER_FOLDER, DOCKER_IMAGES_FOLDER_NAME, PLATFORM_TOOLS_FOLDER_NAME)

UBUNTU_NAME_STANDARD_VERSION_NUMBER=UBUNTU_NAME + "_" + UBUNTU_STANDARD_VERSION_NUMBER 
UBUNTU_NAME_STANDARD_VERSION_NUMBER_DEVELOPMENT=UBUNTU_NAME_STANDARD_VERSION_NUMBER + "_" + DEVELOPMENT
UBUNTU_NAME_STANDARD_VERSION_NUMBER_PYTHON_DEVELOPMENT=UBUNTU_NAME_STANDARD_VERSION_NUMBER + "_" + PYTHON + "_" + DEVELOPMENT

#### repositories ####
BASE_REPO="base_repo"
PACKAGES_REPO="packages_repo"

#### supported base image names ####


#### supported version codes for python####
PYTHON3_3_6_8="3.6.8"
PYTHON3_3_7_2="3.7.2"

UBUNTU_STANDARD_DEVELOPMENT_PYTHON_3_6_8_PATH=os.path.join(BI_PATH, UBUNTU_NAME_STANDARD_VERSION_NUMBER_PYTHON_DEVELOPMENT, PYTHON3_3_6_8, "")
UBUNTU_STANDARD_DEVELOPMENT_PYTHON_3_7_2_PATH=os.path.join(BI_PATH, UBUNTU_NAME_STANDARD_VERSION_NUMBER_PYTHON_DEVELOPMENT, PYTHON3_3_7_2, "")

#### packages to build ####
DEBMAKE="debmake"
UBUNTU_STANDARD_DEVELOPMENT_BUILD_DEBMAKE=os.path.join(BI_PATH, UBUNTU_NAME_STANDARD_VERSION_NUMBER_DEVELOPMENT, DEBMAKE, "")

#####################################
#                                   #
#       END CONSTANTS               #
#                                   #
#####################################

base_images=dict()
tools=dict()
platform_tools=dict()
PROCS=[]

def define_base_images():
    """ define_base_images """
    try:
        base_images[UBUNTU_NAME_STANDARD_VERSION_NUMBER]=os.path.join(BI_PATH, UBUNTU_NAME_STANDARD_VERSION_NUMBER,"")
        base_images[UBUNTU_NAME_STANDARD_VERSION_NUMBER_DEVELOPMENT]=os.path.join(BI_PATH, UBUNTU_NAME_STANDARD_VERSION_NUMBER_DEVELOPMENT,"")
        base_images[UBUNTU_NAME_STANDARD_VERSION_NUMBER_PYTHON_DEVELOPMENT]=os.path.join(BI_PATH, UBUNTU_NAME_STANDARD_VERSION_NUMBER_PYTHON_DEVELOPMENT,"")
    except Exception as e:
        print("error above...")
        print(e)

def define_tools_images():
    """ define_tools_images """


def define_platform_tools_images():
    """ define_platform_tools_images """


def build_new_image(params=None):
    """ build_new_image """
    image_name=params[0]
    image_path=params[1]

    print("Building image named: " + image_name)

    final_command = DOCKER_COMMAND + " " + BUILD_NEW_DOCKER_IMAGE_SUB_COMMAND + " " + image_path + " -t" + image_name
    
    process = subprocess.Popen(final_command, shell=True, stderr=sys.stderr, stdout=sys.stdout)
    process.wait()
    PROCS.append(process.pid)

def build_base_images():
    """ build_base_images """
    build_new_image((BASE_REPO + "/" + UBUNTU_NAME_STANDARD_VERSION_NUMBER + ":" + BASE, base_images[UBUNTU_NAME_STANDARD_VERSION_NUMBER],))
    build_new_image((BASE_REPO + "/" + UBUNTU_NAME_STANDARD_VERSION_NUMBER+":"+DEVELOPMENT, base_images[UBUNTU_NAME_STANDARD_VERSION_NUMBER_DEVELOPMENT],))
    build_new_image((BASE_REPO + "/" + UBUNTU_NAME_STANDARD_VERSION_NUMBER+":"+PYTHON+"_"+DEVELOPMENT, base_images[UBUNTU_NAME_STANDARD_VERSION_NUMBER_PYTHON_DEVELOPMENT],))

def build_packages():
    """ build_tools_images """
    build_new_image((PACKAGES_REPO + "/" + UBUNTU_NAME_STANDARD_VERSION_NUMBER + ":" + DEBMAKE, UBUNTU_STANDARD_DEVELOPMENT_BUILD_DEBMAKE,))

def build_python3s_packages():
    """ build_packages_images """
    #with Pool(processes=2) as pool:
    #    pool.map(build_new_image,[
    #        (PACKAGES_REPO + "/" + UBUNTU_NAME_STANDARD_VERSION_NUMBER_PYTHON_DEVELOPMENT + ":" + PYTHON3_3_6_8, UBUNTU_STANDARD_DEVELOPMENT_PYTHON_3_6_8_PATH,),
    #        (PACKAGES_REPO + "/" + UBUNTU_NAME_STANDARD_VERSION_NUMBER_PYTHON_DEVELOPMENT + ":" + PYTHON3_3_7_2, UBUNTU_STANDARD_DEVELOPMENT_PYTHON_3_7_2_PATH,),
    #        ])
    #build_new_image((PACKAGES_REPO + "/" + UBUNTU_NAME_STANDARD_VERSION_NUMBER_PYTHON_DEVELOPMENT + ":" + PYTHON3_3_6_8, UBUNTU_STANDARD_DEVELOPMENT_PYTHON_3_6_8_PATH,))

def run_program():
    """ run_program """

    define_base_images()
    define_tools_images()
    define_platform_tools_images()

    build_base_images()
    build_packages()
    build_python3s_packages()

if __name__ == "__main__":
    try:
        run_program()
    except KeyboarInterrupt:
        # https://stackoverflow.com/a/39503654
        # https://stackoverflow.com/a/4547350
        while PROCS:
            print(str(len(PROCS)))
            proc = PROCS.pop()
            proc.terminate()
        raise
