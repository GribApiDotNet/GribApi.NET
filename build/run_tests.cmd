:: run_tests.cmd x86|x64 Debug|Release
@echo off
set CONSOLE=nunit-console
if "%1"=="x86" %CONSOLE%=nunit-console-x86
taskkill /f /t /im nunit-agent.exe /fi "memusage gt 2"
@echo on
xcopy %~dp0..\ext\grib_api-1.14.0-Source\definitions %~dp0..\bin\%1\%2\definitions /S /Y /I /Q
nunit-console /noshadow %~dp0..\bin\%1\%2\Grib.Api.Tests.dll