# (C) Copyright 1996-2015 ECMWF.
# 
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0. 
# In applying this licence, ECMWF does not waive the privileges and immunities 
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

# - Try to find FDB
# Once done this will define
#  LEGACY_FDB_FOUND - System has FDB
#  LEGACY_FDB_INCLUDE_DIRS - The FDB include directories
#  LEGACY_FDB_LIBRARIES - The libraries needed to use FDB


if( NOT LEGACY_FDB_FOUND )

	if( DEFINED LEGACY_FDB_PATH )
		find_library( LEGACY_FDB_LIBRARY NAMES fdb_legacy PATHS ${LEGACY_FDB_PATH} ${LEGACY_FDB_PATH}/lib NO_DEFAULT_PATH)
	endif()
	
	find_library( LEGACY_FDB_LIBRARY NAMES fdb_legacy )
	
	set( LEGACY_FDB_LIBRARIES  ${LEGACY_FDB_LIBRARY} )
	
	include(FindPackageHandleStandardArgs)
	
	# handle the QUIETLY and REQUIRED arguments and set LEGACY_FDB_FOUND to TRUE
	# if all listed variables are TRUE
	find_package_handle_standard_args(LEGACY_FDB  DEFAULT_MSG
		LEGACY_FDB_LIBRARY )
	
	mark_as_advanced(LEGACY_FDB_LIBRARY)

endif()
