#!/usr/bin/env bash

# Included by ofx

function install_openframeworks()
{
    echoFancy "Installing" "openFrameworks"
    if [ ! -d ${1} ]; then
        git clone --depth=${OF_CLONE_DEPTH} --branch=${OF_CLONE_BRANCH} https://github.com/${OF_CLONE_USERNAME}/openFrameworks.git ${1}
    else 
        echoWarning "${1} already exists"
    fi
}

