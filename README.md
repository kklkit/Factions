# Factions

Factions is a strategic multiplayer first-person shooter built on the [Unreal Development Kit](http://www.unrealengine.com/en/udk/).

## Getting Started

1. Install the [July 2012 UDK Beta](http://www.unrealengine.com/en/udk/downloads/).
2. Open the files listed in the configuration section below and change the specified properties.

## Configuration

### UDKGame\Config\DefaultEngine.ini

* __[URL]__
  * `Map=FactionsFrontEndMap.udk`
  * `LocalMap=FactionsFrontEndMap.udk`

* __[UnrealEd.EditorEngine]__
  * Add after the last entry in the list: `+EditPackages=FGame`

### UDKGame\Config\DefaultGame.ini

* __[Engine.GameInfo]__
  * `DefaultGame=FGame.FCommanderGame`
  * `DefaultServerGame=FGame.FCommanderGame`
  * `PlayerControllerClassName=FGame.FPlayerController`
  * `DefaultGameType=FGame.FCommanderGame`
  
## Copyright

Copyright (c) 2012 "Jephir" and individual contributors (see credits).