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
# ecbuild_add_cxx_flags
# =====================
#
# Add C++ compiler flags to CMAKE_CXX_FLAGS only if supported by compiler. ::
#
#   ecbuild_add_cxx_flags( <flag1> [ <flag2> ... ]
#                          [ BUILD <build> ]
#                          [ NAME <name> ] )
#
# Options
# -------
#
# BUILD : optional
#   add flags to ``CMAKE_CXX_FLAGS_<build>`` instead of ``CMAKE_CXX_FLAGS``
#
# NAME : optional
#   name of the check (if omitted, checks are enumerated)
#
##############################################################################

macro( ecbuild_add_cxx_flags m_cxx_flags )

  set( _flags ${m_cxx_flags} )
  if( _flags AND CMAKE_CXX_COMPILER_LOADED )
    set( options )
    set( single_value_args BUILD NAME )
    set( multi_value_args )

    cmake_parse_arguments( _PAR "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

    if( NOT DEFINED N_CXXFLAG )
      set( N_CXXFLAG 0 )
    endif()

    math( EXPR N_CXXFLAG '${N_CXXFLAG}+1' )

    if( NOT ECBUILD_TRUST_FLAGS )
      if( DEFINED _PAR_NAME )
        check_cxx_compiler_flag( ${_flags} ${_PAR_NAME} )
        set( _flag_ok ${${_PAR_NAME}} )
      else()
        check_cxx_compiler_flag( ${_flags} CXX_FLAG_TEST_${N_CXXFLAG} )
        set( _flag_ok CXX_FLAG_TEST_${N_CXXFLAG} )
      endif()
    else()
      set( _flag_ok 1 )
    endif()

    if( _flag_ok )
      if( _PAR_BUILD )
        set( CMAKE_CXX_FLAGS_${_PAR_BUILD} "${CMAKE_CXX_FLAGS_${_PAR_BUILD}} ${_flags}" )
        ecbuild_debug( "C++ FLAG [${_flags}] added for build type ${_PAR_BUILD}" )
      else()
        set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${_flags}" )
        ecbuild_debug( "C++ FLAG [${_flags}] added" )
      endif()
    else()
      message( STATUS "Unrecognised CXX flag [${_flags}] -- skipping" )
    endif()
  endif()
  unset( _flags )
  unset( _flag_ok )

endmacro()

macro( cmake_add_cxx_flags m_cxx_flags )
  message( DEPRECATION " cmake_add_cxx_flags is deprecated, use ecbuild_add_cxx_flags instead." )
  ecbuild_add_cxx_flags( ${m_cxx_flags} )
endmacro()
