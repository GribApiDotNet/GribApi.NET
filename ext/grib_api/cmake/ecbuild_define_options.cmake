# (C) Copyright 1996-2015 ECMWF.
# 
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0. 
# In applying this licence, ECMWF does not waive the privileges and immunities 
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

# general options

option( BUILD_SHARED_LIBS       "build shared libraries when possible"            ON  )

option( ENABLE_RPATHS           "when installing insert RPATHS into binaries"     ON  )
option( ENABLE_RELATIVE_RPATHS  "try to use relative RPATHS, including build dir" ON  )
option( ENABLE_WARNINGS         "enable compiler warnings"                        OFF )

option( ENABLE_LARGE_FILE_SUPPORT "build with large file support"   ON  )

option( ENABLE_PROFILING        "build with profiling support" OFF )

mark_as_advanced( ENABLE_LARGE_FILE_SUPPORT )

option( ENABLE_OS_TESTS          "Run all OS tests" ON )

mark_as_advanced( ENABLE_OS_TESTS )

option( ENABLE_FORTRAN_C_INTERFACE "Enable Fortran/C Interface" OFF )
mark_as_advanced( ENABLE_FORTRAN_C_INTERFACE )

option( DEVELOPER_MODE           "activates developer mode"               OFF )
option( CHECK_UNUSED_FILES       "check for unused project files (slow)"  OFF )

mark_as_advanced( DEVELOPER_MODE  )
mark_as_advanced( CHECK_UNUSED_FILES  )

include( CMakeDependentOption ) # make options depend on one another

cmake_dependent_option( ENABLE_OS_TYPES_TEST     "Run sizeof tests on C types" ON "ENABLE_OS_TESTS" OFF)
cmake_dependent_option( ENABLE_OS_ENDINESS_TEST  "Run OS endiness tests"       ON "ENABLE_OS_TESTS" OFF)
cmake_dependent_option( ENABLE_OS_FUNCTIONS_TEST "Run OS functions tests"      ON "ENABLE_OS_TESTS" OFF)

mark_as_advanced( ENABLE_OS_TYPES_TEST ENABLE_OS_ENDINESS_TEST ENABLE_OS_FUNCTIONS_TEST  )

option( ECBUILD_USE_INCLUDE_DIRECTORIES "Forces to use global include_directories() instead of target specific. Adverse effect on PkgConfig generation." OFF )

mark_as_advanced( ECBUILD_USE_INCLUDE_DIRECTORIES )

set( CMAKE_NO_SYSTEM_FROM_IMPORTED ON )
