# Factions

This is the development repository for Factions. Everything is stored in the repository except for asset (models and sound) sources (which are stored in Dropbox).

## Installation

### Installing UDK

1. [Install the latest UDK](http://udk.com/download)
2. Open each file listed below and make the following replacements

#### UDKGame/Config/DefaultEngine.ini

* __[URL]__
  * `Map=TestMap.udk`
  * `LocalMap=TestMap.udk`

* __[UnrealEd.EditorEngine]__
  * Add this at the bottom of the list: `+EditPackages=FGame`

#### UDKGame/Config/DefaultGame.ini

* __[Engine.GameInfo]__
  * `DefaultGame=FGame.FTeamGame`
  * `DefaultServerGame=FGame.FTeamGame`
  * `PlayerControllerClassName=FGame.FPlayerController`
  * `DefaultGameType=FGame.FTeamGame`
  
### Creating an SSH Key

SSH keys are used to authorize access to the Git repository. You upload the *public* key to GitLab, and keep the *private* key safe on your own computer.

1. [Install PuTTY](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) using the Windows installer
2. Launch PuTTYgen
3. Click **Generate**
4. Enter a comment and passphrase
5. Click **Save private key** and save the private key on your computer
6. Copy the entire contents of the "Public key for pasting into OpenSSH" textbox to your [GitLab SSH Keys](https://gitlab.factionshq.com/keys/new)

### Loading the SSH Key

Whenever you want to pull or push from Git, you need to first load your SSH key.

1. Launch Pageant (PuTTY authentication agent)
2. Right-click the Pageant icon in your notification area and select Add Key
3. Select the private key you saved earlier

### Setting up Git

We need to clone the repository to a temporary location first since Git won't allow you to clone to an existing directory.

1. [Install Git Extensions](http://code.google.com/p/gitextensions/) using the default settings
2. Launch Git Extensions and follow the setup instructions
3. Click **Clone repository**
4. Enter the settings below and then click **Clone**

* Repository to clone: `gitolite@gitlab.factionshq.com:factions.git`
* Destination: Desktop (or anywhere, this is just temporary)
* Subdirectory to create: TemporaryFactions (or anything)
* Branch: `master`

5. Git will clone the repository to your computer
6. Click File > **Close**
7. Go to where the repository was cloned and copy everything (including the hidden .git folder) and paste it into your UDK install directory (e.g. `C:\UDK\UDK-2012-05`)
8. In Git Extensions, click File > **Open** and select your UDK install directory (e.g. `C:\UDK\UDK-2012-05`)
9. The repository should be open and you can delete the temporary folder created earlier

## Usage

### Updating Git

Whenever you want to update, click the Pull button (blue down arrow). In the Pull dialog, select "Rebase current branch on top of remote branch" in the Merge options. Then click Pull. Finally, run the UDK Editor to compile the scripts.

Your working directory has to be clean (no un-committed changes) to Pull. If you have un-committed changes, either click Stash first or Commit your changes.

Sometimes a config file will be updated, which means you have to delete the generated configuration files for the change to take effect. Check the commit diff and delete the matching UDK\*.ini file for the Default\*.ini file that was changed.

### Committing changes

Click the Commit button to open the commit dialog. Press the blue double down arrow to choose all your changes (or select your changes individually if you only want to commit parts). Enter a summary of what has changed into the commit message textbox (use present tense). Click Commit & push to make the commit.

## Troubleshooting

### Windows XP 64-bit

UDK needs to be installed with this command-line argument as SP3 is not available for Windows XP 64-bit.

`D:\UDKInstall-2011-09-BETA.exe -progressonly`