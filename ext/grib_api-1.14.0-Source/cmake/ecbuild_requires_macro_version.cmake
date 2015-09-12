# (C) Copyright 1996-2014 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

macro( ecbuild_requires_macro_version req_vrs )

	if( ECBUILD_MACRO_VERSION VERSION_LESS ${req_vrs} )
		message( FATAL_ERROR "${PROJECT_NAME} needs ecbuild macro version >= ${req_vrs}" )
	endif()

endmacro()
