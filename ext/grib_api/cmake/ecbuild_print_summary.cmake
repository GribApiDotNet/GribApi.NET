# (C) Copyright 1996-2014 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

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

    # issue a warning that 'make install' mighty be broken for old cmakes
    if( ${CMAKE_VERSION} VERSION_LESS "2.8.3" )

        message( STATUS " +++ WARNING +++ WARNING +++ WARNING +++" )
        message( STATUS " +++ " )
		message( STATUS " +++ This CMake version [${CMAKE_VERSION}] is rather OLD !!" )
        message( STATUS " +++ " )
        message( STATUS " +++ We work hard to keep CMake backward compatibility (support >= 2.6.4)" )
        message( STATUS " +++ but there are some limits inherent to older versions." )
        message( STATUS " +++ " )
        message( STATUS " +++ You will be able to build the software... " )
        message( STATUS " +++ " )
        message( STATUS " +++ But: " )
        message( STATUS " +++     * the 'make install' target most likely will NOT WORK" )
        message( STATUS " +++     * if you want to install these binaries you might need to copy them by yourself" )
        message( STATUS " +++     * the binaries are in '${CMAKE_BINARY_DIR}' /lib and /bin" )
        message( STATUS " +++     * copying headers will take substantially more work, and you might end up copying files that won't be needed" )
        message( STATUS " +++ " )
        message( STATUS " +++ Therefore, we recommend that you:  " )
        message( STATUS " +++     * upgrade to a newer CMake with version at least >= 2.8.3" )
        message( STATUS " +++     * remove this build directory '${CMAKE_BINARY_DIR}'" )
        message( STATUS " +++     * rerun a newer cmake on an new empty build directory" )
        message( STATUS " +++ " )
        message( STATUS " +++ WARNING +++ WARNING +++ WARNING +++" )

    endif()

    endif( PROJECT_NAME STREQUAL CMAKE_PROJECT_NAME )

endmacro( ecbuild_print_summary )
