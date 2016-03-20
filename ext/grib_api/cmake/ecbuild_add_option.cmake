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
# ecbuild_add_option
# ==================
#
# Add a CMake configuration option, which may depend on a list of packages. ::
#
#   ecbuild_add_option( FEATURE <name>
#                       [ DEFAULT ON|OFF ]
#                       [ DESCRIPTION <description> ]
#                       [ REQUIRED_PACKAGES <package1> [<package2> ...] ]
#                       [ CONDITION <condition1> [<condition2> ...] ]
#                       [ ADVANCED ] )
#
# Options
# -------
#
# FEATURE : required
#   name of the feature / option
#
# DEFAULT : optional, defaults to ON
#   if set to ON, the feature is enabled even if not explicitly requested
#
# DESCRIPTION : optional
#   string describing the feature (shown in summary and stored in the cache)
#
# REQUIRED_PACKAGES : optional
#   list of packages required to be found for this feature to be enabled
#
#   The package specification can be either ::
#
#     <package> [ <version> ... ]
#
#   to search for a given package with option minimum required version or ::
#
#     PROJECT <name> [ VERSION <version> ... ]
#
#   to search for an ecBuild project with optional minimum required version.
#
# CONDITION : optional
#   conditional expression which must evaluate to true for this option to be
#   enabled (must be valid in a CMake ``if`` statement)
#
# ADVANCED : optional
#   mark the feature as advanced
#
# Usage
# -----
#
# Features with ``DEFAULT OFF`` need to be explcitly enabled by the user with
# ``-DENABLE_<FEATURE>=ON``. If a feature is enabled, all ``REQUIRED_PACKAGES``
# are found and ``CONDITION`` is met, ecBuild sets the variable
# ``HAVE_<FEATURE>`` to ``ON``. This is the variable to use to check for the
# availability of the feature.
#
# If a feature is explicitly enabled but the required packages are not found,
# configuration fails. This only applies when configuring from *clean cache*.
# With an already populated cache, use ``-DENABLE_<FEATURE>=REQUIRE`` to make
# the feature a required feature (this cannot be done via the CMake GUI).
#
##############################################################################

macro( ecbuild_add_option )

  set( options ADVANCED )
  set( single_value_args FEATURE DEFAULT DESCRIPTION )
  set( multi_value_args  REQUIRED_PACKAGES CONDITION )

  cmake_parse_arguments( _p "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

  if( _p_UNPARSED_ARGUMENTS )
    message(FATAL_ERROR "Unknown keywords given to ecbuild_add_option(): \"${_p_UNPARSED_ARGUMENTS}\"")
  endif()

  # check FEATURE parameter

  if( NOT _p_FEATURE  )
    message(FATAL_ERROR "The call to ecbuild_add_option() doesn't specify the FEATURE.")
  endif()

  # check DEFAULT parameter

  if( NOT DEFINED _p_DEFAULT )
    set( _p_DEFAULT ON )
  else()
    if( NOT _p_DEFAULT MATCHES "[Oo][Nn]" AND NOT _p_DEFAULT MATCHES "[Oo][Ff][Ff]" )
      message(FATAL_ERROR "In macro ecbuild_add_option(), DEFAULT is either ON or OFF: \"${_p_DEFAULT}\"")
    endif()
  endif()
  ecbuild_debug("ecbuild_add_option(${_p_FEATURE}): defaults to ${_p_DEFAULT}")

  # check CONDITION parameter
  if( DEFINED _p_CONDITION )
    set(_feature_condition_file "${CMAKE_CURRENT_BINARY_DIR}/set_${_p_FEATURE}_condition.cmake")
    file( WRITE  ${_feature_condition_file} "  if( ")
    foreach( term ${_p_CONDITION} )
      file( APPEND ${_feature_condition_file} " ${term}")
    endforeach()
    file( APPEND ${_feature_condition_file} " )\n    set(_${_p_FEATURE}_condition TRUE)\n  else()\n    set(_${_p_FEATURE}_condition FALSE)\n  endif()\n")
    include( ${_feature_condition_file} )
    ecbuild_debug("ecbuild_add_option(${_p_FEATURE}): checking condition ${_p_CONDITION} -> ${_${_p_FEATURE}_condition}")
  else()
    set( _${_p_FEATURE}_condition TRUE )
  endif()

  # check if user provided value

  get_property( _in_cache CACHE ENABLE_${_p_FEATURE} PROPERTY VALUE )

  # A feature set to REQUIRE is always treated as explicitly enabled
  if( ENABLE_${_p_FEATURE} MATCHES "REQUIRE" )
    set( ENABLE_${_p_FEATURE} ON CACHE BOOL "" FORCE )
    ecbuild_debug("ecbuild_add_option(${_p_FEATURE}): ENABLE_${_p_FEATURE} was required")
    set( ${_p_FEATURE}_user_provided_input 1 CACHE BOOL "" FORCE )
  elseif( NOT "${ENABLE_${_p_FEATURE}}" STREQUAL "" AND _in_cache )
    ecbuild_debug("ecbuild_add_option(${_p_FEATURE}): ENABLE_${_p_FEATURE} was found in cache")
    set( ${_p_FEATURE}_user_provided_input 1 CACHE BOOL "" )
  else()
    ecbuild_debug("ecbuild_add_option(${_p_FEATURE}): ENABLE_${_p_FEATURE} not found in cache")
    set( ${_p_FEATURE}_user_provided_input 0 CACHE BOOL "" )
  endif()

  mark_as_advanced( ${_p_FEATURE}_user_provided_input )


  # define the option -- for cmake GUI

  option( ENABLE_${_p_FEATURE} "${_p_DESCRIPTION}" ${_p_DEFAULT} )
  ecbuild_set_feature( ${_p_FEATURE} ENABLED ${_p_DEFAULT} PURPOSE "${_p_DESCRIPTION}" )

  ecbuild_debug("ecbuild_add_option(${_p_FEATURE}): ENABLE_${_p_FEATURE} = ${ENABLE_${_p_FEATURE}}")
  set( _do_search ${ENABLE_${_p_FEATURE}} )
  if( _p_FEATURE STREQUAL "OMP" )
    set( _do_search TRUE )
  endif()

  if( _do_search  )
    ecbuild_debug("ecbuild_add_option(${_p_FEATURE}): feature enabled")

    set( HAVE_${_p_FEATURE} 1 )

    if( _${_p_FEATURE}_condition )

      ### search for dependent packages

      set( _failed_to_find_packages )  # clear variable
      foreach( pkg ${_p_REQUIRED_PACKAGES} )
        ecbuild_debug("ecbuild_add_option(${_p_FEATURE}): searching for dependent package ${pkg}")

        string(REPLACE " " ";" pkglist ${pkg}) # string to list

        list( GET pkglist 0 pkgname )

        if( pkgname STREQUAL "PROJECT" )  # if 1st entry is PROJECT, then we are looking for a ecbuild project
          set( pkgproject 1 )
          list( GET pkglist 1 pkgname )
        else()                            # else 1st entry is package name
          set( pkgproject 0 )
        endif()

        # debug_var( pkg )
        # debug_var( pkglist )
        # debug_var( pkgname )

        string( TOUPPER ${pkgname} pkgUPPER )
        string( TOLOWER ${pkgname} pkgLOWER )

        if( ${pkgname}_FOUND OR ${pkgUPPER}_FOUND OR ${pkgLOWER}_FOUND )

          ecbuild_debug("ecbuild_add_option(${_p_FEATURE}): ${pkgname} has already been found")
          set( ${pkgname}_already_found 1 )

        else()

          if( pkgproject )

            ecbuild_debug("ecbuild_add_option(${_p_FEATURE}): searching for ecbuild project ${pkgname}")
            ecbuild_use_package( ${pkglist} )

          else()

            if( pkgname STREQUAL "MPI" )
              set( _find_args ${pkglist} )
              list( REMOVE_ITEM _find_args "MPI" )
              ecbuild_debug("ecbuild_add_option(${_p_FEATURE}): searching for MPI")
              ecbuild_find_mpi( ${_find_args} )
            elseif( pkgname STREQUAL "OMP" )
              set( _find_args ${pkglist} )
              list( REMOVE_ITEM _find_args "OMP" )
              if( NOT ENABLE_${_p_FEATURE} )
                list( APPEND _find_args STUBS )
              endif()
              ecbuild_debug("ecbuild_add_option(${_p_FEATURE}): searching for OpenMP")
              ecbuild_find_omp( ${_find_args} )
            elseif( pkgname STREQUAL "Python" OR pkgname STREQUAL "PYTHON" )
              set( _find_args ${pkglist} )
              list( REMOVE_ITEM _find_args ${pkgname} )
              ecbuild_debug("ecbuild_add_option(${_p_FEATURE}): searching for Python")
              ecbuild_find_python( ${_find_args} )
            else()
              ecbuild_debug("ecbuild_add_option(${_p_FEATURE}): searching for package ${pkgname}")
              find_package( ${pkglist} )
            endif()

          endif()

        endif()

        # if found append to list of third-party libraries (to be forward to other packages )
        if( ${pkgname}_FOUND OR ${pkgUPPER}_FOUND OR ${pkgLOWER}_FOUND )

          list( APPEND ${PROJECT_NAME_CAPS}_TPLS ${pkgname} )
          list( REMOVE_DUPLICATES ${PROJECT_NAME_CAPS}_TPLS )

        endif()

        # debug_var( ${pkgname}_FOUND  )
        # debug_var( ${pkgLOWER}_FOUND )
        # debug_var( ${pkgUPPER}_FOUND )

        # we have feature if all required packages were FOUND

        if( ${pkgname}_FOUND OR ${pkgUPPER}_FOUND OR ${pkgLOWER}_FOUND )
          message( STATUS "Found package ${pkgname} required for feature ${_p_FEATURE}" )
        else()
          message( STATUS "Could not find package ${pkgname} required for feature ${_p_FEATURE} -- Provide ${pkgname} location with -D${pkgUPPER}_PATH=/..." )
          set( HAVE_${_p_FEATURE} 0 )
          list( APPEND _failed_to_find_packages ${pkgname} )
        endif()

      endforeach()
    else( _${_p_FEATURE}_condition )
      set( HAVE_${_p_FEATURE} 0 )
    endif( _${_p_FEATURE}_condition )

    ecbuild_set_feature( ${_p_FEATURE} ENABLED ${HAVE_${_p_FEATURE}} )
    # FINAL CHECK

    if( HAVE_${_p_FEATURE} )

      message( STATUS "Feature ${_p_FEATURE} enabled" )

    else() # if user provided input and we cannot satisfy FAIL otherwise WARN

      if( ${_p_FEATURE}_user_provided_input )
        if( _${_p_FEATURE}_condition )
          message( FATAL_ERROR "Feature ${_p_FEATURE} cannot be enabled -- following required packages weren't found: ${_failed_to_find_packages}" )
        else()
          message( FATAL_ERROR "Feature ${_p_FEATURE} cannot be enabled -- following condition was not met: ${_p_CONDITION}" )
        endif()
      else()
        if( _${_p_FEATURE}_condition )
          message( STATUS "Feature ${_p_FEATURE} was not enabled (also not requested) -- following condition was not met: ${_p_CONDITION}" )
        else()
          message( STATUS "Feature ${_p_FEATURE} was not enabled (also not requested) -- following required packages weren't found: ${_failed_to_find_packages}" )
        endif()
        set( ENABLE_${_p_FEATURE} OFF )
        ecbuild_set_feature( ${_p_FEATURE} ENABLED OFF )
      endif()

    endif()

  else( _do_search )

    ecbuild_debug("ecbuild_add_option(${_p_FEATURE}): feature disabled")
    set( HAVE_${_p_FEATURE} 0 )
    ecbuild_set_feature( ${_p_FEATURE} ENABLED OFF )

  endif( _do_search )


  if( ${_p_ADVANCED} )
    mark_as_advanced( ENABLE_${_p_FEATURE} )
  endif()

  set( ${PROJECT_NAME_CAPS}_HAVE_${_p_FEATURE} ${HAVE_${_p_FEATURE}} )

endmacro( ecbuild_add_option  )
