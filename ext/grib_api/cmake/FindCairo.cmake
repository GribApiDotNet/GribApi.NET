# - Try to find the cairo library
# Once done this will define
#
# CAIRO_FOUND - system has cairo
# CAIRO_INCLUDE_DIRS - the cairo include directory
# CAIRO_LIBRARIES - Link these to use cairo
#
# Define CAIRO_MIN_VERSION for which version desired.


if( NOT DEFINED CAIRO_PATH AND NOT "$ENV{CAIRO_PATH}" STREQUAL "" )
    set( APPEND CAIRO_PATH "$ENV{CAIRO_PATH}" )
endif()

if( NOT DEFINED CAIRO_PATH )

    include(FindPkgConfig)

    if(Cairo_FIND_REQUIRED)
        set(_pkgconfig_REQUIRED "REQUIRED")
    else()
        set(_pkgconfig_REQUIRED "")
    endif()

    if(CAIRO_MIN_VERSION)
        pkg_check_modules(PKCAIRO ${_pkgconfig_REQUIRED} cairo>=${CAIRO_MIN_VERSION})
    else()
        pkg_check_modules(PKCAIRO ${_pkgconfig_REQUIRED} cairo)
    endif()

    if( PKG_CONFIG_FOUND AND PKCAIRO_FOUND )

        find_path(CAIRO_INCLUDE_DIR cairo.h HINTS ${PKCAIRO_INCLUDEDIR} ${PKCAIRO_INCLUDE_DIRS} PATH_SUFFIXES cairo NO_DEFAULT_PATH )
        find_library(CAIRO_LIBRARY  cairo   HINTS ${PKCAIRO_LIBDIR}     ${PKCAIRO_LIBRARY_DIRS} PATH_SUFFIXES cairo NO_DEFAULT_PATH )

    endif()

else()

    find_path(CAIRO_INCLUDE_DIR cairo.h PATHS ${CAIRO_PATH}/include PATH_SUFFIXES cairo NO_DEFAULT_PATH )
    find_library(CAIRO_LIBRARY  cairo   PATHS ${CAIRO_PATH}/lib     PATH_SUFFIXES cairo NO_DEFAULT_PATH )

endif()

find_path(CAIRO_INCLUDE_DIR cairo.h PATH_SUFFIXES cairo )
find_library( CAIRO_LIBRARY cairo   PATH_SUFFIXES cairo )

set( CAIRO_LIBRARIES    ${CAIRO_LIBRARY} )
set( CAIRO_INCLUDE_DIRS ${CAIRO_INCLUDE_DIR} )

include(FindPackageHandleStandardArgs)

# handle the QUIETLY and REQUIRED arguments and set GRIBAPI_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(CAIRO  DEFAULT_MSG
                                  CAIRO_LIBRARY CAIRO_INCLUDE_DIR)

mark_as_advanced( CAIRO_INCLUDE_DIR CAIRO_LIBRARY )
