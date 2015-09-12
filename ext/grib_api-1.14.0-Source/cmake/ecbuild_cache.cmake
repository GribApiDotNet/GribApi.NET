# (C) Copyright 1996-2014 ECMWF.
# 
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0. 
# In applying this licence, ECMWF does not waive the privileges and immunities 
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

macro( ecbuild_prepare_cache )
    include( CheckSymbolExists )
    include( CheckIncludeFiles )
    include( CheckCSourceCompiles )
    include( CheckCXXSourceCompiles )
    include( CheckTypeSize )
    set( ecbuild_cache_file ${CMAKE_BINARY_DIR}/ecbuild-cache.cmake )
    file(WRITE ${ecbuild_cache_file} "# ecbuild cache file\n\n")    
endmacro()


function( ecbuild_cache_var var )
  if( NOT ${var} )
    set( ${var} 0 )
  endif()
  set( ECBUILD_CACHE_BUFFER "${ECBUILD_CACHE_BUFFER}set( ${var} ${${var}} )\n" CACHE INTERNAL "Cache buffer" )
endfunction()

function( ecbuild_cache_check_symbol_exists symbol includes output )
  if( NOT DEFINED ${output} )
    check_symbol_exists( ${symbol} ${includes} ${output} )
  endif()
  ecbuild_cache_var( ${output} )
endfunction()

function( ecbuild_cache_check_include_files includes output )
  if( NOT DEFINED ${output} )
    check_include_files( ${includes} ${output} )
  endif()
  ecbuild_cache_var( ${output} )
endfunction()

function( ecbuild_cache_check_c_source_compiles source output )
  if( NOT DEFINED ${output} )
    check_c_source_compiles( "${source}" ${output} )
  endif()
  ecbuild_cache_var( ${output} )
endfunction()

function( ecbuild_cache_check_cxx_source_compiles source output )
  if( NOT DEFINED ${output} )
    check_cxx_source_compiles( "${source}" ${output} )
  endif()
  ecbuild_cache_var( ${output} )
endfunction()

function( ecbuild_cache_check_type_size type output )
  if( NOT DEFINED ${output} )
    check_type_size( "${type}" ${output} )
  endif()
  ecbuild_cache_var( ${output} )
endfunction()

function( ecbuild_flush_cache )
  file( APPEND ${ecbuild_cache_file} "${ECBUILD_CACHE_BUFFER}" )
  set( ECBUILD_CACHE_BUFFER "" CACHE INTERNAL "Cache buffer" )
endfunction()