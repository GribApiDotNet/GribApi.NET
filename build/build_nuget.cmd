:: build_nuget.cmd [x.x.x] [Release|Debug]

SET _VERSION=%1
SET _CONFIG=%2
if "%1"=="" SET _VERSION=0.0.0-beta
if "%2"=="" SET _CONFIG=Release

xcopy %~dp0..\bin\x64\%_CONFIG%\Grib.Api.dll %~dp0..\nuget.package\lib\net45\ /S /Y /I /Q
::xcopy %~dp0..\bin\x64\%_CONFIG%\Grib.Api.pdb %~dp0..\nuget.package\lib\net45\ /S /Y /I /Q
xcopy %~dp0..\bin\x64\%_CONFIG%\Grib.Api.xml %~dp0..\nuget.package\lib\net45\ /S /Y /I /Q
xcopy %~dp0..\bin\x64\%_CONFIG%\Grib.Api %~dp0..\nuget.package\Grib.Api\ /S /Y /I /Q

pushd %~dp0..\nuget.package
nuget pack Grib.Api.nuspec -Version %_VERSION%
popd