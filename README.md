# Factions

This is the development repository for Factions.

## Installation

1. [Download the latest UDK](http://udk.com/download)
2. Install it to your computer (see additional instructions below if using Windows XP 64-bit)
3. Clone this repo to your UDK directory (e.g. `C:\UDK\UDK-2012-05`)
4. Update the configuration files using the settings below

## Setting up development environment

There are other programs that can be utilized instead, but these are very good and popular

* Download all the following: 
1. msysGit - code.google.com/p/msysgit/downloads/list?can=2&q="Full+installer+for+official+Git+for+Windows"
2. TortoseGit - http://code.google.com/p/tortoisegit/
3. Visual Studio 2010 Shell - http://www.microsoft.com/en-us/download/details.aspx?id=115
4. nFringe - http://wiki.pixelminegames.com/index.php?title=Tools:nFringe:Releases
5. PuttyGen - http://the.earth.li/~sgtatham/putty/latest/x86/puttygen.exe

* Install all the above programs appropriately.
* Make sure you have privileges in the GitLab to get the repository (contact Jephir)
* Have a clean install of the UDK when doing the first pull, just to be safe.

SSH Keys:
1. Generate SSH keys. Open up PuttyGen and generate SSH2-RSA 1024-bit key (the default).
2. Copy paste the public key into the GitLab account page where you manage your public SSH keys.
3. Enter a passphrase and save your private key somewhere wise in your computer where you can access it.
4. The passphrase is the password you will be using every time you access the git repository.

Repository:
Once you have successfully installed Tortoise Git and have set up your public - private key pair
1. Go to the UDK folder and right click -> Git Clone (context menu choice should be supplied by Tortoise)
2. URL target is "gitolite@gitlab.factionshq.com:factions.git"
3. Use the Load Putty Key option and locate your private SSH key.
4. Make sure you clone to the root of the UDK, this should mean you need to remove the "factions" folder at the end of destination.

IDE:
Installing nFringe and Visual Studio should be straight forward. Remember to install Visual Studio first as nFringe is a plugin for that.
1. Once you have both of them, launch up the Visual Studio.
2. If the license pop up does not appear, there should be an icon in your system tray labeled "nFringe Licensing Notification"
3. Open that up and set up a new non-commercial license for the project (requires e-mail validation).

## Configuration

### UDKGame/Config/DefaultEngine.ini

* __[URL]__
  * `Map=TestMap.udk`
  * `LocalMap=TestMap.udk`

* __[UnrealEd.EditorEngine]__
  * Add this line at the bottom of the list: `+EditPackages=FGame`

### UDKGame/Config/DefaultGame.ini

* __[Engine.GameInfo]__
  * `DefaultGame=FGame.FTeamGame`
  * `DefaultServerGame=FGame.FTeamGame`
  * `PlayerControllerClassName=FGame.FPlayerController`
  * `DefaultGameType=FGame.FTeamGame`

## Updating

* Always pull using the `rebase` option
* The generated config files (UDK\*.ini) need to be deleted when the default config (Default\*.ini) is updated in order to reload the configuration

## Windows XP 64-bit

For those users that use Windows XP 64bit, since there is no actual SP3, you can make a shortcut of the UDKinstaller. Right click the shortcut, and select Properties. At the end of the .exe string add -progressonly. That will skip the installer having to look for SP3. So for example it should look like:

D:\UDKInstall-2011-09-BETA.exe -progressonly
