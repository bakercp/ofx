#!/usr/bin/env bash
#
# Copyright (c) 2019 Christopher Baker <https://christopherbaker.net>
#
# SPDX-License-Identifier:	MIT
#


# \brief Convert a string to lower case.
# \param $1 A string.
# \returns a lowercase string an a 0 exit code on success.
function lowercase()
{
  echo "${1}" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
  return 0
}

# \brief Convert a string to upper case.
# \param $1 A string.
# \returns an uppercase string an a 0 exit code on success.
function uppercase()
{
  echo "${1}" | sed "y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/"
  return 0
}


# Logging
LOG_VERBOSE_NONE=0
#LOG_VERBOSE_LOW=1
#LOG_VERBOSE_MEDIUM=2
#LOG_VERBOSE_HIGH=3

# Verbose level.
LOG_LEVEL=$LOG_VERBOSE_NONE

# ANSI console escape codes.
ANSI_COLOR_DEFAULT="0"
ANSI_COLOR_RED="31"
ANSI_COLOR_YELLOW="33"
ANSI_COLOR_GREEN="32"
ANSI_COLOR_PURPLE="35"

CON_DEFAULT="\033[${ANSI_COLOR_DEFAULT}m"

CON_BOLD="\033[1m"
CON_UNDERLINE="\033[4m"

CON_RED="\033[${ANSI_COLOR_RED}m"
CON_RED_BOLD="\033[${ANSI_COLOR_RED};1m"
CON_RED_UNDERLINE="\033[${ANSI_COLOR_RED};4m"
CON_RED_BOLD_UNDERLINE="\033[${ANSI_COLOR_RED};1;4m"

CON_YELLOW="\033[${ANSI_COLOR_YELLOW}m"
CON_YELLOW_BOLD="\033[${ANSI_COLOR_YELLOW};1m"
CON_YELLOW_UNDERLINE="\033[${ANSI_COLOR_YELLOW};4m"
CON_YELLOW_BOLD_UNDERLINE="\033[${ANSI_COLOR_YELLOW};1;4m"

CON_GREEN="\033[${ANSI_COLOR_GREEN}m"
CON_GREEN_BOLD="\033[${ANSI_COLOR_GREEN};1m"
CON_GREEN_UNDERLINE="\033[${ANSI_COLOR_GREEN};4m"
CON_GREEN_BOLD_UNDERLINE="\033[${ANSI_COLOR_GREEN};1;4m"

echoIconColorMessage() {
  if [ $# -lt 3 ]; then
    echo -e "Three parameters required: icon, color, message".
    exit 1
  fi

  local icon=${1}
  local color=${2}

  local _CON_BOLD_UNDERLINE="\033[${color};1;4m"
  local _CON_BOLD="\033[${color};1m"
  local _CON_UNDERLINE="\033[${color};4m"
  local _CON_NONE="\033[${color}m"

  shift 2

  local message=""
  if [ $# -gt 2 ]; then message="$_CON_BOLD_UNDERLINE$(uppercase ${1})$CON_DEFAULT "; shift 1; fi

  if [ $# -gt 1 ]; then message="${message}$_CON_BOLD$1$CON_DEFAULT "; shift 1; fi

  message="${message}$_CON_NONE$@$CON_DEFAULT";

  echo -e "${icon}  ${message}";

}

# Console printing functions (with color).
echoError() {
  (echoIconColorMessage "❌" "${ANSI_COLOR_RED}" "$@");
}

echoWarning() {
  (echoIconColorMessage "⚠️" "${ANSI_COLOR_YELLOW}" "$@");
}

echoInfo() {
  (echoIconColorMessage "ℹ️" "${ANSI_COLOR_DEFAULT}" "$@");
}

echoSuccess() {
  (echoIconColorMessage "✅️" "${ANSI_COLOR_GREEN}" "$@");
}

echoVerbose() {
  if [ $LOG_LEVEL -gt $LOG_VERBOSE_NONE ] ; then
    (echoIconColorMessage "📢️" "${ANSI_COLOR_PURPLE}" "$@");
  fi
}


# \brief Get the openFrameworks name of the host operating system.
# \returns a string an a 0 exit code on success.
function os()
{
  local OS
  OS="$(lowercase "$(uname)")"

  if [ "${OS}" == "darwin" ]; then
    OS="osx"
  elif [ "${OS}" == "windowsnt" ] ; then
    OS="vs"
  elif [ "${OS:0:5}" == "mingw" ] || [ "${OS}" == "msys_nt-6.3" ]; then
    OS="msys2"
  elif [ "${OS}" == "linux" ]; then
    ARCH=`uname -m`
    if [ "${ARCH}" == "i386" ] || [ "${ARCH}" == "i686" ] ; then
      OS="linux"
    elif [ "${ARCH}" == "x86_64" ] ; then
      OS="linux64"
    elif [ "${ARCH}" == "armv6l" ] ; then
      OS="linuxarmv6l"
    elif [ "${ARCH}" == "armv7l" ] ; then
      # Make an exception for raspberry pi to run on armv6l, to conform
      # with openFrameworks.
      if [ -f /opt/vc/include/bcm_host.h ]; then
        OS="linuxarmv6l"
      else
        OS="linuxarmv7l"
      fi
    else
      # We don't know this one, but we will try to make a reasonable guess.
      OS="linux"${ARCH}
    fi
  fi
  echo ${OS}
  return 0
}


# https://stackoverflow.com/a/21188136/1518329
get_abs_filename() {
  # $1 : relative filename
  filename=$1
  parentdir=$(dirname "${filename}")

  if [ -d "${filename}" ]; then
    echo "$(cd "${filename}" && pwd)"
  elif [ -d "${parentdir}" ]; then
    echo "$(cd "${parentdir}" && pwd)/$(basename "${filename}")"
  fi
}


# via https://stackoverflow.com/a/24848739/1518329
function relpath()
{
  echo $(perl -e 'use File::Spec; print File::Spec->abs2rel(@ARGV) . "\n"' ${1} ${2})
}


function get_max_number_of_jobs()
{
  local host_os=$(os)

  local n_processors=1

  if [ "${host_os}" == "osx" ]; then
    n_processors=$(sysctl -n hw.ncpu)
  else
    n_processors=$(nproc)
  fi

  # Remove one processor for low RAM devices.
  if [[ "${host_os}" == linuxarm* ]]; then
    ((n_processors-=1))
  fi

  echo ${n_processors}
}

# \brief Get the openFrameworks name of the host operating system.
# \param $1 The space-delimited string to de-duplicated and sort.
# \returns a string an a 0 exit code on success.
function sort_and_remove_duplicates()
{
    echo $(echo ${1} | tr ' ' '\n' | sort -u | tr '\n' ' ')
    return 0
}

# \brief Compare two files using cmp.
# \param $1 The first file.
# \param $2 The second file.
# \returns a "1" on match or a "0" on failure and a 0 exit code on success.
function is_same_file()
{
  cmp --silent $1 $2 && echo "1" || echo "0"
  return 0;
}


function remove_os_files
{
  echoInfo "Removing os files for $1"

  find $1 -depth \
  \( \
        -name ".DS_Store" \
    -o -name ".AppleDouble" \
  \) \
  -exec rm -rf {} \;
}

function remove_empty_data_folders
{
  echoInfo "Removing empty data folders for $1"

  find $1 -depth -empty -type d \
  \( \
        -name "data" \
  \) \
  -exec rm -rf {} \;
}


function remove_empty_bin_folders
{
  echoInfo "Removing empty bin folders for $1"

  find $1 -depth -empty -type d \
  \( \
        -name "bin" \
  \) \
  -exec rm -rf {} \;
}


# \brief Clean all project files from the given project.
# \param $1 The project to clean.
# \param $2 (optional) To force clean all project files.
# \returns 0 exit code on success.
function clean_project_files()
{
  if [ "${FORCE}" == "true" ]; then
    # Here we force clean the makefiles and config.make.
    find -L $1 -maxdepth 1 \
    \( \
         -name "*.qbs" \
      -o -name "*.xcodeproj" \
      -o -name "*.xcconfig" \
      -o -name "*.plist" \
      -o -name "*.qbs.user" \
      -o -name "config.make" \
      -o -name "Makefile" \
    \) \
    -exec rm -rf {} \;
  else
    find -L $1 -maxdepth 1 \
    \( \
         -name "*.qbs" \
      -o -name "*.xcodeproj" \
      -o -name "*.xcconfig" \
      -o -name "*.plist" \
      -o -name "*.qbs.user" \
    \) \
    -exec rm -rf {} \;
  fi

  echoSuccess "Cleaned Project Files For: $1"

  return 0;
}


# \brief Clean all build files from the given project.
# \param $1 The project to clean.
# \param $2 (optional) To force clean all build files.
# \returns 0 exit code on success.
function clean_project_build_files()
{
  # QTCreatorBuild paths
  # find -L $1 -maxdepth 1 \( \
  #     -type d -a \
  #     -name "build-*" \
  #   \)  -exec rm -rf {} \;

  # Get the build files in the parent directory.
  find -L $1/.. -maxdepth 2 \( \
      -type d -a \
      -name "build-*" \
    \)  -exec rm -rf {} \;

  find -L $1 -maxdepth 1 \( \
        -type d -a \
        -name "_obj*" \
    \)  -exec rm -rf {} \;

  # Project build files
  find -L $1 -maxdepth 1 \( \
      -type d -a \
      -name "obj" \
    \)  -exec rm -rf {} \;

  if [ -d $1/bin ] ; then
    # Project app files
    find -L $1/bin -maxdepth 1 \( \
         -name "*.app" \
      -o -name "*.app.dSYM" \
      -o -name "PkgInfo" \
      -o -name ".tmp" \
      -o -name "*.plist" \
      \)  -exec rm -rf {} \;
  fi
  echoSuccess "Cleaned Build Files For: $1"

  return 0;
}


# \brief PrintHere we just print the parent directory.
# \param $1 The addon directory to search.
# \returns 0 exit code on success.
function find_projects()
{
  if [ ! -d $1 ]; then
    echo ""
  elif [ "${TARGET_PLATFORM}" == "ios" ] ; then
    echo $(find -L $1 -name addons.make -path "*/ios/*" -o -path "*/*-ios/*" -exec dirname {} \;)
  elif [ "${TARGET_PLATFORM}" == "android" ] ; then
    echo $(find -L $1 -name addons.make -path "*/android/*" -o -path "*/*-android/*"-exec dirname {} \;)
  else 
    echo $(find -L $1 -name addons.make -not -path "*/ios/*" -not -path "*/*-ios/*" -not -path "*/android/*" -not -path "*/*-android/*" -exec dirname {} \;)
  fi

  return 0
}


function find_example_projects()
{
  echo $(find_projects "$1/example*")
  return 0
}


# \brief Print every test folder with a valid addons.make path.
function find_test_projects()
{
  echo $(find_projects "$1/tests")
  return 0
}


# Extract ADDON_DEPENDENCIES from an addon's addon_config.mk file.
function get_addon_dependencies_for_addon()
{
  if [ -f $1/addon_config.mk ]; then
    local ADDON_DEPENDENCIES=""
    while read line; do
      if [[ $line == ADDON_DEPENDENCIES* ]] ;
      then
        line=${line#*=}
        IFS=' ' read -ra ADDR <<< "$line"
        for i in "${ADDR[@]}"; do
          ADDON_DEPENDENCIES="${ADDON_DEPENDENCIES} ${i}"
        done
      fi
    done < $1/addon_config.mk
    echo $(sort_and_remove_duplicates "${ADDON_DEPENDENCIES}")
  fi
  return 0
}


# Extract ADDON_DEPENDENCIES from an project's addons.make files.
function get_addon_dependencies_for_project()
{
  local ADDON_DEPENDENCIES=""
  while read addon; do
    ADDON_DEPENDENCIES="${ADDON_DEPENDENCIES} ${addon}"
  done < $1/addons.make
  echo $(sort_and_remove_duplicates "${ADDON_DEPENDENCIES}")
  return 0
}


function build_project()
{
  echoInfo "🔨 Building" "$1"
  pushd $1 > /dev/null

  # TODO pass additional arguments to make.

  if [ $LOG_LEVEL -gt $LOG_VERBOSE_NONE ] ; then
    make -j${JOBS}
  else 
    make -j${JOBS} -s 
  fi

  #make -j${JOBS} -s DebugNoOF
  popd > /dev/null
}


function run_project()
{
  echoInfo "🏃‍ Running" "$1"
  pushd $1 > /dev/null

  # TODO pass additional arguments to make.

  if [ $LOG_LEVEL -gt $LOG_VERBOSE_NONE ] ; then
    make -j${JOBS} run
  else 
    make -j${JOBS} run -s 
  fi

  popd > /dev/null
}
