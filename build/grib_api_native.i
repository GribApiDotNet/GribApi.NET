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
#include "grib_api.h"

extern "C" {
SWIGEXPORT struct FileHandleProxy
{
	HANDLE Win32Handle;
	FILE* File;
};

SWIGEXPORT int __stdcall Count(char * fn)
{
	int nm = 0;
	FILE* f = 0;

	f = fopen(fn, "r");
	rewind(f);
	auto c = grib_context_get_default();
	grib_count_in_file(c, f, &nm);
	return nm;
}

SWIGEXPORT void __stdcall DestroyFileHandleProxy(FileHandleProxy* fhp)
{
	assert(CloseHandle((HANDLE)fhp->Win32Handle) == TRUE);
	fclose(fhp->File);
	free(fhp);
}

HANDLE OpenGribFile(char * fn, int access, int mode) {
	HANDLE hFile;

	int share = FILE_SHARE_READ;
	int disposition = OPEN_EXISTING;

	// convert System.IO.FileAccess to win32 constants
	switch (access) {
		case 1:
			access = GENERIC_READ;
			break;
		case 2:
			access = GENERIC_WRITE;
			break;
		case 3:
			access = GENERIC_READ | GENERIC_WRITE;
			break;
	}

	switch (mode) {
		// create new
		case 1:
			disposition = CREATE_NEW;
			break;
		// create
		case 2:
			disposition = CREATE_ALWAYS;
			break;
		// open
		case 3:
			disposition = OPEN_EXISTING;
			break;
		// open or create
		case 4:
			disposition = OPEN_ALWAYS;
			break;
		// truncate
		case 5:
			disposition = TRUNCATE_EXISTING;
			break;
		// append
		case 6:
			access |= FILE_APPEND_DATA;
			break;
	}

	hFile = CreateFileA(fn,
		access, 
		share,
		NULL,                     			 // no security
		disposition,
		FILE_ATTRIBUTE_NORMAL,    // normal file
		NULL);                 				  // no attr. template

	if (hFile == INVALID_HANDLE_VALUE)
	{
		return NULL;
	}

	return hFile;
}

SWIGEXPORT FileHandleProxy* __stdcall CreateFileHandleProxy(char * fn)
{
    char * fmode = NULL;

	FileHandleProxy* fhp = 0;
	fhp = (FileHandleProxy*)malloc(sizeof(FileHandleProxy));

    auto hFile = CreateFileA(fn, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    
    if (hFile == INVALID_HANDLE_VALUE)
    {
        return NULL;
    }
	
    auto fd = _open_osfhandle((intptr_t)hFile, 0);

    if (fd == -1)
    {
        free(fhp);
        return NULL;
    }
    
    fhp->File = _fdopen(fd, "r");
    fhp->Win32Handle = hFile;

	return fhp;
}

SWIGEXPORT void __stdcall GetGribKeysIteratorName(char** name, grib_keys_iterator* iter)
{
    const char* v = NULL;

    v = grib_keys_iterator_get_name(iter);
    strcpy((*name), v);
}
}
%}




