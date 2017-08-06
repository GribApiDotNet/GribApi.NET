@ECHO OFF

REM Sample usages:
REM
REM  Building and running tests
REM  - build_gribapi.cmd [rebuild] [tools version] [Debug|Release] [package version]
REM 

SET REBUILD=/t:Build 
if "%1"=="rebuild" SET REBUILD=/t:Clean,Build 

SET VisualStudioVersion=%2
if "%2"=="" (
	SET VisualStudioVersion=11
)

SET CONFIG=%3
if "%3"=="" (
	SET CONFIG=Release
)

SET PKG_VERSION=%4

SET ERRORLEVEL=0

::SETLOCAL

SET TV=/property:PlatformToolset=V%VisualStudioVersion%0

SET PATH=C:\Program Files (x86)\NUnit 2.6.4\bin;%PATH%
::SET PATH=C:\Program Files (x86)\NUnit 2.6.4\bin;C:\Program Files (x86)\Microsoft Visual Studio %VisualStudioVersion%.0\VC\bin;%PATH%
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

::Setlocal EnableDelayedExpansion

@ECHO ON

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%src\GribApi.NET\Grib.Api\Grib.Api.csproj"  /property:Configuration="%CONFIG%" /property:Platform="AnyCPU" /tv:4.0 %REBUILD% /p:NoWarn="1591"

@ECHO OFF
if ERRORLEVEL 1 (
	@ECHO ON
	ECHO BUILD FAILED
	EXIT /B 1
)

:::::::::: X64 TEST

@ECHO ON

"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%src\GribApi.NET\Grib.Api.Tests\Grib.Api.Tests.csproj"  /property:Configuration="%CONFIG%" /property:Platform="x64" /tv:4.0 %REBUILD% /p:NoWarn="1591"

@ECHO OFF
if ERRORLEVEL 1 (
	@ECHO ON
	ECHO BUILD FAILED
	EXIT /B 1
)


:::::::::: X86 TEST

@ECHO ON


"%FrameworkDir%\%FrameworkVersion%\msbuild.exe" "%BASEDIR%src\GribApi.NET\Grib.Api.Tests\Grib.Api.Tests.csproj"  /property:Configuration="%CONFIG%" /property:Platform="x86" /tv:4.0 %REBUILD% /p:NoWarn="1591"

@ECHO OFF
if ERRORLEVEL 1 (
	@ECHO ON
	ECHO BUILD FAILED
	EXIT /B 1
)

::ENDLOCAL
@ECHO ON

:: Copy the AnyCPU build to the x86 dir for testing
xcopy "%BASEDIR%bin\x64\%CONFIG%\Grib.Api.dll" "%BASEDIR%bin\x86\%CONFIG%\Grib.Api.dll"  /S /Y /I /Q
xcopy "%BASEDIR%bin\x64\%CONFIG%\Grib.Api.xml" "%BASEDIR%bin\x86\%CONFIG%\Grib.Api.xml"  /S /Y /I /Q
xcopy "%BASEDIR%bin\x64\%CONFIG%\Grib.Api.pdb" "%BASEDIR%bin\x86\%CONFIG%\Grib.Api.pdb"  /S /Y /I /Q
xcopy "%BASEDIR%bin\x64\%CONFIG%\Grib.Api" "%BASEDIR%bin\x86\%CONFIG%\Grib.Api"  /S /Y /I /Q

@ECHO OFF
if ERRORLEVEL 1 (
	@ECHO ON
	ECHO COPY FAILED
	EXIT /B 1
)
@ECHO ON
	
call %~dp0run_tests.cmd x64 %CONFIG%
@ECHO OFF
if ERRORLEVEL 1 (
	@ECHO ON
	ECHO TEST FAILED
	EXIT /B 1
)
@ECHO ON

call %~dp0run_tests.cmd x86 %CONFIG%
@ECHO OFF
if ERRORLEVEL 1 (
	@ECHO ON
	ECHO TEST FAILED
	EXIT /B 1
)

if NOT "%PKG_VERSION%"=="" (
	@ECHO ON
	call %~dp0build_nuget.cmd %PKG_VERSION% %CONFIG%
	@ECHO OFF
	if ERRORLEVEL 1 (
		ECHO PACKAGE FAILED
		EXIT /B 1
	)
)

@ECHO ON
@ECHO Build success.
EXIT /B 0



