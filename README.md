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

## Coding Standards

### UnrealScript

* **Important:** When extending a function always put the `@extends` annotation in the function comment. If a function is overriding (not calling `super`) be sure to state so in the comment.
* Use the `event` keyword when extending events.
* Name a local variable that would have the same name as its class using initials (e.g. `local FSPawn FSP`, `local PlayerController PC`)
* Don't put spaces around the `=` operator for `defaultproperties` or `const` variables.
* Don't put a space between the comment and the `@` for todo comments (e.g. `//@todo stuff that has to be done`)

#### Class Organization

1. Constants
2. Variables
4. States
5. Non-State Functions
6. Default Properties

#### Function Organization

1. Events (e.g. `PostBeginPlay`, `Tick`)
2. Extended Functions (e.g. `CalcCamera`)
3. Non-Extended Functions
4. Exec Functions

### ActionScript

* Avoid putting code inside the `.fla` file because Git will not be able to merge changes.
* Press the `Auto format` button before saving and committing code.

## Testing

Test the changes in dedicated server mode before committing because the engine behaves differently as a dedicated server. The `TestMultiplayer.bat` script starts a dedicated server and automatically connects a client to it.