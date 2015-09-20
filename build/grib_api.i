%module GribApiProxy

%rename("%(strip:[grib])s") ""; 
%rename("%(strip:[Grib])s") ""; 

%{
#include "grib_api.h"
%}

//%include "swigtype_inout.i" 

%typemap(imtype) size_t * size, size_t * length, size_t * message_length "ref uint"
%typemap(cstype) size_t * size, size_t * length, size_t * message_length "ref uint"
%typemap(csin) size_t * size, size_t * length, size_t * message_length "ref  $csinput"

%typemap(imtype) size_t * offset "out uint"
%typemap(cstype) size_t * offset "out uint"
%typemap(csin) size_t * offset "out offset"

%typemap(imtype) int * err, int * error "out int"
%typemap(cstype) int * err, int * error "out int"
%typemap(csin) int * err, int * error "out $csinput"
// %typemap(csout, excode=SWIGEXCODE)  int * err, int * error {
    // if ($csinput != 0)
	// {
		// throw Grib.Api.GribApiException.Create($csinput);
	// }
	
	// return $imcall;$excode
// }
%typemap(imtype) int * n, int * type "out int"
%typemap(cstype) int * n, int * type "out int"
%typemap(csin) int * n, int * type "out $csinput"

%typemap(imtype) long * value "out int"
%typemap(cstype) long * value "out int"
%typemap(csin) long * value "out value"

%typemap(imtype) double * value, double * val "out double"
%typemap(cstype) double * value, double * val "out double"
%typemap(csin) double * value, double * val "out $csinput"

%typemap(imtype) float * value "out float"
%typemap(cstype) float * value "out float"
%typemap(csin) float * value "out value"

%typemap(csin) long * vals "vals"
%typemap(cstype) long * vals "int[]"
%typemap(imtype) long * vals "int[]"
		 
%typemap(csin) long * values "values"
%typemap(cstype) long * values "int[]"
%typemap(imtype) long * values "int[]"

%typemap(csin) double * vals "vals"
%typemap(cstype) double * vals "double[]"
%typemap(imtype) double * vals "double[]"
		 
%typemap(csin) double * values "values"
%typemap(cstype) double * values "double[]"
%typemap(imtype) double * values "double[]"

%typemap(csin) unsigned char * bytes "bytes"
%typemap(cstype) unsigned char * bytes "byte[]"
%typemap(imtype) unsigned char * bytes "byte[]"

%typemap(csin) unsigned char const * bytes "bytes"
%typemap(cstype) unsigned char const * bytes "byte[]"
%typemap(imtype) unsigned char const * bytes "byte[]"

%typemap(imtype) double * lat "out double"
%typemap(cstype) double * lat "out double"
%typemap(csin) double * lat "out lat"

%typemap(imtype) double * lon "out double"
%typemap(cstype) double * lon "out double"
%typemap(csin) double * lon "out lon"

%typemap(csin) double * lats "lats"
%typemap(cstype) double * lats "double[]"
%typemap(imtype) double * lats "double[]"

%typemap(csin) double * lons "lons"
%typemap(cstype) double * lons "double[]"
%typemap(imtype) double * lons "double[]"

%typemap(csin) double * outlons "outlons"
%typemap(cstype) double * outlons "double[]"
%typemap(imtype) double * outlons "double[]"

%typemap(csin) double * outlats "outlats"
%typemap(cstype) double * outlats "double[]"
%typemap(imtype) double * outlats "double[]"

%typemap(csin) double * inlats "inlats"
%typemap(cstype) double * inlats "double[]"
%typemap(imtype) double * inlats "double[]"

%typemap(csin) double * inlons "inlons"
%typemap(cstype) double * inlons "double[]"
%typemap(imtype) double * inlons "double[]"

%typemap(csin) double * distances "distances"
%typemap(cstype) double * distances "double[]"
%typemap(imtype) double * distances "double[]"

%typemap(csin) int * indexes "indexes"
%typemap(cstype) int * indexes "int[]"
%typemap(imtype) int * indexes "int[]"

%typemap(csin) void **, const void ** "out $csinput"
%typemap(cstype) void **, const void ** "out System.IntPtr"
%typemap(imtype) void **, const void ** "out System.IntPtr"

%typemap(csin) char * mesg "mesg"
%typemap(imtype) char * mesg "System.Text.StringBuilder"
%typemap(cstype) char * mesg "System.Text.StringBuilder"

%typemap(csin) const char * mesg "mesg"
%typemap(imtype) const char * mesg "string"
%typemap(cstype) const char * mesg "string"

%typemap(imtype) grib_get_native_type "out int"
%typemap(cstype) grib_get_native_type "out int"
%typemap(csin) grib_get_native_type "out type"

%typemap(cstype, out="int") int grib_iterator_next, int grib_keys_iterator_next, int grib_is_defined "int"
%typemap(csout, excode=SWIGEXCODE) int grib_iterator_next, int grib_keys_iterator_next {
    return $imcall;$excode
}

%typemap(csvarin) int grid_type, int truncateLaplacian %{
	set
	{
		$imcall;$excode
	} %}
%typemap(csvarout, out="int", excode=SWIGEXCODE2) int grid_type, int truncateLaplacian %{
	get
	{
		return $imcall;$excode
	} %}
%typemap(cstype, out="int") int grid_type, int truncateLaplacian "int $ccall"

%typemap(cstype, out="void") int "int"
%typemap(csout, excode=SWIGEXCODE) int {
    int ret = $imcall;$excode
	
	if (ret != 0)
	{
		throw Grib.Api.GribApiException.Create(ret);
	}
  }
  
%typemap(cstype, out="bool") int grib_is_missing, int grib_is_defined "bool"
%typemap(csout, excode=SWIGEXCODE) int grib_is_missing  {
    int ret = $imcall;$excode
	
	if (err != 0)
	{
		throw Grib.Api.GribApiException.Create(ret);
	}
	
	return ret == 1;
  }
%typemap(csout, excode=SWIGEXCODE) int grib_is_defined  {
    int ret = $imcall;$excode

	return ret == 1;
  }

%typemap(imtype,         inattributes="[global::System.Runtime.InteropServices.MarshalAs(global::System.Runtime.InteropServices.UnmanagedType.LPStr)]",
         outattributes="[return: global::System.Runtime.InteropServices.MarshalAs(global::System.Runtime.InteropServices.UnmanagedType.LPStr)]") char * "string"

		 
%ignore grib_values;
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
		 
%rename("%(lowercamelcase)s", %$isvariable) "";
%rename("%(camelcase)s", %$isclass) "";
%rename("%(camelcase)s", %$isaccess) "";
%rename("%(camelcase)s", %$classname) "";
%rename("%(camelcase)s", %$ismemberget) "";
%rename("%(camelcase)s", %$ismemberset) "";
%rename("%(camelcase)s", %$isfunction) "";
%rename("%(camelcase)s", %$isenum) "";
%rename("%(camelcase)s", %$isenumitem) "";
//%rename("%(camelcase)s", %$isproperty) "";

%include "grib_api.h"
%{

#include <windows.h>
#include <assert.h>
#include <io.h>
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

SWIGEXPORT FileHandleProxy* __stdcall CreateFileHandleProxy(char * fn, int access, int mode)
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
}
%}
