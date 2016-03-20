# (C) Copyright 1996-2015 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0. 
# In applying this licence, ECMWF does not waive the privileges and immunities 
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

############################################################################################
# os capability checks

if( ENABLE_OS_FUNCTIONS_TEST )

    ### symbol checks ##################

    ecbuild_cache_check_symbol_exists( fseek        "stdio.h"                         EC_HAVE_FSEEK  )
    ecbuild_cache_check_symbol_exists( fseeko       "stdio.h"                         EC_HAVE_FSEEKO )
    ecbuild_cache_check_symbol_exists( ftello       "stdio.h"                         EC_HAVE_FTELLO )
    ecbuild_cache_check_symbol_exists( lseek        "sys/types.h;unistd.h"            EC_HAVE_LSEEK  )
    ecbuild_cache_check_symbol_exists( ftruncate    "sys/types.h;unistd.h"            EC_HAVE_FTRUNCATE  )
    ecbuild_cache_check_symbol_exists( open         "sys/types.h;sys/stat.h;fcntl.h"  EC_HAVE_OPEN   )
    ecbuild_cache_check_symbol_exists( fopen        "stdio.h"                         EC_HAVE_FOPEN  )
    ecbuild_cache_check_symbol_exists( flock        "sys/file.h"                      EC_HAVE_FLOCK  )
    ecbuild_cache_check_symbol_exists( mmap         "sys/mman.h"                      EC_HAVE_MMAP   )

    ecbuild_cache_check_symbol_exists( posix_memalign "stdlib.h"                      EC_HAVE_POSIX_MEMALIGN )

    ecbuild_cache_check_symbol_exists( F_GETLK      "fcntl.h"                         EC_HAVE_F_GETLK  )
    ecbuild_cache_check_symbol_exists( F_SETLK      "fcntl.h"                         EC_HAVE_F_SETLK  )
    ecbuild_cache_check_symbol_exists( F_SETLKW     "fcntl.h"                         EC_HAVE_F_SETLKW  )

    ecbuild_cache_check_symbol_exists( F_GETLK64     "fcntl.h"                        EC_HAVE_F_GETLK64  )
    ecbuild_cache_check_symbol_exists( F_SETLK64     "fcntl.h"                        EC_HAVE_F_SETLK64  )
    ecbuild_cache_check_symbol_exists( F_SETLKW64    "fcntl.h"                        EC_HAVE_F_SETLKW64  )

    ecbuild_cache_check_symbol_exists( MAP_ANONYMOUS "sys/mman.h"                     EC_HAVE_MAP_ANONYMOUS )
    ecbuild_cache_check_symbol_exists( MAP_ANON      "sys/mman.h"                     EC_HAVE_MAP_ANON )

    ### include files checks ##################

    ecbuild_cache_check_include_files( assert.h       EC_HAVE_ASSERT_H      )
    ecbuild_cache_check_include_files( stdlib.h       EC_HAVE_STDLIB_H      )
    ecbuild_cache_check_include_files( unistd.h       EC_HAVE_UNISTD_H      )
    ecbuild_cache_check_include_files( string.h       EC_HAVE_STRING_H      )
    ecbuild_cache_check_include_files( strings.h      EC_HAVE_STRINGS_H     )
    ecbuild_cache_check_include_files( sys/stat.h     EC_HAVE_SYS_STAT_H    )
    ecbuild_cache_check_include_files( sys/time.h     EC_HAVE_SYS_TIME_H    )
    ecbuild_cache_check_include_files( sys/types.h    EC_HAVE_SYS_TYPES_H   )
    ecbuild_cache_check_include_files( malloc.h       EC_HAVE_MALLOC_H      )
    ecbuild_cache_check_include_files( sys/malloc.h   EC_HAVE_SYS_MALLOC_H  )

    ecbuild_cache_check_include_files( sys/param.h    EC_HAVE_SYS_PARAM_H   )
    ecbuild_cache_check_include_files( sys/mount.h    EC_HAVE_SYS_MOUNT_H   )
    ecbuild_cache_check_include_files( sys/vfs.h      EC_HAVE_SYS_VFS_H     )

    ### capability checks ##################

    # test off_t
    ecbuild_cache_check_c_source_compiles( "#include <sys/types.h>\nint main(){ off_t l=0; return 0;}\n" EC_HAVE_OFFT )
    # test off64_t
    ecbuild_cache_check_c_source_compiles( "#define _LARGEFILE64_SOURCE\n#include <stdio.h>\n#include <sys/types.h>\nint main(){ off64_t l=0; return 0;}\n" EC_HAVE_OFF64T  )
    # test struct stat
    ecbuild_cache_check_c_source_compiles( "#include <sys/stat.h>\nint main(){ struct stat s; return 0; }"   EC_HAVE_STRUCT_STAT )
    # test struct stat64
    ecbuild_cache_check_c_source_compiles( "#define _LARGEFILE64_SOURCE\n#include <sys/stat.h>\nint main(){ struct stat64 s; return 0; }" EC_HAVE_STRUCT_STAT64 )
    # test stat
    ecbuild_cache_check_c_source_compiles( "#include <sys/stat.h>\nint main(){ struct stat s;	stat(\"\",&s); return 0; }"    EC_HAVE_STAT )
    # test stat64
    ecbuild_cache_check_c_source_compiles( "#define _LARGEFILE64_SOURCE\n#include <sys/stat.h>\nint main(){ struct stat64 s; stat64(\"\",&s); return 0; }"  EC_HAVE_STAT64 )
    # test fstat
    ecbuild_cache_check_c_source_compiles( "#include <sys/stat.h>\nint main(){ struct stat s; fstat(1,&s); return 0; }" EC_HAVE_FSTAT )
    # test fstat64
    ecbuild_cache_check_c_source_compiles( "#define _LARGEFILE64_SOURCE\n#include <sys/stat.h>\nint main(){ struct stat64 s; fstat64(1,&s); return 0; }" EC_HAVE_FSTAT64 )
    # test fseeko64
    ecbuild_cache_check_c_source_compiles( "#define _LARGEFILE64_SOURCE\n#include <stdio.h>\n#include <sys/types.h>\nint main(){FILE* file;off64_t l=0;fseeko64(file,l,SEEK_CUR);return 0;}\n" EC_HAVE_FSEEKO64 )
   
    # test for ftello64
    ecbuild_cache_check_c_source_compiles( "#define _LARGEFILE64_SOURCE\n#include <stdio.h>\n#include <sys/types.h>\nint main(){FILE* file;off64_t l = ftello64(file);return 0;}\n"  EC_HAVE_FTELLO64 )
    
    # test for lseek64
    ecbuild_cache_check_c_source_compiles( "#define _LARGEFILE64_SOURCE\n#include <sys/types.h>\n#include <unistd.h>\nint main(){off64_t h = lseek64(0,0,SEEK_SET);return 0;}\n"  EC_HAVE_LSEEK64 )
    # test for open64
    ecbuild_cache_check_c_source_compiles( "#define _LARGEFILE64_SOURCE\n#include <fcntl.h>\nint main(){int fd = open64(\"name\",O_RDWR|O_CREAT,0777);return 0;}\n" EC_HAVE_OPEN64 )
    # test for fopen64
    ecbuild_cache_check_c_source_compiles( "#define _LARGEFILE64_SOURCE\n#include <stdio.h>\nint main(){FILE* file = fopen64(\"name\",\"w\");return 0;}\n"  EC_HAVE_FOPEN64 )
    # test for ftruncate64
    ecbuild_cache_check_c_source_compiles( "#define _LARGEFILE64_SOURCE\n#include <unistd.h>\n#include <sys/types.h>\nint main(){ftruncate64(0,(off64_t)0);return 0;}\n" EC_HAVE_FTRUNCATE64 )
    # test for flock64
    ecbuild_cache_check_c_source_compiles( "#define _LARGEFILE64_SOURCE\n#include <fcntl.h>\nint main(){struct flock64 l;return 0;}\n" EC_HAVE_FLOCK64 )
    # test for mmap64
    ecbuild_cache_check_c_source_compiles( "#define _LARGEFILE64_SOURCE\n#include <sys/mman.h>\nint main(){void* addr = mmap64(0,10,PROT_READ|PROT_WRITE,MAP_PRIVATE,10,0); return 0;}\n" EC_HAVE_MMAP64 )
    # test for struct statvfs
    ecbuild_cache_check_c_source_compiles( "#include <sys/statvfs.h>\nint main(){ struct statvfs v; }" EC_HAVE_STRUCT_STATVFS )
    # test for struct statvfs64
    ecbuild_cache_check_c_source_compiles( "#define _LARGEFILE64_SOURCE\n#include <sys/statvfs.h>\nint main(){ struct statvfs64 v; }" EC_HAVE_STRUCT_STATVFS64 )

    # test for fsync
    ecbuild_cache_check_symbol_exists(fsync "unistd.h" EC_HAVE_FSYNC)
    # test for fdatasync
    ecbuild_cache_check_symbol_exists(fdatasync "unistd.h" EC_HAVE_FDATASYNC)
    # test for dirfd
    ecbuild_cache_check_c_source_compiles( "#include <sys/types.h>\n#include <dirent.h>\nint main(){ DIR *dirp; int i = dirfd(dirp); }\n" EC_HAVE_DIRFD )
    # test for sys/proc.h
    ecbuild_cache_check_c_source_compiles( "#include <sys/proc.h>\nint main(){ return 0; }\n" EC_HAVE_SYSPROC )
    # test for procfs
    ecbuild_cache_check_c_source_compiles( "#include <sys/procfs.h>\nint main(){ return 0; }\n" EC_HAVE_SYSPROCFS )
    # test for backtrace
    ecbuild_cache_check_c_source_compiles( "#include <unistd.h>\n#include <execinfo.h>\n int main(){ void ** buffer; int i = backtrace(buffer, 256); }\n" EC_HAVE_EXECINFO_BACKTRACE )

    #### reentrant funtions support  #############

    # test for gmtime_r
    ecbuild_cache_check_c_source_compiles( "#include <time.h>\nint main(){ time_t now; time(&now); struct tm t; gmtime_r(&now,&t); }\n" EC_HAVE_GMTIME_R )
    # test for getpwuid_r
    ecbuild_cache_check_c_source_compiles( "#include <unistd.h>\n#include <sys/types.h>\n#include <pwd.h>\nint main(){ char buf[4096]; struct passwd pwbuf; struct passwd *pwbufp = 0; getpwuid_r(getuid(), &pwbuf, buf, sizeof(buf), &pwbufp); }\n" EC_HAVE_GETPWUID_R )
    # test for getpwnam_r
    ecbuild_cache_check_c_source_compiles( "#include <sys/types.h>\n#include <pwd.h>\nint main(){ struct passwd p; char line[1024]; int n = getpwnam_r(\"user\",&p,line,sizeof(line),0); }\n" EC_HAVE_GETPWNAM_R )    
    # test for readdir_r
    ecbuild_cache_check_c_source_compiles( "#include <dirent.h>\nint main(){ DIR *dirp; struct dirent *entry; struct dirent **result; int i = readdir_r(dirp, entry, result); }\n" EC_HAVE_READDIR_R )
    # test for gethostbyname_r
    ecbuild_cache_check_c_source_compiles( "#include <netdb.h>\nint main(){ const char *name; struct hostent *ret; char *buf; struct hostent **result; size_t buflen; int *h_errnop; int i = gethostbyname_r(name,ret,buf,buflen,result,h_errnop); }\n" EC_HAVE_GETHOSTBYNAME_R )

    #### special compiler __atributes__  #############

    # test for __attribute__ ((__constructor__)) -- usually present in GCC, Clang, Intel on Linux, Solaris, MacOSX; not present in AIX XLC
    ecbuild_cache_check_c_source_compiles( "#include <stdio.h>\nstatic int argc_;static char** argv_;static char** envp_;\nint main(){printf(\"%d\", argc_);}\n__attribute__ ((__constructor__)) static void before_main(int argc, char* argv[], char* envp[]){argc_ = argc;argv_ = argv;envp_ = envp;}\n" EC_HAVE_ATTRIBUTE_CONSTRUCTOR )

    if( NOT DEFINED EC_ATTRIBUTE_CONSTRUCTOR_INITS_ARGV )
        ecbuild_check_c_source_return("
            #include <stdio.h>
            #include <string.h>
            int main(){return 0;}
            __attribute__ ((__constructor__))
            static void before_main(int argc, char* argv[], char* envp[])
            {
                printf(\"%d:%d\",argc, strstr(argv[0],\"cmTryCompileExec\")?1:0);
            }"
            VAR    EC_ATTRIBUTE_CONSTRUCTOR_INITS_ARGV
            OUTPUT EC_ATTRIBUTE_CONSTRUCTOR_INITS_OUTPUT )

        if( EC_ATTRIBUTE_CONSTRUCTOR_INITS_ARGV AND NOT EC_ATTRIBUTE_CONSTRUCTOR_INITS_OUTPUT STREQUAL "1:1" )
          set(EC_ATTRIBUTE_CONSTRUCTOR_INITS_ARGV 0 CACHE INTERNAL "ATTRIBUTE_CONSTRUCTOR doesnt init argv correctly")
        endif()
    endif()
    ecbuild_cache_var( EC_ATTRIBUTE_CONSTRUCTOR_INITS_ARGV )


    #### check for some Linux stuff #############

    if( NOT DEFINED EC_HAVE_PROCFS )
        ecbuild_check_c_source_return("
            #include <sys/types.h>
            #include <dirent.h>
            int main()
            {
                DIR* d = opendir(\"/proc\");
                if(d)
                    return 0;
                else
                    return -1;
            }"
            VAR    EC_HAVE_PROCFS
            OUTPUT EC_HAVE_PROCFS_OUTPUT )
    endif()
    ecbuild_cache_var( EC_HAVE_PROCFS )

#    debug_var(EC_HAVE_PROCFS)
#    debug_var(EC_HAVE_PROCFS_OUTPUT)

endif()


