/*
 * In-game menu for selecting team, loadout, squad, etc.
 */
class EmpGFxHUDMenu extends EmpGFxHUD;

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

event OnClose()
{
	Super.OnClose();

	GetGameViewportClient().bDisplayHardwareMouseCursor = false;
}

defaultproperties
{
	MovieInfo=SwfMovie'EmpFlashAssets.emp_hud_menu'
	bAutoPlay=false
	bCaptureMouseInput=true
}