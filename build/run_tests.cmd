:: run_tests.cmd x86|x64 Debug|Release [1]
@echo off

taskkill /f /t /im nunit-agent.exe /fi "memusage gt 2"

set _CONSOLE=nunit-console
if "%1"=="x86" (set _CONSOLE=nunit-console-x86)

:: if 3rd param == 1, break on start, otherwise ignored
set _GRIB_BREAK=%3

@echo on

xcopy %~dp0..\ext\grib_api-1.14.0-Source\definitions %~dp0..\bin\%1\%2\Grib.Api\definitions /S /d /I /Q

%_CONSOLE% /noshadow %~dp0..\bin\%1\%2\Grib.Api.Tests.dll