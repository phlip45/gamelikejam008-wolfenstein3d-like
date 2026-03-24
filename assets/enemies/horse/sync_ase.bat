@echo off
setlocal

REM ---- SET ASEPRITE PATH ----
set ASEPRITE=C:\Program Files (x86)\Steam\steamapps\common\Aseprite\Aseprite.exe

cd /d %~dp0

echo.
set /p MASTER=Enter master .ase filename (example: idle.ase): 

if not exist "%MASTER%" (
    echo File not found.
    pause
    exit /b
)

REM ---- write temp file ----
>master_temp.txt echo %MASTER%

for %%F in (*.ase) do (
    if /I not "%%F"=="%MASTER%" (
        >>master_temp.txt echo %%F
    )
)

echo.
echo Master: %MASTER%
echo Targets written to temp file.
echo.

"%ASEPRITE%" -b -script apply_timings.lua

echo.
echo Done.
pause