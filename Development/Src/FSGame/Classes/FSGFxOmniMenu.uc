/*
 * In-game menu for selecting team, loadout, squad, etc.
 */
class FSGFxOmniMenu extends GFxMoviePlayer;

function Init(optional LocalPlayer LocPlay)
{
	Super.Init(LocPlay);

	SetAlignment(Align_Center);
}

function bool Start(optional bool StartPaused)
{
	super.Start(StartPaused);

	GetGameViewportClient().bDisplayHardwareMouseCursor = true;

	return true;
}

function OnClose()
{
	Super.OnClose();

	GetGameViewportClient().bDisplayHardwareMouseCursor = false;
}

function CloseOmniMenu(string FrameLabel)
{
	Close(false);
}

function SelectTeam(int TeamNumber)
{
	GetPC().ServerChangeTeam(TeamNumber);
}

function UpdateTeam(int TeamIndex)
{
	ActionScriptVoid("_root.UpdateTeam");
}

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_omnimenu'
	bAutoPlay=true
	bCaptureMouseInput=true
}