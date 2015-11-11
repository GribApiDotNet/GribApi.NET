# © Copyright 1996-2014 ECMWF.
# 
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0. 
# In applying this licence, ECMWF does not waive the privileges and immunities 
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

###############################################################################

list( APPEND xl_libs xlf90 xlopt xlf xlsmp )

set( xlf_all_libs_found 1 )

foreach( lib ${xl_libs} )

	find_library( ${lib}_lib  ${lib} PATHS ${XLF_PATH} PATH_SUFFIXES lib lib64 NO_DEFAULT_PATH )

	find_library( ${lib}_lib  ${lib} )

	if( ${lib}_lib )
        list( APPEND XLFORTRAN_LIBRARIES ${${lib}_lib} )
	else()
		set( xlf_all_libs_found 0 )
    endif()

endforeach()

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args( LIBXLFORTRAN DEFAULT_MSG xlf_all_libs_found XLFORTRAN_LIBRARIES  )

# HACK for support libraries

if(  LIBXLFORTRAN_FOUND )
	list( APPEND xl_extra_libs pthreads m essl )
	foreach( lib ${xl_extra_libs} )

		find_library( ${lib}_lib  ${lib} PATHS ${XLF_PATH} PATH_SUFFIXES lib lib64 NO_DEFAULT_PATH )

		find_library( ${lib}_lib  ${lib} )

		if( ${lib}_lib )
			list( APPEND XLFORTRAN_LIBRARIES ${${lib}_lib} )
		endif()

	endforeach()
endif()

