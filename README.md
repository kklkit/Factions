# Empires UDK

This repository contains submodules for Empires UDK development.

## Submodules

* [empires-udk-unrealscript](https://bitbucket.org/jephir/empires-udk-unrealscript)
* [empires-udk-content](https://bitbucket.org/jephir/empires-udk-content)
* [empires-udk-maps](https://bitbucket.org/jephir/empires-udk-maps)
* [empires-udk-flash](https://bitbucket.org/jephir/empires-udk-flash)

## Permissions

Send a message to [jephir](https://bitbucket.org/account/notifications/send/?receiver=jephir) if you cannot access a submodule.

## Installation

1. [Download and install UDK](http://udk.com/download).
2. Clone this repository to your UDK installation directory (e.g. `C:\UDK\UDK-2012-03`).
3. Initialize and update submodules.
4. In each submodule, set the branch to `master`.
5. In `UDKGame/Config/DefaultEngine.ini`, under section `[URL]`, set `Map=TestMap.udk` and `LocalMap=TestMap.udk`. At the end of section `[UnrealEd.EditorEngine]`, add `+EditPackages=EmpGame`. 
7. In `UDKGame/Config/DefaultGame.ini`, under section `[Engine.GameInfo]`, set `DefaultGame=EmpGame.EmpGame`, `DefaultServerGame=EmpGame.EmpGame`, and `DefaultGameType="EmpGame.EmpGame";`.
8. Compile the scripts.

## Committing

1. For each submodule that you've changed, make a commit inside the submodule and push it.
2. Then, in the top-level repository, commit the changed submodules and push the commit.

Committing the submodules in the top-level repository saves the latest commit in each submodule. This allows us to update without having to go into each submodule and running pull.

## Updating

1. Pull at the top-level repository.
2. Update the submodules. If you are using Git Extensions, you can do this by selecting `Submodules > Update all submodules` while in the top-level repository. Do **not** run pull inside of the submodules because it will fetch changes beyond what was committed in the top-level repository.
3. Solve any rebase errors if necessary.