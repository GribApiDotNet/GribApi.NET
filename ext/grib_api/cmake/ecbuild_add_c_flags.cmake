# (C) Copyright 1996-2015 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation
# nor does it submit to any jurisdiction.

##############################################################################
#.rst:
#
# ecbuild_add_c_flags
# ===================
#
# Add C compiler flags to CMAKE_C_FLAGS only if supported by the compiler. ::
#
#   ecbuild_add_c_flags( <flag1> [ <flag2> ... ]
#                        [ BUILD <build> ]
#                        [ NAME <name> ] )
#
# Options
# -------
#
# BUILD : optional
#   add flags to ``CMAKE_C_FLAGS_<build>`` instead of ``CMAKE_C_FLAGS``
#
# NAME : optional
#   name of the check (if omitted, checks are enumerated)
#
##############################################################################

macro( ecbuild_add_c_flags m_c_flags )

  set( _flags ${m_c_flags} )

  if( _flags AND CMAKE_C_COMPILER_LOADED )
    set( options )
    set( single_value_args BUILD NAME )
    set( multi_value_args )

    cmake_parse_arguments( _PAR "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

    if( NOT DEFINED N_CFLAG )
      set( N_CFLAG 0 )
    endif()

    math( EXPR N_CFLAG '${N_CFLAG}+1' )

    if( NOT ECBUILD_TRUST_FLAGS )
      if( DEFINED _PAR_NAME )
        check_c_compiler_flag( ${_flags} ${_PAR_NAME} )
        set( _flag_ok ${${_PAR_NAME}} )
      else()
        check_c_compiler_flag( ${_flags} C_FLAG_TEST_${N_CFLAG} )
        set( _flag_ok ${C_FLAG_TEST_${N_CFLAG}} )
      endif()
    else()
      set( _flag_ok 1 )
    endif()

    if( _flag_ok )
      if( _PAR_BUILD )
        set( CMAKE_C_FLAGS_${_PAR_BUILD} "${CMAKE_C_FLAGS_${_PAR_BUILD}} ${_flags}" )
        ecbuild_debug( "C FLAG [${_flags}] added for build type ${_PAR_BUILD}" )
      else()
        set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${_flags}" )
        ecbuild_debug( "C FLAG [${_flags}] added" )
      endif()
    else()
      message( WARNING "Unrecognised C flag [${_flags}] -- skipping" )
    endif()
  endif()
  unset( _flags )
  unset( _flag_ok )
endmacro()

macro( cmake_add_c_flags m_c_flags )
  message( DEPRECATION " cmake_add_c_flags is deprecated, use ecbuild_add_c_flags instead." )
  ecbuild_add_c_flags( ${m_c_flags} )
endmacro()
