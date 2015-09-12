# (C) Copyright 1996-2014 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

##############################################################################
# macro for adding a test
##############################################################################

# Arguments:
#  TARGET : name of test
#  ENABLED [optional]: (default ON)
#  COMMAND [optional]: Run command instead of executable
#  TYPE [optional]: EXE / SCRIPT / PYTHON  (default EXE)
#  MPI [optional]: number of mpi-tasks to use. If greater than 1,
#                  and MPI is not available, the test is disabled
#  SOURCES: sources to be compiled
#  LIBS: Libraries needed for linking
#  INCLUDES: Extra include directories
#  DEPENDS: Add explicit dependency to other targets (for building)
#  TEST_DEPENDS: add explicity dependency on another test running before
#  ARGS: Command-line arguments to COMMAND OR TARGET

macro( ecbuild_add_test )

    set( options           BOOST )
    set( single_value_args TARGET ENABLED COMMAND TYPE LINKER_LANGUAGE MPI WORKING_DIRECTORY )
    set( multi_value_args  SOURCES LIBS INCLUDES TEST_DEPENDS DEPENDS ARGS PERSISTENT DEFINITIONS RESOURCES TEST_DATA CFLAGS CXXFLAGS FFLAGS GENERATED CONDITION ENVIRONMENT )

    cmake_parse_arguments( _PAR "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

    if(_PAR_UNPARSED_ARGUMENTS)
      message(FATAL_ERROR "Unknown keywords given to ecbuild_add_test(): \"${_PAR_UNPARSED_ARGUMENTS}\"")
    endif()

    set( _TEST_DIR ${CMAKE_CURRENT_BINARY_DIR} )

    # Check for MPI
    if(_PAR_MPI)
      if( (_PAR_MPI GREATER 1) AND ( (NOT HAVE_MPI) OR (NOT MPIEXEC) ) )
        set( _PAR_ENABLED 0 )
      endif()
      if( (_PAR_MPI EQUAL 1) AND (NOT HAVE_MPI) )
        set( _PAR_MPI 0 )
      endif()
    endif()

    # default is enabled
    if( NOT DEFINED _PAR_ENABLED )
      set( _PAR_ENABLED 1 )
    endif()


    ### check test type

    # command implies script
    if( DEFINED _PAR_COMMAND )
        set( _PAR_TYPE "SCRIPT" )
    endif()

    # default of TYPE
    if( NOT _PAR_TYPE AND DEFINED _PAR_TARGET )
        set( _PAR_TYPE "EXE" )
        if( NOT _PAR_SOURCES )
           message(FATAL_ERROR "The call to ecbuild_add_test() defines neither a TARGET without SOURCES.")
        endif()
    endif()

    if( _PAR_TYPE MATCHES "PYTHON" )
        if( PYTHONINTERP_FOUND )
            set( _PAR_COMMAND ${PYTHON_EXECUTABLE} )
        else()
            message( FATAL_ERROR "Requested a python test but python interpreter not found - PYTHON_EXECUTABLE: [${PYTHON_EXECUTABLE}]" )
        endif()
    endif()

    ### further checks

    if( NOT _PAR_TARGET AND NOT _PAR_COMMAND )
        message(FATAL_ERROR "The call to ecbuild_add_test() defines neither a TARGET nor a COMMAND.")
    endif()

    if( NOT _PAR_COMMAND AND NOT _PAR_SOURCES )
      message(FATAL_ERROR "The call to ecbuild_add_test() defines neither a COMMAND nor SOURCES, so no test can be defined or built.")
    endif()

    if( _PAR_TYPE MATCHES "SCRIPT" AND NOT _PAR_COMMAND )
        message(FATAL_ERROR "The call to ecbuild_add_test() defines a 'script' but doesn't specify the COMMAND.")
    endif()

    ### conditional build

    if( DEFINED _PAR_CONDITION )
        set(_target_condition_file "${CMAKE_CURRENT_BINARY_DIR}/set_${_PAR_TARGET}_condition.cmake")
        file( WRITE  ${_target_condition_file} "  if( ")
        foreach( term ${_PAR_CONDITION} )
            file( APPEND ${_target_condition_file} " ${term}")
        endforeach()
        file( APPEND ${_target_condition_file} " )\n    set(_${_PAR_TARGET}_condition TRUE)\n  else()\n    set(_${_PAR_TARGET}_condition FALSE)\n  endif()\n")
        include( ${_target_condition_file} )
    else()
        set( _${_PAR_TARGET}_condition TRUE )
    endif()

	# boost unit test linking to unit_test lib ?

	if( _PAR_BOOST AND ENABLE_TESTS AND _${_PAR_TARGET}_condition )

		if( HAVE_BOOST_UNIT_TEST )
			if( BOOST_UNIT_TEST_FRAMEWORK_HEADER_ONLY )
        include_directories( ${ECBUILD_BOOST_HEADER_DIRS} )
        include_directories( ${Boost_INCLUDE_DIRS}  ) # temporary until we ship Boost Unit Test with ecBuild
			else()
				include_directories( ${ECBUILD_BOOST_HEADER_DIRS} ${Boost_INCLUDE_DIRS} )
			endif()
		else()
			set( _${_PAR_TARGET}_condition FALSE )
		endif()

	endif()

	### enable the tests

    if( ENABLE_TESTS AND _${_PAR_TARGET}_condition )

      # add resources

      if( DEFINED _PAR_RESOURCES )
        foreach( rfile ${_PAR_RESOURCES} )
          execute_process( COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_SOURCE_DIR}/${rfile} ${CMAKE_CURRENT_BINARY_DIR} )
        endforeach()
      endif()

      # build executable

      if( DEFINED _PAR_SOURCES )

                # add include dirs if defined
                if( DEFINED _PAR_INCLUDES )
                  list(REMOVE_DUPLICATES _PAR_INCLUDES )
                  foreach( path ${_PAR_INCLUDES} ) # skip NOTFOUND
                    if( path )
                      include_directories( ${path} )
                    endif()
                  endforeach()
                endif()

                # add persistent layer files
                if( DEFINED _PAR_PERSISTENT )
		            if( DEFINED PERSISTENT_NAMESPACE )
        		        ecbuild_add_persistent( SRC_LIST _PAR_SOURCES FILES ${_PAR_PERSISTENT} NAMESPACE ${PERSISTENT_NAMESPACE} )
            		else()
                		ecbuild_add_persistent( SRC_LIST _PAR_SOURCES FILES ${_PAR_PERSISTENT} )
            		endif()
                endif()

                # add the test target

                add_executable( ${_PAR_TARGET} ${_PAR_SOURCES} )

                # add extra dependencies
                if( DEFINED _PAR_DEPENDS)
                  add_dependencies( ${_PAR_TARGET} ${_PAR_DEPENDS} )
                endif()

                # add the link libraries
                if( DEFINED _PAR_LIBS )
                  list(REMOVE_DUPLICATES _PAR_LIBS )
                  list(REMOVE_ITEM _PAR_LIBS debug)
                  list(REMOVE_ITEM _PAR_LIBS optimized)
                  foreach( lib ${_PAR_LIBS} ) # skip NOTFOUND
                    if( lib )
                      target_link_libraries( ${_PAR_TARGET} ${lib} )
                    else()
                      message( WARNING "Lib ${lib} was skipped" )
                    endif()
                  endforeach()
                endif()

                # add test libraries
                if( _PAR_BOOST AND BOOST_UNIT_TEST_FRAMEWORK_LINKED AND HAVE_BOOST_UNIT_TEST )
                    target_link_libraries( ${_PAR_TARGET} ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY} ${Boost_TEST_EXEC_MONITOR_LIBRARY} )
                endif()

                # filter sources
                ecbuild_separate_sources( TARGET ${_PAR_TARGET} SOURCES ${_PAR_SOURCES} )

                # add local flags
                if( DEFINED _PAR_CFLAGS )
                    set_source_files_properties( ${${_PAR_TARGET}_c_srcs}   PROPERTIES COMPILE_FLAGS "${_PAR_CFLAGS}" )
                endif()
                if( DEFINED _PAR_CXXFLAGS )
                    set_source_files_properties( ${${_PAR_TARGET}_cxx_srcs} PROPERTIES COMPILE_FLAGS "${_PAR_CXXFLAGS}" )
                endif()
                if( DEFINED _PAR_FFLAGS )
                    set_source_files_properties( ${${_PAR_TARGET}_f_srcs}   PROPERTIES COMPILE_FLAGS "${_PAR_FFLAGS}" )
                endif()
                if( DEFINED _PAR_GENERATED )
                    set_source_files_properties( ${_PAR_GENERATED} PROPERTIES GENERATED 1 )
                endif()


                # modify definitions to compilation ( -D... )
                get_property( _target_defs TARGET ${_PAR_TARGET} PROPERTY COMPILE_DEFINITIONS )

                if( DEFINED _PAR_DEFINITIONS )
                    list( APPEND _target_defs ${_PAR_DEFINITIONS} )
                endif()

				if( _PAR_BOOST AND BOOST_UNIT_TEST_FRAMEWORK_HEADER_ONLY )
					list( APPEND _target_defs BOOST_UNIT_TEST_FRAMEWORK_HEADER_ONLY )
				endif()

			    set_property( TARGET ${_PAR_TARGET} PROPERTY COMPILE_DEFINITIONS ${_target_defs} )

                # set build location to local build dir
                # not the project base as defined for libs and execs
                set_property( TARGET ${_PAR_TARGET} PROPERTY RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} )

				# whatever project settings are, we always build tests with the build_rpath, not the install_rpath
				set_property( TARGET ${_PAR_TARGET} PROPERTY BUILD_WITH_INSTALL_RPATH FALSE )
				set_property( TARGET ${_PAR_TARGET} PROPERTY SKIP_BUILD_RPATH         FALSE )

                # set linker language
                if( DEFINED _PAR_LINKER_LANGUAGE )
                    set_property( TARGET ${_PAR_TARGET} PROPERTY LINKER_LANGUAGE ${_PAR_LINKER_LANGUAGE} )
                endif()

                # make sure target is removed before - some problems with AIX
                get_target_property(EXE_FILENAME ${_PAR_TARGET} OUTPUT_NAME)
                add_custom_command(
                      TARGET ${_PAR_TARGET}
                      PRE_BUILD
                      COMMAND ${CMAKE_COMMAND} -E remove ${EXE_FILENAME}
                )

				set_property( TARGET ${_PAR_TARGET} PROPERTY SKIP_BUILD_RPATH         FALSE )
				set_property( TARGET ${_PAR_TARGET} PROPERTY BUILD_WITH_INSTALL_RPATH FALSE )

      endif() # _PAR_SOURCES

      if( DEFINED _PAR_COMMAND AND NOT _PAR_TARGET ) # in the absence of target, we use the command as a name
          set( _PAR_TARGET ${_PAR_COMMAND} )
      endif()

      # scripts dont have actual build targets
      # we build a phony target to trigger the dependencies
      if( DEFINED _PAR_COMMAND AND DEFINED _PAR_DEPENDS )

          add_custom_target( ${_PAR_TARGET}.x ALL COMMAND ${CMAKE_COMMAND} -E touch ${_PAR_TARGET}.x )

          add_dependencies( ${_PAR_TARGET}.x ${_PAR_DEPENDS} )

      endif()


      # define the arguments
      set( TEST_ARGS "" )
      if( DEFINED _PAR_ARGS  )
        list( APPEND TEST_ARGS ${_PAR_ARGS} )
      endif()

      # Wrap with MPIEXEC
      if( _PAR_MPI )
        if( DEFINED _PAR_COMMAND )
          set( _PAR_COMMAND ${MPIEXEC} -n ${_PAR_MPI} ${_PAR_COMMAND} )
        else()
          set( _PAR_COMMAND ${MPIEXEC} -n ${_PAR_MPI} ${_PAR_TARGET} )
        endif()
      endif()

      ### define the test

      if( _PAR_ENABLED ) # we can disable and still build it but not run it with 'make tests'

          if( DEFINED _PAR_COMMAND )
              add_test( ${_PAR_TARGET} ${_PAR_COMMAND} ${TEST_ARGS} ${_working_dir} ) # run a command as test
          else()
              add_test( ${_PAR_TARGET} ${_PAR_TARGET}  ${TEST_ARGS} ${_working_dir} ) # run the test that was generated
          endif()

          # get test data

          if( _PAR_TEST_DATA )

             ecbuild_get_test_multidata( TARGET ${_PAR_TARGET}_data NAMES ${_PAR_TEST_DATA} )

             list( APPEND _PAR_TEST_DEPENDS ${_PAR_TARGET}_data )

          endif()

          if( DEFINED _PAR_ENVIRONMENT )
              set_property( TEST ${_PAR_TARGET} APPEND PROPERTY ENVIRONMENT "${_PAR_ENVIRONMENT}" )
          endif()

          if( DEFINED _PAR_WORKING_DIRECTORY )
              set_tests_properties( ${_PAR_TARGET} PROPERTIES WORKING_DIRECTORY "${_PAR_WORKING_DIRECTORY}")
          endif()

          if( DEFINED _PAR_TEST_DEPENDS )
              set_property( TEST ${_PAR_TARGET} APPEND PROPERTY DEPENDS "${_PAR_TEST_DEPENDS}" )
          endif()

      endif()

      # add to the overall list of tests
      list( APPEND ECBUILD_ALL_TESTS ${_PAR_TARGET} )
      list( REMOVE_DUPLICATES ECBUILD_ALL_TESTS )
      set( ECBUILD_ALL_TESTS ${ECBUILD_ALL_TESTS} CACHE INTERNAL "" )

    endif() # _condition

    # finally mark project files
    ecbuild_declare_project_files( ${_PAR_SOURCES} )

endmacro( ecbuild_add_test )
