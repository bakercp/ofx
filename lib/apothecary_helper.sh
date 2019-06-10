#!/usr/bin/env bash

# Included by ../ofx

function clean_apothecary()
{
  if ! [ -f ${OF_APOTHECARY_PATH}/apothecary/apothecary ] ; then
    echoError "Apothecary not installed."
    exit 1;
  fi

  echoFancy "Cleaning " "${THIS_ADDON_NAME} libraries for ${TARGET_PLATFORM}"
  /usr/bin/env bash ${OF_APOTHECARY_PATH}/apothecary/apothecary -j ${JOBS} -t "${TARGET_PLATFORM}" -d "${THIS_ADDON_PATH}/libs" clean "${THIS_ADDON_NAME}"
  echoSuccess "Cleaning of ${THIS_ADDON_NAME} for ${TARGET_PLATFORM} complete."
}


function install_apothecary()
{
  # Check to see if apothecary is already installed.
  if ! [ -f ${OF_APOTHECARY_PATH}/apothecary/apothecary ] ; then
    echoInfo "Apothecary not installed, pulling latest version."
    git clone https://github.com/openframeworks/apothecary.git ${OF_APOTHECARY_PATH}/
  else
    pushd "${OF_APOTHECARY_PATH}/" > /dev/null
    if git rev-parse --is-inside-work-tree ; then
        echoInfo "Apothecary is under git control, updating."
        git pull origin master
    else
        echoWarning "Apothecary is not under git control, so it may not be up-to-date."
    fi
    popd > /dev/null
  fi

  if [ "${HOST_PLATFORM}" == "osx" ]; then
    if ! [ -x "$(command -v brew)" ]; then
      echoError "Brew is not installed. Go here and install it: https://brew.sh/." >&2
      exit 1
    else
      echoInfo "Brew is installed, continuing."
    fi

    if xcrun -sdk iphoneos --show-sdk-version ; then
      echoInfo "macOS iOS SDK Found"
    else
      echoError "The SDK path is not set correctly ..."

      if ! [ -e "/Applications/Xcode.app/Contents/Developer" ]; then
        echoError "Xcode is NOT installed."
        echoError "Install it from the App Store, then open the application and agree to the license."
      else
        echoError "Xcode is installed, so try running:"
        echo ""
        echoWarning "    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer/"
        echo ""
        echoWarning "    Or ..."
        echo ""
        echoWarning "    1) Open Xcode Preferences ..."
        echoWarning "    2) Got to the Locations tab ..."
        echoWarning "    3) Make sure the Command Line Tools are set to the latest version ..."
        echo ""
      fi

      echoError "Then run this command again."

      exit 1
    fi
  fi

  # Install any apothecary dependencies.
  if [ -f ${OF_APOTHECARY_PATH}/scripts/${HOST_PLATFORM}/install.sh ] ; then
    echoFancy "Installing" "Apothecary Dependencies"
    /usr/bin/env bash ${OF_APOTHECARY_PATH}/scripts/${HOST_PLATFORM}/install.sh
  else
    echoInfo "No additional apothecary dependencies to install."
  fi

  echoSuccess "Done installing apothecary."
}