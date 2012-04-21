# Empires UDK

This is the development repository for Empires UDK.

## Installation

1. [Download and install UDK](http://udk.com/download).
2. Clone this repository to your UDK installation directory (e.g. `C:\UDK\UDK-2012-03`)
3. In _UDKGame/Config/DefaultEngine.ini_, under section **[URL]**, set `Map=TestMap.udk` and `LocalMap=TestMap.udk`. At the end of section **[UnrealEd.EditorEngine]**, add `+EditPackages=EmpGame` 
4. In _UDKGame/Config/DefaultGame.ini_, under section **[Engine.GameInfo]**, set `DefaultGame=EmpGame.EmpTeamGame`, `DefaultServerGame=EmpGame.EmpTeamGame`, and `DefaultGameType="EmpGame.EmpTeamGame";`
5. Compile the scripts.

## Updating

**Important:** Always pull using **rebase**. Do not use merge because this will cause a non-linear history.

If the default key binds were updated, you need to delete all _UDKGame/Config/UDK*.ini_ files (but not the _Default*.ini_ files) for the changes to take effect.