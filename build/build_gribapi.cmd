@ECHO OFF

REM Sample usages:
REM
REM  Building and running tests
REM  - build_gribapi.cmd [rebuild] [tools version] [package version]
REM 

SET REBUILD=/t:Build 
if "%1"=="rebuild" SET REBUILD=/t:Clean,Build 

SET VisualStudioVersion=%2
if "%2"=="" (
	SET VisualStudioVersion=11
)

SET PKG_VERSION=%3

SET ERRORLEVEL=0

::SETLOCAL

SET TV=/property:PlatformToolset=V%VisualStudioVersion%0

SET PATH=C:\Program Files (x86)\NUnit 2.6.4\bin;%PATH%

SET BASEDIR=%~dp0..\
SET FrameworkVersion=v4.0.30319
SET FrameworkDir="%SystemRoot%\Microsoft.NET\Framework"
SET CRT="C:\Program Files\MSBuild\Microsoft.Cpp\v4.0\V%VisualStudioVersion%0/"

if exist "C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\V%VisualStudioVersion%0" (
  SET CRT="C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\V%VisualStudioVersion%0/"
)

if exist "%SystemRoot%\Microsoft.NET\Framework64" (
  SET FrameworkDir="%SystemRoot%\Microsoft.NET\Framework64"
)

taskkill /f /t /im nunit-agent.exe /fi "memusage gt 2"
taskkill /f /t /im nunit-agent-x86.exe /fi "memusage gt 2"

@ECHO ON

:::::::::: X64 NATIVE

SET _OUT=/p:OutputPath="..\..\..\bin\x64\Release\"
::C:\Users\ericmillin\Projects\GribApi.NET\ext\lpng1618\projects\vstudio

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%ext/lpng1618\projects\vstudio\zlib\zlib.vcxproj"  /property:Configuration="Release" /property:Platform="x64" /property:ExtraDefine="%ExtraDefine%"  %TV% /property:VCTargetsPath=%CRT% %REBUILD%

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%ext/lpng1618\projects\vstudio\libpng\libpng.vcxproj"  /property:Configuration="Release" /property:Platform="x64" /property:ExtraDefine="%ExtraDefine%"  %TV% /property:VCTargetsPath=%CRT% %REBUILD%

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%ext/jasper-1.900.1/src/msvc\libjasper.vcxproj"  /property:Configuration="Release" /property:Platform="x64" /property:ExtraDefine="%ExtraDefine%"  %TV% /property:VCTargetsPath=%CRT% %REBUILD%

@ECHO OFF
set BUILD_STATUS=%ERRORLEVEL%
if %BUILD_STATUS% neq 0 (
	goto :fail
)
@ECHO ON

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%ext/grib_api-1.14.0-Source/windows/msvc/grib_api_lib/grib_api_lib.vcxproj"  /property:Configuration="Release" /property:Platform="x64" /property:ExtraDefine="%ExtraDefine%" %TV% /property:VCTargetsPath=%CRT% %REBUILD%

@ECHO OFF
set BUILD_STATUS=%ERRORLEVEL%
if %BUILD_STATUS% neq 0 (
	goto :fail
)
@ECHO ON

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%src\GribApi.NET\Grib.Api.Native\Grib.Api.Native.vcxproj"  /property:Configuration="Release" /property:Platform="x64" /property:ExtraDefine="%ExtraDefine%"  %TV% /property:VCTargetsPath=%CRT% /t:Clean,Build 

@ECHO OFF
set BUILD_STATUS=%ERRORLEVEL%
if %BUILD_STATUS% neq 0 (
	goto :fail
)
@ECHO ON

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%src\GribApi.NET\Grib.Api\Grib.Api.csproj"  /property:Configuration="Release" /property:Platform="AnyCPU" /property:ExtraDefine="%ExtraDefine%" /tv:4.0 %REBUILD% /p:NoWarn="1591" /nowarn:1591

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%src\GribApi.NET\Grib.Api.Tests\Grib.Api.Tests.csproj"  /property:Configuration="Release" /property:Platform="x64" /property:ExtraDefine="%ExtraDefine%" /tv:4.0 %REBUILD% 

@ECHO OFF
set BUILD_STATUS=%ERRORLEVEL%
if %BUILD_STATUS% neq 0 (
	goto :fail
)

:::::::::: X86 NATIVE

SET _OUT=/p:OutputPath="..\..\..\bin\x86\Release\"
@ECHO ON


"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%ext\lpng1618\projects\vstudio\zlib\zlib.vcxproj"  /property:Configuration="Release" /property:Platform="x86" /property:ExtraDefine="%ExtraDefine%"  %TV% /property:VCTargetsPath=%CRT% %REBUILD%

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%ext\lpng1618\projects\vstudio\libpng\libpng.vcxproj"  /property:Configuration="Release" /property:Platform="x86" /property:ExtraDefine="%ExtraDefine%"  %TV% /property:VCTargetsPath=%CRT% %REBUILD%

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%ext/jasper-1.900.1/src/msvc\libjasper.vcxproj"  /property:Configuration="Release" /property:Platform="x86" /property:ExtraDefine="%ExtraDefine%" %TV% /property:VCTargetsPath=%CRT% %REBUILD%

@ECHO OFF
set BUILD_STATUS=%ERRORLEVEL%
if %BUILD_STATUS% neq 0 (
	goto :fail
)
@ECHO ON 

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%ext/grib_api-1.14.0-Source/windows/msvc/grib_api_lib/grib_api_lib.vcxproj"  /property:Configuration="Release" /property:Platform="Win32" /property:ExtraDefine="%ExtraDefine%" %TV% /property:VCTargetsPath=%CRT% %REBUILD%

@ECHO OFF
set BUILD_STATUS=%ERRORLEVEL%
if %BUILD_STATUS% neq 0 (
	goto :fail
)
@ECHO ON

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%src\GribApi.NET\Grib.Api.Native\Grib.Api.Native.vcxproj"  /property:Configuration="Release" /property:Platform="Win32" /property:ExtraDefine="%ExtraDefine%"  %TV% /property:VCTargetsPath=%CRT% /t:Clean,Build 

@ECHO OFF
set BUILD_STATUS=%ERRORLEVEL%
if %BUILD_STATUS% neq 0 (
	goto :fail
)
@ECHO ON

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%src\GribApi.NET\Grib.Api.Tests\Grib.Api.Tests.csproj"  /property:Configuration="Release" /property:Platform="x86" /property:ExtraDefine="%ExtraDefine%" /tv:4.0 %REBUILD%  

@ECHO OFF
set BUILD_STATUS=%ERRORLEVEL%
if %BUILD_STATUS% neq 0 (
	goto :fail
)
@ECHO ON

:::::::::: ANYCPU

:: Copy the AnyCPU build to the x86 dir for testing
xcopy "%BASEDIR%bin\x64\Release\Grib.Api.dll" "%BASEDIR%bin\x86\Release\Grib.Api.dll"  /S /Y /I /Q
xcopy "%BASEDIR%bin\x64\Release\Grib.Api.xml" "%BASEDIR%bin\x86\Release\Grib.Api.xml"  /S /Y /I /Q
xcopy "%BASEDIR%bin\x64\Release\Grib.Api.pdb" "%BASEDIR%bin\x86\Release\Grib.Api.pdb"  /S /Y /I /Q

@ECHO OFF
set BUILD_STATUS=%ERRORLEVEL%
if %BUILD_STATUS% neq 0 (
	goto :fail
)
@ECHO ON

::ENDLOCAL

call build_nuget.cmd %PKG_VERSION%

call run_tests.cmd x64 Release
call run_tests.cmd x86 Release

goto end

:fail
SET ERRORLEVEL=1

:end
IF %ERRORLEVEL%==0 (
	echo Build success.
)
EXIT /B %ERRORLEVEL%
