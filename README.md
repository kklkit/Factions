# Factions

This is the development repository for Factions.

## Installation

1. [Download and install UDK](http://udk.com/download).
2. Clone this repository to your UDK installation directory (e.g. `C:\UDK\UDK-2012-03`)
3. In _UDKGame/Config/DefaultEngine.ini_, under section **[URL]**, set `Map=TestMap.udk` and `LocalMap=TestMap.udk`. At the end of section **[UnrealEd.EditorEngine]**, add `+EditPackages=FSGame` 
4. In _UDKGame/Config/DefaultGame.ini_, under section **[Engine.GameInfo]**, set `DefaultGame=FSGame.FSTeamGame`, `DefaultServerGame=FSGame.FSTeamGame`, and `DefaultGameType="FSGame.FSTeamGame";`
5. Compile the scripts.

## Updating

**Important:** Always pull using **rebase**. Do not use merge because this will cause a non-linear history.

You need to delete all _UDKGame/Config/UDK\*.ini_ files if the default scripts are changed in a commit. This will force UDK to reload the new default scripts.