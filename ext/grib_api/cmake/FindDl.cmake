# © Copyright 1996-2014 ECMWF.
# 
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0. 
# In applying this licence, ECMWF does not waive the privileges and immunities 
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

#Sets:
# DL_LIBRARIES      = the library to link against (RT etc)

if( DEFINED DL_PATH )
    find_library(DL_LIBRARIES dl PATHS ${DL_PATH}/lib NO_DEFAULT_PATH )
endif()

find_library(DL_LIBRARIES dl )

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(DL  DEFAULT_MSG DL_LIBRARIES )
