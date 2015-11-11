# (C) Copyright 1996-2014 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

###################################################################################################
# enable C to use in system introspection

if( NOT CMAKE_C_COMPILER_LOADED AND ENABLE_OS_TESTS )
	enable_language( C )
endif()

############################################################################################
# try to get compiler version if cmake did not

if( NOT CMAKE_C_COMPILER_VERSION )

    set( EC_COMPILER_VERSION "?.?" )

    if( CMAKE_C_COMPILER_ID MATCHES "GNU" OR CMAKE_C_COMPILER_ID MATCHES "Intel" )
        exec_program( ${CMAKE_C_COMPILER}
                      ARGS ${CMAKE_C_COMPILER_ARG1} -dumpversion
                      OUTPUT_VARIABLE EC_COMPILER_VERSION )

        string(REGEX REPLACE "([0-9])\\.([0-9])(\\.([0-9]))?" "\\1.\\2"  EC_COMPILER_VERSION ${EC_COMPILER_VERSION} )
    endif()

    if( CMAKE_C_COMPILER_ID MATCHES "Clang" )
        exec_program( ${CMAKE_C_COMPILER}
                      ARGS ${CMAKE_C_COMPILER_ARG1} --version
                      OUTPUT_VARIABLE EC_COMPILER_VERSION )

        string(REGEX REPLACE ".*clang version ([0-9])\\.([0-9])(\\.([0-9]))?.*" "\\1.\\2" EC_COMPILER_VERSION ${EC_COMPILER_VERSION} )
    endif()

    if( CMAKE_C_COMPILER_ID MATCHES "SunPro" )
        exec_program( ${CMAKE_C_COMPILER}
                      ARGS ${CMAKE_C_COMPILER_ARG1} -V
                      OUTPUT_VARIABLE EC_COMPILER_VERSION )

        string(REGEX REPLACE ".*([0-9]+)\\.([0-9]+).*" "\\1.\\2" EC_COMPILER_VERSION ${EC_COMPILER_VERSION} )
    endif()

    if( CMAKE_C_COMPILER_ID MATCHES "XL" )
        exec_program( ${CMAKE_C_COMPILER}
                      ARGS ${CMAKE_C_COMPILER_ARG1} -qversion
                      OUTPUT_VARIABLE EC_COMPILER_VERSION )

        string(REGEX REPLACE ".*V([0-9]+)\\.([0-9]+).*" "\\1.\\2" EC_COMPILER_VERSION ${EC_COMPILER_VERSION} )

    endif()

    if( NOT EC_COMPILER_VERSION STREQUAL "?.?" )
        set(CMAKE_C_COMPILER_VERSION "${EC_COMPILER_VERSION}" )
    endif()

endif()

############################################################################################
# c compiler tests

if( CMAKE_C_COMPILER_LOADED AND ENABLE_OS_TESTS )

	ecbuild_cache_check_c_source_compiles(
		  " typedef int foo_t;
			static inline foo_t static_foo(){return 0;}
			foo_t foo(){return 0;}
			int main(int argc, char *argv[]){return 0;}
		  " EC_HAVE_C_INLINE )

endif()

############################################################################################
# c++ compiler tests

if( CMAKE_CXX_COMPILER_LOADED AND ENABLE_OS_TESTS )

    # check for __FUNCTION__
    ecbuild_cache_check_cxx_source_compiles( "#include <iostream>\nint main(int argc, char* argv[]) { std::cout << __FUNCTION__ << std::endl; }"
      EC_HAVE_FUNCTION_DEF )

    # check for c++ abi, usually present in GNU compilers
    ecbuild_cache_check_cxx_source_compiles( "#include <cxxabi.h>\n int main() { char * type; int status; char * r = abi::__cxa_demangle(type, 0, 0, &status); }"
    EC_HAVE_CXXABI_H )

    # check for bool
    ecbuild_cache_check_cxx_source_compiles( "int main() { bool aflag = true; }"
	  EC_HAVE_CXX_BOOL )

    # check for sstream
    ecbuild_cache_check_cxx_source_compiles( "#include <sstream>\nint main() { std::stringstream s; }"
	  EC_HAVE_CXX_SSTREAM )

endif()

############################################################################################
# enable warnings

if( CMAKE_COMPILER_IS_GNUCC )

    cmake_add_c_flags("-pipe") # use pipe for faster compilation

    if( ENABLE_WARNINGS )
        cmake_add_c_flags("-Wall")
        # cmake_add_c_flags("-pedantic")
        # cmake_add_c_flags("-Wextra")
    endif()

endif()

if( CMAKE_COMPILER_IS_GNUCXX )

   cmake_add_cxx_flags("-pipe") # use pipe for faster compilation

    if( ENABLE_WARNINGS )
        cmake_add_cxx_flags("-Wall")
        #    cmake_add_cxx_flags("-Wextra")
    endif()

endif()

############################################################################################
# compiler dependent fixes

# For Cray compilers add "-Wl,-Bdynamic" at very end of linker commands, in order to produce dynamic executables by default

if( "${CMAKE_C_COMPILER_ID}" STREQUAL "Cray" )
  set( CMAKE_C_LINK_EXECUTABLE "<CMAKE_C_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES> -Wl,-Bdynamic" )
endif()

if( "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Cray" )
  set( CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_CXX_COMPILER> <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES> -Wl,-Bdynamic" )
endif()

if( "${CMAKE_Fortran_COMPILER_ID}" STREQUAL "Cray" )
  set(CMAKE_Fortran_LINK_EXECUTABLE "<CMAKE_Fortran_COMPILER> <CMAKE_Fortran_LINK_FLAGS> <LINK_FLAGS> <FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES> -Wl,-Bdynamic" )
endif()

############################################################################################
# Fortran compiler specific flags
# if( NOT HAVE_SINGLE_PRECISION )
#  if(CMAKE_Fortran_COMPILER_ID STREQUAL "PGI")
#      cmake_add_fortran_flags("-r8")
#  elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
#      # NOTE that if we add -fdefault-real-8 then we NEED -fdefault-double-8 to avoid quadmath
#      cmake_add_fortran_flags("-fdefault-real-8 -fdefault-double-8")
#  endif()
# endif()