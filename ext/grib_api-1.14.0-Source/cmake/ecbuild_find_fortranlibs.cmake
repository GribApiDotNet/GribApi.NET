# (C) Copyright 1996-2014 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

############################################################################################
# macro to find fortran (static) link libraries


macro( ecbuild_find_fortranlibs )

    # parse parameters

    set( options REQUIRED )
	set( single_value_args COMPILER )
    set( multi_value_args  )

    cmake_parse_arguments( _PAR "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

    if(_PAR_UNPARSED_ARGUMENTS)
      message(FATAL_ERROR "Unknown keywords given to ecbuild_find_python(): \"${_PAR_UNPARSED_ARGUMENTS}\"")
    endif()

	if( NOT FORTRANLIBS_FOUND ) # don't repeat search

		if( _PAR_COMPILER )
			set( __known_fcomp 0 )
		endif()

		if( _PAR_COMPILER MATCHES "gfortran" )
			set( WITH_LIBGFORTRAN 1 )
			set( __known_fcomp 1 )
		endif()

		if( _PAR_COMPILER MATCHES "pgi" )
			set( WITH_PGI_FORTRAN 1 )
			set( __known_fcomp 1 )
		endif()

		if( _PAR_COMPILER MATCHES "xlf" )
			set( WITH_XL_FORTRAN 1 )
			set( __known_fcomp 1 )
		endif()

		if( _PAR_COMPILER MATCHES "intel" )
			message( FATAL_ERROR "searching for intel libraries has not been implemented" )
			set( __known_fcomp 1 )
		endif()

		if( _PAR_COMPILER AND NOT __known_fcomp )
			message( FATAL_ERROR "unknown fortran compiler ${_PAR_COMPILER}" )
		endif()

		### set path from environment variables

		foreach( _fortran_lib PGI XLF LIBGFORTRAN )
			if( NOT ${_fortran_lib}_PATH AND NOT "$ENV{${_fortran_lib}_PATH}" STREQUAL "" )
				set( ${_fortran_lib}_PATH "$ENV{${_fortran_lib}_PATH}" )
			endif()
		endforeach()

		set( _flibs_found 0 )

		### default is to search for gfortran

		if( NOT WITH_PGI_FORTRAN AND NOT WITH_LIBGFORTRAN AND NOT WITH_XL_FORTRAN
			AND NOT DEFINED PGI_PATH AND NOT DEFINED LIBGFORTRAN_PATH AND NOT DEFINED XLF_PATH )
			message( WARNING "Finding fortran libs for unspecified Fortran compiler: default search [ gfortran ]" )
			set( WITH_LIBGFORTRAN 1 )
		endif()

		### actual search ...

		if( WITH_PGI_FORTRAN OR DEFINED PGI_PATH )

			find_package(PGIFortran)

			if( LIBPGIFORTRAN_FOUND )
				set( FORTRAN_LIBRARIES ${PGIFORTRAN_LIBRARIES} )
				set( _flibs_found 1 )
				set( _flibs_txt "PGI" )
			endif()

		endif()

		if( WITH_LIBGFORTRAN OR DEFINED LIBGFORTRAN_PATH )

			find_package(LibGFortran)

			if( LIBGFORTRAN_FOUND )
				set( FORTRAN_LIBRARIES ${GFORTRAN_LIBRARIES} )
				set( _flibs_found 1 )
				set( _flibs_txt "gfortran" )
			endif()

		endif()

		if( WITH_XL_FORTRAN OR DEFINED XLF_PATH )

			find_package(XLFortranLibs)

			if( LIBXLFORTRAN_FOUND )
				set( FORTRAN_LIBRARIES ${XLFORTRAN_LIBRARIES} )
				set( _flibs_found 1 )
				set( _flibs_txt "XLF" )
			endif()

		endif()

		### set found

		if( _flibs_found )
			set( FORTRANLIBS_FOUND 1 CACHE INTERNAL "Fortran libraries found" )
			set( FORTRANLIBS_NAME ${_flibs_txt}  CACHE INTERNAL "Fortran library name" )
			set( FORTRAN_LIBRARIES ${FORTRAN_LIBRARIES} CACHE INTERNAL "Fortran libraries" )
			message( STATUS "Found Fortran libraries: ${_flibs_txt}" )
		else()
			set( FORTRANLIBS_FOUND 0 )
			if( _PAR_REQUIRED )
			   message( FATAL_ERROR "Failed to find Fortran libraries" )
			else()
			   message( STATUS "Failed to find Fortran libraries" )
			endif()
		endif()

	endif( NOT FORTRANLIBS_FOUND )

endmacro( ecbuild_find_fortranlibs )
