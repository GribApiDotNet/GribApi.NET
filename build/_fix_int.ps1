$path="..\src\GribApi.NET\Grib.Api\Interop\SWIG\GribApiProxy.cs"

(Get-Content $path) | 
Foreach-Object {$_ -replace "public static readonly void GRIB", "public static readonly int GRIB"} | 
Set-Content $path