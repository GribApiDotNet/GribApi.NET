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

%module GribApiProxy

#define SWIG_CSHARP_NO_IMCLASS_STATIC_CONSTRUCTOR

%rename("%(strip:[grib])s") ""; 
%rename("%(strip:[Grib])s") ""; 
%rename("%(lowercamelcase)s", %$isvariable) "";
%rename("%(camelcase)s", %$isclass) "";
%rename("%(camelcase)s", %$isaccess) "";
%rename("%(camelcase)s", %$classname) "";
%rename("%(camelcase)s", %$ismemberget) "";
%rename("%(camelcase)s", %$ismemberset) "";
%rename("%(camelcase)s", %$isfunction) "";
%rename("%(camelcase)s", %$isenum) "";
%rename("%(camelcase)s", %$isenumitem) "";

%typemap(imtype, out="System.IntPtr") FILE*, grib_handle*, grib_context* , grib_keys_iterator*, grib_iterator* "System.Runtime.InteropServices.HandleRef"
%typemap(csin) FILE*, grib_handle*, grib_context*, grib_keys_iterator*, grib_iterator* "$csinput.Reference"
%typemap(cstype) FILE* "GribFile"
%typemap(csout, out="GribFile", excode=SWIGEXCODE) FILE* %{
		System.IntPtr pVal = $imcall;$excode

		return pVal == System.IntPtr.Zero ? null : new GribFile(pVal);
 %}
 
  %typemap(cstype) grib_iterator* "GribValuesIterator"
 %typemap(cstype) grib_context* "GribContext"
 %typemap(cstype) grib_handle* "GribHandle"
  %typemap(cstype) grib_keys_iterator* "GribKeysIterator"

 %typemap(csvarout, out="GribContext", excode=SWIGEXCODE2) grib_context* %{
	get {
		System.IntPtr pVal = $imcall;$excode

		return pVal == System.IntPtr.Zero ? null : new GribContext(pVal);
	} %}
 %typemap(csout, out="GribContext", excode=SWIGEXCODE) grib_context* %{{
		System.IntPtr pVal = $imcall;$excode

		return pVal == System.IntPtr.Zero ? null : new GribContext(pVal);
	}%}
 
 %typemap(csvarout, out="GribHandle", excode=SWIGEXCODE2) grib_handle* %{
	get {
		System.IntPtr pVal = $imcall;$excode

		return pVal == System.IntPtr.Zero ? null : new GribHandle(pVal);
	} %}
%typemap(csout, out="GribHandle", excode=SWIGEXCODE) grib_handle* %{{
		System.IntPtr pVal = $imcall;$excode

		return pVal == System.IntPtr.Zero ? null : new GribHandle(pVal);
	}%}
	
	 %typemap(csvarout, out="GribKeysIterator", excode=SWIGEXCODE2) grib_keys_iterator* %{
	get {
		System.IntPtr pVal = $imcall;$excode

		return pVal == System.IntPtr.Zero ? null : new GribKeysIterator(pVal);
	} %}
%typemap(csout, out="GribKeysIterator", excode=SWIGEXCODE) grib_keys_iterator* %{{
		System.IntPtr pVal = $imcall;$excode

		return pVal == System.IntPtr.Zero ? null : new GribKeysIterator(pVal);
	}%}
	
%typemap(csvarout, out="GribValuesIterator", excode=SWIGEXCODE2) grib_iterator* %{
	get {
		System.IntPtr pVal = $imcall;$excode

		return pVal == System.IntPtr.Zero ? null : new GribValuesIterator(pVal);
	} %}
%typemap(csout, out="GribValuesIterator", excode=SWIGEXCODE) grib_iterator* %{{
		System.IntPtr pVal = $imcall;$excode

		return pVal == System.IntPtr.Zero ? null : new GribValuesIterator(pVal);
	}%}


%typemap(imtype, out="System.UIntPtr") off_t, size_t "System.UIntPtr"
%typemap(csin) off_t, size_t "$csinput.Value"
%typemap(cstype) off_t, size_t "SizeT"
%typemap(imtype, out="System.IntPtr") off_t*, size_t * "ref System.UIntPtr"
//%typemap(imout, out="System.UIntPtr") off_t*, size_t * "System.UIntPtr"
%typemap(csin) off_t*, size_t * "ref  $csinput.Value"
%typemap(cstype, out="SizeT") off_t*, size_t * "ref SizeT"
%typemap(csout, out="SizeT", excode=SWIGEXCODE) off_t*, size_t * %{
		System.IntPtr pVal = $imcall;$excode
		
		// dereference the pointer
		System.UIntPtr val = (System.UIntPtr)System.Runtime.InteropServices.Marshal.PtrToStructure(pVal, typeof(System.UIntPtr));
		
		return (SizeT)val;
 %}
%typemap(csvarout, out="SizeT", excode=SWIGEXCODE2) off_t*, size_t * %{
	get {
		System.IntPtr pVal = $imcall;$excode
		
		// dereference the pointer
		System.UIntPtr val = (System.UIntPtr)System.Runtime.InteropServices.Marshal.PtrToStructure(pVal, typeof(System.UIntPtr));
		
		return (SizeT)val;
	} %}
%typemap(csvarout, out="SizeT", excode=SWIGEXCODE2) off_t, size_t %{
	get {
		System.UIntPtr val = $imcall;$excode
		
		return (SizeT)val;
	} %}

%typemap(imtype) long * v, int * n, int * type, long * value, int * err, int * error "out int"
%typemap(cstype) long * v, int * n, int * type, long * value, int * err, int * error "out int"
%typemap(csin) long * v, int * n, int * type, long * value, int * err, int * error "out $csinput"

%typemap(imtype) double * v, double * value, double * val, double * lat, double * lon "out double"
%typemap(cstype) double * v, double * value, double * val, double * lat, double * lon "out double"
%typemap(csin) double * v, double * value, double * val, double * lat, double * lon "out $csinput"

%typemap(imtype) float * value "out float"
%typemap(cstype) float * value "out float"
%typemap(csin) float * value "out $csinput"

%typemap(csin) long * vals, long * values, int * indexes, long * pl "$csinput"
%typemap(cstype) long * vals, long * values, int * indexes, long * pl "int[]"
%typemap(imtype) long * vals, long * values, int * indexes, long * pl "int[]"

%typemap(csin) double * data_values, double * vals, double * values, double * latitudes, double * longitudes, double * lats, double * lons, double * outlats, double * outlons, double * inlats, double * inlons, double * distances "$csinput"
%typemap(cstype) double * data_values, double * vals, double * values, double * latitudes, double * longitudes, double * lats, double * lons, double * outlats, double * outlons, double * inlats, double * inlons, double * distances "double[]"
%typemap(imtype) double * data_values, double * vals, double * values, double * latitudes, double * longitudes, double * lats, double * lons, double * outlats, double * outlons, double * inlats, double * inlons, double * distances "double[]"

// GribPoints
%typemap(csvarout, out="double[]", excode=SWIGEXCODE2) double * latitudes, double * longitudes %{
	get {
	    var p = $imcall;$excode
        double[] d = new double[this.n];
        Marshal.Copy(p, d, 0, d.Length);

        return d;
	} %}


%typemap(csin) void*, unsigned char *, unsigned char const * "$csinput"
%typemap(cstype) void*, unsigned char *, unsigned char const * "byte[]"
%typemap(imtype) void*, unsigned char *, unsigned char const * "byte[]"
%typemap(csout, excode=SWIGEXCODE,
         outattributes="[return: global::System.Runtime.InteropServices.MarshalAs(global::System.Runtime.InteropServices.UnmanagedType.LPArray)]") void*, unsigned char *, unsigned char const *  {
    return $imcall;$excode
}

%typemap(csin) void **, const void ** "out $csinput"
%typemap(cstype) void **, const void ** "out System.IntPtr"
%typemap(imtype) void **, const void ** "out System.IntPtr"

%typemap(csin) char * v, char * mesg "$csinput"
%typemap(imtype) char * v, char * mesg "System.Text.StringBuilder"
%typemap(cstype) char * v, char * mesg "System.Text.StringBuilder"

%typemap(csin) const char * mesg "$csinput"
%typemap(imtype) const char * mesg "string"
%typemap(cstype) const char * mesg "string"

%typemap(csin) char **, const char **,  char *[] "$csinput"
%typemap(imtype) char **, const char **, char *[] "string[]"
%typemap(cstype) char **, const char **, char *[] "string[]"

%typemap(csin) char ** values "out $csinput"
%typemap(imtype) char ** values "out System.Text.StringBuilder"
%typemap(cstype) char ** values "out System.Text.StringBuilder"

%typemap(imtype) grib_get_native_type "out int"
%typemap(cstype) grib_get_native_type "out int"
%typemap(csin) grib_get_native_type "out $csinput"

%typemap(cstype, out="int") int grib_iterator_next, int grib_keys_iterator_next, int grib_is_defined "int"
%typemap(csout, excode=SWIGEXCODE) int grib_iterator_next, int grib_keys_iterator_next {
    return $imcall;$excode
}

%typemap(csvarout, out="int[]", excode=SWIGEXCODE2) long * pl %{
	get
	{
		return $imcall;$excode
	} %}

%typemap(csvarout, out="double[]", excode=SWIGEXCODE2) double * latitudes,double * longitudes %{
	get
	{
		return $imcall;$excode
	} %}

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
		throw Grib.Api.Interop.GribApiException.Create(ret);
	}
  }
  
%typemap(cstype, out="bool") int grib_is_missing, int grib_is_defined "bool"
%typemap(csout, excode=SWIGEXCODE) int grib_is_missing  {
    int ret = $imcall;$excode
	
	if (err != 0)
	{
		throw Grib.Api.Interop.GribApiException.Create(ret);
	}
	
	return ret == 1;
  }
%typemap(csout, excode=SWIGEXCODE) int grib_is_defined  {
    int ret = $imcall;$excode

	return ret == 1;
  }

%typemap(imtype, inattributes="[global::System.Runtime.InteropServices.MarshalAs(global::System.Runtime.InteropServices.UnmanagedType.LPStr)]",
         outattributes="[return: global::System.Runtime.InteropServices.MarshalAs(global::System.Runtime.InteropServices.UnmanagedType.LPStr)]") char * "string"		 
		 
%include "grib_api_native.i"
