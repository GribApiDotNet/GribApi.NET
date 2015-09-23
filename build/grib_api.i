%module GribApiProxy

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

%typemap(imtype, out="System.UIntPtr") off_t, size_t "System.UIntPtr"
%typemap(csin) off_t, size_t "$csinput.Value"
%typemap(imtype, out="System.UIntPtr") off_t*, size_t * "ref System.UIntPtr"
%typemap(csin) off_t*, size_t * "ref  $csinput.Value"
%typemap(cstype) off_t, size_t, off_t*, size_t * "SizeT"
%typemap(csvarout, out="SizeT", excode=SWIGEXCODE2) off_t, size_t, off_t*, size_t * %{
	get {
		System.UIntPtr val = $imcall;$excode
		return new SizeT(val);
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

%typemap(csin) long * vals, long * values, int * indexes "$csinput"
%typemap(cstype) long * vals, long * values, int * indexes "int[]"
%typemap(imtype) long * vals, long * values, int * indexes "int[]"

%typemap(csin) double * data_values, double * vals, double * values, double * latitudes, double * longitudes, double * lats, double * lons, double * outlats, double * outlons, double * inlats, double * inlons, double * distances "$csinput"
%typemap(cstype) double * data_values, double * vals, double * values, double * latitudes, double * longitudes, double * lats, double * lons, double * outlats, double * outlons, double * inlats, double * inlons, double * distances "double[]"
%typemap(imtype) double * data_values, double * vals, double * values, double * latitudes, double * longitudes, double * lats, double * lons, double * outlats, double * outlons, double * inlats, double * inlons, double * distances "double[]"

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

%typemap(imtype, inattributes="[global::System.Runtime.InteropServices.MarshalAs(global::System.Runtime.InteropServices.UnmanagedType.LPStr)]",
         outattributes="[return: global::System.Runtime.InteropServices.MarshalAs(global::System.Runtime.InteropServices.UnmanagedType.LPStr)]") char * "string"

%include "grib_api_native.i"
