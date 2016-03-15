// Copyright 2015 Eric Millin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

%ignore grib_values;

%ignore GRIB_TYPE_UNDEFINED;
%ignore  GRIB_TYPE_LONG;
%ignore  GRIB_TYPE_DOUBLE;
%ignore  GRIB_TYPE_STRING;
%ignore  GRIB_TYPE_BYTES;
%ignore  GRIB_TYPE_SECTION;
%ignore  GRIB_TYPE_LABEL;
%ignore  GRIB_TYPE_MISSING;

%ignore GRIB_KEYS_ITERATOR_ALL_KEYS;
%ignore GRIB_KEYS_ITERATOR_SKIP_READ_ONLY;
%ignore GRIB_KEYS_ITERATOR_SKIP_OPTIONAL;
%ignore GRIB_KEYS_ITERATOR_SKIP_EDITION_SPECIFIC;
%ignore GRIB_KEYS_ITERATOR_SKIP_CODED;
%ignore GRIB_KEYS_ITERATOR_SKIP_COMPUTED;
%ignore GRIB_KEYS_ITERATOR_SKIP_DUPLICATES;
%ignore GRIB_KEYS_ITERATOR_SKIP_FUNCTION;

%include "grib_api.h"

%{
#include <windows.h>
#include <assert.h>
#include <io.h>
#include <sstream>
#include "grib_api_internal.h"

typedef void (SWIGSTDCALL* CSharpExceptionCallback_t)(const char *);
CSharpExceptionCallback_t gribExceptionCallback = NULL;

extern "C" {
  SWIGEXPORT
  void SWIGSTDCALL GribExceptionRegisterCallback(CSharpExceptionCallback_t customCallback) {
    gribExceptionCallback = customCallback;
  }

  static void GribSetPendingException(const char *msg) {
    gribExceptionCallback(msg);
  }
  
  SWIGEXPORT struct FileHandleProxy
  {
    FILE* File;
  };

  SWIGEXPORT void __stdcall DestroyFileHandleProxy(FileHandleProxy* fhp)
  {
    intptr_t h = _get_osfhandle(_fileno(fhp->File));

    if (h != (intptr_t)INVALID_HANDLE_VALUE)
    {
      // On Windows, DO NOT call CloseHandle here, see remarks in
      // https://msdn.microsoft.com/en-us/library/fxfsw25t(v=vs.120).aspx
      assert(fclose(fhp->File) == 0);
    }

    delete(fhp);
  }

  SWIGEXPORT FileHandleProxy* __stdcall CreateFileHandleProxy(char * fn)
  {
    char * fmode = NULL;

    auto hFile = CreateFileA(fn, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);

    if (hFile == INVALID_HANDLE_VALUE)
    {
      return NULL;
    }

    auto fd = _open_osfhandle((intptr_t)hFile, 0);

    if (fd == -1)
    {
      return NULL;
    }

    FileHandleProxy* fhp = 0;
    fhp = new FileHandleProxy();
    fhp->File = _fdopen(fd, "r");

    return fhp;
  }

  SWIGEXPORT void __stdcall RewindFileHandleProxy(FileHandleProxy* fhp)
  {
    rewind(fhp->File);
  }

  SWIGEXPORT void __stdcall GetGribKeysIteratorName(char* name, grib_keys_iterator* iter)
  {
    char* v = NULL;
    v = (char*)grib_keys_iterator_get_name(iter);
    strcpy_s(name, 255, v);
  }

  SWIGEXPORT bool __stdcall GribKeyIsReadOnly(grib_handle* h, char * name)
  {
    grib_accessor* a = grib_find_accessor(h, name);
    return (a->flags & GRIB_ACCESSOR_FLAG_READ_ONLY) != 0;
  }

  SWIGEXPORT int __stdcall DeleteGribBox(grib_box* box)
  {
    // not exposed by SWIG by default
    return grib_box_delete(box) == 0;
  }

  SWIGEXPORT void  __stdcall GribSetContextLogger(void* ctx, grib_log_proc proc)
  {
    grib_context* pCtx = (grib_context*)ctx;
    grib_context_set_logging_proc(pCtx, proc);
  }
  
  void OnFail(const char* expr, const char* file, int line)
  {
    std::ostringstream stringStream;
    stringStream << expr << " failed at " << file << " " << line;
	GribSetPendingException(stringStream.str().c_str());
  };
  
  void OnExit(int code)
  {
    std::ostringstream stringStream;
    stringStream << "grib_api signaled exit with code " << code;
	GribSetPendingException(stringStream.str().c_str());
  };
  
  SWIGEXPORT void  __stdcall GribSetOnFatal()
  {
    grib_set_fail_proc(&OnFail);
    grib_set_exit_proc(&OnExit);
  }
}

%}




