# (C) Copyright 1996-2014 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

############################################################################################
#
# macro for adding search paths to CMAKE_PREFIX_PATH
# for example the ECMWF /usr/local/apps paths
#
# usage: ecbuild_add_extra_search_paths( netcdf4 )

function( ecbuild_add_extra_search_paths pkg )

    string( TOUPPER ${pkg} _PKG )

	ecbuild_list_extra_search_paths( ${pkg} CMAKE_PREFIX_PATH )

	# fixes BOOST_ROOT taking precedence on the search for location
	if( ${pkg} STREQUAL "boost" )
		if( BOOST_ROOT OR BOOSTROOT OR DEFINED ENV{BOOST_ROOT} OR DEFINED ENV{BOOSTROOT} )
			set( CMAKE_PREFIX_PATH ${BOOST_ROOT} ${BOOSTROOT} $ENV{BOOST_ROOT} $ENV{BOOSTROOT} ${CMAKE_PREFIX_PATH} )
		endif()
	endif()

    # in DEVELOPER_MODE we give priority to projects parallel in the build tree
    # so lets prepend a parallel build tree to the search path if we find it
    if( DEVELOPER_MODE )
        if( EXISTS ${CMAKE_BINARY_DIR}/../${pkg}/${pkg}-config.cmake AND NOT ${_PKG}_PATH )
            get_filename_component( _proj_bdir "${CMAKE_BINARY_DIR}/../${pkg}" ABSOLUTE )
            set( ${_PKG}_PATH "${_proj_bdir}" PARENT_SCOPE )
        endif()
    endif()

    set( CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} PARENT_SCOPE )
    # debug_var( CMAKE_PREFIX_PATH )

endfunction()

