@echo off
setlocal

set "VCVARS=%ProgramFiles(x86)%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
set "CACHE=%~dp0msvc_env_x64_cached.cmd"

if /I "%~1"=="--refresh" set "REFRESH=1" & shift

if not defined REFRESH if defined VSCMD_VER if /I "%VSCMD_ARG_TGT_ARCH%"=="x64" goto :have_env
if not defined REFRESH if defined VCINSTALLDIR goto :have_env

if not defined REFRESH if exist "%CACHE%" if exist "%VCVARS%" (
  for %%F in ("%VCVARS%") do set "VCSTAMP=%%~tF"
  for %%F in ("%CACHE%")  do set "CACSTAMP=%%~tF"
  REM If cache is newer or same timestamp, use it.
  if /I "%CACSTAMP%" GEQ "%VCSTAMP%" goto :use_cache
)

if not exist "%VCVARS%" (
  echo [raddbg] vcvars64.bat not found at:
  echo   %VCVARS%
  echo Edit VCVARS path in this script.
  exit /b 1
)

echo [raddbg] Initializing MSVC env (one-time)...
call "%VCVARS%"
(
  echo @echo off
  echo REM Auto-generated from "%VCVARS%"
  for %%V in (
    PATH INCLUDE LIB LIBPATH
    VCINSTALLDIR VSINSTALLDIR
    VCToolsInstallDir VCToolsVersion
    WindowsSdkDir WindowsSDKLibVersion WindowsSdkBinPath WindowsSdkVerBinPath
    UniversalCRTSdkDir UCRTVersion
    VSCMD_VER VSCMD_ARG_TGT_ARCH
  ) do (
    for /f "tokens=1* delims==" %%a in ('set %%V 2^>nul') do @echo set "%%a=%%b"
  )
) > "%CACHE%"
goto :have_env

:use_cache
call "%CACHE%"

:have_env
"raddbg.exe" %*
exit /b 0
endlocal


