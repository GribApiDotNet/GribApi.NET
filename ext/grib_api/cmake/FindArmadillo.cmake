# (C) Copyright 1996-2014 ECMWF.
# 
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0. 
# In applying this licence, ECMWF does not waive the privileges and immunities 
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

ecbuild_add_extra_search_paths( armadillo )

IF( NOT DEFINED ARMADILLO_PATH AND NOT "$ENV{ARMADILLO_PATH}" STREQUAL "" )
  SET( ARMADILLO_PATH "$ENV{ARMADILLO_PATH}" )
ENDIF()

if( DEFINED ARMADILLO_PATH )
        find_path(ARMADILLO_INCLUDE_DIR ARMADILLO.h PATHS ${ARMADILLO_PATH}/include PATH_SUFFIXES ARMADILLO  NO_DEFAULT_PATH)
        find_library(ARMADILLO_LIBRARY  ARMADILLO   PATHS ${ARMADILLO_PATH}/lib     PATH_SUFFIXES ARMADILLO  NO_DEFAULT_PATH)
endif()

find_path(ARMADILLO_INCLUDE_DIR  armadillo PATH_SUFFIXES include )
find_library( ARMADILLO_LIBRARY  armadillo   PATH_SUFFIXES lib )

set( ARMADILLO_LIBRARIES    ${ARMADILLO_LIBRARY} )
set( ARMADILLO_INCLUDE_DIRS ${ARMADILLO_INCLUDE_DIR} )

include(FindPackageHandleStandardArgs)

# handle the QUIETLY and REQUIRED arguments and set ARMADILLO_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(ARMADILLO  DEFAULT_MSG
                                  ARMADILLO_LIBRARY ARMADILLO_INCLUDE_DIR)

mark_as_advanced(ARMADILLO_INCLUDE_DIR ARMADILLO_LIBRARY )
