# (C) Copyright 1996-2014 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

##############################################################################

# function to download stuff

function( ecbuild_download_resource _p_OUT _p_URL )

    if( NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/${_p_OUT} )

        find_program( CURL_PROGRAM curl )

        execute_process( COMMAND ${CURL_PROGRAM} --silent --show-error --fail --output ${_p_OUT} ${_p_URL} WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} RESULT_VARIABLE CMD_RESULT )

        if(CMD_RESULT)
            message(FATAL_ERROR \"Error downloading ${_p_URL}\")
        endif()

    endif()

endfunction()


# function for downloading test data

function( _download_test_data _p_NAME _p_DIRNAME )

    # TODO: make that 'at ecmwf'
    #if(1)
    #unset(ENV{no_proxy})
    #unset(ENV{NO_PROXY})
    #set(ENV{http_proxy} "http://proxy.ecmwf.int:3333")
    #endif()

    find_program( CURL_PROGRAM curl )

    if( CURL_PROGRAM )

		add_custom_command( OUTPUT ${_p_NAME}
			COMMENT "(curl) downloading http://download.ecmwf.org/test-data/${_p_DIRNAME}/${_p_NAME}"
			COMMAND ${CURL_PROGRAM} --silent --show-error --fail --output ${_p_NAME} http://download.ecmwf.org/test-data/${_p_DIRNAME}/${_p_NAME} )

    else()

        find_program( WGET_PROGRAM wget )

        if( WGET_PROGRAM )

				 add_custom_command( OUTPUT ${_p_NAME}
						COMMENT "(wget) downloading http://download.ecmwf.org/test-data/${_p_DIRNAME}/${_p_NAME}"
						COMMAND ${WGET_PROGRAM} -nv -O ${_p_NAME} http://download.ecmwf.org/test-data/${_p_DIRNAME}/${_p_NAME} )

				else()

					if( WARNING_CANNOT_DOWNLOAD_TEST_DATA )
						message( WARNING "Couldn't find curl neither wget -- cannot download test data from server.\nPlease obtain the test data by other means and pleace it in the build directory." )
						set( WARNING_CANNOT_DOWNLOAD_TEST_DATA 1 CACHE INTERNAL "Couldn't find curl neither wget -- cannot download test data from server" )
						mark_as_advanced( WARNING_CANNOT_DOWNLOAD_TEST_DATA )
					endif()

        endif()

    endif()

endfunction()


##############################################################################
# function for getting test data
#
# examples:
#
## no check done
#    ecbuild_get_test_data( NAME msl.grib NOCHECK )
#
## checksum agains remote md5 file
#    ecbuild_get_test_data( NAME msl.grib )
#
## checksum agains local md5
#    ecbuild_get_test_data( NAME msl.grib MD5 f69ca0929d1122c7878d19f32401abe9 )
#
## (DEPRECATED) checksum agains local sha1
#    ecbuild_get_test_data( NAME msl.grib SHA1 5a8e8c57c510b64e31863ca47cfc3b65971089d9 )

function( ecbuild_get_test_data )

    set( options NOCHECK )
    set( single_value_args TARGET URL NAME DIRNAME MD5 SHA1)
    set( multi_value_args  )

    cmake_parse_arguments( _p "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

    if(_p_UNPARSED_ARGUMENTS)
      message(FATAL_ERROR "Unknown keywords given to ecbuild_get_test_data(): \"${_p_UNPARSED_ARGUMENTS}\"")
    endif()

    file( RELATIVE_PATH currdir ${PROJECT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR} )

    ### check parameters

    if( NOT _p_NAME )
      message(FATAL_ERROR "ecbuild_get_test_data() expects a NAME")
    endif()

    if( NOT _p_TARGET )
      string( REGEX REPLACE "[^A-Za-z0-9_]" "_" _p_TARGET "test_data_${_p_NAME}")
#      string( REGEX REPLACE "[^A-Za-z0-9_]" "_" _p_TARGET "${_p_NAME}")
#      set( _p_TARGET ${_p_NAME} )
    endif()

    if( NOT _p_DIRNAME )
      set( _p_DIRNAME ${PROJECT_NAME}/${currdir} )
    endif()

#    debug_var( _p_TARGET )
#    debug_var( _p_NAME )
#    debug_var( _p_URL )
#    debug_var( _p_DIRNAME )

    # download the data

    _download_test_data( ${_p_NAME} ${_p_DIRNAME} )

    # perform the checksum if requested

    set( _deps ${_p_NAME} )

    if( NOT _p_NOCHECK )

        find_program( MD5SUM md5sum )

        if( MD5SUM AND NOT _p_MD5 AND NOT _p_SHA1) # use remote md5

#            message( STATUS " ---  getting MD5 sum " )

            add_custom_command( OUTPUT ${_p_NAME}.localmd5
                                COMMAND ${MD5SUM} -t ${_p_NAME} > ${_p_NAME}.localmd5
                                DEPENDS ${_p_NAME} )

            _download_test_data( ${_p_NAME}.md5 ${_p_DIRNAME} )

            add_custom_command(	OUTPUT ${_p_NAME}.ok
                                COMMAND diff ${_p_NAME}.md5 ${_p_NAME}.localmd5 && touch ${_p_NAME}.ok
                                DEPENDS ${_p_NAME}.localmd5 ${_p_NAME}.md5 )

            list( APPEND _deps  ${_p_NAME}.localmd5 ${_p_NAME}.ok )

        endif()

        if( MD5SUM AND _p_MD5 )

#            message( STATUS " ---  computing MD5 sum [${_p_MD5}]" )

            add_custom_command( OUTPUT ${_p_NAME}.localmd5
                                COMMAND ${MD5SUM} -t ${_p_NAME} > ${_p_NAME}.localmd5
                                DEPENDS ${_p_NAME} )

            configure_file( "${ECBUILD_MACROS_DIR}/md5.in" ${_p_NAME}.md5 @ONLY )

            add_custom_command( OUTPUT ${_p_NAME}.ok
                                COMMAND diff ${_p_NAME}.md5 ${_p_NAME}.localmd5 && touch ${_p_NAME}.ok
                                DEPENDS ${_p_NAME}.localmd5 )

            list( APPEND _deps ${_p_NAME}.localmd5 ${_p_NAME}.ok )

        endif()

#        if( _p_SHA1 )

##            message( STATUS " ---  computing SHA1 sum [${_p_SHA1}]" )

#            find_program( SHASUM NAMES sha1sum shasum )
#            if( SHASUM )
#                add_custom_command( OUTPUT ${_p_NAME}.localsha1
#                                    COMMAND ${SHASUM} ${_p_NAME} > ${_p_NAME}.localsha1 )

#                add_custom_command( OUTPUT ${_p_NAME}.ok
#                                    COMMAND diff ${_p_NAME}.sha1 ${_p_NAME}.localsha1 && touch ${_p_NAME}.ok )

#                configure_file( "${ECBUILD_MACROS_DIR}/sha1.in" ${_p_NAME}.sha1 @ONLY )

#                list( APPEND _deps ${_p_NAME}.localsha1 ${_p_NAME}.ok )
#            endif()

#        endif()

    endif()

    add_custom_target( ${_p_TARGET} DEPENDS ${_deps} )

endfunction(ecbuild_get_test_data)

##############################################################################
# function for getting test data
#
# examples:
#
## no check done
#    ecbuild_get_test_multidata( TARGET get_foobar_data NAMES foo.grib bar.grib DIRNAME test/data/dir NOCHECK )
#
## check for remote md5
#    ecbuild_get_test_multidata( TARGET get_foobar_data NAMES foo.grib bar.grib DIRNAME test/data/dir )
#

function( ecbuild_get_test_multidata )

    set( options NOCHECK )
    set( single_value_args TARGET DIRNAME )
    set( multi_value_args  NAMES )

    cmake_parse_arguments( _p "${options}" "${single_value_args}" "${multi_value_args}"  ${_FIRST_ARG} ${ARGN} )

    if(_p_UNPARSED_ARGUMENTS)
      message(FATAL_ERROR "Unknown keywords given to ecbuild_get_test_data(): \"${_p_UNPARSED_ARGUMENTS}\"")
    endif()

    ### check parameters

    if( NOT _p_NAMES )
      message(FATAL_ERROR "ecbuild_get_test_data() expects a NAMES")
    endif()

    if( NOT _p_TARGET )
      message(FATAL_ERROR "ecbuild_get_test_data() expects a TARGET")
    endif()

#    debug_var( _p_TARGET )
#    debug_var( _p_NAME )
#    debug_var( _p_DIRNAME )

    if( _p_NOCHECK )
        set( _nocheck NOCHECK )
    endif()

    ### prepare file

    set( _script ${CMAKE_CURRENT_BINARY_DIR}/get_data_${_p_TARGET}.cmake )

    file( WRITE ${_script} "
function(EXEC_CHECK)
     execute_process(COMMAND \${ARGV} RESULT_VARIABLE CMD_RESULT)
     if(CMD_RESULT)
           message(FATAL_ERROR \"Error running ${CMD}\")
     endif()
endfunction()\n\n" )

    foreach( _d ${_p_NAMES} )

        string( REGEX MATCH "[^:]+" _f "${_d}" )

        get_filename_component( _file ${_f} NAME )
        get_filename_component( _dir  ${_f} PATH )

        list( APPEND _path_comps ${_p_DIRNAME} ${_dir} )

        join( _path_comps "/" _dirname )

        if( _dirname )
            set( _dirname DIRNAME ${_dirname} )
        endif()

        string( REPLACE "." "_" _name "${_file}" )
        string( REGEX MATCH ":.*"  _md5  "${_d}" )
        string( REPLACE ":" "" _md5 "${_md5}" )

        if( _md5 )
            set( _md5 MD5 ${_md5} )
        endif()

        #debug_var(_f)
        #debug_var(_file)
        #debug_var(_dirname)
        #debug_var(_name)
        #debug_var(_md5)

        ecbuild_get_test_data(
            TARGET __get_data_${_p_TARGET}_${_name}
            NAME ${_file} ${_dirname} ${_md5} ${_nocheck} )

        file( APPEND ${_script}
            "exec_check( ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target __get_data_${_p_TARGET}_${_name} )\n" )

    endforeach()

    add_test(  NAME ${_p_TARGET} COMMAND ${CMAKE_COMMAND} -P ${_script} )

endfunction(ecbuild_get_test_multidata)

