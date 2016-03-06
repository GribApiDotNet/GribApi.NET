# (C) Copyright 1996-2015 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

##############################################################################
#.rst:
#
# ecbuild_print_summary
# =====================
#
# Print a summary of the project, build environment and enabled features. ::
#
#   ecbuild_print_summary()
#
# If ``project_summary.cmake`` exist in the source root directory, a project
# summary is printed by including this file.
#
# For a top level project, a summary of the build environment and a feature
# summary are also printed.
#
##############################################################################

macro( ecbuild_print_summary )

  if( EXISTS ${PROJECT_SOURCE_DIR}/project_summary.cmake )

    message( STATUS "---------------------------------------------------------" )
    message( STATUS "Project ${PROJECT_NAME} summary" )
    message( STATUS "---------------------------------------------------------" )

    include( ${PROJECT_SOURCE_DIR}/project_summary.cmake )

  endif()

  if( PROJECT_NAME STREQUAL CMAKE_PROJECT_NAME )

    ecbuild_define_links_target()

    get_property( langs GLOBAL PROPERTY ENABLED_LANGUAGES )

    message( STATUS "---------------------------------------------------------" )
    if( NOT ${DEVELOPER_MODE} )
      message( STATUS "Build summary" )
    else()
      message( STATUS "Build summary -- ( DEVELOPER_MODE )" )
    endif()
    message( STATUS "---------------------------------------------------------" )

    message( STATUS "system : [${BUILD_SITE}] [${CMAKE_SYSTEM}] [${EC_OS_NAME}.${EC_OS_BITS}]" )
    message( STATUS "processor        : [${CMAKE_SYSTEM_PROCESSOR}]" )
    if( EC_BIG_ENDIAN )
      message( STATUS "endiness         : Big Endian -- IEEE [${IEEE_BE}]" )
    endif()
    if( EC_LITTLE_ENDIAN )
      message( STATUS "endiness         : Little Endian -- IEEE [${IEEE_LE}]" )
    endif()
    message( STATUS "build type       : [${CMAKE_BUILD_TYPE}]" )
    message( STATUS "timestamp        : [${EC_BUILD_TIMESTAMP}]" )
    message( STATUS "install prefix   : [${CMAKE_INSTALL_PREFIX}]" )
    if( EC_LINK_DIR )
      message( STATUS "links prefix     : [${EC_LINK_DIR}]" )
    endif()
    message( STATUS "---------------------------------------------------------" )

    foreach( lang ${langs} )
      message( STATUS "${lang} -- ${CMAKE_${lang}_COMPILER_ID} ${CMAKE_${lang}_COMPILER_VERSION}"  )
      message( STATUS "    compiler   : ${CMAKE_${lang}_COMPILER} ${CMAKE_${lang}_FLAGS} ${CMAKE_${lang}_FLAGS_${CMAKE_BUILD_TYPE_CAPS}}" )
      message( STATUS "    link flags : ${CMAKE_${lang}_LINK_FLAGS}" )
    endforeach()

    message( STATUS "linker : ${CMAKE_LINKER}")
    message( STATUS "ar     : ${CMAKE_AR}")
    message( STATUS "ranlib : ${CMAKE_RANLIB}")
    message( STATUS "link flags" )
    message( STATUS "    executable [${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS_${CMAKE_BUILD_TYPE_CAPS}}]" )
    message( STATUS "    shared lib [${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS_${CMAKE_BUILD_TYPE_CAPS}}]" )
    message( STATUS "    static lib [${CMAKE_MODULE_LINKER_FLAGS} ${CMAKE_MODULE_LINKER_FLAGS_${CMAKE_BUILD_TYPE_CAPS}}]" )
    message( STATUS "install rpath  : ${CMAKE_INSTALL_RPATH}" )

    get_directory_property( defs COMPILE_DEFINITIONS )

    message( STATUS "common definitions: ${defs}" )

    message( STATUS "---------------------------------------------------------" )

    ### FEATURE SUMMARY

    # debug_var( CMAKE_VERSION )
    if( ${CMAKE_VERSION} VERSION_LESS "2.8.6" )
      feature_summary( WHAT ALL )
    else()
      feature_summary( WHAT ALL INCLUDE_QUIET_PACKAGES )
    endif()

    ### WARNINGS

    # issue warnings / errors in case there are unused project files
    ecbuild_warn_unused_files()

  endif( PROJECT_NAME STREQUAL CMAKE_PROJECT_NAME )

endmacro( ecbuild_print_summary )
