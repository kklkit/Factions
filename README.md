# Factions

### Getting the Factions development files

1. Install and configure Git if you haven't already (instructions below)
2. Install [July 2012 UDK Beta](http://www.unrealengine.com/en/udk/downloads/), do not install Perforce or run UDK if prompted
3. In the UDK installation directory, open each file listed below and replace the specified configuration lines:

#### UDKGame\Config\DefaultEngine.ini

* __[URL]__
  * `Map=FactionsFrontEndMap.udk`
  * `LocalMap=FactionsFrontEndMap.udk`

* __[UnrealEd.EditorEngine]__
  * Add this after the last entry in the list: `+EditPackages=FGame`

#### UDKGame\Config\DefaultGame.ini

* __[Engine.GameInfo]__
  * `DefaultGame=FGame.FTeamGame`
  * `DefaultServerGame=FGame.FTeamGame`
  * `PlayerControllerClassName=FGame.FPlayerController`
  * `DefaultGameType=FGame.FTeamGame`

Your private SSH key needs to be loaded before you can pull or push from Git.

1. Launch __Pageant__ (PuTTY authentication agent)
2. Right-click the Pageant icon in your notification area and select __Add Key__
3. Select your private key

We first need to clone the repository to a temporary location since Git won't allow you to clone into an existing directory. This is just for the initial clone. Onced cloned, you use git pull to get updates.

1. Open __Git Extensions__ and close the current repository if one is open
2. Click __Clone repository__
3. Enter the settings below and then click __Clone__

* Repository to clone: `gitolite@gitlab.factionshq.com:factions.git`
* Destination: `Desktop` (or anywhere)
* Subdirectory to create: `TemporaryFactions` (or anything)
* Branch: `master`

1. Git will clone the repository to your computer
2. Click File > __Close__
3. Go to where the repository was cloned and copy everything (including the hidden .git folder) and paste it into your UDK install directory (e.g. C:\UDK\UDK-2012-07)
4. In Git Extensions, click File > __Open__ and select your UDK install directory (e.g. C:\UDK\UDK-2012-07)
5. The repository should open successfully
6. You can delete the temporary folder created earlier (TemporaryFactions)
7. If you are upgrading from a previous UDK release, open Flash and update the ActionScript 3.0 source paths to the new installation
8. If you have nFringe installed, open the project properties and set __Load map at startup:__ to `TestMap`

## Installing and configuring Git

Skip this section if you already have Git installed and configured.

### Create an SSH Key

SSH keys are used to authorize access to the Git repository. You copy the _public_ key to GitLab and keep the _private_ key safe on your own computer.

1. [Install PuTTY](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) using the Windows installer
2. Launch PuTTYgen
3. Click __Generate__
4. Enter a comment and passphrase
5. Click __Save private key__ and save the private key on your computer
6. Copy the entire contents of the _Public key for pasting into OpenSSH_ textbox to your [GitLab SSH Keys](https://gitlab.factionshq.com/keys/new)

### Setting up Git

1. [Install Git Extensions](http://code.google.com/p/gitextensions/) using the default settings
2. Launch Git Extensions and follow the setup instructions
3. You can now get the UDK development files (instructions above)

## Usage

### Updating your working directory

Whenever you want to update, click the Pull button (blue down arrow). In the Pull dialog, select "Rebase current branch on top of remote branch" in the Merge options. Then click Pull. Finally, run the UDK Editor to compile the scripts.

Your working directory has to be clean (no un-committed changes) to Pull. If you have un-committed changes, either click Stash first or Commit your changes.

Sometimes a config file will be updated, which means you have to delete the generated configuration files for the change to take effect. Check the commit diff and delete the matching UDK\*.ini file for the Default\*.ini file that was changed.

### Committing and pushing changes

Click the Commit button to open the commit dialog. Press the blue double down arrow to choose all your changes (or select your changes individually if you only want to commit parts). Enter a summary of what has changed into the commit message textbox (use present tense). Click Commit & push to make the commit.

## Additional notes

### Windows XP 64-bit

The UDK installer needs to be run with the `-progressonly` command-line argument as SP3 is not available for Windows XP 64-bit.