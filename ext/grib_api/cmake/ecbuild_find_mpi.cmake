# (C) Copyright 1996-2014 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

############################################################################################
# macro to find MPI
# uses the canonical find_package( MPI )
# but does more checks

macro( ecbuild_find_mpi )

    # parse parameters

    set( options REQUIRED )
    set( single_value_args )
    set( multi_value_args COMPONENTS )

    cmake_parse_arguments( _PAR "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

    if(_PAR_UNPARSED_ARGUMENTS)
      message(FATAL_ERROR "Unknown keywords given to ecbuild_find_mpi(): \"${_PAR_UNPARSED_ARGUMENTS}\"")
    endif()

    # if user defined compilers are MPI compliant, then we use them ...
    if( NOT DEFINED ECBUILD_FIND_MPI )
      set( ECBUILD_FIND_MPI TRUE )
    endif()
    if( ECBUILD_FIND_MPI )

        # C compiler

        if( CMAKE_C_COMPILER_LOADED AND NOT MPI_C_COMPILER )

            include(CheckCSourceCompiles)

            check_c_source_compiles("
                #include <mpi.h>
                int main(int argc, char* argv[])
                {
                int rank;
                MPI_Init(&argc, &argv); 
                MPI_Comm_rank(MPI_COMM_WORLD, &rank); 
                MPI_Finalize();
                return 0;
                }
                "
                C_COMPILER_SUPPORTS_MPI )

            if( C_COMPILER_SUPPORTS_MPI )
                message( STATUS "C compiler supports MPI -- ${CMAKE_C_COMPILER}" )
                set( MPI_C_COMPILER ${CMAKE_C_COMPILER} )
            endif()

        endif()

        # CXX compiler

        if( CMAKE_CXX_COMPILER_LOADED AND NOT MPI_CXX_COMPILER )

            include(CheckCXXSourceCompiles)

            check_cxx_source_compiles("
                #include <mpi.h>
                 #include <iostream>
                 int main(int argc, char* argv[])
                 {
                   MPI_Init(&argc, &argv); int rank; MPI_Comm_rank(MPI_COMM_WORLD, &rank); MPI_Finalize();
                   return 0;
                 }
                 "
                 CXX_COMPILER_SUPPORTS_MPI )

            if( CXX_COMPILER_SUPPORTS_MPI )
                message( STATUS "C++ compiler supports MPI -- ${CMAKE_CXX_COMPILER}" )
                set( MPI_CXX_COMPILER ${CMAKE_CXX_COMPILER} )
            endif()

        endif()

        # Fortran compiler

        if( CMAKE_Fortran_COMPILER_LOADED AND NOT MPI_Fortran_COMPILER )

            include(CheckFortranSourceCompiles)

            check_fortran_source_compiles("
                program main
                use MPI
                integer ierr
                call MPI_INIT( ierr )
                call MPI_FINALIZE( ierr )
                end
                "
            Fortran_COMPILER_SUPPORTS_MPI )

            if( Fortran_COMPILER_SUPPORTS_MPI )
                message( STATUS "Fortran compiler supports MPI (F90) -- ${CMAKE_Fortran_COMPILER}" )
                set( MPI_Fortran_COMPILER ${CMAKE_Fortran_COMPILER} )
                set( MPI_Fortran_FOUND TRUE )
            endif()

        endif()

        if( NOT _PAR_REQUIRED )
            find_package( MPI QUIET )
        else()
            find_package( MPI QUIET REQUIRED )
        endif()

        if( C_COMPILER_SUPPORTS_MPI )
            set( MPI_C_FOUND TRUE )
        endif()
        if( CXX_COMPILER_SUPPORTS_MPI )
            set( MPI_CXX_FOUND TRUE )
        endif()
        if( Fortran_COMPILER_SUPPORTS_MPI )
            set( MPI_Fortran_FOUND TRUE )
        endif()

    else()

        # find_package with Cray compiler did not send MPI_<lang>_FOUND
        if( CMAKE_C_COMPILER_LOADED )
            set( C_COMPILER_SUPPORTS_MPI TRUE )
            set( MPI_C_FOUND TRUE )
        endif()
        if( CMAKE_CXX_COMPILER_LOADED )
            set( CXX_COMPILER_SUPPORTS_MPI TRUE )
            set( MPI_CXX_FOUND TRUE )
        endif()
        if( CMAKE_Fortran_COMPILER_LOADED )
            set( Fortran_COMPILER_SUPPORTS_MPI TRUE )
            set( MPI_Fortran_FOUND TRUE )
        endif()

    endif( ECBUILD_FIND_MPI )

    # hide these variables from UI

    mark_as_advanced( MPI_LIBRARY MPI_EXTRA_LIBRARY )

    if( NOT _PAR_COMPONENTS )
      set( _PAR_COMPONENTS C )
    endif()

    set( MPI_FOUND TRUE )
    foreach( _lang ${_PAR_COMPONENTS} )
      if( NOT MPI_${_lang}_FOUND )
        set( MPI_FOUND FALSE )
      endif()
    endforeach()

endmacro( ecbuild_find_mpi )


macro( ecbuild_enable_mpi )

    set( options REQUIRED )
    set( single_value_args )
    set( multi_value_args COMPONENTS )

    cmake_parse_arguments( _PAR "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

    if(_PAR_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unknown keywords given to ecbuild_find_mpi(): \"${_PAR_UNPARSED_ARGUMENTS}\"")
    endif()

    if( NOT _PAR_COMPONENTS )
      set (_PAR_COMPONENTS C )
    endif()

    if( NOT _PAR_REQUIRED )
       ecbuild_find_mpi( COMPONENTS ${_PAR_COMPONENTS} )
    else()
       ecbuild_find_mpi( COMPONENTS ${_PAR_COMPONENTS} REQUIRED )
    endif()

    if( MPI_C_FOUND AND NOT C_COMPILER_SUPPORTS_MPI )
        cmake_add_c_flags("${MPI_C_COMPILE_FLAGS}")
        include_directories(${MPI_C_INCLUDE_PATH})
    endif()

    if( MPI_CXX_FOUND AND NOT CXX_COMPILER_SUPPORTS_MPI )
        cmake_add_cxx_flags("${MPI_CXX_COMPILE_FLAGS}")
        include_directories(${MPI_CXX_INCLUDE_PATH})
    endif()

    if( MPI_Fortran_FOUND AND NOT Fortran_COMPILER_SUPPORTS_MPI )
        include(ecbuild_check_fortran_source)
        cmake_add_fortran_flags("${MPI_Fortran_COMPILE_FLAGS}")
        include_directories(${MPI_Fortran_INCLUDE_PATH})
    endif()

endmacro( ecbuild_enable_mpi )

macro( ecbuild_include_mpi )

    set( options )
    set( single_value_args )
    set( multi_value_args )

    cmake_parse_arguments( _PAR "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

    if(_PAR_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unknown keywords given to ecbuild_find_mpi(): \"${_PAR_UNPARSED_ARGUMENTS}\"")
    endif()

    if( MPI_C_FOUND AND NOT C_COMPILER_SUPPORTS_MPI )
        include( ecbuild_check_c_source )
        cmake_add_c_flags("${MPI_C_COMPILE_FLAGS}")
        include_directories(${MPI_C_INCLUDE_PATH})
    endif()

    if( MPI_CXX_FOUND AND NOT CXX_COMPILER_SUPPORTS_MPI )
        include( ecbuild_check_cxx_source )
        cmake_add_cxx_flags("${MPI_CXX_COMPILE_FLAGS}")
        include_directories(${MPI_CXX_INCLUDE_PATH})
    endif()

    if( MPI_Fortran_FOUND AND NOT Fortran_COMPILER_SUPPORTS_MPI )
        include( ecbuild_check_fortran_source )
        cmake_add_fortran_flags("${MPI_Fortran_COMPILE_FLAGS}")
        include_directories(${MPI_Fortran_INCLUDE_PATH})
    endif()

endmacro( ecbuild_include_mpi )
