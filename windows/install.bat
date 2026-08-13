@echo off
REM Rasa OS Windows installer (double-click, run as administrator).
REM Installs into %LOCALAPPDATA%\RasaOS and registers it on the user PATH.
REM Works from the project folder (after `cargo build --release`) or from a
REM release zip (rasa.exe + etc\ + share\rasa\ next to this batch file).
setlocal
set BASE=%LOCALAPPDATA%\RasaOS
set BIN=%BASE%\rasa.exe

echo.
echo === Rasa OS Windows installer ===
echo.

REM Where the installer files live (same folder as this .bat).
set HERE=%~dp0

REM Prefer a release zip layout (rasa.exe beside install.bat), else the
REM freshly built binary in target\release.
if exist "%HERE%rasa.exe" (
  set SRC_EXE=%HERE%rasa.exe
) else (
  set SRC_EXE=%HERE%..\..\target\release\rasa.exe
)

if not exist "%SRC_EXE%" (
  echo [!] rasa.exe not found.
  echo     Either run this from a release zip, or build it first:
  echo         cargo build --release
  echo.
  pause
  exit /b 1
)

echo Installing rasa.exe + bundled etc to %BASE%

if not exist "%BASE%" mkdir "%BASE%"
copy /Y "%SRC_EXE%" "%BIN%" >nul

REM Bundled etc configs. Flat layout: rasa.exe + etc\ (or share\rasa\etc\).
if not exist "%BASE%\etc" (
  if exist "%HERE%etc" (
    Robocopy "%HERE%etc" "%BASE%\etc" /E >nul
  ) else if exist "%HERE%share\rasa\etc" (
    Robocopy "%HERE%share\rasa\etc" "%BASE%\etc" /E >nul
  ) else if exist "%HERE%..\..\etc" (
    Robocopy "%HERE%..\..\etc" "%BASE%\etc" /E >nul
  )
)

REM Register on PATH (per-user).
set PATHKEY=HKCU\Environment
set OLDPATH=
for /f "tokens=2*" %%A in ('reg query "%PATHKEY%" /v Path 2^>nul') do set OLDPATH=%%B
if "%OLDPATH%"=="" set OLDPATH=%PATH%

echo "%OLDPATH%" | findstr /C:"%BASE%" >nul 2>nul
if errorlevel 1 (
  reg add "%PATHKEY%" /v Path /t REG_EXPAND_SZ /d "%OLDPATH%;%BASE%" /f >nul
  echo [PATH updated - new terminals will see 'rasa']
) else (
  echo [PATH already set]
)

echo.
echo Installed. Close this window and open a new CMD, then run:  rasa os
pause
endlocal