# (C) Copyright 1996-2015 ECMWF.
# 
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0. 
# In applying this licence, ECMWF does not waive the privileges and immunities 
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

# - Try to find Pango

# Output:
#   PANGO_FOUND
#   PANGO_LIBRARIES
#   PANGO_INCLUDE_DIRS

find_package(PkgConfig)

pkg_check_modules(PC_LIBPANGO QUIET pango)

debug_var( PC_LIBPANGO_FOUND )
debug_var( PC_LIBPANGO_VERSION )
debug_var( PC_LIBPANGO_LIBRARIES )
debug_var( PC_LIBPANGO_INCLUDE_DIRS )

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args( pango DEFAULT_MSG PC_LIBPANGO_LIBRARIES PC_LIBPANGO_INCLUDE_DIRS )

set( PANGO_VERSION ${PC_LIBPANGO_VERSION} )
set( PANGO_LIBRARIES ${PC_LIBPANGO_LIBRARIES} )
set( PANGO_INCLUDE_DIRS ${PC_LIBPANGO_INCLUDE_DIRS} )

