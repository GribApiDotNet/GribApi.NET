# Config file for the ecbuild package
# Defines the following variables:
#
#  ECBUILD_INCLUDE_DIRS - include directories
#  ECBUILD_DEFINITIONS  - preprocessor definitions
#  ECBUILD_LIBRARIES    - libraries to link against
#  ECBUILD_FEATURES     - list of enabled features
#  ECBUILD_VERSION      - version of the package
#
# Also defines ecbuild third-party library dependencies:
#  ECBUILD_TPLS             - package names of  third-party library dependencies
#  ECBUILD_TPL_INCLUDE_DIRS - include directories
#  ECBUILD_TPL_DEFINITIONS  - preprocessor definitions
#  ECBUILD_TPL_LIBRARIES    - libraries to link against

### compute paths

get_filename_component(ECBUILD_CMAKE_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)

set( ECBUILD_SELF_INCLUDE_DIRS "${ECBUILD_CMAKE_DIR}/../../../include" )
set( ECBUILD_SELF_DEFINITIONS  "" )
set( ECBUILD_SELF_LIBRARIES    "" )

set( ECBUILD_TPLS              "" )
set( ECBUILD_TPL_INCLUDE_DIRS  "" )
set( ECBUILD_TPL_DEFINITIONS   "" )
set( ECBUILD_TPL_LIBRARIES     "" )

### export include paths as absolute paths

set( ECBUILD_INCLUDE_DIRS "" )
foreach( path ${ECBUILD_SELF_INCLUDE_DIRS} )
	get_filename_component( abspath ${path} ABSOLUTE )
	list( APPEND ECBUILD_INCLUDE_DIRS ${abspath} )
endforeach()
list( APPEND ECBUILD_INCLUDE_DIRS ${ECBUILD_TPL_INCLUDE_DIRS} )

### export definitions

set( ECBUILD_DEFINITIONS      ${ECBUILD_SELF_DEFINITIONS} ${ECBUILD_TPL_DEFINITIONS} )

### export list of all libraries

set( ECBUILD_LIBRARIES        ${ECBUILD_SELF_LIBRARIES}   ${ECBUILD_TPL_LIBRARIES}   )

### export the features provided by the package

set( ECBUILD_FEATURES    "TESTS;INSTALL" )
foreach( _f ${ECBUILD_FEATURES} )
	set( ECBUILD_HAVE_${_f} 1 )
endforeach()

# Has this configuration been exported from a build tree?
set( ECBUILD_IS_BUILD_DIR_EXPORT OFF )

if( EXISTS ${ECBUILD_CMAKE_DIR}/ecbuild-import.cmake )
  set( ECBUILD_IMPORT_FILE "${ECBUILD_CMAKE_DIR}/ecbuild-import.cmake" )
  include( ${ECBUILD_IMPORT_FILE} )
endif()

# insert definitions for IMPORTED targets

if( NOT ecbuild_BINARY_DIR )

  if( ECBUILD_IS_BUILD_DIR_EXPORT )
		include( "/tmp/metabuilds/ecflow-metab_5062/opensuse131/ecbuild/builds/ecbuild-targets.cmake" OPTIONAL )
	else()
		include( "${ECBUILD_CMAKE_DIR}/ecbuild-targets.cmake" )
	endif()

endif()

# here goes the imports of the TPL's

include( ${CMAKE_CURRENT_LIST_FILE}.tpls OPTIONAL )

# publish this file as imported

set( ECBUILD_IMPORT_FILE ${CMAKE_CURRENT_LIST_FILE} )
mark_as_advanced( ECBUILD_IMPORT_FILE )

# set ecbuild_BASE_DIR for final installations or build directories

if( NOT ecbuild )
	if( ECBUILD_IS_BUILD_DIR_EXPORT )
		set( ecbuild_BASE_DIR /tmp/metabuilds/ecflow-metab_5062/opensuse131/ecbuild/builds )
	else()
		set( ecbuild_BASE_DIR /usr/local/apps/ecbuild/1.9.0 )
	endif()
endif()
