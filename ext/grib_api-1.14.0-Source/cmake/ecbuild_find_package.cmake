# (C) Copyright 1996-2014 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

##############################################################################
# macro for adding a subproject directory
##############################################################################

macro( ecbuild_find_package )

    set( options REQUIRED QUIET EXACT )
    set( single_value_args NAME VERSION )
    set( multi_value_args )

    cmake_parse_arguments( _PAR "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

    if(_PAR_UNPARSED_ARGUMENTS)
      message(FATAL_ERROR "Unknown keywords given to ecbuild_find_package(): \"${_PAR_UNPARSED_ARGUMENTS}\"")
    endif()

    if( NOT _PAR_NAME  )
      message(FATAL_ERROR "The call to ecbuild_find_package() doesn't specify the NAME.")
    endif()

    if( _PAR_EXACT AND NOT _PAR_VERSION )
      message(FATAL_ERROR "Call to ecbuild_find_package() requests EXACT but doesn't specify VERSION.")
    endif()

	# debug_var( _PAR_NAME )

    string( TOUPPER ${_PAR_NAME} PNAME )

    set( _${PNAME}_version "" )
    if( _PAR_VERSION )
        set( _${PNAME}_version ${_PAR_VERSION} )
        if( _PAR_EXACT )
            set( _${PNAME}_version ${_PAR_VERSION} EXACT )
        endif()
    endif()

	# check developer mode (search in cmake cache )

	if( NOT ${DEVELOPER_MODE} )
		set( NO_DEV_BUILD_DIRS NO_CMAKE_PACKAGE_REGISTRY NO_CMAKE_BUILDS_PATH )
	endif()

	# search user defined paths first

    if( NOT DEFINED ${PNAME}_PATH AND NOT "$ENV{${PNAME}_PATH}" STREQUAL "" )
        set( ${PNAME}_PATH "$ENV{${PNAME}_PATH}" )
    endif()

    if( NOT DEFINED ${_PAR_NAME}_DIR AND NOT "$ENV{${_PAR_NAME}_DIR}" STREQUAL "" )
        set( ${_PAR_NAME}_DIR "$ENV{${_PAR_NAME}_DIR}" )
    endif()

	if( ${_PAR_NAME}_PATH OR ${PNAME}_PATH OR ${_PAR_NAME}_DIR OR ${PNAME}_DIR )

		# debug_var( ${_PAR_NAME}_PATH )
		# debug_var( ${PNAME}_PATH )

		# 1) search using CONFIG mode -- try to locate a configuration file provided by the package (package-config.cmake)

		if( NOT ${_PAR_NAME}_FOUND )
			find_package( ${_PAR_NAME} ${_${PNAME}_version} NO_MODULE QUIET
                HINTS ${${PNAME}_PATH} ${_PAR_NAME}_PATH ${${PNAME}_DIR} ${${_PAR_NAME}_DIR}
                NO_DEFAULT_PATH )
		endif()

		# 2) search using a file Find<package>.cmake if it exists ( macro should itself take *_PATH into account )

		if( NOT ${_PAR_NAME}_FOUND )
			find_package( ${_PAR_NAME} ${_${PNAME}_version} MODULE QUIET )
		endif()

		# is <package>_PATH was given and we don't find anything then we FAIL

		if( NOT ${_PAR_NAME}_FOUND )
			if( ${_PAR_NAME}_PATH )
				message( FATAL_ERROR "${_PAR_NAME}_PATH was provided by user but package ${_PAR_NAME} wasn't found" )
			endif()
			if( ${PNAME}_PATH )
				message( FATAL_ERROR "${PNAME}_PATH was provided by user but package ${_PAR_NAME} wasn't found" )
			endif()
		endif()

	endif()

	# 3) search developer cache and recently configured packages in the CMake GUI

	if( NOT ${_PAR_NAME}_FOUND )

		find_package( ${_PAR_NAME} ${_${PNAME}_version} QUIET NO_MODULE HINTS ENV ${PNAME}_PATH
				${NO_DEV_BUILD_DIRS}
				NO_CMAKE_ENVIRONMENT_PATH
				NO_SYSTEM_ENVIRONMENT_PATH
				NO_CMAKE_SYSTEM_PATH
				NO_CMAKE_SYSTEM_PACKAGE_REGISTRY )

	endif()

	# 4) search special ECMWF paths

	if( NOT ${_PAR_NAME}_FOUND )

		set( _ecmwf_paths ) # clear variable
		ecbuild_list_extra_search_paths( ${_PAR_NAME} _ecmwf_paths )

		if( _ecmwf_paths )
			find_package( ${_PAR_NAME} ${_${PNAME}_version} QUIET NO_MODULE PATHS ${_ecmwf_paths} NO_DEFAULT_PATH )
		endif()

	endif()

	# 5) search system paths, for <package>-config.cmake

	if( NOT ${_PAR_NAME}_FOUND )

		find_package( ${_PAR_NAME} ${_${PNAME}_version} QUIET NO_MODULE ${NO_DEV_BUILD_DIRS} )

	endif()

	# 6) search system paths, using Find<package>.cmake if it exists

	if( NOT ${_PAR_NAME}_FOUND )

		find_package( ${_PAR_NAME} ${_${PNAME}_version} QUIET MODULE )

	endif()

    # check version found is acceptable

    if( ${_PAR_NAME}_FOUND )
        set( _version_acceptable 1 )
        if( _PAR_VERSION )
            if( ${_PAR_NAME}_VERSION )
                if( _PAR_EXACT )
                    if( NOT ${_PAR_NAME}_VERSION VERSION_EQUAL _PAR_VERSION )
                        message( WARNING "${PROJECT_NAME} requires (exactly) ${_PAR_NAME} = ${_PAR_VERSION} -- found ${${_PAR_NAME}_VERSION}" )
                        set( _version_acceptable 0 )
                    endif()
                else()
                    if( _PAR_VERSION VERSION_LESS ${_PAR_NAME}_VERSION OR _PAR_VERSION VERSION_EQUAL ${_PAR_NAME}_VERSION )
                        set( _version_acceptable 1 )
                    else()
                        if( NOT _PAR_QUIET )
                            message( WARNING "${PROJECT_NAME} requires ${_PAR_NAME} >= ${_PAR_VERSION} -- found ${${_PAR_NAME}_VERSION}" )
                        endif()
                        set( _version_acceptable 0 )
                    endif()
                endif()
            else()
                if( NOT _PAR_QUIET )
                    message( WARNING "${PROJECT_NAME} found ${_PAR_NAME} but no version information, so cannot check if satisfies ${_PAR_VERSION}" )
                endif()
                set( _version_acceptable 0 )
            endif()
        endif()
    endif()

    if( ${_PAR_NAME}_FOUND )

        if( _version_acceptable )
            set( ${PNAME}_FOUND ${${_PAR_NAME}_FOUND} )
        else()
            if( NOT _PAR_QUIET )
                message( WARNING "${PROJECT_NAME} found ${_PAR_NAME} but with unsuitable version" )
            endif()
            set( ${PNAME}_FOUND 0 )
            set( ${_PAR_NAME}_FOUND 0 )
        endif()

    endif()

	### final messages

    set( _failed_message 
        "\n"
        "  ${PROJECT_NAME} FAILED to find package ${_PAR_NAME}\n"
        "\n"
        "    Provide location with \"-D ${PNAME}_PATH=/...\" or \"-D ${_PAR_NAME}_DIR=/...\" \n"
        "    You may also export environment variables ${PNAME}_PATH or ${_PAR_NAME}_DIR\n"
        "\n"
        "  Values (note CAPITALISATION):\n"
        "    ${PNAME}_PATH should contain the path to the installation (as in <install>/bin <install>/lib <install>/include)\n"
        "    ${_PAR_NAME}_DIR should be a directory containing a <package>-config.cmake file (usually <install>/share/<package>/cmake)\n"
        "\n"
         )

	if( NOT ${_PAR_NAME}_FOUND )
		if( _PAR_REQUIRED )
			message( FATAL_ERROR ${_failed_message} " !! ${PROJECT_NAME} requires package ${_PAR_NAME} !!" )
		else()
			if( NOT _PAR_QUIET )
				message( STATUS ${_failed_message} )
			endif()
		endif()
	endif()

endmacro()
