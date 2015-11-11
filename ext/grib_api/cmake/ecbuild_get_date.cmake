# (C) Copyright 1996-2014 ECMWF.
# 
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0. 
# In applying this licence, ECMWF does not waive the privileges and immunities 
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

############################################################################################
# get date macro

macro(ecbuild_get_date RESULT)
    if(UNIX)
        execute_process(COMMAND "date" "+%d/%m/%Y" OUTPUT_VARIABLE ${RESULT})
        string(REGEX REPLACE "(..)/(..)/(....).*" "\\3.\\2.\\1" ${RESULT} ${${RESULT}})
    else()
        message(SEND_ERROR "date not implemented")
    endif()
endmacro(ecbuild_get_date)

############################################################################################
# get timestamp

macro(ecbuild_get_timestamp RESULT)
    if(UNIX)
        execute_process(COMMAND "date" "+%Y/%m/%d/%H/%M/%S" OUTPUT_VARIABLE _timestamp)
        string(REGEX REPLACE "(....)/(..)/(..)/(..)/(..)/(..).*" "\\1\\2\\3\\4\\5\\6" ${RESULT} ${_timestamp})
    else()
        message(WARNING "This is NOT UNIX - timestamp not implemented")
    endif()
endmacro(ecbuild_get_timestamp)

