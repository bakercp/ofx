#!/usr/bin/env bash

# \brief Convert a string to lower case.
# \param $1 A string.
# \returns a lowercase string an a 0 exit code on success.
function lowercase()
{
  echo "${1}" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
  return 0
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

# via https://stackoverflow.com/a/24848739/1518329
function relpath()
{
  echo $(perl -e 'use File::Spec; print File::Spec->abs2rel(@ARGV) . "\n"' ${1} ${2})

  # b=""
  # s=$(cd ${1%%/}; pwd); 
  # d=$(cd $2;pwd);
  # while [ "${d#$s/}" == "${d}" ]
  # do s=$(dirname $s);
  # b="../${b}"; 
  # done; 
  # echo ${b}${d#$s/}
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

  if [ "$(host_os)" == "linuxarmv6l" ] || [ "$(host_os)" == "linuxarmv7l" ]; then 
    n_processors = $((n_processors-1))
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

# \brief Clean all project files from the given project.
# \param $1 The project to clean.
# \param $2 (optional) To force clean all project files.
# \returns 0 exit code on success.
function clean_project_files()
{
  local FORCE_CLEAN=false

  if [ $# -gt 1 ] && [ "$2" == "force" ]; then
    FORCE_CLEAN=true
  fi

  if [ "${FORCE_CLEAN}" == "true" ]; then
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
  local FORCE_CLEAN=false

  if [ $# -gt 1 ] && [ "$2" == "force" ]; then
    FORCE_CLEAN=true
  fi

  # QTCreatorBuild paths
  find -L $1 -maxdepth 1 \( \
      -type d -a \
      -name "build-example*" \
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
  echo $(find -L $1 -name addons.make -exec dirname {} \;)
  return 0
}

function find_example_projects()
{
  # echo ">> $1/example*"

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
  PROJECT_PATH=$1

  echo "---"

  pushd $PROJECT_PATH > /dev/null

  echo "BUILDING PROJECT"
  pwd
  ls -la
  echo ${PROJECT_PATH}
  echo ${JOBS}
  echo ${OF_ROOT}
  cat Makefile

  make -j${JOBS} -s
  popd > /dev/null
}


function run_project()
{

  PROJECT_PATH=$1

  echo "---"

  pushd $PROJECT_PATH > /dev/null

  echo "RUNNING PROJECT"
  pwd
  ls -la
  echo ${PROJECT_PATH}
  echo ${JOBS}
  echo ${OF_ROOT}
  cat Makefile


  make -j${JOBS} -s run
  popd > /dev/null
}
