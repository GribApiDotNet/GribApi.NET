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
# ecbuild_download_resource
# =========================
#
# Download a file from a given URL and save to FILE at configure time. ::
#
#   ecbuild_download_resource( FILE URL )
#
# curl or wget is required (curl is preferred if available).
#
##############################################################################

function( ecbuild_download_resource _p_OUT _p_URL )

  if( NOT EXISTS ${_p_OUT} )

    find_program( CURL_PROGRAM curl )
    if( CURL_PROGRAM )
      execute_process( COMMAND ${CURL_PROGRAM} --silent --show-error --fail --output ${_p_OUT} ${_p_URL}
                       WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} RESULT_VARIABLE CMD_RESULT )
    else()
      find_program( WGET_PROGRAM wget )
      if( WGET_PROGRAM )
        execute_process( COMMAND ${WGET_PROGRAM} -nv -O ${_p_OUT} ${_p_URL}
                         WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} RESULT_VARIABLE CMD_RESULT )
      else()
        message(FATAL_ERROR "Could not find curl or wget. Error downloading ${_p_URL}")
      endif()
    endif()

    if(CMD_RESULT)
      message(FATAL_ERROR "Error downloading ${_p_URL}")
    endif()

  endif()

endfunction()
