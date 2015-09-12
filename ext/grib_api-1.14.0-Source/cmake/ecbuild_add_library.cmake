# (C) Copyright 1996-2014 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

##############################################################################
# auxiliary macro for adding a library
##############################################################################

function( ecbuild_add_library_impl )

	set( options NOINSTALL AUTO_VERSION )
	set( single_value_args TARGET TYPE COMPONENT INSTALL_HEADERS LINKER_LANGUAGE HEADER_DESTINATION VERSION OUTPUT_NAME )
	set( multi_value_args  SOURCES TEMPLATES LIBS INCLUDES DEPENDS PERSISTENT DEFINITIONS INSTALL_HEADERS_LIST CFLAGS CXXFLAGS FFLAGS GENERATED CONDITION )

	cmake_parse_arguments( _PAR "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

	if(_PAR_UNPARSED_ARGUMENTS)
	  message(FATAL_ERROR "Unknown keywords given to ecbuild_add_library(): \"${_PAR_UNPARSED_ARGUMENTS}\"")
	endif()

	if( NOT _PAR_TARGET  )
	  message(FATAL_ERROR "The call to ecbuild_add_library() doesn't specify the TARGET.")
	endif()

	if( NOT _PAR_SOURCES )
	  message(FATAL_ERROR "The call to ecbuild_add_library() doesn't specify the SOURCES.")
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

	if( _${_PAR_TARGET}_condition )

		# defines the type of library
		if( DEFINED _PAR_TYPE )
			# checks that is either SHARED or STATIC or MODULE
			if( NOT _PAR_TYPE MATCHES "STATIC" AND
				NOT _PAR_TYPE MATCHES "SHARED" AND
				NOT _PAR_TYPE MATCHES "MODULE" )
				message( FATAL_ERROR "library type must be one of [ STATIC | SHARED | MODULE ]" )
			endif()
		endif()


		# add persistent layer files
		if( DEFINED _PAR_PERSISTENT )
			if( DEFINED PERSISTENT_NAMESPACE )
				ecbuild_add_persistent( SRC_LIST _PAR_SOURCES FILES ${_PAR_PERSISTENT} NAMESPACE ${PERSISTENT_NAMESPACE} )
			else()
				ecbuild_add_persistent( SRC_LIST _PAR_SOURCES FILES ${_PAR_PERSISTENT} )
			endif()
		endif()

		# remove templates from compilation sources
		if( DEFINED _PAR_TEMPLATES )
			list( REMOVE_ITEM _PAR_SOURCES ${_PAR_TEMPLATES} )
			add_custom_target( ${_PAR_TARGET}_templates SOURCES ${_PAR_TEMPLATES} )
		endif()

		add_library( ${_PAR_TARGET} ${_PAR_TYPE} ${_PAR_SOURCES} )

		# set OUTPUT_NAME

		if( DEFINED _PAR_OUTPUT_NAME )
			set_target_properties( ${_PAR_TARGET} PROPERTIES OUTPUT_NAME ${_PAR_OUTPUT_NAME} )
		endif()

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
#              message( WARNING "Lib ${lib} was skipped" )
			endif()
		  endforeach()
		endif()

		# add include dirs if defined
		if( DEFINED _PAR_INCLUDES )
		  list( REMOVE_DUPLICATES _PAR_INCLUDES )
		  foreach( path ${_PAR_INCLUDES} ) # skip NOTFOUND
			if( path )
				if( "${CMAKE_VERSION}" VERSION_LESS "2.8.11" OR ECBUILD_USE_INCLUDE_DIRECTORIES )
					include_directories( ${path} )
				else()
			  		target_include_directories( ${_PAR_TARGET} PUBLIC ${path} )
				endif()
	#        else()
	#          message( WARNING "Path ${path} was skipped" )
			endif()
		  endforeach()
		endif()

		# FIX: Cray compiler PIC option is not detected by CMake

		get_property( _target_pic TARGET ${_PAR_TARGET} PROPERTY POSITION_INDEPENDENT_CODE )
		if( _target_pic )
			if( "${CMAKE_C_COMPILER_ID}" STREQUAL "Cray" )
				set( _PAR_CFLAGS "-fPIC -h PIC ${_PAR_CFLAGS}" )
			endif()
			if( "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Cray" )
				set( _PAR_CXXFLAGS "-fPIC -h PIC ${_PAR_CXXFLAGS}" )
			endif()
			if( "${CMAKE_Fortran_COMPILER_ID}" STREQUAL "Cray" )
				set( _PAR_FFLAGS "-fPIC -h PIC ${_PAR_FFLAGS}" )
			endif()
		endif()

		# define VERSION if requested
		if( DEFINED _PAR_VERSION )
			set_target_properties( ${_PAR_TARGET} PROPERTIES VERSION "${_PAR_VERSION}" )
		else()
			if( _PAR_AUTO_VERSION OR LIBS_VERSION MATCHES "[Aa][Uu][Tt][Oo]")
				set_target_properties( ${_PAR_TARGET} PROPERTIES VERSION "${${PNAME}_MAJOR_VERSION}.${${PNAME}_MINOR_VERSION}" )
			endif()
			if( LIBS_VERSION AND NOT LIBS_VERSION MATCHES "[Aa][Uu][Tt][Oo]" )
				set_target_properties( ${_PAR_TARGET} PROPERTIES VERSION "${LIBS_VERSION}" )
			endif()
		endif()

		# filter sources

		ecbuild_separate_sources( TARGET ${_PAR_TARGET} SOURCES ${_PAR_SOURCES} )

#		debug_var( ${_PAR_TARGET}_h_srcs )
#		debug_var( ${_PAR_TARGET}_c_srcs )
#		debug_var( ${_PAR_TARGET}_cxx_srcs )
#		debug_var( ${_PAR_TARGET}_f_srcs )

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

		# set linker language
		if( DEFINED _PAR_LINKER_LANGUAGE )
			set_property( TARGET ${_PAR_TARGET} PROPERTY LINKER_LANGUAGE ${_PAR_LINKER_LANGUAGE} )
		endif()

		# installation

		if( NOT _PAR_NOINSTALL )

			# and associate with defined component
#            if( DEFINED _PAR_COMPONENT )
#                set( COMPONENT_DIRECTIVE "${_PAR_COMPONENT}" )
#            else()
#                set( COMPONENT_DIRECTIVE "${PROJECT_NAME}" )
#            endif()

			install( TARGETS ${_PAR_TARGET}
			  EXPORT  ${CMAKE_PROJECT_NAME}-targets
			  RUNTIME DESTINATION ${INSTALL_BIN_DIR}
			  LIBRARY DESTINATION ${INSTALL_LIB_DIR}
			  ARCHIVE DESTINATION ${INSTALL_LIB_DIR} )
#              COMPONENT ${COMPONENT_DIRECTIVE} )

			# install headers
			if( _PAR_HEADER_DESTINATION )
				set( _h_destination "${_PAR_HEADER_DESTINATION}" )
			else()
				set( _h_destination "${INSTALL_INCLUDE_DIR}" )
			endif()

			if( _PAR_INSTALL_HEADERS )
				if( _PAR_INSTALL_HEADERS MATCHES "LISTED" )
					foreach( file ${${_PAR_TARGET}_h_srcs} )
						get_filename_component( _file_dir ${file} PATH )
						install( FILES ${file} DESTINATION "${_h_destination}/${_file_dir}" )
					endforeach()
					if( DEFINED _PAR_TEMPLATES )
						foreach( file ${_PAR_TEMPLATES} )
							get_filename_component( _file_dir ${file} PATH )
							install( FILES ${file} DESTINATION "${_h_destination}/${_file_dir}" )
						endforeach()
					endif()
					if( DEFINED _PAR_PERSISTENT )
						foreach( file ${_PAR_PERSISTENT} )
							  get_filename_component( _file_dir ${file} PATH )
							  get_filename_component( _file_we  ${file} NAME_WE )
							  set( pfile "${CMAKE_CURRENT_BINARY_DIR}/${_file_dir}/${_file_we}.b" )
							  install( FILES ${pfile} DESTINATION "${_h_destination}/${_file_dir}" )
						endforeach()
					endif()
				endif()
				if( _PAR_INSTALL_HEADERS MATCHES "ALL" ) # "(\\.h|\\.b|\\.hxx|\\.hh|\\.hpp|\\.H)" ????
					install( DIRECTORY ./  DESTINATION ${_h_destination} FILES_MATCHING PATTERN "*.h" )
					install( DIRECTORY ./  DESTINATION ${_h_destination} FILES_MATCHING PATTERN "*.hh" )
					install( DIRECTORY ./  DESTINATION ${_h_destination} FILES_MATCHING PATTERN "*.hpp" )
					install( DIRECTORY ./  DESTINATION ${_h_destination} FILES_MATCHING PATTERN "*.H" )
				endif()
			endif()

			if( DEFINED _PAR_INSTALL_HEADERS_LIST )
				install( FILES ${_PAR_INSTALL_HEADERS_LIST} DESTINATION ${_h_destination} )
			endif()

			if( DEFINED _PAR_INSTALL_HEADERS_REGEX )
				install( DIRECTORY ./  DESTINATION ${_h_destination} FILES_MATCHING PATTERN "${_PAR_INSTALL_HEADERS_REGEX}")
			endif()

			# set build location

			set_property( TARGET ${_PAR_TARGET} PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib )
			set_property( TARGET ${_PAR_TARGET} PROPERTY ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib )

			# export location of target to other projects -- must be exactly after setting the build location (see previous 2 commands)

			export( TARGETS ${_PAR_TARGET} APPEND FILE "${TOP_PROJECT_TARGETS_FILE}" )

		endif()

		# add definitions to compilation
		if( DEFINED _PAR_DEFINITIONS )
			get_property( _target_defs TARGET ${_PAR_TARGET} PROPERTY COMPILE_DEFINITIONS )
			list( APPEND _target_defs ${_PAR_DEFINITIONS} )
			set_property( TARGET ${_PAR_TARGET} PROPERTY COMPILE_DEFINITIONS ${_target_defs} )
		endif()

		# make sure target is removed before - some problems with AIX
		add_custom_command( TARGET ${_PAR_TARGET} PRE_BUILD COMMAND ${CMAKE_COMMAND} -E remove $<TARGET_FILE:${_PAR_TARGET}> )

		# for the links target
		if( NOT _PAR_NOINSTALL )
			ecbuild_link_lib( ${_PAR_TARGET} $<TARGET_FILE_NAME:${_PAR_TARGET}> $<TARGET_FILE:${_PAR_TARGET}>  )
		endif()

		# append to the list of this project targets
		set( ${PROJECT_NAME}_ALL_LIBS ${${PROJECT_NAME}_ALL_LIBS} ${_PAR_TARGET} CACHE INTERNAL "" )

	endif()

	# mark source files as used
	ecbuild_declare_project_files( ${_PAR_SOURCES} )
  if( DEFINED _PAR_TEMPLATES )
    ecbuild_declare_project_files( ${_PAR_TEMPLATES} )
  endif()

endfunction( ecbuild_add_library_impl  )

##############################################################################
# auxiliary macro for adding a library
##############################################################################

macro( ecbuild_add_library )

	set( options  )
	set( single_value_args TARGET TYPE )
	set( multi_value_args )

	cmake_parse_arguments( _p "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

	if( DEFINED _p_TYPE ) # don't do anything if TYPE was specified

			if( _p_TYPE MATCHES "[Bb][Oo][Tt][Hh]" ) # build both types

				ecbuild_add_library_impl( TARGET ${_p_TARGET}        TYPE SHARED ${_p_UNPARSED_ARGUMENTS} )
				ecbuild_add_library_impl( TARGET ${_p_TARGET}-static TYPE STATIC ${_p_UNPARSED_ARGUMENTS} OUTPUT_NAME ${_p_TARGET} DEPENDS ${_p_TARGET} )

			else()

				ecbuild_add_library_impl( ${ARGV} )

			endif()

	else()

		if( NOT DEFINED _p_TARGET )
			message(FATAL_ERROR "The call to ecbuild_add_library() doesn't specify the TARGET.")
		else()

			if( BUILD_SHARED_LIBS MATCHES "[Bb][Oo][Tt][Hh]" ) # build both types

				ecbuild_add_library_impl( TARGET ${_p_TARGET}        TYPE SHARED ${_p_UNPARSED_ARGUMENTS} )
				ecbuild_add_library_impl( TARGET ${_p_TARGET}-static TYPE STATIC ${_p_UNPARSED_ARGUMENTS} DEPENDS ${_p_TARGET} )

				set_target_properties( ${_p_TARGET}-static PROPERTIES OUTPUT_NAME ${_p_TARGET} )

			else()

				ecbuild_add_library_impl( ${ARGV} )

			endif()

		endif()

	endif()

endmacro( ecbuild_add_library )
