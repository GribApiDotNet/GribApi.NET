# Manages an external git repository
# Usage:
# git(DIR <directory> URL <giturl> [BRANCH <gitbranch>] [TAG <gittag>] [UPDATE] )
#
# Arguments:
#  - DIR: directory name where repo will be cloned to
#  - URL: location of origin git repository
#  - BRANCH (optional): Branch to clone
#  - TAG (optional): Tag or commit-id to checkout
#  - UPDATE (optional) : Option to try to update every cmake run
#  - NOREMOTE (optional) : Option to avoid remote operations that require network
#                          changes to tags that havent been fetched might fail

macro( debug_here VAR )
  message( STATUS " >>>>> ${VAR} [${${VAR}}]")
endmacro()

include(CMakeParseArguments)

set( ECBUILD_GIT  ON  CACHE BOOL "Turn on/off ecbuild_git() function" )

if( ECBUILD_GIT )

  find_package(Git)

  set( ECMWF_USER $ENV{USER} CACHE STRING "ECMWF git user" )
  set( ECMWF_GIT  SSH        CACHE STRING "ECMWF git protocol" )

  set( ECMWF_GIT_SSH   "ssh://git@software.ecmwf.int:7999"                  CACHE INTERNAL "ECMWF ssh address" )
  set( ECMWF_GIT_HTTPS "https://${ECMWF_USER}@software.ecmwf.int/stash/scm" CACHE INTERNAL "ECMWF https address" )

  if( ECMWF_GIT MATCHES "[Ss][Ss][Hh]" )
    set( ECMWF_GIT_ADDRESS ${ECMWF_GIT_SSH} CACHE INTERNAL "" )
  else()
    set( ECMWF_GIT_ADDRESS ${ECMWF_GIT_HTTPS} CACHE INTERNAL "" )
  endif()

endif()

macro( ecbuild_git )

  set( options UPDATE NOREMOTE )
  set( single_value_args PROJECT DIR URL TAG BRANCH )
  set( multi_value_args )
  cmake_parse_arguments( _PAR "${options}" "${single_value_args}" "${multi_value_args}" ${_FIRST_ARG} ${ARGN} )

  if( DEFINED _PAR_BRANCH AND DEFINED _PAR_TAG )
    message( FATAL_ERROR "Cannot defined both BRANCH and TAG in macro ecbuild_git" )
  endif()

  if( _PAR_UPDATE AND _PAR_NOREMOTE )
    message( FATAL_ERROR "Cannot pass both NOREMOTE and UPDATE in macro ecbuild_git" )
  endif()

  if(_PAR_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unknown keywords given to ecbuild_git(): \"${_PAR_UNPARSED_ARGUMENTS}\"")
  endif()

  if( ECBUILD_GIT )

    set( _needs_switch 0 )

    get_filename_component( ABS_PAR_DIR "${_PAR_DIR}" ABSOLUTE )
    get_filename_component( PARENT_DIR  "${_PAR_DIR}/.." ABSOLUTE )

    ### clone if no directory

    if( NOT EXISTS "${_PAR_DIR}" )

      message( STATUS "Cloning ${_PAR_PROJECT} from ${_PAR_URL} into ${_PAR_DIR}...")
      execute_process(
        COMMAND ${GIT_EXECUTABLE} "clone" ${_PAR_URL} ${clone_args} ${_PAR_DIR} "-q"
        RESULT_VARIABLE nok ERROR_VARIABLE error
        WORKING_DIRECTORY "${PARENT_DIR}")
      if(nok)
        message(FATAL_ERROR "${_PAR_DIR} git clone failed: ${error}\n")
      endif()
      message( STATUS "${_PAR_DIR} retrieved.")
      set( _needs_switch 1 )

    endif()

    ### check current tag and sha1

    if( IS_DIRECTORY "${_PAR_DIR}/.git" )

        execute_process(
          COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
          OUTPUT_VARIABLE _sha1 RESULT_VARIABLE nok ERROR_VARIABLE error OUTPUT_STRIP_TRAILING_WHITESPACE
          WORKING_DIRECTORY "${ABS_PAR_DIR}" )
        if(nok)
          message(STATUS "git rev-parse HEAD on ${_PAR_DIR} failed:\n ${error}")
        endif()

        execute_process(
          COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
          OUTPUT_VARIABLE _current_branch RESULT_VARIABLE nok ERROR_VARIABLE error OUTPUT_STRIP_TRAILING_WHITESPACE
          WORKING_DIRECTORY "${ABS_PAR_DIR}" )
        if( nok OR _current_branch STREQUAL "" )
          message(STATUS "git rev-parse --abbrev-ref HEAD on ${_PAR_DIR} failed:\n ${error}")
        endif()

        #message(STATUS "git describe --exact-match --abbrev=0 @ ${ABS_PAR_DIR}")
        execute_process(
          COMMAND ${GIT_EXECUTABLE} describe --exact-match --abbrev=0
          OUTPUT_VARIABLE _current_tag RESULT_VARIABLE nok ERROR_VARIABLE error
          OUTPUT_STRIP_TRAILING_WHITESPACE  ERROR_STRIP_TRAILING_WHITESPACE
          WORKING_DIRECTORY "${ABS_PAR_DIR}" )

        if( error MATCHES "no tag exactly matches" OR error MATCHES "No names found" )
          unset( _current_tag )
        else()
          if( nok )
            message(STATUS "git describe --exact-match --abbrev=0 on ${_PAR_DIR} failed:\n ${error}")
          endif()
        endif()

        if( NOT _current_tag ) # try nother method
          #message(STATUS "git name-rev --tags --name-only @ ${ABS_PAR_DIR}")
          execute_process(
            COMMAND ${GIT_EXECUTABLE} name-rev --tags --name-only ${_sha1}
            OUTPUT_VARIABLE _current_tag RESULT_VARIABLE nok ERROR_VARIABLE error OUTPUT_STRIP_TRAILING_WHITESPACE
            WORKING_DIRECTORY "${ABS_PAR_DIR}" )
          if( nok OR _current_tag STREQUAL "" )
            message(STATUS "git name-rev --tags --name-only on ${_PAR_DIR} failed:\n ${error}")
          endif()
        endif()

    endif()

    if( DEFINED _PAR_BRANCH AND NOT "${_current_branch}" STREQUAL "${_PAR_BRANCH}" )
      set( _needs_switch 1 )
    endif()

    if( DEFINED _PAR_TAG AND NOT "${_current_tag}" STREQUAL "${_PAR_TAG}" )
      set( _needs_switch 1 )
    endif()

    if( DEFINED _PAR_BRANCH AND _PAR_UPDATE AND NOT _PAR_NOREMOTE )

      add_custom_target( git_update_${_PAR_PROJECT}
                         COMMAND "${GIT_EXECUTABLE}" pull -q
                         WORKING_DIRECTORY "${ABS_PAR_DIR}"
                         COMMENT "git pull of branch ${_PAR_BRANCH} on ${_PAR_DIR}" )

      set( git_update_targets "git_update_${_PAR_PROJECT};${git_update_targets}" )

    endif()

    ### updates

    if( _needs_switch AND IS_DIRECTORY "${_PAR_DIR}/.git" )

      # debug_here( ABS_PAR_DIR )
      # debug_here( _sha1 )
      # debug_here( _current_branch )
      # debug_here( _current_tag )
      # debug_here( _PAR_TAG )
      # debug_here( _PAR_BRANCH )
      # debug_here( _needs_switch )
      # debug_here( _PAR_UPDATE )

      if( DEFINED _PAR_BRANCH )
        set ( _gitref ${_PAR_BRANCH} )
        message(STATUS "Updating ${_PAR_PROJECT} to head of BRANCH ${_PAR_BRANCH}...")
      else()
        message(STATUS "Updating ${_PAR_PROJECT} to TAG ${_PAR_TAG}...")
        set ( _gitref ${_PAR_TAG} )
      endif()

      # fetching latest tags and branches

      if( NOT _PAR_NOREMOTE )

          message(STATUS "git fetch --all @ ${ABS_PAR_DIR}")
          execute_process(COMMAND "${GIT_EXECUTABLE}" fetch --all -q
            RESULT_VARIABLE nok ERROR_VARIABLE error
            WORKING_DIRECTORY "${ABS_PAR_DIR}")
          if(nok)
            message(STATUS "git fetch --all in ${_PAR_DIR} failed:\n ${error}")
          endif()

          message(STATUS "git fetch --all --tags @ ${ABS_PAR_DIR}")
          execute_process(COMMAND "${GIT_EXECUTABLE}" fetch --all --tags -q
            RESULT_VARIABLE nok ERROR_VARIABLE error
            WORKING_DIRECTORY "${ABS_PAR_DIR}")
          if(nok)
            message(STATUS "git fetch --all --tags in ${_PAR_DIR} failed:\n ${error}")
          endif()

      else()
          message(STATUS "${_PAR_DIR} marked NOREMOTE : Skipping git fetch")
      endif()

      # checking out gitref

      message(STATUS "git checkout ${_gitref} @ ${ABS_PAR_DIR}")
      execute_process(COMMAND "${GIT_EXECUTABLE}" checkout -q "${_gitref}"
        RESULT_VARIABLE nok ERROR_VARIABLE error
        WORKING_DIRECTORY "${ABS_PAR_DIR}")
      if(nok)
        message(FATAL_ERROR "git checkout ${_gitref} on ${_PAR_DIR} failed:\n ${error}")
      endif()

      if( DEFINED _PAR_BRANCH AND _PAR_UPDATE ) #############################################################################

            execute_process(COMMAND "${GIT_EXECUTABLE}" pull -q
              RESULT_VARIABLE nok ERROR_VARIABLE error
              WORKING_DIRECTORY "${ABS_PAR_DIR}")
            if(nok)
              message(STATUS "git pull of branch ${_PAR_BRANCH} on ${_PAR_DIR} failed:\n ${error}")
            endif()

      endif() ####################################################################################

    endif( _needs_switch AND IS_DIRECTORY "${_PAR_DIR}/.git" )

  endif( ECBUILD_GIT )

endmacro()

########################################################################################################################

macro( ecmwf_stash )

  set( options )
  set( single_value_args STASH )
  set( multi_value_args )
  cmake_parse_arguments( _PAR "${options}" "${single_value_args}" "${multi_value_args}" ${_FIRST_ARG} ${ARGN} )

  ecbuild_git( URL "${ECMWF_GIT_ADDRESS}/${_PAR_STASH}.git" ${_PAR_UNPARSED_ARGUMENTS} )

endmacro()

########################################################################################################################

macro( ecbuild_bundle_initialize )

  include( local-config.cmake OPTIONAL )

  # ecmwf_stash( PROJECT ecbuild DIR ${PROJECT_SOURCE_DIR}/ecbuild STASH "ecsdk/ecbuild" BRANCH develop )

  # set( CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/ecbuild/cmake;${CMAKE_MODULE_PATH}" )

  include( ecbuild_system )

  ecbuild_requires_macro_version( 1.6 )

  ecbuild_declare_project()

  file( GLOB local_config_files RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *local-config.cmake )

  ecbuild_add_resources( TARGET ecbuild_bundle_dont_pack DONT_PACK "${local_config_files}" )

  if( EXISTS "${PROJECT_SOURCE_DIR}/README.md" )
    add_custom_target( ${PROJECT_NAME}_readme SOURCES "${PROJECT_SOURCE_DIR}/README.md" )
  endif()

endmacro()

########################################################################################################################

macro( ecbuild_bundle )

  set( options )
  set( single_value_args PROJECT )
  set( multi_value_args )
  cmake_parse_arguments( _PAR "${options}" "${single_value_args}" "${multi_value_args}" ${_FIRST_ARG} ${ARGN} )

  string(TOUPPER "${_PAR_PROJECT}" PNAME)

  if( BUNDLE_SKIP_${PNAME} )
      message( STATUS "Skipping bundle project ${PNAME}" )
  else()
      ecmwf_stash( PROJECT ${_PAR_PROJECT} DIR ${PROJECT_SOURCE_DIR}/${_PAR_PROJECT} ${_PAR_UNPARSED_ARGUMENTS} )
      ecbuild_use_package( PROJECT ${_PAR_PROJECT} )
  endif()

endmacro()

macro( ecbuild_bundle_finalize )

  add_custom_target( update DEPENDS ${git_update_targets} )

  ecbuild_install_project( NAME ${CMAKE_PROJECT_NAME} )

  ecbuild_print_summary()

endmacro()
