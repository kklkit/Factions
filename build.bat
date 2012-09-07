set build_zip=UDKInstall-Factions.zip
set build_dir=..\build
set build_progress=buildprogress.txt

rem Abort build if already in progress

if exist %build_progress% (
exit /b 2
)

rem Set build in progress

echo Build started at: >> %build_progress%
call date /t >> %build_progress%
call time /t >> %build_progress%

rem Delete old build files

if exist %build_zip% (
del %build_zip% /q
)

if exist %build_dir% (
rmdir %build_dir% /s /q
)

rem Get latest game code

call git clean -d -f -n
if errorlevel 1 goto error

call git pull
if errorlevel 1 goto error

rem Compile source code and cook packages

call Binaries\Win32\UDK.com make -full -unattended -stripsource -nullrhi
if errorlevel 1 goto error

call Binaries\Win32\UDK.com CookPackages -platform=PC -full -cookallmaps -nullrhi
if errorlevel 1 goto error

rem Copy game files into a zip

call Binaries\UnSetup.exe -GameCreateManifest
if errorlevel 1 goto error

call Binaries\UnSetup.exe -BuildGameInstaller
if errorlevel 1 goto error

rem Extract zip into build directory

call 7z x %build_zip% -o%build_dir%
if errorlevel 1 goto error

:end

del %build_progress% /q

exit /b

:error

del %build_progress% /q

exit /b 1