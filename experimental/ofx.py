# https://docs.python.org/3/howto/argparse.html

import argparse
import os

parser = argparse.ArgumentParser()

parser.add_argument("command", 
                    type=str, 
                    help="The command to use.",
                    choices=['bootstrap', 'clean', 'install'])


parser.add_argument("-j", "--jobs", type=int, default=1, help="Number of jobs (cores) to use when compiling.")
parser.add_argument("--project_generator_path", type=str, default="", help="Project Generator path")
parser.add_argument("--of_root", type=str, default="", help="The openFrameworks root path.")
parser.add_argument("-v", "--verbose", action='count', help="Enable verbose output,")

args = parser.parse_args()

print(args)

# Determine if we are running in a CI environment.
CI = os.getenv('CI', False)
APPVEYOR = os.getenv('APPVEYOR', False)
TRAVIS = os.getenv('TRAVIS', False)

if CI:
    OF_ROOT=~/openFrameworks
    if APPVEYOR:
        THIS_ADDON_NAME=os.getenv("APPVEYOR_PROJECT_SLUG", "")
        THIS_ADDON_USERNAME=os.getenv("APPVEYOR_PROJECT_SLUG", "")
        THIS_BRANCH=os.getenv("APPVEYOR_REPO_BRANCH", "")
    elif TRAVIS
        THIS_ADDON_NAME=os.getenv("APPVEYOR_PROJECT_SLUG", "")
        THIS_ADDON_USERNAME=os.getenv("APPVEYOR_PROJECT_SLUG", "")
        THIS_BRANCH=os.getenv("APPVEYOR_REPO_BRANCH", "")
else:
    OF_ROOT=${OF_ROOT:-$(cd "$( dirname "${BASH_SOURCE[0]}" )/../../../.." && pwd)}
    THIS_ADDON_NAME=$(basename "$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.."  && pwd)")
    THIS_USERNAME=$(whoami)
    THIS_BRANCH=$(git rev-parse --abbrev-ref HEAD)


# # This script should live in the scripts directory of the addon.
# if [ ! -z ${_CI} ] && [ "$_CI" = true ]; then
#   OF_ROOT=${OF_ROOT:-~/openFrameworks}
#   if [ ! -z ${_APPVEYOR} ] && [ "$_APPVEYOR" = true ]; then
#     THIS_ADDON_NAME=${APPVEYOR_PROJECT_SLUG#*/}
#     THIS_USERNAME=${APPVEYOR_PROJECT_SLUG%/*}
#     THIS_BRANCH=${APPVEYOR_REPO_BRANCH}
#   elif [ ! -z ${_TRAVIS} ] && [ "$_TRAVIS" = true ]; then
#     THIS_ADDON_NAME=${TRAVIS_REPO_SLUG#*/}
#     THIS_USERNAME=${TRAVIS_REPO_SLUG%/*}
#     THIS_BRANCH=${TRAVIS_BRANCH}
#   fi
# else
#   OF_ROOT=${OF_ROOT:-$(cd "$( dirname "${BASH_SOURCE[0]}" )/../../../.." && pwd)}
#   THIS_ADDON_NAME=$(basename "$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.."  && pwd)")
#   THIS_USERNAME=$(whoami)
#   THIS_BRANCH=$(git rev-parse --abbrev-ref HEAD)
# fi

# # OF paths.
# OF_ADDONS_PATH=${OF_ADDONS_PATH:-${OF_ROOT}/addons}
# OF_SCRIPTS_PATH=${OF_SCRIPTS_PATH:-${OF_ROOT}/scripts}
# OF_APOTHECARY_PATH=${OF_APOTHECARY_PATH:-${OF_SCRIPTS_PATH}/apothecary}

# # Addon paths.
# THIS_ADDON_PATH=${THIS_ADDON_PATH:-${OF_ADDONS_PATH}/${THIS_ADDON_NAME}}
# THIS_ADDON_SHARED_PATH=${THIS_ADDON_SHARED_PATH:-${THIS_ADDON_PATH}/shared}
# THIS_ADDON_SHARED_DATA_PATH=${THIS_ADDON_SHARED_DATA_PATH:-${THIS_ADDON_SHARED_PATH}/data}
# THIS_ADDON_SCRIPTS_PATH=${THIS_ADDON_SCRIPTS_PATH:-${THIS_ADDON_PATH}/scripts}

# # OF Clone info.
# OF_CLONE_DEPTH=${OF_CLONE_DEPTH:-${DEFAULT_CLONE_DEPTH}}
# OF_CLONE_BRANCH=${OF_CLONE_BRANCH:-${THIS_BRANCH}}
# OF_CLONE_USERNAME=${OF_CLONE_USERNAME:-openFrameworks}

# # Addon Clone info.
# ADDON_CLONE_DEPTH=${ADDON_CLONE_DEPTH:-${DEFAULT_CLONE_DEPTH}}
# ADDON_CLONE_BRANCH=${ADDON_CLONE_BRANCH:-${THIS_BRANCH}}
# ADDON_CLONE_USERNAME=${ADDON_CLONE_USERNAME:-${THIS_USERNAME}}

# OF_PROJECT_GENERATOR_PATH=${OF_PROJECT_GENERATOR_PATH:-$OF_ROOT:/projectGenerator-osx}

# if [ $_VERBOSE == 1 ]; then
#   echo "================================================================================"
#   echo ""
#   echo "                                     _CI: ${_CI}"
#   echo "                               _APPVEYOR: ${_APPVEYOR}"
#   echo "                                 _TRAVIS: ${_TRAVIS}"
#   echo ""
#   echo "                                 OF_ROOT: ${OF_ROOT}"
#   echo "                          OF_ADDONS_PATH: ${OF_ADDONS_PATH}"
#   echo "                         OF_SCRIPTS_PATH: ${OF_SCRIPTS_PATH}"
#   echo "                      OF_APOTHECARY_PATH: ${OF_APOTHECARY_PATH}"
#   echo "               OF_PROJECT_GENERATOR_PATH: ${OF_PROJECT_GENERATOR_PATH}"
#   echo ""
#   echo "                         THIS_ADDON_NAME: ${THIS_ADDON_NAME}"
#   echo "                         THIS_ADDON_PATH: ${THIS_ADDON_PATH}"
#   echo "             THIS_ADDON_SHARED_DATA_PATH: ${THIS_ADDON_SHARED_DATA_PATH}"
#   echo "                 THIS_ADDON_SCRIPTS_PATH: ${THIS_ADDON_SCRIPTS_PATH}"
#   echo ""
#   echo "                           THIS_USERNAME: ${THIS_USERNAME}"
#   echo "                             THIS_BRANCH: ${THIS_BRANCH}"
#   echo ""
#   echo "                          OF_CLONE_DEPTH: ${OF_CLONE_DEPTH}"
#   echo "                         OF_CLONE_BRANCH: ${OF_CLONE_BRANCH}"
#   echo "                       OF_CLONE_USERNAME: ${OF_CLONE_USERNAME}"
#   echo ""
#   echo "                       ADDON_CLONE_DEPTH: ${ADDON_CLONE_DEPTH}"
#   echo "                      ADDON_CLONE_BRANCH: ${ADDON_CLONE_BRANCH}"
#   echo "                    ADDON_CLONE_USERNAME: ${ADDON_CLONE_USERNAME}"
#   echo ""
#   echo "================================================================================"
# fi



