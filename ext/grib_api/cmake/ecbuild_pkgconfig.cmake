# (C) Copyright 1996-2014 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

#############################################################################################
#
# MACRO ecbuild_pkgconfig
#
# This macro creates a pkg-config file for the current project
#
# It takes following optional arguments:
#
#  - FILENAME <filename>
#       The file that will be generated. Default value is the lowercase
#       name of the project with suffix ".pc" is used
#
#  - NAME <name>
#       The name to be given to the package. Default value is the lowercase
#       name of the project
#
#  - TEMPLATE <template>
#       The template configuration file to use. This is useful to create more
#       custom pkg-config files. Default is ${ECBUILD_CMAKE_DIR}/pkg-config.pc.in
#
#  - URL <url>
#       The url of the package. Default is ${UPPERCASE_PROJECT_NAME}_URL
#
#  - DESCRIPTION <description>
#       The description of the package. Default is ${UPPERCASE_PROJECT_NAME}_DESCRIPTION
#
#  - LIBRARIES <libraries>
#       The package libraries. Default is ${UPPERCASE_PROJECT_NAME}_LIBRARIES
#       This is e.g. of the form "eckit;eckit_geometry"
#
#  - IGNORE_INCLUDE_DIRS <include_dirs>
#       Ignore specified include directories
#
#  - IGNORE_LIBRARIES <libraries>
#       Ignore specified libraries
#
#  - LANGUAGES <languages>
#       List of languages used. If none given, all CMake_<lang>_COMPILER_LOAED languages
#       are added. Accepted languages: C CXX Fortran
#
#  - NO_PRIVATE_INCLUDE_DIRS
#       Don't add include dirs of dependencies to Cflags. This is mainly useful
#       for Fortran only packages, when only the modules need to be added to Cflags
#
#############################################################################################

function( ecbuild_library_dependencies dependencies libraries )

  set( _libraries ${${libraries}} )

  foreach( _lib ${_libraries})

    unset( _location )

    if( TARGET ${_lib} ) # check if this is an existing target

      set( _imported 0 )
      get_property( _imported TARGET ${_lib} PROPERTY IMPORTED )

      unset( _deps )

      if( _imported )

        get_property( _location TARGET ${_lib} PROPERTY LOCATION )
        get_property( _configs   TARGET ${_lib} PROPERTY IMPORTED_CONFIGURATIONS )
        list( REVERSE _configs )
        list( GET _configs 0 _config)
        get_property( _deps     TARGET ${_lib} PROPERTY IMPORTED_LINK_INTERFACE_LIBRARIES_${_config} )
        get_property( _locimp   TARGET ${_lib} PROPERTY IMPORTED_LOCATION_${_config} )

      else()

        list( APPEND _location ${_lib} )
        get_property( _deps TARGET ${_lib} PROPERTY LINK_LIBRARIES )

      endif()

      ecbuild_library_dependencies( _deps_location _deps )
      list( APPEND _location ${_deps_location} )

    else()

      set( _location ${_lib} )

    endif()

    list( APPEND _dependencies ${_location} )

  endforeach()

  if( _dependencies )
    list( REVERSE           _dependencies )
    list( REMOVE_DUPLICATES _dependencies )
    list( REVERSE           _dependencies )
    set( ${dependencies} ${_dependencies} PARENT_SCOPE )
  endif()

endfunction(ecbuild_library_dependencies)

#############################################################################################

function( ecbuild_include_dependencies dependencies libraries )

  set( _libraries ${${libraries}} )

  foreach( _lib ${_libraries})

    if( TARGET ${_lib} ) # check if this is an existing target

      get_property( _include_dirs TARGET ${_lib} PROPERTY INCLUDE_DIRECTORIES )
      list( APPEND _dependencies ${_include_dirs} )

    endif()

  endforeach()

  if( _dependencies )
    list( REMOVE_DUPLICATES _dependencies )
    set( ${dependencies} ${_dependencies} PARENT_SCOPE )
  endif()

endfunction(ecbuild_include_dependencies)

#############################################################################################

function( ecbuild_pkgconfig_libs pkgconfig_libs libraries ignore_libs )

  set( _libraries ${${libraries}} )
  set( _ignore_libs ${${ignore_libs}} )

  foreach( _lib ${_libraries} )

    unset( _name )
    unset( _dir  )

    if( ${_lib} MATCHES ".+/Frameworks/.+" )

      get_filename_component( _name ${_lib} NAME_WE )
      list( APPEND _pkgconfig_libs "-framework ${_name}" )

    else()

      if( ${_lib} MATCHES "-l.+" )

        string( REGEX REPLACE "^-l" "" _name ${_lib} )

      else()


        get_filename_component( _name ${_lib} NAME_WE )
        get_filename_component( _dir  ${_lib} PATH )

        if( NOT _name )
          set( _name ${_lib} )
        endif()

        string( REGEX REPLACE "^lib" "" _name ${_name} )

        if( "${_dir}" STREQUAL "/usr/lib" )
          unset( _dir )
        endif()
        if( "${_dir}" STREQUAL "/usr/lib64" )
          unset( _dir )
        endif()

      endif()

      set( _set_append TRUE )
        foreach( _ignore ${_ignore_libs} )
          if( "${_name}" STREQUAL "${_ignore}" )
            set( _set_append FALSE )
          endif()
      endforeach()

      if( _set_append )

        if( _dir )
          list( APPEND _pkgconfig_libs "-L${_dir}" "-l${_name}" )
        else()
          list( APPEND _pkgconfig_libs "-l${_name}" )
        endif()

      endif()

    endif( ${_lib} MATCHES ".+/Frameworks/.+" )

  endforeach( _lib ${_libraries} )

  if( _pkgconfig_libs )
    list( REMOVE_DUPLICATES _pkgconfig_libs )
    string( REPLACE ";" " " _pkgconfig_libs "${_pkgconfig_libs}" )

    set( ${pkgconfig_libs} ${_pkgconfig_libs} PARENT_SCOPE )
  endif()

endfunction(ecbuild_pkgconfig_libs)


#############################################################################################


function( ecbuild_pkgconfig_include INCLUDE INCLUDE_DIRS ignore_includes )

  string( TOUPPER ${PROJECT_NAME} PNAME )

  set( _ignore_includes ${${ignore_includes}} )

  list( APPEND ignore_include_dirs
    "/usr/include"
     ${${PNAME}_INCLUDE_DIRS} # These are build-directory includes
     ${_ignore_includes}
  )

  foreach( _incdir ${${INCLUDE_DIRS}} )

    foreach( _ignore ${ignore_include_dirs} )
      if( "${_incdir}" STREQUAL "${_ignore}" )
        unset( _incdir )
      endif()
    endforeach()

    if( _incdir )
      list( APPEND _include "-I${_incdir}")
    endif()

  endforeach()

  if( _include )
    list( REMOVE_DUPLICATES _include)
    string( REPLACE ";" " " _include "${_include}")
    set( ${INCLUDE} ${_include} PARENT_SCOPE )
  endif()

endfunction(ecbuild_pkgconfig_include)


#############################################################################################

function( ecbuild_pkgconfig )

  set( options REQUIRES NO_PRIVATE_INCLUDE_DIRS )
  set( single_value_args FILEPATH NAME TEMPLATE URL DESCRIPTION )
  set( multi_value_args LIBRARIES IGNORE_INCLUDE_DIRS IGNORE_LIBRARIES VARIABLES LANGUAGES )

  cmake_parse_arguments( _PAR "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

  string( TOUPPER ${PROJECT_NAME} PNAME )
  string( TOLOWER ${PROJECT_NAME} LNAME )

  if(_PAR_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unknown keywords given to ecbuild_add_executable(): \"${_PAR_UNPARSED_ARGUMENTS}\"")
  endif()

  unset( PKGCONFIG_LANGUAGES )
  if( NOT _PAR_LANGUAGES )
    if( CMAKE_C_COMPILER_LOADED )
      list( APPEND PKGCONFIG_LANGUAGES C )
    endif()
    if( CMAKE_CXX_COMPILER_LOADED )
      list( APPEND PKGCONFIG_LANGUAGES CXX )
    endif()
    if( CMAKE_Fortran_COMPILER_LOADED )
      list( APPEND PKGCONFIG_LANGUAGES Fortran )
    endif()
  else()
    foreach( _lang ${_PAR_LANGUAGES} )
      if( CMAKE_${_lang}_COMPILER_LOADED )
        list( APPEND PKGCONFIG_LANGUAGES ${_lang} )
      endif()
    endforeach()
  endif()

  foreach( _lang ${PKGCONFIG_LANGUAGES} )
    set( PKGCONFIG_HAVE_${_lang} 1 )
  endforeach()

  set( LIBRARIES ${${PNAME}_LIBRARIES} )
  if( _PAR_LIBRARIES )
    set( LIBRARIES ${_PAR_LIBRARIES} )
  endif()

  if( CMAKE_CXX_COMPILER_LOADED )
   set( _linker_lang CXX )
  elseif( CMAKE_C_COMPILER_LOADED )
   set( _linker_lang C )
  elseif( CMAKE_Fortran_COMPILER_LOADED )
   set( _linker_lang Fortran )
  endif()

  set( RPATH_FLAG ${CMAKE_SHARED_LIBRARY_RUNTIME_${_linker_lang}_FLAG} )

  set( PKGCONFIG_MOD_FLAG ${CMAKE_Fortran_MODPATH_FLAG} )

  if( NOT PKGCONFIG_MOD_FLAG )
    set( PKGCONFIG_MOD_FLAG "-I" )
  endif()

  ecbuild_pkgconfig_libs( PKGCONFIG_LIBS LIBRARIES _PAR_IGNORE_LIBRARIES )

  ecbuild_library_dependencies( _libraries LIBRARIES )
  foreach( _lib ${LIBRARIES} )
    list( REMOVE_ITEM _libraries ${_lib} )
  endforeach()

  ecbuild_pkgconfig_libs( PKGCONFIG_LIBS_PRIVATE _libraries _PAR_IGNORE_LIBRARIES )

  if( NOT _PAR_NO_PRIVATE_INCLUDE_DIRS )
    ecbuild_include_dependencies( _include_dirs LIBRARIES )
    ecbuild_pkgconfig_include( PKGCONFIG_CFLAGS _include_dirs _PAR_IGNORE_INCLUDE_DIRS )
  endif()

  set( PKGCONFIG_INCLUDE "-I\${includedir}" )
  if( PKGCONFIG_HAVE_Fortran )
    set( PKGCONFIG_INCLUDE "${PKGCONFIG_INCLUDE} ${PKGCONFIG_MOD_FLAG}\${fmoddir}" )
  endif()

  if( NOT _PAR_TEMPLATE )
    set( _PAR_TEMPLATE "${ECBUILD_MACROS_DIR}/pkg-config.pc.in" )
  endif()

  set( PKGCONFIG_NAME ${LNAME} )
  if( _PAR_NAME )
    set( PKGCONFIG_NAME ${_PAR_NAME} )
  endif()

  if( NOT _PAR_FILEPATH )
    set( _PAR_FILEPATH "${PKGCONFIG_NAME}.pc" )
  endif()

  set( PKGCONFIG_DESCRIPTION ${${PNAME}_DESCRIPTION} )
  if( _PAR_DESCRIPTION )
    set( PKGCONFIG_DESCRIPTION ${_PAR_DESCRIPTION} )
  endif()

  set( PKGCONFIG_URL ${${PNAME}_URL} )
  if( _PAR_URL )
    set( PKGCONFIG_URL ${_PAR_URL} )
  endif()

  set( PKGCONFIG_VERSION ${${PNAME}_VERSION} )
  set( PKGCONFIG_GIT_TAG ${${PNAME}_GIT_SHA1} )  # For now set it to a commit id

  if( _PAR_VARIABLES )
    set( PKGCONFIG_VARIABLES "\n### Features:\n\n")
    foreach( _var ${_PAR_VARIABLES} )
      set( PKGCONFIG_VARIABLES "${PKGCONFIG_VARIABLES}${_var}=${${_var}}\n" )
    endforeach()
  endif()

  configure_file( ${_PAR_TEMPLATE} "${CMAKE_BINARY_DIR}/${_PAR_FILEPATH}" @ONLY )
  message( STATUS "pkg-config file created: ${_PAR_FILEPATH}" )

  install( FILES ${CMAKE_BINARY_DIR}/${_PAR_FILEPATH}
           DESTINATION ${CMAKE_INSTALL_PREFIX}/${INSTALL_LIB_DIR}/pkgconfig/
           COMPONENT utilities )

endfunction(ecbuild_pkgconfig)
