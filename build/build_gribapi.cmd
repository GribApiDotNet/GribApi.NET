@ECHO OFF

REM Sample usages:
REM
REM  Building and running tests
REM  - build_gribapi.cmd [rebuild]
REM 

SET REBUILD=/t:Build 
if "%1"=="rebuild" SET REBUILD=/t:Clean,Build 


SET ERRORLEVEL=0

SETLOCAL

SET VisualStudioVersion=%2
if "%2"=="" SET VisualStudioVersion=%2.0

SET PATH=C:\Program Files (x86)\NUnit 2.6.4\bin;%PATH%

SET BASEDIR=%~dp0..\
SET FrameworkVersion=v4.0.30319
SET FrameworkDir="%SystemRoot%\Microsoft.NET\Framework"
SET CRT="C:\Program Files\MSBuild\Microsoft.Cpp\v4.0\V120/"

if exist "C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\V120" (
  SET CRT="C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\V120/"
)

if exist "%SystemRoot%\Microsoft.NET\Framework64" (
  SET FrameworkDir="%SystemRoot%\Microsoft.NET\Framework64"
)

ECHO ON

:::::::::: X64 NATIVE

SET _OUT=/p:OutputPath="%BASEDIR%bin\x64\Release\"

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%ext/jasper-1.900.1/src/msvc\libjasper.vcxproj"  /property:Configuration="Release" /property:Platform="x64" /property:ExtraDefine="%ExtraDefine%"  %TV%/property:VCTargetsPath=%CRT% %REBUILD%

ECHO OFF
set BUILD_STATUS=%ERRORLEVEL%
if not %BUILD_STATUS%==0 goto fail 
ECHO ON

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%ext/grib_api-1.14.0-Source/windows/msvc\grib_api.sln"  /property:Configuration="Release" /property:Platform="x64" /property:ExtraDefine="%ExtraDefine%" %TV%/property:VCTargetsPath=%CRT% %REBUILD%

ECHO OFF
set BUILD_STATUS=%ERRORLEVEL%
if not %BUILD_STATUS%==0 goto fail 
ECHO ON

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%src\GribApi.NET\Grib.Api.sln"  /property:Configuration="Release" /property:Platform="x64" /property:ExtraDefine="%ExtraDefine%"  %TV%/property:VCTargetsPath=%CRT% %REBUILD%  /t:Clean,Build 

ECHO OFF
set BUILD_STATUS=%ERRORLEVEL%
if not %BUILD_STATUS%==0 goto fail 
ECHO ON

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%src\GribApi.NET\Grib.Api.Tests\Grib.Api.Tests.csproj"  /property:Configuration="Release" /property:Platform="x64" /property:ExtraDefine="%ExtraDefine%" /tv:4.0 %REBUILD%

ECHO OFF
set BUILD_STATUS=%ERRORLEVEL%
if not %BUILD_STATUS%==0 goto fail 
ECHO ON

:::::::::: X86 NATIVE

SET _OUT=/p:OutputPath="%BASEDIR%bin\x86\Release\"

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%ext/jasper-1.900.1/src/msvc\libjasper.vcxproj"  /property:Configuration="Release" /property:Platform="x86" /property:ExtraDefine="%ExtraDefine%" %TV% /property:VCTargetsPath=%CRT% %REBUILD%

ECHO OFF
set BUILD_STATUS=%ERRORLEVEL%
if not %BUILD_STATUS%==0 goto fail 
ECHO ON 

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%ext/grib_api-1.14.0-Source/windows/msvc\grib_api.sln"  /property:Configuration="Release" /property:Platform="Win32" /property:ExtraDefine="%ExtraDefine%" %TV%/property:VCTargetsPath=%CRT% %REBUILD%

ECHO OFF
set BUILD_STATUS=%ERRORLEVEL%
if not %BUILD_STATUS%==0 goto fail 
ECHO ON

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%src\GribApi.NET\Grib.Api.Native\Grib.Api.Native.vcxproj"  /property:Configuration="Release" /property:Platform="Win32" /property:ExtraDefine="%ExtraDefine%"  %TV%/property:VCTargetsPath=%CRT% /t:Clean,Build 

ECHO OFF
set BUILD_STATUS=%ERRORLEVEL%
if not %BUILD_STATUS%==0 goto fail 
ECHO ON

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%src\GribApi.NET\Grib.Api.Tests\Grib.Api.Tests.csproj"  /property:Configuration="Release" /property:Platform="x86" /property:ExtraDefine="%ExtraDefine%" /tv:4.0 %REBUILD%

ECHO OFF
set BUILD_STATUS=%ERRORLEVEL%
if not %BUILD_STATUS%==0 goto fail 
ECHO ON

:::::::::: ANYCPU

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%src\GribApi.NET\Grib.Api\Grib.Api.csproj"  /property:Configuration="Release" /property:Platform="AnyCPU" /property:ExtraDefine="%ExtraDefine%" /tv:4.0 %REBUILD%



copy "%BASEDIR%bin\x64\Release\Grib.Api.dll" "%BASEDIR%bin\x86\Release\Grib.Api.dll"

ECHO OFF
set BUILD_STATUS=%ERRORLEVEL%
if not %BUILD_STATUS%==0 goto fail 
ECHO ON
ENDLOCAL

run_tests.cmd x64 Release
set BUILD_STATUS=%ERRORLEVEL%
if not %BUILD_STATUS%==0 goto fail

run_tests.cmd x86 Release
set BUILD_STATUS=%ERRORLEVEL%
if not %BUILD_STATUS%==0 goto fail

build_nuget.cmd
set BUILD_STATUS=%ERRORLEVEL%
if not %BUILD_STATUS%==0 goto fail

goto end

:fail
SET ERRORLEVEL=1

:end
IF %ERRORLEVEL% eq 0 echo Build success.
EXIT /B %ERRORLEVEL%
