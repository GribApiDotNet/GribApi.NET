:: build_nuget.cmd [x.x.x] [Release|Debug]

SET _VERSION=%1
SET _CONFIG=%2
if "%1"=="" SET _VERSION=0.0.0-beta
if "%2"=="" SET _CONFIG=Release

xcopy %~dp0..\bin\x64\%_CONFIG%\Grib.Api.dll %~dp0..\nuget.package\lib\net40\ /S /Y /I /Q
xcopy %~dp0..\bin\x64\%_CONFIG%\Grib.Api.pdb %~dp0..\nuget.package\lib\net40\ /S /Y /I /Q
xcopy %~dp0..\bin\x64\%_CONFIG%\Grib.Api.xml %~dp0..\nuget.package\lib\net40\ /S /Y /I /Q
xcopy %~dp0..\bin\x64\%_CONFIG%\Grib.Api\lib\win\x64\Grib.Api.Native.dll %~dp0..\nuget.package\Grib.Api\lib\win\x64\ /S /Y /I /Q
xcopy %~dp0..\bin\x64\%_CONFIG%\Grib.Api\lib\win\x64\Grib.Api.Native.pdb %~dp0..\nuget.package\Grib.Api\lib\win\x64\ /S /Y /I /Q

xcopy %~dp0..\bin\x86\%_CONFIG%\Grib.Api.dll %~dp0..\nuget.package\lib\net40\ /S /Y /I /Q
xcopy %~dp0..\bin\x86\%_CONFIG%\Grib.Api.pdb %~dp0..\nuget.package\lib\net40\ /S /Y /I /Q
xcopy %~dp0..\bin\x86\%_CONFIG%\Grib.Api.xml %~dp0..\nuget.package\lib\net40\ /S /Y /I /Q
xcopy %~dp0..\bin\x86\%_CONFIG%\Grib.Api\lib\win\x86\Grib.Api.Native.dll %~dp0..\nuget.package\Grib.Api\lib\win\x86\ /S /Y /I /Q
xcopy %~dp0..\bin\x86\%_CONFIG%\Grib.Api\lib\win\x86\Grib.Api.Native.pdb %~dp0..\nuget.package\Grib.Api\lib\win\x86\ /S /Y /I /Q

xcopy %~dp0..\ext\grib_api\definitions %~dp0..\nuget.package\Grib.Api\definitions\ /S /d /I /Q

xcopy %~dp0..\ext\grib_api\samples %~dp0..\nuget.package\Grib.Api\samples\ /S /d /I /Q

pushd %~dp0..\nuget.package
nuget pack Grib.Api.nuspec -Version %_VERSION%
popd