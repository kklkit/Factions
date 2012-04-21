/*
 * In-game menu for selecting team, loadout, squad, etc.
 */
class EmpGFxHUDMenu extends GFxMoviePlayer;

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

function CloseInfantryMenu()
{
	Close(false);
}

function SelectTeam(int TeamNumber)
{
	GetPC().ServerChangeTeam(TeamNumber);
}

defaultproperties
{
	MovieInfo=SwfMovie'EmpFlashAssets.emp_hud_menu'
	bAutoPlay=true
	bCaptureMouseInput=true
}