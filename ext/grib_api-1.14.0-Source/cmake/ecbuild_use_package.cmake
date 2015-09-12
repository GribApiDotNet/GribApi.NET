# (C) Copyright 1996-2014 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

##############################################################################
# function for adding a subproject directory
##############################################################################

macro( ecbuild_use_package )

    set( options            REQUIRED QUIET EXACT )
    set( single_value_args  PROJECT VERSION )
    set( multi_value_args )

	cmake_parse_arguments( _p "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

	if(_p_UNPARSED_ARGUMENTS)
	  message(FATAL_ERROR "Unknown keywords given to ecbuild_use_package(): \"${_p_UNPARSED_ARGUMENTS}\"")
    endif()

	if( NOT _p_PROJECT  )
      message(FATAL_ERROR "The call to ecbuild_use_package() doesn't specify the PROJECT.")
    endif()

	if( _p_EXACT AND NOT _p_VERSION )
      message(FATAL_ERROR "Call to ecbuild_use_package() requests EXACT but doesn't specify VERSION.")
    endif()

    # try to find the package as a subproject and build it

	string( TOUPPER ${_p_PROJECT} PNAME )

    # user defined dir with subprojects

    if( NOT DEFINED ${PNAME}_SOURCE AND DEFINED SUBPROJECT_DIRS )
        foreach( dir ${SUBPROJECT_DIRS} )
			if( EXISTS ${dir}/${_p_PROJECT} AND EXISTS ${dir}/${_p_PROJECT}/CMakeLists.txt )
				set( ${PNAME}_SOURCE "${dir}/${_p_PROJECT}" )
            endif()
        endforeach()
    endif()

    # user defined path to subproject

    if( DEFINED ${PNAME}_SOURCE )

        if( NOT EXISTS ${${PNAME}_SOURCE} OR NOT EXISTS ${${PNAME}_SOURCE}/CMakeLists.txt )
			message( FATAL_ERROR "User defined source directory '${${PNAME}_SOURCE}' for project '${_p_PROJECT}' does not exist or does not contain a CMakeLists.txt file." )
        endif()

		set( ${PNAME}_subproj_dir_ "${${PNAME}_SOURCE}" )

    else() # default is 'dropped in' subdirectory named as project

		if( EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_p_PROJECT} AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_p_PROJECT}/CMakeLists.txt )
			set( ${PNAME}_subproj_dir_ "${CMAKE_CURRENT_SOURCE_DIR}/${_p_PROJECT}" )
        endif()

    endif()

    # check if was already added as subproject ...

    set( _just_added 0 )
    set( _do_version_check 0 )
    set( _source_description "" )

	list( FIND ECBUILD_PROJECTS ${_p_PROJECT} _ecbuild_project_${PNAME} )

    if( NOT _ecbuild_project_${PNAME} EQUAL "-1" )
		set( ${PNAME}_previous_subproj_ 1 )
    else()
		set( ${PNAME}_previous_subproj_ 0 )
    endif()

    # solve capitalization issues
    
	if( ${_p_PROJECT}_FOUND AND NOT ${PNAME}_FOUND )
        set( ${PNAME}_FOUND 1 ) 
    endif()
	if( ${PNAME}_FOUND AND NOT ${_p_PROJECT}_FOUND )
		set( ${_p_PROJECT}_FOUND 1 )
    endif()

    # Case 1) project was NOT added as subproject and is NOT FOUND

	if( NOT ${PNAME}_FOUND AND NOT ${PNAME}_previous_subproj_ )

            # check if SUBPROJDIR is set

			if( DEFINED ${PNAME}_subproj_dir_ )

                # check version is acceptable
                set( _just_added 1 )
                set( _do_version_check 1 )
				set( _source_description "sub-project ${_p_PROJECT} (sources)" )

                # add as a subproject

				set( ${PNAME}_subproj_dir_ ${${PNAME}_subproj_dir_} CACHE PATH "Path to ${_p_PROJECT} source directory" )

				set( ECBUILD_PROJECTS ${ECBUILD_PROJECTS} ${_p_PROJECT} CACHE INTERNAL "" )

				add_subdirectory( ${${PNAME}_subproj_dir_} ${_p_PROJECT} )

				set( ${_p_PROJECT}_BASE_DIR ${CMAKE_BINARY_DIR} )

				set( ${PNAME}_FOUND 1 )
				set( ${_p_PROJECT}_VERSION ${${PNAME}_VERSION} )

            endif()

    endif()

    # Case 2) project was already added as subproject, so is already FOUND -- BUT must check version acceptable

	if( ${PNAME}_previous_subproj_ )

        if( NOT ${PNAME}_FOUND )
			message( FATAL_ERROR "${_p_PROJECT} was already included as sub-project but ${PNAME}_FOUND isn't set -- this is likely a BUG in ecbuild" )
        endif()

        # check version is acceptable
        set( _do_version_check 1 )
		set( _source_description "already existing sub-project ${_p_PROJECT} (sources)" )

    endif()

    # Case 3) project was NOT added as subproject, but is FOUND -- so it was previously found as a binary ( either build or install tree )

	if( ${PNAME}_FOUND AND NOT ${PNAME}_previous_subproj_ AND NOT _just_added )

        # check version is acceptable
        set( _do_version_check 1 )
		set( _source_description "previously found package ${_p_PROJECT} (binaries)" )

    endif()

    # test version for Cases 1,2,3

# debug_var( _p_PROJECT )
# debug_var( _p_VERSION )
# debug_var( ${PNAME}_VERSION )
# debug_var( ${_p_PROJECT}_VERSION )
# debug_var( _just_added )
# debug_var( _do_version_check )
# debug_var( _source_description )
# debug_var( ${PNAME}_FOUND )
# debug_var( ${PNAME}_previous_subproj_ )

	if( _p_VERSION AND _do_version_check )
			if( _p_EXACT )
				if( NOT ${_p_PROJECT}_VERSION VERSION_EQUAL _p_VERSION )
					message( FATAL_ERROR "${PROJECT_NAME} requires (exactly) ${_p_PROJECT} = ${_p_VERSION} -- detected as ${_source_description} ${${_p_PROJECT}_VERSION}" )
                endif()
            else()
				if( _p_VERSION VERSION_LESS ${_p_PROJECT}_VERSION OR _p_VERSION VERSION_EQUAL ${_p_PROJECT}_VERSION )
					message( STATUS "${PROJECT_NAME} requires ${_p_PROJECT} >= ${_p_VERSION} -- detected as ${_source_description} ${${_p_PROJECT}_VERSION}" )
				else()
					message( FATAL_ERROR "${PROJECT_NAME} requires ${_p_PROJECT} >= ${_p_VERSION} -- detected only ${_source_description} ${${_p_PROJECT}_VERSION}" )
                endif()
            endif()
    endif()

    # Case 4) is NOT FOUND so far, NOT as sub-project (now or before), and NOT as binary neither 
    #         so try to find precompiled binaries or a build tree

    if( NOT ${PNAME}_FOUND )

        set( _opts )
		if( _p_VERSION )
			list( APPEND _opts VERSION ${_p_VERSION} )
        endif()
		if( _p_EXACT )
            list( APPEND _opts EXACT )
        endif()
		if( _p_REQUIRED )
            list( APPEND _opts REQUIRED )
        endif()

		ecbuild_find_package( NAME ${_p_PROJECT} ${_opts} )

		if( ${_p_PROJECT}_FOUND )

			set( ${PNAME}_FOUND ${${_p_PROJECT}_FOUND} )

			message( STATUS "[${_p_PROJECT}] (${${_p_PROJECT}_VERSION})" )

            message( STATUS "   ${PNAME}_INCLUDE_DIRS : [${${PNAME}_INCLUDE_DIRS}]" )
            if( ${PNAME}_DEFINITIONS )
                message( STATUS "   ${PNAME}_DEFINITIONS : [${${PNAME}_DEFINITIONS}]" )
            endif()
            message( STATUS "   ${PNAME}_LIBRARIES : [${${PNAME}_LIBRARIES}]" )

        endif()

    endif()

### for when we change this macro to a function()
#	set_parent_scope( ${PNAME}_FOUND )
#	set_parent_scope( ${_p_PROJECT}_FOUND )
#	set_parent_scope( ${PNAME}_VERSION )
#	set_parent_scope( ${_p_PROJECT}_VERSION )
# set_parent_scope( ${_p_PROJECT}_BINARY_DIR )

endmacro()
