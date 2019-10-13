#!/usr/bin/env bash


# Included by ../ofx


function install_libraries()
{
  THE_ADDON_NAME=$1
  THE_ADDON_PATH=$2

  echoInfo "Installing" "Libraries and System Dependencies"

  if [ -f ${THE_ADDON_PATH}/scripts/${TARGET_PLATFORM}/install.sh ] ; then
    /usr/bin/env bash ${THE_ADDON_PATH}/scripts/${TARGET_PLATFORM}/install.sh
  fi

  echoInfo "Installing" "3rd Party Libraries"

  if ! [ -f ${OF_APOTHECARY_PATH}/apothecary/apothecary ] ; then
    echoError "Apothecary not installed."
    exit 1;
  fi

  echoInfo "Building " "${THE_ADDON_NAME} libraries for ${TARGET_PLATFORM}"
  /usr/bin/env bash ${OF_APOTHECARY_PATH}/apothecary/apothecary -j${JOBS} -t "${TARGET_PLATFORM}" -d "${THE_ADDON_PATH}/libs" update "${THE_ADDON_NAME}"
  echoSuccess "Build of ${THE_ADDON_NAME} for ${TARGET_PLATFORM} complete."
}


