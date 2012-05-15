/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSGFxCommanderHUD extends FSGFxMoviePlayer;

var GFxObject StatusText;

function TickHUD()
{
	local FSPlayerController PC;

	if (!bMovieIsOpen)
		return;

	PC = FSPlayerController(GetPC());

	// Update status text
	if (StatusText != None)
	{
		if (PC.PlacingStructureClass != None)
			StatusText.SetText("Placing:" @ PC.PlacingStructureClass);
		else
			StatusText.SetText("No structure selected");
	}
	else
		StatusText = GetVariableObject("_root.statusText");
}

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_commander_hud'
	bDisplayWithHudOff=False
	bDisplayMouseCursor=True
}
