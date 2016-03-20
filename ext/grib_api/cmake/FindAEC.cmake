# (C) Copyright 1996-2015 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

# - Try to find AEC (Adaptive Entropy Coding library)
# See https://www.dkrz.de/redmine/projects/aec/wiki

# Once done this will define
#  AEC_FOUND - System has AEC
#  AEC_INCLUDE_DIRS - The AEC include directories
#  AEC_LIBRARIES - The libraries needed to use AEC

if( DEFINED AEC_PATH )
    find_path( AEC_INCLUDE_DIR szlib.h    PATHS ${AEC_PATH}/include PATH_SUFFIXES aec NO_DEFAULT_PATH )
    find_library( AEC_LIBRARY  NAMES aec  PATHS ${AEC_PATH}/lib     PATH_SUFFIXES aec NO_DEFAULT_PATH )
endif()

find_path( AEC_INCLUDE_DIR szlib.h PATH_SUFFIXES aec )
find_library( AEC_LIBRARY NAMES aec PATH_SUFFIXES aec )

set( AEC_LIBRARIES    ${AEC_LIBRARY} )
set( AEC_INCLUDE_DIRS ${AEC_INCLUDE_DIR} )

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(AEC  DEFAULT_MSG AEC_LIBRARY AEC_INCLUDE_DIR)

mark_as_advanced(AEC_INCLUDE_DIR AEC_LIBRARY )
