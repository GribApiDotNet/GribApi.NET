# (C) Copyright 1996-2015 ECMWF.
# 
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0. 
# In applying this licence, ECMWF does not waive the privileges and immunities 
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

# - Try to find the OpenJPEG includes and library
# This module defines
#  OPENJPEG_FOUND         - System has OpenJPEG
#  OPENJPEG_INCLUDE_DIRS  - the OpenJPEG include directories
#  OPENJPEG_LIBRARIES     - the libraries needed to use OpenJPEG
#
# also defined internally:
#  OPENJPEG_LIBRARY, where to find the OpenJPEG library.
#  OPENJPEG_INCLUDE_DIR, where to find the openjpeg.h header

IF( NOT DEFINED OPENJPEG_PATH AND NOT "$ENV{OPENJPEG_PATH}" STREQUAL "" )
  SET( OPENJPEG_PATH "$ENV{OPENJPEG_PATH}" )
ENDIF()

# TODO: This only works for OpenJPEG v1.x.y and not for v2 which has a different API, library name etc
if( DEFINED OPENJPEG_PATH )
        find_path(OPENJPEG_INCLUDE_DIR openjpeg.h PATHS ${OPENJPEG_PATH}/include PATH_SUFFIXES openjpeg  NO_DEFAULT_PATH)
        find_library(OPENJPEG_LIBRARY  openjpeg   PATHS ${OPENJPEG_PATH}/lib     PATH_SUFFIXES openjpeg  NO_DEFAULT_PATH)
endif()

find_path(OPENJPEG_INCLUDE_DIR  openjpeg.h PATH_SUFFIXES openjpeg )
find_library( OPENJPEG_LIBRARY  openjpeg   PATH_SUFFIXES openjpeg )

set( OPENJPEG_LIBRARIES    ${OPENJPEG_LIBRARY} )
set( OPENJPEG_INCLUDE_DIRS ${OPENJPEG_INCLUDE_DIR} )

include(FindPackageHandleStandardArgs)

# handle the QUIETLY and REQUIRED arguments and set OPENJPEG_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(OpenJPEG  DEFAULT_MSG
                                  OPENJPEG_LIBRARY OPENJPEG_INCLUDE_DIR)

mark_as_advanced(OPENJPEG_INCLUDE_DIR OPENJPEG_LIBRARY )
