# (C) Copyright 1996-2014 ECMWF.
# 
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0. 
# In applying this licence, ECMWF does not waive the privileges and immunities 
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

# OUTPUT:

macro( ecbuild_find_perl )

    # parse parameters

    set( options REQUIRED )
    set( single_value_args )
    set( multi_value_args  )

    cmake_parse_arguments( _p "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

    if(_p_UNPARSED_ARGUMENTS)
      message(FATAL_ERROR "Unknown keywords given to ecbuild_find_perl(): \"${_p_UNPARSED_ARGUMENTS}\"")
    endif()

	find_package( Perl )

    if( NOT PERL_EXECUTABLE AND _p_REQUIRED )
        message( FATAL_ERROR "Failed to find Perl (REQUIRED)" )
    endif()

    if( PERL_EXECUTABLE )

		execute_process( COMMAND ${PERL_EXECUTABLE} -V:version OUTPUT_VARIABLE  perl_version_output_variable  RESULT_VARIABLE  perl_version_return )
		if( NOT perl_version_return )
			string(REGEX REPLACE "version='([^']+)'.*" "\\1" PERL_VERSION ${perl_version_output_variable})
		endif()

		# from cmake 2.8.8 onwards
		if( NOT PERL_VERSION_STRING )
			set( PERL_VERSION_STRING ${PERL_VERSION} )
		endif()

	endif()

endmacro( ecbuild_find_perl )