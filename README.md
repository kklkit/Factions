# Empires UDK

This repository contains submodules for Empires UDK development.

## Submodules

* [empires-udk-unrealscript](https://bitbucket.org/jephir/empires-udk-unrealscript)
* [empires-udk-content](https://bitbucket.org/jephir/empires-udk-content)
* [empires-udk-maps](https://bitbucket.org/jephir/empires-udk-maps)
* [empires-udk-flash](https://bitbucket.org/jephir/empires-udk-flash)

## Installation

1. [Download and install UDK](http://udk.com/download).
2. Clone this repository to your UDK installation directory (e.g. `C:\UDK\UDK-2012-03`).
3. Initialize and update all the submodules. In each submodule, set the branch to `master`.
4. Add `+EditPackages=EmpGame` to the end of the `[UnrealEd.EditorEngine]` section in `UDKGame/Config/DefaultEngine.ini`.
5. Set `Map=TestMap.udk` and `LocalMap=TestMap.udk` under `[URL]` in the same file.
6. Set `DefaultGame=EmpGame.EmpGame`, `DefaultServerGame=EmpGame.EmpGame`, and `DefaultGameType="EmpGame.EmpGame";` under `[Engine.GameInfo]` in `UDKGame/Config/DefaultGame.ini`.
7. Run the UDK editor to compile the scripts.

## Committing

1. For each submodule that you've changed, make a commit in the submodule and push it to Bitbucket.
2. In the top-level repository, commit the changed directories and push the commit.

## Updating

1. In the top-level repository, pull, and then update all submodules.