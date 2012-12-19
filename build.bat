rem This script is used in automated build systems to build and deploy the game
rem This script depends on: git, 7zip

set build_bat_path=%0
set build_output_path=%1
set build_zip_path=UDKInstall-Factions.zip
set build_progress_path=buildprogress.txt
set build_queue_path=buildqueue.txt

rem Queue another build if already in progress

if exist %build_progress_path% (
echo Build queued at: >> %build_queue_path%
call date /t >> %build_queue_path%
call time /t >> %build_queue_path%
exit /b
)

rem Set build in progress

echo Build started at: >> %build_progress_path%
call date /t >> %build_progress_path%
call time /t >> %build_progress_path%

rem Delete old build files

if exist %build_zip_path% (
del %build_zip_path% /q
)

if exist %build_output_path% (
rmdir %build_output_path% /s /q
)

rem Get latest game code

call git clean -d -f -n
if errorlevel 1 goto error

call git pull
if errorlevel 1 goto error

rem Compile source code and cook packages

call Binaries\Win32\UDK.com make -full -unattended -stripsource -nullrhi
if errorlevel 1 goto error

call Binaries\Win32\UDK.com CookPackages -full -platform=PC -nullrhi
if errorlevel 1 goto error

rem Copy game files into a zip

call Binaries\UnSetup.exe -GameCreateManifest
if errorlevel 1 goto error

call Binaries\UnSetup.exe -BuildGameInstaller
if errorlevel 1 goto error

rem Extract zip into build directory

call 7z x %build_zip_path% -o%build_output_path%
if errorlevel 1 goto error

copy Binaries\Win32\UserCode\clipboard.dll %build_output_path%\Binaries\Win32\UserCode\clipboard.dll
if errorlevel 1 goto error

rem Build complete

:end

del %build_progress_path% /q

rem Execute next build if queued

if exist %build_queue_path% (
del %build_queue_path% /q
call %build_bat_path%
)

exit /b

rem Build error

:error

del %build_progress_path% /q

exit /b 1