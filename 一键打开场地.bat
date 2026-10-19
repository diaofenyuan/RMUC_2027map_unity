@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "PROJ=%ROOT%\Project"
set "WANT=2022.3.62f1"
set "UNITY="

echo.
echo ============================================================
echo    RMUC2027 Field Model  /  One-click Unity launch
echo ============================================================
echo.

if not exist "%PROJ%\Assets\Rmvf\Scenes\U1Field.unity" goto :no_project

rem 1) Environment override, for machines with several editors installed.
if defined RMVF_UNITY_EXE if exist "!RMVF_UNITY_EXE!" set "UNITY=!RMVF_UNITY_EXE!"
if defined UNITY goto :launch

rem 2) unity_path.txt next to this file, first line only.
if exist "%ROOT%\unity_path.txt" call :probe_file
if defined UNITY goto :launch

rem 3) Standard Unity Hub locations.
call :probe "%ProgramFiles%\Unity\Hub\Editor\%WANT%\Editor\Unity.exe"
if defined UNITY goto :launch
call :probe "%ProgramFiles(x86)%\Unity\Hub\Editor\%WANT%\Editor\Unity.exe"
if defined UNITY goto :launch
call :probe "%ProgramFiles%\Unity\Hub\Editor\%WANT%\Unity.exe"
if defined UNITY goto :launch

rem 4) Known non-standard location.
call :probe "D:\unity2\%WANT%\Editor\Unity.exe"
if defined UNITY goto :launch

rem 5) Any other Hub version, as a last resort.
if exist "%ProgramFiles%\Unity\Hub\Editor" for /d %%D in ("%ProgramFiles%\Unity\Hub\Editor\*") do if not defined UNITY call :probe "%%D\Editor\Unity.exe"
if defined UNITY goto :launch
if exist "%ProgramFiles(x86)%\Unity\Hub\Editor" for /d %%D in ("%ProgramFiles(x86)%\Unity\Hub\Editor\*") do if not defined UNITY call :probe "%%D\Editor\Unity.exe"
if defined UNITY goto :launch

goto :no_unity

:launch
set "CHK=!UNITY!"
if "!CHK:%WANT%=!"=="!CHK!" echo [WARN] Editor is not %WANT%; Unity will upgrade this project on first open.
echo [OK] Editor  : !UNITY!
echo [OK] Project : %PROJ%
echo.
echo Launching Unity Editor. The first open imports a 7.07M-triangle field mesh,
echo usually taking several minutes and a few GB in Library.
echo The field scene opens automatically once import finishes. If it does not,
echo open Assets/Rmvf/Scenes/U1Field.unity from the Project panel.
echo.
start "" "!UNITY!" -projectPath "%PROJ%"
exit /b 0

:probe
if "%~1"=="" goto :eof
if not exist "%~1" goto :eof
set "UNITY=%~1"
goto :eof

:probe_file
for /f "usebackq delims=" %%L in ("%ROOT%\unity_path.txt") do if not defined UNITY call :probe "%%L"
goto :eof

:no_project
echo [ERROR] Project files are missing. Clone the repository completely first,
echo         including Git LFS objects.
echo         Expected: %PROJ%\Assets\Rmvf\Scenes\U1Field.unity
echo.
pause
exit /b 1

:no_unity
echo [ERROR] Unity Editor was not found.
echo.
echo Do ONE of the following:
echo   1. Install Unity %WANT%
echo   2. Create unity_path.txt next to this file and put the full path of
echo      Unity.exe on its first line
echo   3. Set the environment variable RMVF_UNITY_EXE to Unity.exe
echo.
echo Default path: C:\Program Files\Unity\Hub\Editor\%WANT%\Editor\Unity.exe
echo.
pause
exit /b 2
