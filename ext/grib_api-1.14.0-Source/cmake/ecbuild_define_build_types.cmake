# (C) Copyright 1996-2014 ECMWF.
# 
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0. 
# In applying this licence, ECMWF does not waive the privileges and immunities 
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

############################################################################################
# define a Production build type

# NOTE: gcc does not guarrante that -O3 performs better than -O2
#       -- it can perform worse due to assembly code bloating.
#   Moreover for gcc 4.1.2 we found that -O3 remove the parser code generated from Lex/Yacc
#   and therefore in production mode we downgrade to -O2 if the compiler is GCC (for all versions).


if(CMAKE_COMPILER_IS_GNUCXX)
    set( CMAKE_CXX_FLAGS_PRODUCTION "-O2 -g" CACHE STRING "Flags used by the C++ compiler during Production builds." FORCE )
else()
    set( CMAKE_CXX_FLAGS_PRODUCTION "-O3 -g" CACHE STRING "Flags used by the C++ compiler during Production builds." FORCE )
endif()

if(CMAKE_COMPILER_IS_GNUCC)
    set( CMAKE_C_FLAGS_PRODUCTION "-O2 -g" CACHE STRING "Flags used by the C compiler during Production builds." FORCE )
else()
    set( CMAKE_C_FLAGS_PRODUCTION "-O3 -g" CACHE STRING "Flags used by the C compiler during Production builds." FORCE )
endif()

set( CMAKE_EXE_LINKER_FLAGS_PRODUCTION "" CACHE STRING "Flags used for linking binaries during Production builds." FORCE )
set( CMAKE_SHARED_LINKER_FLAGS_PRODUCTION "" CACHE STRING "Flags used by the shared libraries linker during Production builds." FORCE )
set( CMAKE_MODULE_LINKER_FLAGS_PRODUCTION "" CACHE STRING "Flags used by the static libraries linker during Production builds." FORCE )

mark_as_advanced(
    CMAKE_CXX_FLAGS_PRODUCTION
    CMAKE_C_FLAGS_PRODUCTION
    CMAKE_EXE_LINKER_FLAGS_PRODUCTION
	  CMAKE_SHARED_LINKER_FLAGS_PRODUCTION
	  CMAKE_MODULE_LINKER_FLAGS_PRODUCTION )

############################################################################################
# fixes for specific compilers

### remove -Mipa=fast from PGI compilers in RELEASE mode

if( CMAKE_C_COMPILER_ID STREQUAL "PGI" )
  set(CMAKE_C_FLAGS_RELEASE "-fast -O3")
endif()

if( CMAKE_CXX_COMPILER_ID STREQUAL "PGI" )
  set(CMAKE_CXX_FLAGS_RELEASE "-fast -O3")
endif()

if( CMAKE_Fortran_COMPILER_ID STREQUAL "PGI" )
  set(CMAKE_Fortran_FLAGS_RELEASE "-fast -O3")
endif()

############################################################################################
# define default build type

set( _BUILD_TYPE_MSG "Build type options are: [ None | Debug | Bit | Production | Release | RelWithDebInfo ]" )

if( NOT ECBUILD_DEFAULT_BUILD_TYPE )
	set( ECBUILD_DEFAULT_BUILD_TYPE "RelWithDebInfo" )
endif()

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE ${ECBUILD_DEFAULT_BUILD_TYPE} CACHE STRING  ${_BUILD_TYPE_MSG}  FORCE )
endif()

# capitalize the build type for easy use with conditionals
string( TOUPPER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE_CAPS )

# correct capitatlization of the build type

if( CMAKE_BUILD_TYPE_CAPS STREQUAL "NONE" )
  set(CMAKE_BUILD_TYPE None CACHE STRING ${_BUILD_TYPE_MSG} FORCE )
endif()

if( CMAKE_BUILD_TYPE_CAPS STREQUAL "DEBUG" )
  set(CMAKE_BUILD_TYPE Debug CACHE STRING ${_BUILD_TYPE_MSG} FORCE )
endif()

if( CMAKE_BUILD_TYPE_CAPS STREQUAL "BIT" )
  set(CMAKE_BUILD_TYPE Bit CACHE STRING ${_BUILD_TYPE_MSG} FORCE )
endif()

if( CMAKE_BUILD_TYPE_CAPS STREQUAL "PRODUCTION" )
  set(CMAKE_BUILD_TYPE Production CACHE STRING ${_BUILD_TYPE_MSG} FORCE )
endif()

if( CMAKE_BUILD_TYPE_CAPS STREQUAL "RELEASE" )
  set(CMAKE_BUILD_TYPE Release CACHE STRING ${_BUILD_TYPE_MSG} FORCE )
endif()

if( CMAKE_BUILD_TYPE_CAPS STREQUAL "RELWITHDEBINFO" )
  set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING ${_BUILD_TYPE_MSG} FORCE )
endif()

# fail if build type is not one of the defined ones
if( NOT CMAKE_BUILD_TYPE MATCHES "None"  AND
	  NOT CMAKE_BUILD_TYPE MATCHES "Debug" AND
	  NOT CMAKE_BUILD_TYPE MATCHES "Bit" AND
	  NOT CMAKE_BUILD_TYPE MATCHES "Production" AND
    NOT CMAKE_BUILD_TYPE MATCHES "Release"  AND
    NOT CMAKE_BUILD_TYPE MATCHES "RelWithDebInfo" )
    message( FATAL_ERROR "CMAKE_BUILD_TYPE is not recognized. ${_BUILD_TYPE_MSG}" )
endif()

############################################################################################
# overrides of the flags per build type

foreach( _btype NONE DEBUG BIT PRODUCTION RELEASE RELWITHDEBINFO )

  # OVERRIDE Compiler FLAGS per language (we override because CMake forcely defines them)
  foreach( _lang C CXX Fortran )
    if( ECBUILD_${_lang}_FLAGS_${_btype} )
      set( CMAKE_${_lang}_FLAGS_${_btype} ${ECBUILD_${_lang}_FLAGS_${_btype}} )
    endif()
  endforeach()

  # OVERRIDE Linker FLAGS per object type (we override because CMake forcely defines them)
  foreach( _obj EXE SHARED MODULE )
    if( ECBUILD_${_obj}_LINKER_FLAGS_${_btype} )
      set( CMAKE_${_obj}_LINKER_FLAGS_${_btype} ${ECBUILD_${_obj}_LINKER_FLAGS_${_btype}} )
    endif()
  endforeach()

  # APPEND Linker FLAGS per language (we append because CMake typically leaves them empty)
  foreach( _lang C CXX Fortran )
    if( ECBUILD_${_lang}_LINK_FLAGS )
      set( CMAKE_${_lang}_LINK_FLAGS "${CMAKE_${_lang}_LINK_FLAGS} ${ECBUILD_${_lang}_LINK_FLAGS}" )
    endif()
  endforeach()

endforeach()