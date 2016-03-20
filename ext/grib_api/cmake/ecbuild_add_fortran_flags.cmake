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
# ecbuild_add_fortran_flags
# =========================
#
# Add Fortran compiler flags to CMAKE_Fortran_FLAGS only if supported by the
# compiler. ::
#
#   ecbuild_add_fortran_flags( <flag1> [ <flag2> ... ]
#                              [ BUILD <build> ]
#                              [ NAME <name> ] )
#
# Options
# -------
#
# BUILD : optional
#   add flags to ``CMAKE_Fortran_FLAGS_<build>`` instead of
#   ``CMAKE_Fortran_FLAGS``
#
# NAME : optional
#   name of the check (if omitted, checks are enumerated)
#
##############################################################################

include( CheckFortranCompilerFlag )
macro( ecbuild_add_fortran_flags m_fortran_flags )

  set( _flags ${m_fortran_flags} )

  if( _flags AND CMAKE_Fortran_COMPILER_LOADED )

    set( options )
    set( single_value_args BUILD NAME )
    set( multi_value_args )

    cmake_parse_arguments( _PAR "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

    if( NOT DEFINED N_FortranFLAG )
      set( N_FortranFLAG 0 )
    endif()

    math( EXPR N_FortranFLAG '${N_FortranFLAG}+1' )

    if( NOT ECBUILD_TRUST_FLAGS )
      if( DEFINED _PAR_NAME )
        check_fortran_compiler_flag( ${_flags} ${_PAR_NAME} )
        set( _flag_ok ${${_PAR_NAME}} )
      else()
        check_fortran_compiler_flag( ${_flags} Fortran_FLAG_TEST_${N_FortranFLAG} )
        set( _flag_ok ${Fortran_FLAG_TEST_${N_FortranFLAG}} )
      endif()
    else()
      set( _flag_ok 1 )
    endif()

    if( _flag_ok )
      if( _PAR_BUILD )
        set( CMAKE_Fortran_FLAGS_${_PAR_BUILD} "${CMAKE_Fortran_FLAGS_${_PAR_BUILD}} ${_flags}" )
        ecbuild_debug( "Fortran FLAG [${_flags}] added for build type ${_PAR_BUILD}" )
      else()
        set( CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${_flags}" )
        ecbuild_debug( "Fortran FLAG [${_flags}] added" )
      endif()
    else()
      message( STATUS "Unrecognised Fortran flag [${_flags}] -- skipping" )
    endif()
  endif()

  unset( _flags )
  unset( _flag_ok )

endmacro()

macro( cmake_add_fortran_flags m_fortran_flags )
  message( DEPRECATION " cmake_add_fortran_flags is deprecated, use ecbuild_add_fortran_flags instead." )
  ecbuild_add_fortran_flags( ${m_fortran_flags} )
endmacro()
