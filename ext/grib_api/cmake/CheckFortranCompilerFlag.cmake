# - Check whether the CXX compiler supports a given flag.
# CHECK_CXX_COMPILER_FLAG(FLAG VARIABLE)
#
#  FLAG - the compiler flag
#  VARIABLE - variable to store the result

# Copyright (c) 2006, Alexander Neundorf, <neundorf@kde.org>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.


INCLUDE(CheckFortranSourceCompiles)

MACRO (CHECK_FORTRAN_COMPILER_FLAG _FLAG _RESULT)
   SET(SAFE_CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS}")
   SET(CMAKE_REQUIRED_DEFINITIONS "${_FLAG}")
   CHECK_FORTRAN_SOURCE_COMPILES("program main\nend program\n" ${_RESULT}
     # Some compilers do not fail with a bad flag
     FAIL_REGEX "command line option .* is valid for .* but not for C\\\\+\\\\+" # GNU
     FAIL_REGEX "unrecognized .*option"                     # GNU
     FAIL_REGEX "unknown .*option"                          # Clang
     FAIL_REGEX "invalid value"                             # Clang
     FAIL_REGEX "ignoring unknown option"                   # MSVC
     FAIL_REGEX "warning D9002"                             # MSVC, any lang
     FAIL_REGEX "option.*not supported"                     # Intel
     FAIL_REGEX "invalid argument .*option"                 # Intel
     FAIL_REGEX "ignoring option .*argument required"       # Intel
     FAIL_REGEX "[Uu]nknown option"                         # HP
     FAIL_REGEX "[Ww]arning: [Oo]ption"                     # SunPro
     FAIL_REGEX "command option .* is not recognized"       # XL
     FAIL_REGEX "not supported in this configuration; ignored"       # AIX
     FAIL_REGEX "File with unknown suffix passed to linker" # PGI
     FAIL_REGEX "WARNING: unknown flag:"                    # Open64
     )
   SET (CMAKE_REQUIRED_DEFINITIONS "${SAFE_CMAKE_REQUIRED_DEFINITIONS}")
ENDMACRO (CHECK_FORTRAN_COMPILER_FLAG)
