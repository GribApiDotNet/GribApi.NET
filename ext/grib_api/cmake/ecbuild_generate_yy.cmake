# (C) Copyright 1996-2014 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

############################################################################################
# macro to process lex/yacc files

macro( ecbuild_generate_yy )

	ecbuild_find_lexyacc() # find [ yacc|byson ] and [ lex|flex ]

	ecbuild_find_perl( REQUIRED )

    set( options )
	set( single_value_args YYPREFIX YACC LEX YACC_TARGET LEX_TARGET LEX_FLAGS YACC_FLAGS FLEX_FLAGS BISON_FLAGS )
    set( multi_value_args  DEPENDANT )

    cmake_parse_arguments( _PAR "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

    if(_PAR_UNPARSED_ARGUMENTS)
      message(FATAL_ERROR "Unknown keywords given to ecbuild_generate_yy(): \"${_PAR_UNPARSED_ARGUMENTS}\"")
    endif()

    if( NOT _PAR_YYPREFIX  )
      message(FATAL_ERROR "The call to ecbuild_generate_yy() doesn't specify the YYPREFIX.")
    endif()

    if( NOT _PAR_YACC  )
      message(FATAL_ERROR "The call to ecbuild_generate_yy() doesn't specify the YACC file.")
    endif()

    if( NOT _PAR_LEX  )
      message(FATAL_ERROR "The call to ecbuild_generate_yy() doesn't specify the LEX file.")
    endif()

    if( NOT _PAR_DEPENDANT )
      message(FATAL_ERROR "The call to ecbuild_generate_yy() doesn't specify the DEPENDANT files.")
    endif()

    set( BASE ${_PAR_YYPREFIX}_${_PAR_YACC} )

	## default flags

	if( NOT _PAR_LEX_FLAGS )
		set( _PAR_LEX_FLAGS "" )
	endif()

	if( NOT _PAR_FLEX_FLAGS )
		set( _PAR_FLEX_FLAGS "-l" )
	endif()

	if( NOT _PAR_YACC_FLAGS )
		set( _PAR_YACC_FLAGS "-t" )
	endif()

	if( NOT _PAR_BISON_FLAGS )
		set( _PAR_BISON_FLAGS "-t" )
	endif()

    #debug_var( BASE )

    if( NOT _PAR_YACC_TARGET )
        set ( _PAR_YACC_TARGET ${_PAR_YACC} )
    endif()

    if ( NOT _PAR_LEX_TARGET )
        set ( _PAR_LEX_TARGET ${_PAR_LEX} )
    endif()

    set( ${BASE}yy_tmp_target ${CMAKE_CURRENT_BINARY_DIR}/${_PAR_YACC_TARGET}.tmp.c )
    set( ${BASE}yl_tmp_target ${CMAKE_CURRENT_BINARY_DIR}/${_PAR_LEX_TARGET}.tmp.c )

    set( ${BASE}yy_target ${CMAKE_CURRENT_BINARY_DIR}/${_PAR_YACC_TARGET}.c )
    set( ${BASE}yl_target ${CMAKE_CURRENT_BINARY_DIR}/${_PAR_LEX_TARGET}.c )

    add_custom_target( ${_PAR_YYPREFIX}_${DEPENDANT} SOURCES ${_PAR_YACC}.y ${_PAR_LEX}.l )

    if( BISON_FOUND )
		bison_target( ${BASE}_parser  ${_PAR_YACC}.y  ${${BASE}yy_tmp_target} COMPILE_FLAGS "${_PAR_BISON_FLAGS}" )
	else()
		yacc_target( ${BASE}_parser  ${_PAR_YACC}.y   ${${BASE}yy_tmp_target} COMPILE_FLAGS "${_PAR_YACC_FLAGS}" )
    endif()

    if( FLEX_FOUND )
		flex_target(  ${BASE}_scanner ${_PAR_LEX}.l   ${${BASE}yl_tmp_target} COMPILE_FLAGS "${_PAR_FLEX_FLAGS}" )
        add_flex_bison_dependency(${BASE}_scanner ${BASE}_parser)
    else()
		lex_target(  ${BASE}_scanner ${_PAR_LEX}.l   ${${BASE}yl_tmp_target} COMPILE_FLAGS "${_PAR_LEX_FLAGS}" )
        add_lex_yacc_dependency(${BASE}_scanner ${BASE}_parser)
    endif()

    set_source_files_properties(${${BASE}yy_tmp_target} GENERATED)
    set_source_files_properties(${${BASE}yl_tmp_target} GENERATED)

    add_custom_command(OUTPUT  ${${BASE}yy_target}
                       COMMAND ${CMAKE_COMMAND} -E copy ${${BASE}yy_tmp_target} ${${BASE}yy_target}
                       COMMAND ${PERL_EXECUTABLE} -pi -e 's/yy/${_PAR_YYPREFIX}/g' ${${BASE}yy_target}
                       COMMAND ${PERL_EXECUTABLE} -pi -e 's/\\.tmp\\.c/\\.c/g' ${${BASE}yy_target}
                       DEPENDS ${${BASE}yy_tmp_target}
    )

    add_custom_command(OUTPUT  ${${BASE}yl_target}
                       COMMAND ${CMAKE_COMMAND} -E copy ${${BASE}yl_tmp_target} ${${BASE}yl_target}
                       COMMAND ${PERL_EXECUTABLE} -pi -e 's/yy/${_PAR_YYPREFIX}/g' ${${BASE}yl_target}
                       COMMAND ${PERL_EXECUTABLE} -pi -e 's/\\.tmp\\.c/\\.c/g' ${${BASE}yl_target}
                       DEPENDS ${${BASE}yl_tmp_target}
    )

    set_source_files_properties(${${BASE}yy_target} GENERATED)
    set_source_files_properties(${${BASE}yl_target} GENERATED)

    foreach( file ${_PAR_DEPENDANT} )
        set_source_files_properties( ${file} PROPERTIES
                                    OBJECT_DEPENDS "${${BASE}yy_target};${${BASE}yl_target}" )
    endforeach()

endmacro( ecbuild_generate_yy )
