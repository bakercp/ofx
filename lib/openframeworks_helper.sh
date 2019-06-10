#!/usr/bin/env bash

# Included by ofx

function install_openframeworks()
{
    git clone --depth=${OF_CLONE_DEPTH} --branch=${OF_CLONE_BRANCH} https://github.com/${OF_CLONE_USERNAME}/openFrameworks.git ${OF_ROOT}
}

