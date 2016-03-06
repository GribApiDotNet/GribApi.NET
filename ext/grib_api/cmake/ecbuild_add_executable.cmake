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
# ecbuild_add_executable
# ======================
#
# Add an executable with a given list of source files. ::
#
#   ecbuild_add_executable( TARGET <name>
#                           SOURCES <source1> [<source2> ...]
#                           [ TEMPLATES <template1> [<template2> ...] ]
#                           [ LIBS <library1> [<library2> ...] ]
#                           [ INCLUDES <path1> [<path2> ...] ]
#                           [ DEFINITIONS <definition1> [<definition2> ...] ]
#                           [ PERSISTENT <file1> [<file2> ...] ]
#                           [ GENERATED <file1> [<file2> ...] ]
#                           [ DEPENDS <target1> [<target2> ...] ]
#                           [ CONDITION <condition1> [<condition2> ...] ]
#                           [ NOINSTALL ]
#                           [ VERSION <version> | AUTO_VERSION ]
#                           [ CFLAGS <flag1> [<flag2> ...] ]
#                           [ CXXFLAGS <flag1> [<flag2> ...] ]
#                           [ FFLAGS <flag1> [<flag2> ...] ]
#                           [ LINKER_LANGUAGE <lang> ]
#                           [ OUTPUT_NAME <name> ] )
#
# Options
# -------
#
# TARGET : required
#   target name
#
# SOURCES : required
#   list of source files
#
# TEMPLATES : optional
#   list of files specified as SOURCES which are not to be compiled separately
#   (these are commonly template implementation files included in a header)
#
# LIBS : optional
#   list of libraries to link against (CMake targets or external libraries)
#
# INCLUDES : optional
#   list of paths to add to include directories
#
# DEFINITIONS : optional
#   list of definitions to add to preprocessor defines
#
# PERSISTENT : optional
#   list of persistent layer object files
#
# GENERATED : optional
#   list of files to mark as generated (sets GENERATED source file property)
#
# DEPENDS : optional
#   list of targets to be built before this target
#
# CONDITION : optional
#   conditional expression which must evaluate to true for this target to be
#   built (must be valid in a CMake ``if`` statement)
#
# NOINSTALL : optional
#   do not install the executable
# 
# VERSION : optional, AUTO_VERSION or LIBS_VERSION is used if not specified
#   version to use as executable version
#
# AUTO_VERSION : optional, ignored if VERSION is specified
#   automatically version the executable with the package version
#
# CFLAGS : optional
#   list of C compiler flags to use for all C source files
#
# CXXFLAGS : optional
#   list of C++ compiler flags to use for all C++ source files
#
# FFLAGS : optional
#   list of Fortran compiler flags to use for all Fortran source files
#
#
# LINKER_LANGUAGE : optional
#   sets the LINKER_LANGUAGE property on the target
#
# OUTPUT_NAME : optional
#   sets the OUTPUT_NAME property on the target
#
##############################################################################

macro( ecbuild_add_executable )

  set( options NOINSTALL AUTO_VERSION )
  set( single_value_args TARGET COMPONENT LINKER_LANGUAGE VERSION OUTPUT_NAME )
  set( multi_value_args  SOURCES TEMPLATES LIBS INCLUDES DEPENDS PERSISTENT DEFINITIONS CFLAGS CXXFLAGS FFLAGS GENERATED CONDITION )

  cmake_parse_arguments( _PAR "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

  if(_PAR_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unknown keywords given to ecbuild_add_executable(): \"${_PAR_UNPARSED_ARGUMENTS}\"")
  endif()

  if( NOT _PAR_TARGET  )
    message(FATAL_ERROR "The call to ecbuild_add_executable() doesn't specify the TARGET.")
  endif()

  if( NOT _PAR_SOURCES )
    message(FATAL_ERROR "The call to ecbuild_add_executable() doesn't specify the SOURCES.")
  endif()

  ### conditional build

  if( DEFINED _PAR_CONDITION )
    set(_target_condition_file "${CMAKE_CURRENT_BINARY_DIR}/set_${_PAR_TARGET}_condition.cmake")
    file( WRITE  ${_target_condition_file} "  if( ")
    foreach( term ${_PAR_CONDITION} )
      file( APPEND ${_target_condition_file} " ${term}")
    endforeach()
    file( APPEND ${_target_condition_file} " )\n    set(_${_PAR_TARGET}_condition TRUE)\n  else()\n    set(_${_PAR_TARGET}_condition FALSE)\n  endif()\n")
    include( ${_target_condition_file} )
  else()
    set( _${_PAR_TARGET}_condition TRUE )
  endif()

  if( _${_PAR_TARGET}_condition )

    # add include dirs if defined
    if( DEFINED _PAR_INCLUDES )
      list(REMOVE_DUPLICATES _PAR_INCLUDES )
      foreach( path ${_PAR_INCLUDES} ) # skip NOTFOUND
        if( path )
          ecbuild_debug("ecbuild_add_executable(${_PAR_TARGET}): add ${path} to include_directories")
          include_directories( ${path} )
        else()
          ecbuild_debug("ecbuild_add_executable(${_PAR_TARGET}): ${path} not found - not adding to include_directories")
        endif()
      endforeach()
    endif()

    # add persistent layer files
    if( DEFINED _PAR_PERSISTENT )
      if( DEFINED PERSISTENT_NAMESPACE )
        ecbuild_add_persistent( SRC_LIST _PAR_SOURCES FILES ${_PAR_PERSISTENT} NAMESPACE ${PERSISTENT_NAMESPACE} )
      else()
        ecbuild_add_persistent( SRC_LIST _PAR_SOURCES FILES ${_PAR_PERSISTENT} )
      endif()
    endif()

    # remove templates from compilation sources
    if( DEFINED _PAR_TEMPLATES )
      ecbuild_debug("ecbuild_add_executable(${_PAR_TARGET}): removing ${_PAR_TEMPLATES} from sources")
      list( REMOVE_ITEM _PAR_SOURCES ${_PAR_TEMPLATES} )
      add_custom_target( ${_PAR_TARGET}_templates SOURCES ${_PAR_TEMPLATES} )
    endif()

    # add the executable target
    add_executable( ${_PAR_TARGET} ${_PAR_SOURCES} )

    # set OUTPUT_NAME

    if( DEFINED _PAR_OUTPUT_NAME )
      ecbuild_debug("ecbuild_add_executable(${_PAR_TARGET}): set OUTPUT_NAME to ${_PAR_OUTPUT_NAME}")
      set_target_properties( ${_PAR_TARGET} PROPERTIES OUTPUT_NAME ${_PAR_OUTPUT_NAME} )
    endif()

    # add extra dependencies
    if( DEFINED _PAR_DEPENDS)
      ecbuild_debug("ecbuild_add_executable(${_PAR_TARGET}): add dependency on ${_PAR_DEPENDS}")
      add_dependencies( ${_PAR_TARGET} ${_PAR_DEPENDS} )
    endif()

    # add the link libraries
    if( DEFINED _PAR_LIBS )
      list(REMOVE_DUPLICATES _PAR_LIBS )
      list(REMOVE_ITEM _PAR_LIBS debug)
      list(REMOVE_ITEM _PAR_LIBS optimized)
      foreach( lib ${_PAR_LIBS} ) # skip NOTFOUND
        if( lib )
          ecbuild_debug("ecbuild_add_executable(${_PAR_TARGET}): linking with ${lib}")
          target_link_libraries( ${_PAR_TARGET} ${lib} )
        else()
          ecbuild_debug("ecbuild_add_executable(${_PAR_TARGET}): ${lib} not found - not linking")
        endif()
      endforeach()
    endif()

    # filter sources
    ecbuild_separate_sources( TARGET ${_PAR_TARGET} SOURCES ${_PAR_SOURCES} )

    # add local flags
    if( DEFINED _PAR_CFLAGS )
      ecbuild_debug("ecbuild_add_executable(${_PAR_TARGET}): use C flags ${_PAR_CFLAGS}")
      set_source_files_properties( ${${_PAR_TARGET}_c_srcs}   PROPERTIES COMPILE_FLAGS "${_PAR_CFLAGS}" )
    endif()
    if( DEFINED _PAR_CXXFLAGS )
      ecbuild_debug("ecbuild_add_executable(${_PAR_TARGET}): use C++ flags ${_PAR_CFLAGS}")
      set_source_files_properties( ${${_PAR_TARGET}_cxx_srcs} PROPERTIES COMPILE_FLAGS "${_PAR_CXXFLAGS}" )
    endif()
    if( DEFINED _PAR_FFLAGS )
      ecbuild_debug("ecbuild_add_executable(${_PAR_TARGET}): use Fortran flags ${_PAR_CFLAGS}")
      set_source_files_properties( ${${_PAR_TARGET}_f_srcs}   PROPERTIES COMPILE_FLAGS "${_PAR_FFLAGS}" )
    endif()
    if( DEFINED _PAR_GENERATED )
      ecbuild_debug("ecbuild_add_executable(${_PAR_TARGET}): mark as generated ${_PAR_GENERATED}")
      set_source_files_properties( ${_PAR_GENERATED} PROPERTIES GENERATED 1 )
    endif()

    # define VERSION if requested
    if( DEFINED _PAR_VERSION )
      ecbuild_debug("ecbuild_add_executable(${_PAR_TARGET}): set version to ${_PAR_VERSION}")
      set_target_properties( ${_PAR_TARGET} PROPERTIES VERSION "${_PAR_VERSION}" )
    else()
      if( _PAR_AUTO_VERSION )
        ecbuild_debug("ecbuild_add_executable(${_PAR_TARGET}): set version to ${${PNAME}_MAJOR_VERSION}.${${PNAME}_MINOR_VERSION}")
        set_target_properties( ${_PAR_TARGET} PROPERTIES VERSION "${${PNAME}_MAJOR_VERSION}.${${PNAME}_MINOR_VERSION}" )
      endif()
    endif()

    #    debug_var( ${_PAR_TARGET}_h_srcs )
    #    debug_var( ${_PAR_TARGET}_c_srcs )
    #    debug_var( ${_PAR_TARGET}_cxx_srcs )
    #    debug_var( ${_PAR_TARGET}_f_srcs )

    # installation

    if( NOT _PAR_NOINSTALL )
      ecbuild_debug("ecbuild_add_executable(${_PAR_TARGET}): installing to ${INSTALL_BIN_DIR}")

      # add installation paths and associate with defined component
      #            if( DEFINED _PAR_COMPONENT )
      #                set( COMPONENT_DIRECTIVE "${_PAR_COMPONENT}" )
      #            else()
      #                set( COMPONENT_DIRECTIVE "${PROJECT_NAME}" )
      #            endif()

      install( TARGETS ${_PAR_TARGET}
               EXPORT  ${CMAKE_PROJECT_NAME}-targets
               RUNTIME DESTINATION ${INSTALL_BIN_DIR}
               LIBRARY DESTINATION ${INSTALL_LIB_DIR}
               ARCHIVE DESTINATION ${INSTALL_LIB_DIR} )
      #        COMPONENT ${COMPONENT_DIRECTIVE} )

      # set build location

      set_property( TARGET ${_PAR_TARGET} PROPERTY RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin )

      # export location of target to other projects -- must be exactly after setting the build location (see previous command)

      export( TARGETS ${_PAR_TARGET} APPEND FILE "${TOP_PROJECT_TARGETS_FILE}" )

    else()
      ecbuild_debug("ecbuild_add_executable(${_PAR_TARGET}): not installing")
      # NOINSTALL targets are always built the build_rpath, not the install_rpath
      set_property( TARGET ${_PAR_TARGET} PROPERTY SKIP_BUILD_RPATH         FALSE )
      set_property( TARGET ${_PAR_TARGET} PROPERTY BUILD_WITH_INSTALL_RPATH FALSE )
    endif()

    # add definitions to compilation
    if( DEFINED _PAR_DEFINITIONS )
      get_property( _target_defs TARGET ${_PAR_TARGET} PROPERTY COMPILE_DEFINITIONS )
      list( APPEND _target_defs ${_PAR_DEFINITIONS} )
      ecbuild_debug("ecbuild_add_executable(${_PAR_TARGET}): using definitions ${_target_defs}")
      set_property( TARGET ${_PAR_TARGET} PROPERTY COMPILE_DEFINITIONS ${_target_defs} )
    endif()

    # set linker language
    if( DEFINED _PAR_LINKER_LANGUAGE )
      ecbuild_debug("ecbuild_add_executable(${_PAR_TARGET}): using linker language ${_PAR_LINKER_LANGUAGE}")
      set_property( TARGET ${_PAR_TARGET} PROPERTY LINKER_LANGUAGE ${_PAR_LINKER_LANGUAGE} )
    endif()

    # make sure target is removed before - some problems with AIX
    add_custom_command( TARGET ${_PAR_TARGET} PRE_BUILD COMMAND ${CMAKE_COMMAND} -E remove $<TARGET_FILE:${_PAR_TARGET}> )

    # for the links target
    if( NOT _PAR_NOINSTALL )
      ecbuild_link_exe( ${_PAR_TARGET} $<TARGET_FILE_NAME:${_PAR_TARGET}> $<TARGET_FILE:${_PAR_TARGET}>  )
    endif()

    # append to the list of this project targets
    set( ${PROJECT_NAME}_ALL_EXES ${${PROJECT_NAME}_ALL_EXES} ${_PAR_TARGET} CACHE INTERNAL "" )

  endif()

  # mark source files as used
  ecbuild_declare_project_files( ${_PAR_SOURCES} )
  if( DEFINED _PAR_TEMPLATES )
    ecbuild_declare_project_files( ${_PAR_TEMPLATES} )
  endif()

endmacro( ecbuild_add_executable  )
