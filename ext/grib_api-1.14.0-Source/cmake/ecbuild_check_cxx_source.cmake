# (C) Copyright 1996-2014 ECMWF.
# 
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0. 
# In applying this licence, ECMWF does not waive the privileges and immunities 
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

##############################################################################
# macro that runs the given C++ code and returns its output

macro( ecbuild_check_cxx_source_return SOURCE )

    set( options )
    set( single_value_args VAR  OUTPUT )
    set( multi_value_args  INCLUDES LIBS DEFINITIONS )

    cmake_parse_arguments( _p "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

    if(_p_UNPARSED_ARGUMENTS)
      message(FATAL_ERROR "Unknown keywords given to ecbuild_check_cxx_source_return(): \"${_p_UNPARSED_ARGUMENTS}\"")
    endif()

    if( NOT _p_VAR OR NOT _p_OUTPUT )
      message(FATAL_ERROR "The call to ecbuild_check_cxx_source_return() doesn't specify either SOURCE, VAR or OUTPUT")
    endif()

    set( _msg "Testing ${_p_VAR}:" )

    if( NOT DEFINED ${_p_VAR} )

        set(MACRO_CHECK_FUNCTION_DEFINITIONS "-D${_p_VAR} ${CMAKE_REQUIRED_FLAGS}")

        set(CHECK_CXX_SOURCE_COMPILES_ADD_LIBRARIES)
        if(CMAKE_REQUIRED_LIBRARIES)
            list( APPEND __add_libs ${CMAKE_REQUIRED_LIBRARIES} )
        endif()
        if( _p_LIBS )
            list( APPEND __add_libs ${_p_LIBS} )
        endif()
        if( __add_libs )
            set(CHECK_CXX_SOURCE_COMPILES_ADD_LIBRARIES "-DLINK_LIBRARIES:STRING=${__add_libs}")
        endif()

        set(CHECK_CXX_SOURCE_COMPILES_ADD_INCLUDES)
        if(CMAKE_REQUIRED_INCLUDES)
            list( APPEND __add_incs ${CMAKE_REQUIRED_INCLUDES} )
        endif()
        if( _p_INCLUDES )
            list( APPEND __add_incs ${_p_INCLUDES} )
        endif()
		if( __add_incs )
            set(CHECK_CXX_SOURCE_COMPILES_ADD_INCLUDES "-DINCLUDE_DIRECTORIES:STRING=${__add_incs}")
        endif()
    
        # write the source file
    
        file( WRITE "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/test_${_p_VAR}.cxx" "${SOURCE}\n" )

        message( STATUS "${_msg}" )
        try_run( ${_p_VAR}_EXITCODE ${_p_VAR}_COMPILED
          ${CMAKE_BINARY_DIR}
          ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/test_${_p_VAR}.cxx
          COMPILE_DEFINITIONS ${CMAKE_REQUIRED_DEFINITIONS}
          CMAKE_FLAGS -DCOMPILE_DEFINITIONS:STRING=${MACRO_CHECK_FUNCTION_DEFINITIONS}
          -DCMAKE_SKIP_RPATH:BOOL=${CMAKE_SKIP_RPATH}
          "${CHECK_CXX_SOURCE_COMPILES_ADD_LIBRARIES}"
          "${CHECK_CXX_SOURCE_COMPILES_ADD_INCLUDES}"
          COMPILE_OUTPUT_VARIABLE compile_OUTPUT 
          RUN_OUTPUT_VARIABLE     run_OUTPUT )
   
	  # debug_var( ${_p_VAR}_COMPILED )
	  # debug_var( ${_p_VAR}_EXITCODE )

        # if it did not compile make the return value fail code of 1

        if( NOT ${_p_VAR}_COMPILED )
          message( STATUS "${_msg} failed to compile" )
        endif()

        if( "${${_p_VAR}_EXITCODE}" MATCHES  "FAILED_TO_RUN" )
          message( STATUS "${_msg} failed to run" )
        endif()

        # if the return value was 0 then it worked
        if( ${_p_VAR}_COMPILED AND "${${_p_VAR}_EXITCODE}" EQUAL 0 )
    
          message(STATUS "${_msg} Success")
          file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log 
            "Performing C++ SOURCE FILE Test ${_p_VAR} succeded with the following compile output:\n"
            "${compile_OUTPUT}\n" 
            "Performing C++ SOURCE FILE Run ${_p_VAR} succeded with the following run output:\n"
            "${run_OUTPUT}\n" 
            "Return value: ${${_p_VAR}}\n"
            "Source file was:\n${SOURCE}\n")

          set( ${_p_VAR}     1              CACHE INTERNAL "Test ${_p_VAR}")
          set( ${_p_OUTPUT} "${run_OUTPUT}" CACHE INTERNAL "Test ${_p_VAR} output")
    
        else()
    
          if(CMAKE_CROSSCOMPILING AND "${${_p_VAR}_EXITCODE}" MATCHES  "FAILED_TO_RUN")
            set(${_p_VAR} "${${_p_VAR}_EXITCODE}")
            set(${OUTPUT} "")
          else()
            set(${_p_VAR} "" CACHE INTERNAL "Test ${_p_VAR}")
            set(${_p_OUTPUT} "" CACHE INTERNAL "Test ${_p_VAR} output")
          endif()
    
          message(STATUS "Test ${_p_VAR} - Failed")
          file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log 
            "Performing C++ SOURCE FILE Test ${_p_VAR} failed with the following compile output:\n"
            "${compile_OUTPUT}\n" 
            "Performing C++ SOURCE FILE Run ${_p_VAR} failed with the following run output:\n"
            "${run_OUTPUT}\n" 
            "Return value: ${${_p_VAR}_EXITCODE}\n"
            "Source file was:\n${SOURCE}\n")
        endif()
    
    endif()

endmacro()

##############################################################################
# macro that only adds a cxx flag if compiler supports it

macro( cmake_add_cxx_flags m_cxx_flags )

  set( _flags ${m_cxx_flags} )
  if( _flags AND CMAKE_CXX_COMPILER_LOADED )
    set( options )
    set( single_value_args BUILD )
    set( multi_value_args )

    cmake_parse_arguments( _PAR "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

    if( NOT DEFINED N_CXXFLAG )
      set( N_CXXFLAG 0 )
    endif()

    math( EXPR N_CXXFLAG '${N_CXXFLAG}+1' )

    if( NOT ECBUILD_TRUST_FLAGS )
      check_cxx_compiler_flag( ${_flags} CXX_FLAG_TEST_${N_CXXFLAG} )
    endif()

    if( CXX_FLAG_TEST_${N_CXXFLAG} OR ECBUILD_TRUST_FLAGS )
      if( _PAR_BUILD )
        set( CMAKE_CXX_FLAGS_${_PAR_BUILD} "${CMAKE_CXX_FLAGS_${_PAR_BUILD}} ${_flags}" )
      else()
        set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${_flags}" )
        # message( STATUS "C++ FLAG [${_flags}] added" )
      endif()
    else()
      message( STATUS "Unrecognised CXX flag [${_flags}] -- skipping" )
    endif()
  endif()
  unset( _flags )

endmacro()
