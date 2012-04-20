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
3. Initialize and update all the submodules.
4. Add `+EditPackages=EmpGame` to the end of the `[UnrealEd.EditorEngine]` section in `UDKGame/Config/DefaultEngine.ini`.
5. Set `Map=TestMap.udk` and `LocalMap=TestMap.udk` under `[URL]` in the same file.
6. Set `DefaultGame=EmpGame.EmpGame`, `DefaultServerGame=EmpGame.EmpGame`, and `DefaultGameType="EmpGame.EmpGame";` under `[Engine.GameInfo]` in `UDKGame/Config/DefaultGame.ini`.
7. Run the UDK editor to compile the scripts.

## Important Information

* Make sure all of your submodules are on branch `master` **before** making changes. If you are in a detached HEAD (no branch), your changes will disappear when the submodules are updated!
* Do not commit to the top-level repository as it is read-only. Instead commit your changes directly to the appropriate submodules. It is normal for the top-level repository to have un-committed changes.
* To check if you have un-committed changes in your submodules, in the top-level repository run `git status` (or open the Commit window in Git Extensions) and look for submodules that are listed with `modified content` or `dirty`.
* Remember to update both the top-level repository (using pull) and the submodules (using submodule update).

## Troubleshooting

### Rebase Error When Updating Submodules

* The fastest way to solve this problem is to reset your working directory (`git reset --HARD`). You will lose your un-committed changes however.

### Compiling Warnings or Errors

* Check each of your submodules and make sure the latest commit matches the one on Bitbucket. The `HEAD` of `master` branch must also be set to the latest commit.
* Make sure `UDKGame/Config/DefaultEngine.ini` and `UDKGame/Config/DefaultGame.ini` exist and have valid values.
* Go into the content browser and fully load `EmpAssets` and `EmpFlashAssets`. Then re-compile the scripts.