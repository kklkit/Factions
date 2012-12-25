![Banner](http://i.minus.com/iSnovmsDGNMFI.png)

Factions is a multiplayer strategic first-person shooter built with the [Unreal Development Kit](http://www.unrealengine.com/en/udk/).

## Getting Started

1. Install the [July 2012 UDK Beta](http://www.unrealengine.com/en/udk/downloads/).
2. Clone this repository to the UDK installation.
3. Open the files listed in the configuration section below and change the specified properties.

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
  
## Copying

Copyright (c) 2012 "Jephir" and individual contributors (see credits).

Files under the UDKGame directory (game assets such as art, sounds, models, and maps) are copyright of their respective authors.

Files under the Development directory (game source code) are released under the MIT license.

### Source Code License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
