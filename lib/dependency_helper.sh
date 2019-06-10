#!/usr/bin/env bash


# Included by ../ofx


function install_libraries()
{
  echoFancy "Installing" "Libraries and System Dependencies"

  if [ -f ${THIS_ADDON_PATH}/scripts/${TARGET_PLATFORM}/install.sh ] ; then
    /usr/bin/env bash ${THIS_ADDON_PATH}/scripts/${TARGET_PLATFORM}/install.sh
  fi

  echoFancy "Installing" "3rd Party Libraries"

  if ! [ -f ${OF_APOTHECARY_PATH}/apothecary/apothecary ] ; then
    echoError "Apothecary not installed."
    exit 1;
  fi

  echoFancy "Building " "${THIS_ADDON_NAME} libraries for ${TARGET_PLATFORM}"
  /usr/bin/env bash ${OF_APOTHECARY_PATH}/apothecary/apothecary -j${JOBS} -t "${TARGET_PLATFORM}" -d "${THIS_ADDON_PATH}/libs" update "${THIS_ADDON_NAME}"
  echoSuccess "Build of ${THIS_ADDON_NAME} for ${TARGET_PLATFORM} complete."
}


