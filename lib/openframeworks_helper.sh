#!/usr/bin/env bash

# Included by ofx

function install_openframeworks()
{
  if [ -d $1 ]; then 
    pushd $1 > /dev/null
    git clone --depth=${OF_CLONE_DEPTH} --branch=${OF_CLONE_BRANCH} https://github.com/${OF_CLONE_USERNAME}/openFrameworks
    popd > /dev/null
    exit 0
  else 
    echoError "openFrameworks install directory does not exist: \"$1\""
    exit 1
  fi
}

