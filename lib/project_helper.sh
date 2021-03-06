#!/usr/bin/env bash


# Included by ../ofx


function do_function_for_projects
{
  local the_function=$1
  local the_projects=$2
  shift 2

  echoInfo "$the_function" "${the_projects#$THIS_ADDON_PATH/}"

  for project in $(find_projects "$the_projects"); do
    (${the_function} "${project}" $@)
  done
}


function clean_example_project_files()
{
  (do_function_for_projects clean_project_files "${EXAMPLE_PROJECTS}" $@)
}


function clean_test_project_files()
{
  (do_function_for_projects clean_project_files "${TEST_PROJECTS}" $@)
}


function clean_example_build_files()
{
  (do_function_for_projects clean_project_build_files "${EXAMPLE_PROJECTS}" $@)
}


function clean_test_build_files()
{
  (do_function_for_projects clean_project_build_files "${TEST_PROJECTS}" $@)
}


function install_example_data()
{
  (do_function_for_projects install_data_for_project "${EXAMPLE_PROJECTS}" $@)
}


function install_test_data()
{
  (do_function_for_projects install_data_for_project "${TEST_PROJECTS}" $@)
}


function list_examples()
{
  (do_function_for_projects echo "${EXAMPLE_PROJECTS}" $@)
}


function list_tests()
{
  (do_function_for_projects echo "${TEST_PROJECTS}" $@)
}


function generate_project()
{
  local PROJECT_PATH=$1

  echoInfo "Generating project files for ${PROJECT_PATH}"

  PROJECT_MAKEFILE=${PROJECT_PATH}/Makefile
  PROJECT_CONFIG_MAKE=${PROJECT_PATH}/config.make
  TEMPLATE_MAKEFILE=${OF_SCRIPTS_PATH}/templates/${HOST_PLATFORM}/Makefile
  TEMPLATE_CONFIG_MAKE=${OF_SCRIPTS_PATH}/templates/${HOST_PLATFORM}/config.make

  if [ $LOG_LEVEL -gt 0 ]; then
    echo "================================================================================"
    echo ""
    echo "                       PROJECT_MAKEFILE: ${PROJECT_MAKEFILE}"
    echo "                    PROJECT_CONFIG_MAKE: ${PROJECT_CONFIG_MAKE}"
    echo "                      TEMPLATE_MAKEFILE: ${TEMPLATE_MAKEFILE}"
    echo "                   TEMPLATE_CONFIG_MAKE: ${TEMPLATE_CONFIG_MAKE}"
    echo ""
    echo "================================================================================"
  fi

  if [ ${OF_PROJECT_GENERATOR_AVAILABLE} == true ]; then
    if [ -f ${PROJECT_MAKEFILE} ]; then
      echoWarning "Removing and regenerating ${PROJECT_MAKEFILE} because of https://github.com/openframeworks/projectGenerator/issues/210."
      rm ${PROJECT_MAKEFILE}
    fi

    if [ -f ${PROJECT_CONFIG_MAKE} ]; then
      echoWarning "Removing and regenerating ${PROJECT_CONFIG_MAKE} because of https://github.com/openframeworks/projectGenerator/issues/210."
      rm ${PROJECT_CONFIG_MAKE}
    fi

    if [ $LOG_LEVEL -gt 1 ]; then
      ${OF_PROJECT_GENERATOR_COMMAND} -o${OF_ROOT} ${PROJECT_PATH} -p${TARGET_PLATFORM}
    else
      ${OF_PROJECT_GENERATOR_COMMAND} -o${OF_ROOT} ${PROJECT_PATH} -p${TARGET_PLATFORM} > /dev/null
    fi


  elif [ "${HOST_PLATFORM}" == "${TARGET_PLATFORM}" ] ; then

    if [[ "${TARGET_PLATFORM}" != linux* ]] ; then
      # Only mention this on platforms that aren't linux.
      echoWarning "Project Generator is not available, creating makefiles."
    fi

    PROJECT_PATH_RELATIVE_OF_ROOT=$(relpath "${OF_ROOT}" "${PROJECT_PATH}/..")

    if ! [ -f ${PROJECT_MAKEFILE} ]; then
      cp ${TEMPLATE_MAKEFILE} ${PROJECT_PATH}
      sed -i'.bak' -e 's|\.\./\.\.|'${PROJECT_PATH_RELATIVE_OF_ROOT}'|g' ${PROJECT_MAKEFILE}
      rm ${PROJECT_MAKEFILE}.bak
    else
      echoInfo "${PROJECT_PATH} already has a Makefile."
    fi

    if ! [ -f ${PROJECT_CONFIG_MAKE} ]; then
      cp ${TEMPLATE_CONFIG_MAKE} ${PROJECT_PATH}
      sed -i'.bak' -e 's|\.\./\.\.|'${PROJECT_PATH_RELATIVE_OF_ROOT}'|g' ${PROJECT_CONFIG_MAKE}
      rm ${PROJECT_CONFIG_MAKE}.bak
    else
      echoInfo "${PROJECT_PATH} already has a config.make file."
    fi
  else
      echoError "If TARGET_PLATFORM ${TARGET_PLATFORM} != HOST_PLATFORM ${HOST_PLATFORM}, projectGenerator is needed."
      exit 1
  fi
}


function get_addon_dependencies_from_all_examples()
{
  local ADDON_DEPENDENCIES=""
  for project in $(find_example_projects ${THIS_ADDON_PATH}); do
    ADDON_DEPENDENCIES="${ADDON_DEPENDENCIES} $(get_addon_dependencies_for_project "${project}")"
  done
  echo $(sort_and_remove_duplicates "${ADDON_DEPENDENCIES}")
  return 0
}


function get_addon_dependencies_from_all_tests()
{
  local ADDON_DEPENDENCIES=""
  for project in $(find_test_projects ${THIS_ADDON_PATH}); do
    ADDON_DEPENDENCIES="${ADDON_DEPENDENCIES} $(get_addon_dependencies_for_project "${project}")"
  done
  echo $(sort_and_remove_duplicates "${ADDON_DEPENDENCIES}")
  return 0
}


function get_addon_dependencies_from_all_projects()
{
  echo $(sort_and_remove_duplicates "$(get_addon_dependencies_from_all_examples) $(get_addon_dependencies_from_all_tests)")
  return 0
}


function get_all_addon_dependencies()
{
  echo $(sort_and_remove_duplicates "$(get_addon_dependencies_for_addon ${THIS_ADDON_PATH}) $(get_addon_dependencies_from_all_projects)")
  return 0
}
