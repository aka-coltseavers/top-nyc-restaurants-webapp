#!/bin/bash

CURRDIR=$(dirname $0)
cd $CURRDIR/../
PROJECT_REPO_ROOTDIR=$(pwd)

CHECK_OS_TYPE=`uname`
case ${CHECK_OS_TYPE} in
Darwin ) CURR_OS_TYPE=osx;;
Linux ) CURR_OS_TYPE=linux;;
* ) echo "Unrecognized Operating System Type...defaulting to linux..."; CURR_OS_TYPE=linux;;
esac

if [ "$CURR_OS_TYPE" == "osx" ] ; then
    VENV_WORKSPACE_ROOTDIR=~/egcustom_python27_venv_library
    MONGODB_INSTALL_DESTDIR=/Developer/alt_dev_tools
else
    VENV_WORKSPACE_ROOTDIR=/opt/egcustom_python27_venv_library
    MONGODB_INSTALL_DESTDIR=/opt
fi
MONGODB_VERSION=3.0.6


#TODO - automate (likely via ansible) the installation of python v3.3.5 for YUM-based Linux Distro's

# Ensure mongoDB is installed and setup with the expected filepaths and writability
function establish_mongodb_exists() {
    if [[ ! -e "${MONGODB_INSTALL_DESTDIR}" ]] ; then
        mkdir ${MONGODB_INSTALL_DESTDIR}
    fi
    if [[ -z `ls -Am ${MONGODB_INSTALL_DESTDIR} | grep -o "mongodb"` ]] ; then
        cd /tmp/
        curl -O https://fastdl.mongodb.org/${CURR_OS_TYPE}/mongodb-${CURR_OS_TYPE}-x86_64-${MONGODB_VERSION}.tgz
        cd ${MONGODB_INSTALL_DESTDIR}
        tar -zxvf /tmp/mongodb-${CURR_OS_TYPE}-x86_64-${MONGODB_VERSION}.tgz
        mv mongodb-${CURR_OS_TYPE}-x86_64-${MONGODB_VERSION} mongodb
        rm /tmp/mongodb-${CURR_OS_TYPE}-x86_64-${MONGODB_VERSION}.tgz
        mkdir -p ${MONGODB_INSTALL_DESTDIR}/mongo_data/db
        chmod 777 ${MONGODB_INSTALL_DESTDIR}/mongo_data/db
        
    fi
    cd ${PROJECT_REPO_ROOTDIR}
}

function add_helper_aliases_to_bashprofile() {
    #cat ${PROJECT_REPO_ROOTDIR}/scripts/add_python33_to_path_codeblock.txt >> $HOME/.bash_profile
    #if [ "$CURR_OS_TYPE" == "osx" ] ; then
    #    cat ${PROJECT_REPO_ROOTDIR}/scripts/add_python33_to_path_codeblock.txt >> $HOME/.profile
    #fi
    cat ${PROJECT_REPO_ROOTDIR}/scripts/add_python27_to_path_codeblock.txt >> $HOME/.bash_profile
    if [ "$CURR_OS_TYPE" == "osx" ] ; then
        cat ${PROJECT_REPO_ROOTDIR}/scripts/add_python27_to_path_codeblock.txt >> $HOME/.profile
    fi
    MONGOD_ALIAS_COMMAND_STRING="alias start_demo_mongod=\"mongod --dbpath ${MONGODB_INSTALL_DESTDIR}/mongo_data/db &\""
    echo ${MONGOD_ALIAS_COMMAND_STRING} >> $HOME/.bash_profile
    if [ "$CURR_OS_TYPE" == "osx" ] ; then
        echo ${MONGOD_ALIAS_COMMAND_STRING} >> $HOME/.profile
    fi
}

function add_python33_to_path() {
    #---[ Adding Python-v3.3 to PATH variable for environment ]---
    PYTHON33_BIN_PATH=$(which python3.3 | sed -e "s/\/python3\.3//")
    if ([[ -e "$PYTHON33_BIN_PATH" ]] && [[ -z `echo $PATH | grep -o "${PYTHON33_BIN_PATH}"` ]]) ; then
        export PATH=$PYTHON33_BIN_PATH:$PATH
    fi
}

function add_python27_to_path() {
    #---[ Adding Python-v2.7 to PATH variable for environment ]---
    PYTHON27_BIN_PATH=$(which python2.7 | sed -e "s/\/python2\.7//")
    if ([[ -e "$PYTHON27_BIN_PATH" ]] && [[ -z `echo $PATH | grep -o "${PYTHON27_BIN_PATH}"` ]]) ; then
        export PATH=$PYTHON27_BIN_PATH:$PATH
    fi
}

function establish_python_venv_container() {
    source $HOME/.bash_profile
    if [ "$CURR_OS_TYPE" == "osx" ] ; then
        source $HOME/.profile
    fi
    #add_python33_to_path
    add_python27_to_path
    if [[ ! -e "${VENV_WORKSPACE_ROOTDIR}" ]] ; then
        mkdir ${VENV_WORKSPACE_ROOTDIR}
    fi
    # cd to top-level dir of working copy of git repo,
    cd $PROJECT_REPO_ROOTDIR
    PROJECT_WC_DIRNAME=$(echo $(pwd) | sed -e "s/^\/.*\///")
    GIT_BRANCH_LABEL=`git branch | grep -o -e "^\*.*$" | sed -e "s/^\* //" -e "s/\//-/"`
    
    if [[ -z `ls -Am ${VENV_WORKSPACE_ROOTDIR} | grep -o "venv-${PROJECT_WC_DIRNAME}"` ]] ; then
        cd ${VENV_WORKSPACE_ROOTDIR}/
        #virtualenv --always-copy --no-wheel --python=$(which python3.3) venv-${PROJECT_WC_DIRNAME}
        #ALIAS_COMMAND_STRING="alias start_python33_venv-${PROJECT_WC_DIRNAME}=\"add_python33_to_path; source ${VENV_WORKSPACE_ROOTDIR}/venv-${PROJECT_WC_DIRNAME}/bin/activate\""
        virtualenv --always-copy --no-wheel --python=$(which python2.7) venv-${PROJECT_WC_DIRNAME}
        ALIAS_COMMAND_STRING="alias start_python27_venv-${PROJECT_WC_DIRNAME}=\"add_python27_to_path; source ${VENV_WORKSPACE_ROOTDIR}/venv-${PROJECT_WC_DIRNAME}/bin/activate\""
        echo ${ALIAS_COMMAND_STRING} >> $HOME/.bash_profile
        if [ "$CURR_OS_TYPE" == "osx" ] ; then
            echo ${ALIAS_COMMAND_STRING} >> $HOME/.profile
        fi
    fi
    
    # Printout Instructions and Prerequisites for running the project app
    echo " "
    echo "Usage Instructions: "
    echo "-------------------"
    echo "To run this project, it requires:"
    echo "  - Python3 installed on hostmachine (built and tested with v3.3)"
    echo "  - Environment OS is Mac or Linux"
    echo "  - Python3 is added or already in the Path before running the venv"
    echo " "
    echo "Then run the following command:"
    echo "   source ${VENV_WORKSPACE_ROOTDIR}/venv-${PROJECT_WC_DIRNAME}/bin/activate"
    echo " OR "
    echo "  just re-source your bash_profile and run:  start_python27_venv-${PROJECT_WC_DIRNAME} "
    
}

if [[ ! -e "${MONGODB_INSTALL_DESTDIR}/mongo_data/db" ]] ; then
    establish_mongodb_exists
    add_helper_aliases_to_bashprofile
fi
establish_python_venv_container
