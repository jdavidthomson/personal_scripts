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

#### supported base image names ####


#### supported version codes for python####
PYTHON3_3_6_8="3.6.8"
PYTHON3_3_7_2="3.7.2"

UBUNTU_STANDARD_DEVELOPMENT_PYTHON_3_6_8=os.path.join(BI_PATH, UBUNTU_NAME_STANDARD_VERSION_NUMBER_PYTHON_DEVELOPMENT, PYTHON3_3_6_8)
UBUNTU_STANDARD_DEVELOPMENT_PYTHON_3_7_2=os.path.join(BI_PATH, UBUNTU_NAME_STANDARD_VERSION_NUMBER_PYTHON_DEVELOPMENT, PYTHON3_3_7_2)
#####################################
#                                   #
#       END CONSTANTS               #
#                                   #
#####################################

base_images=dict()
tools=dict()
platform_tools=dict()

def define_base_images():
    """ define_base_images """
    base_images[UBUNTU_NAME_STANDARD_VERSION_NUMBER]=os.path.join(BI_PATH, UBUNTU_NAME_STANDARD_VERSION_NUMBER,"")
    base_images[UBUNTU_NAME_STANDARD_VERSION_NUMBER_DEVELOPMENT]=os.path.join(BI_PATH, UBUNTU_NAME_STANDARD_VERSION_NUMBER_DEVELOPMENT,"")
    base_images[UBUNTU_NAME_STANDARD_VERSION_NUMBER_PYTHON_DEVELOPMENT]=os.path.join(BI_PATH, UBUNTU_NAME_STANDARD_VERSION_NUMBER_PYTHON_DEVELOPMENT,"")

def define_tools_images():
    """ define_tools_images """


def define_platform_tools_images():
    """ define_platform_tools_images """


def build_new_image(image_name=None, image_path=None):
    """ build_new_image """
    final_command = DOCKER_COMMAND + " " + BUILD_NEW_DOCKER_IMAGE_SUB_COMMAND + " " + image_path + " -t" + image_name
    
    process = subprocess.Popen(final_command, shell=True, stderr=sys.stderr, stdout=sys.stdout)

def build_base_images():
    """ build_base_images """
    build_new_image(UBUNTU_NAME_STANDARD_VERSION_NUMBER + ":" + BASE, base_images[UBUNTU_NAME_STANDARD_VERSION_NUMBER])
    build_new_image(UBUNTU_NAME_STANDARD_VERSION_NUMBER_DEVELOPMENT + ":" + DEVELOPMENT, base_images[UBUNTU_NAME_STANDARD_VERSION_NUMBER_DEVELOPMENT])
    build_new_image(UBUNTU_NAME_STANDARD_VERSION_NUMBER_PYTHON_DEVELOPMENT + ":" + PYTHON + "_" + DEVELOPMENT, base_images[UBUNTU_NAME_STANDARD_VERSION_NUMBER_PYTHON_DEVELOPMENT])

    with Pool(processes=2) as pool:
        pool.map(build_new_image[
            [UBUNTU_STANDARD_DEVELOPMENT_PYTHON_3_6_8 + ":" + BASE, base_images[UBUNTU_NAME_STANDARD_VERSION_NUMBER_DEVELOPMENT]],
            [UBUNTU_STANDARD_DEVELOPMENT_PYTHON_3_7_2 + ":" + BASE, base_images[UBUNTU_NAME_STANDARD_VERSION_NUMBER_PYTHON_DEVELOPMENT]]
            ])

def run_program():
    """ run_program """

    define_base_images()
    define_tools_images()
    define_platform_tools_images()

    build_base_images()

if __name__ == "__main__":
    run_program()
