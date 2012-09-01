set build_zip=UDKInstall-Factions.zip
set build_dir=..\build

REM Delete old build files

if exist %build_zip% (
del %build_zip% /q
)

if exist %build_dir% (
rmdir %build_dir% /s /q
)

REM Get latest game code

git clean -d -f -n
if errorlevel 1 exit /b %errorlevel%

git pull
if errorlevel 1 exit /b %errorlevel%

REM Compile source code and cook packages

Binaries\Win32\UDK.com make -full -unattended -stripsource
if errorlevel 1 exit /b %errorlevel%

Binaries\Win32\UDK.com CookPackages -platform=PC -full -cookallmaps
if errorlevel 1 exit /b %errorlevel%

REM Copy game files into a zip

Binaries\UnSetup.exe -GameCreateManifest
if errorlevel 1 exit /b %errorlevel%

Binaries\UnSetup.exe -BuildGameInstaller
if errorlevel 1 exit /b %errorlevel%

REM Extract zip into build directory

7z x %build_zip% -o%build_dir%
if errorlevel 1 exit /b %errorlevel%