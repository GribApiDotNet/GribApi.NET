# (C) Copyright 1996-2014 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

############################################################################################
# macro to find python

# OUTPUT:
#
# BISON_FOUND or YACC_FOUND
# FLEX_FOUND or LEX_FOUND
#
# BISON_EXECUTABLE or YACC_EXECUTABLE
# FLEX_EXECUTABLE or LEX_EXECUTABLE

macro( ecbuild_find_lexyacc )

	# find preferably bison or else yacc

	if( NOT SKIP_BISON )

		find_package( BISON 2.3 )
		find_package( FLEX )

	endif()

	if( NOT BISON_FOUND AND NOT SKIP_YACC )

		find_package( YACC )
		find_package( LEX  )

	endif()

	if( NOT YACC_FOUND AND NOT BISON_FOUND ) # neither bison nor yacc were found
		message( FATAL_ERROR "neither bison or yacc were found - at least one is required (together with its lexical analyser" )
	endif()

	if( NOT YACC_FOUND ) # check for both bison & flex together
		if( BISON_FOUND AND NOT FLEX_FOUND )
			message( FATAL_ERROR "both bison and flex are required - flex not found" )
		endif()
		if( FLEX_FOUND AND NOT BISON_FOUND )
			message( FATAL_ERROR "both bison and flex are required - bison not found" )
		endif()
	endif()

	if( NOT BISON_FOUND ) # check for both yacc & lex together
		if( YACC_FOUND AND NOT LEX_FOUND )
			message( FATAL_ERROR "both yacc and lex are required - lex not found" )
		endif()
		if( LEX_FOUND AND NOT YACC_FOUND )
			message( FATAL_ERROR "both yacc and lex are required - yacc not found" )
		endif()
	endif()

endmacro( ecbuild_find_lexyacc )
