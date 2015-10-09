#!/bin/bash

CURRDIR=$(dirname $0)
cd $CURRDIR/../
PROJECT_REPO_ROOTDIR=$(pwd)

VENV_WORKSPACE_ROOTDIR=$HOME/custom_venv_test_library
MONGODB_INSTALL_DESTDIR=/opt
MONGODB_VERSION=3.0.6

function establish_mongodb_exists() {
    if [[ ! -e "${MONGODB_INSTALL_DESTDIR}" ]] ; then
        mkdir ${MONGODB_INSTALL_DESTDIR}
    fi
    if [[ -z `ls -Am ${MONGODB_INSTALL_DESTDIR} | grep -o "mongodb"` ]] ; then
        cd /tmp/
        curl -O https://fastdl.mongodb.org/osx/mongodb-osx-x86_64-${MONGODB_VERSION}.tgz
        cd ${MONGODB_INSTALL_DESTDIR}
        tar -zxvf /tmp/mongodb-osx-x86_64-${MONGODB_VERSION}.tgz
        mv mongodb-osx-x86_64-${MONGODB_VERSION} mongodb
        rm /tmp/mongodb-osx-x86_64-${MONGODB_VERSION}.tgz
    fi
    #---[ Adding MongoDB to PATH variable for environment ]---
    MONGODB_BIN_PATH=${MONGODB_INSTALL_DESTDIR}/mongodb/bin
    if ([[ -e "$MONGODB_BIN_PATH" ]] && [[ -z `echo $PATH | grep -o "${MONGODB_BIN_PATH}"` ]]) ; then
        export PATH=$PATH:$MONGODB_BIN_PATH
    fi
    cd ${PROJECT_REPO_ROOTDIR}
}

function add_python33_to_path() {
    #---[ Adding Python-v3.3 to PATH variable for environment ]---
    PYTHON3_BIN_PATH=$(which python3.3 | sed -e "s/\/python3\.3//")
    if ([[ -e "$PYTHON3_BIN_PATH" ]] && [[ -z `echo $PATH | grep -o "${PYTHON3_BIN_PATH}"` ]]) ; then
        export PATH=$PYTHON3_BIN_PATH:$PATH
    fi
}

function establish_python_venv_container() {
    add_python33_to_path
    if [[ ! -e "${VENV_WORKSPACE_ROOTDIR}" ]] ; then
        mkdir ${VENV_WORKSPACE_ROOTDIR}
    fi
    # cd to top-level dir of working copy of git repo,
    cd $PROJECT_REPO_ROOTDIR
    PROJECT_WC_DIRNAME=$(echo $(pwd) | sed -e "s/^\/.*\///")
    GIT_BRANCH_LABEL=`git branch | grep -o -e "^\*.*$" | sed -e "s/^\* //" -e "s/\//-/"`
    
    if [[ -z `ls -Am ${VENV_WORKSPACE_ROOTDIR} | grep -o "venv-${PROJECT_WC_DIRNAME}"` ]] ; then
        cd ${VENV_WORKSPACE_ROOTDIR}/
        virtualenv --always-copy --no-wheel --python=$(which python3.3) venv-${PROJECT_WC_DIRNAME}
        ALIAS_COMMAND_STRING="alias start_venv-${PROJECT_WC_DIRNAME}=\"add_python33_to_path; source ${VENV_WORKSPACE_ROOTDIR}/venv-${PROJECT_WC_DIRNAME}/bin/activate\""
        echo ${ALIAS_COMMAND_STRING} >> $HOME/.profile
        echo ${ALIAS_COMMAND_STRING} >> $HOME/.bash_profile
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
    
}

establish_mongodb_exists
establish_python_venv_container
