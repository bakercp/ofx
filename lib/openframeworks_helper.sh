#!/usr/bin/env bash

# Included by ofx

function install_openframeworks()
{
    echoFancy "Installing" "openFrameworks"
    if [ ! -d ${OF_ROOT} ]; then
        git clone --depth=${OF_CLONE_DEPTH} --branch=${OF_CLONE_BRANCH} https://github.com/${OF_CLONE_USERNAME}/openFrameworks.git ${OF_ROOT}
        pushd ${OF_ROOT} > /dev/null
        scripts/ci/addons/install.sh

        # Undo this https://github.com/openframeworks/openFrameworks/blob/master/scripts/ci/addons/install.sh#L39 
        # because we use a symlink.
        mv ${THIS_ADDON_PATH} ${TRAVIS_BUILD_DIR}

        popd > /dev/null
    else 
        echoWarning "${OF_ROOT} already exists"
    fi
}

