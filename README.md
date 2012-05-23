# Factions

This is the development repository for Factions.

## Installation

1. [Download the latest UDK](http://udk.com/download) 
2. Install it to your computer
3. Clone this repo to your UDK directory (e.g. `C:\UDK\UDK-2012-05`)
4. Update the configuration files using the settings below

## Configuration

### UDKGame/Config/DefaultEngine.ini

* __[URL]__
  * `Map=TestMap.udk`
  * `LocalMap=TestMap.udk`

* __[UnrealEd.EditorEngine]__
  * `+EditPackages=FGame`

### UDKGame/Config/DefaultGame.ini

* __[Engine.GameInfo]__
  * `DefaultGame=FGame.FTeamGame`
  * `DefaultServerGame=FGame.FTeamGame`
  * `DefaultGameType=FGame.FTeamGame`

## Updating

* Always pull using the `rebase` option
* The generated config files (UDK*.ini) need to be deleted when the default config (Default*.ini) is updated to reload the configuration