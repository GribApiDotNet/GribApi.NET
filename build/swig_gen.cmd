swig -csharp -c++ -dllimport Grib.Api.Native.dll -o Grib_Api_Native.cpp -namespace Grib.Api.Interop.SWIG -outdir %~dp0..\src\GribApi.NET\Grib.Api\Interop\SWIG -DSWIG_CSHARP_NO_IMCLASS_STATIC_CONSTRUCTOR -I%~dp0..\ext\grib_api\src grib_api.i

if %errorlevel% neq 0 exit /b %errorlevel%

move %~dp0Grib_Api_Native.cpp %~dp0..\src\GribApi.NET\Grib.Api.Native\Grib_Api_Native.cpp

powershell -ExecutionPolicy Unrestricted -File %~dp0fix_int.ps1

