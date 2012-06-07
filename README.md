# Factions

This is the development repository for Factions.

## Installation

1. [Download the latest UDK](http://udk.com/download)
2. Install it to your computer (see additional instructions below if using Windows XP 64-bit)
3. Clone this repo to your UDK directory (e.g. `C:\UDK\UDK-2012-05`)
4. Update the configuration files using the settings below

## Configuration

### UDKGame/Config/DefaultEngine.ini

* __[URL]__
  * `Map=TestMap.udk`
  * `LocalMap=TestMap.udk`

* __[UnrealEd.EditorEngine]__
  * Add this line at the bottom of the list: `+EditPackages=FGame`

### UDKGame/Config/DefaultGame.ini

* __[Engine.GameInfo]__
  * `DefaultGame=FGame.FTeamGame`
  * `DefaultServerGame=FGame.FTeamGame`
  * `PlayerControllerClassName=FGame.FPlayerController`
  * `DefaultGameType=FGame.FTeamGame`

## Updating

* Always pull using the `rebase` option
* The generated config files (UDK\*.ini) need to be deleted when the default config (Default\*.ini) is updated in order to reload the configuration

## Windows XP 64-bit

For those users that use Windows XP 64bit, since there is no actual SP3, you can make a shortcut of the UDKinstaller. First copy the file somewhere easy like the root of hard drive since shortcuts don't like spaces in the path.Then right click, and select Properties. At the end of the .exe string add -progressonly. That will skip the installer having to look for SP3. So for example it should look like:

D:\UDKInstall-2011-09-BETA.exe -progressonly
