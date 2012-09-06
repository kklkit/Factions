set build_zip=UDKInstall-Factions.zip
set build_dir=..\build

rem Delete old build files

if exist %build_zip% (
del %build_zip% /q
)

if exist %build_dir% (
rmdir %build_dir% /s /q
)

rem Get latest game code

call git clean -d -f -n
if errorlevel 1 exit /b %errorlevel%

call git pull
if errorlevel 1 exit /b %errorlevel%

rem Compile source code and cook packages

call Binaries\Win32\UDK.com make -full -unattended -stripsource -nullrhi
if errorlevel 1 exit /b %errorlevel%

call Binaries\Win32\UDK.com CookPackages -platform=PC -full -cookallmaps -nullrhi
if errorlevel 1 exit /b %errorlevel%

rem Copy game files into a zip

call Binaries\UnSetup.exe -GameCreateManifest
if errorlevel 1 exit /b %errorlevel%

call Binaries\UnSetup.exe -BuildGameInstaller
if errorlevel 1 exit /b %errorlevel%

rem Extract zip into build directory

call 7z x %build_zip% -o%build_dir%
if errorlevel 1 exit /b %errorlevel%